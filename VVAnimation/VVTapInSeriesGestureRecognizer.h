//
//  VVTapInSeriesGestureRecognizer.h
//  MvBox
//
//  Created by jufan wang on 2020/7/1.
//  Copyright © 2020 mvbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VVTapInSeriesGestureRecognizer : UIGestureRecognizer

@property (nonatomic, readonly) NSUInteger  numberOfTouchesRequired;   //===1
@property (nonatomic, assign, readonly) long long currentTapCount;
@property (nonatomic, assign) long long skipTapCount;  //>=1

@property (nonatomic, strong) UITouch *touch;
@property (nonatomic, strong) UIEvent *event;

@end

NS_ASSUME_NONNULL_END
