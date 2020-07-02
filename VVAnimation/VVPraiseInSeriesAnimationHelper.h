//
//  VVPraiseInSeriesAnimationHelper.h
//  MvBox
//
//  Created by jufan wang on 2020/7/1.
//  Copyright © 2020 mvbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VVPraiseInSeriesAnimationHelper : NSObject<CAAnimationDelegate>

@property (nonatomic, strong) NSMutableArray *animateImages;

- (void)animationWithTouch:(UITouch *)touch
                 withEvent:(UIEvent *)event;


@end

NS_ASSUME_NONNULL_END
