//
//  VVTapInSeriesGestureRecognizer.m
//  MvBox
//
//  Created by jufan wang on 2020/7/1.
//  Copyright © 2020 mvbox. All rights reserved.
//

#import "VVTapInSeriesGestureRecognizer.h"

#include <mach/mach.h>
#include <mach/mach_time.h>
#include <pthread.h>

#define kVVTapInSeriesGestureRecognizerStopTimeInterval 10000000
#define kVVTapInSeriesGestureRecognizerMaxTimeInterval 7000000
#define kVVTapInSeriesGestureRecognizerMinTimeInterval 1000000

void move_pthread_to_realtime_scheduling_class(pthread_t pthread) {
    mach_timebase_info_data_t timebase_info;
    mach_timebase_info(&timebase_info);

    const uint64_t NANOS_PER_MSEC = 1000000ULL;
    double clock2abs = ((double)timebase_info.denom / (double)timebase_info.numer) * NANOS_PER_MSEC;

    thread_time_constraint_policy_data_t policy;
    policy.period      = 0;
    policy.computation = (uint32_t)(5 * clock2abs); // 5 ms of work
    policy.constraint  = (uint32_t)(10 * clock2abs);
    policy.preemptible = FALSE;

    int kr = thread_policy_set(pthread_mach_thread_np(pthread_self()),
                   THREAD_TIME_CONSTRAINT_POLICY,
                   (thread_policy_t)&policy,
                   THREAD_TIME_CONSTRAINT_POLICY_COUNT);
    if (kr != KERN_SUCCESS) {
        mach_error("thread_policy_set:", kr);
        exit(1);
    }
}

@interface VVTapInSeriesGestureRecognizer()
@property (nonatomic, assign) long long currentTapCount;
@property (nonatomic, assign) uint64_t preTimeInterval;
@property (nonatomic, assign) BOOL timerCacnel;
@property (nonatomic, strong) dispatch_source_t timer;
@end

@implementation VVTapInSeriesGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    if (self = [super initWithTarget:target action:action]) {
        self.timerCacnel = YES;
        self.skipTapCount = 1;
        self.currentTapCount = 0;
    }
    return self;
}

- (void)setSkipTapCount:(long long)skipTapCount {
    _skipTapCount = skipTapCount;
    if (_skipTapCount < 1) {
        _skipTapCount = 1;
    }
}

- (void)startTimer {
    [self timerCacnel];
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                        0, 0,
                                        dispatch_get_main_queue());
    dispatch_source_set_timer(self.timer,
                              dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC),
                              0.2 * NSEC_PER_SEC,
                              0);
    __weak typeof(self) wself = self;
    dispatch_source_set_event_handler(self.timer, ^{
        __strong typeof(wself) self = wself;
        if (!self.timerCacnel) {
            [self cancelTapInSeries];
        }
        dispatch_source_cancel(self.timer);
        self.timerCacnel = YES;
    });
    dispatch_resume(self.timer);
}

- (void)stopTimer {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer=nil;
    }
}

- (void)dealloc {
    [self stopTimer];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.timerCacnel = YES;
    [self stopTimer];
    if (touches.count > 1) {
        [self cancelsTouchesInView];
        return;
    }
    if (!self.preTimeInterval || self.currentTapCount < self.skipTapCount) {
        self.preTimeInterval = mach_absolute_time();
        self.currentTapCount++;
        self.state = UIGestureRecognizerStatePossible;
        self.timerCacnel = NO;
        [self stopTimer];
        [self startTimer];
    } else {
        uint64_t delt = mach_absolute_time() - self.preTimeInterval;
        if (delt > kVVTapInSeriesGestureRecognizerStopTimeInterval) {
            [self stopTimer];
            self.preTimeInterval = mach_absolute_time();
            self.currentTapCount = 1;
            self.state = UIGestureRecognizerStatePossible;
            self.timerCacnel = NO;
            [self startTimer];
        } else if (delt < kVVTapInSeriesGestureRecognizerMaxTimeInterval
                && delt > kVVTapInSeriesGestureRecognizerMinTimeInterval) {
                self.currentTapCount++;
                self.preTimeInterval = mach_absolute_time();
                self.touch = touches.allObjects.lastObject;
                self.event = event;
                self.state = UIGestureRecognizerStateRecognized;
        } else {
            [self cancelTapInSeries];
        }
    }
}

- (NSUInteger)numberOfTouchesRequired {
    return 1;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.state = UIGestureRecognizerStatePossible;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self cancelTapInSeries];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches
               withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self cancelTapInSeries];
}

- (void)cancelTapInSeries {
    self.currentTapCount = 0;
    self.preTimeInterval = 0;
    self.state = UIGestureRecognizerStateFailed;
}

@end


