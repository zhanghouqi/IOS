//
//  HCSpanView.h
//  HotCoin
//
//  Created by iMac on 2019/11/28.
//  Copyright © 2019 Jefferson. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HCSpanView : UIView
+ (HCSpanView *)showSpanViewOnView:(UIView *)view action:(void(^)(void))action;
@end

NS_ASSUME_NONNULL_END
