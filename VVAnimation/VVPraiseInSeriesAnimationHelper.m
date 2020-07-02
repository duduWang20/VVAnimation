//
//  VVPraiseInSeriesAnimationHelper.m
//  MvBox
//
//  Created by jufan wang on 2020/7/1.
//  Copyright © 2020 mvbox. All rights reserved.
//

#import "VVPraiseInSeriesAnimationHelper.h"

#define kVVPraiseInSeriesAnimation_MAXArc4Random    0x100000000


@implementation VVPraiseInSeriesAnimationHelper

- (instancetype)init {
    if (self = [super init]) {
        _animateImages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)animationWithTouch:(UITouch *)touch
                 withEvent:(UIEvent *)event {
    CGPoint point = [touch locationInView:touch.view];
    UIImage *image = [UIImage imageNamed:@"ui_video_icon_praise_sel_big"];
    //ui_video_icon_praise_sel_big ic_home_like_after
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 100.0f)];
    imgView.image = image;
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.center = point;
    int leftOrRight = arc4random() % 2;
    leftOrRight = leftOrRight ? leftOrRight : -1;
    double val = ((double)arc4random() / kVVPraiseInSeriesAnimation_MAXArc4Random) * 3;
    if (val > 1) {
        val = 1;
    }
    imgView.transform = CGAffineTransformRotate(imgView.transform, val * M_PI / 11.0f * leftOrRight);
    [touch.view addSubview:imgView];
    
    [self.animateImages insertObject:@[imgView, image] atIndex:0];

    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animation];
    [rotateAnimation setKeyPath:@"transform.scale"];
    [rotateAnimation setValues:@[ @(1.6), @(0.95), @(1.0)]];
    [rotateAnimation setKeyTimes:@[ @(0.0), @(0.75), @(1.0)]];
    [rotateAnimation setDuration:0.2];
    [rotateAnimation setCalculationMode:kCAAnimationCubic];
    [rotateAnimation setRepeatCount:1];
    [rotateAnimation setBeginTime:CACurrentMediaTime()];
    rotateAnimation.delegate = self;
    
    [imgView.layer addAnimation:rotateAnimation forKey:@"kVVPraiseInSeriesAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim
                finished:(BOOL)flag {
    id obj = [self.animateImages lastObject];
    [self.animateImages removeLastObject];
    if (obj){
        [self performSelector:@selector(animationToTop:)
                   withObject:obj
                   afterDelay:0.3f];
    }
}

- (void)animationToTop:(NSArray *)imgObjects {
    if (imgObjects.count == 2) {
        UIImageView *imgView = (UIImageView *)imgObjects.firstObject;
        [UIView animateWithDuration:0.5f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            CGRect imgViewFrame = imgView.frame;
            imgViewFrame.origin.y -= 50.0f;
            imgView.frame = imgViewFrame;
            imgView.transform = CGAffineTransformScale(imgView.transform, 1.6f, 1.6f);
            imgView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [imgView removeFromSuperview];
        }];
    }
}

@end
