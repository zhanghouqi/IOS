//
//  BlueView.m
//  BUTTON——NO
//
//  Created by 张厚琪 on 2018/4/17.
//  Copyright © 2018年 DDG. All rights reserved.
//

#import "BlueView.h"

@interface BlueView()

@end

@implementation BlueView
-(instancetype)init{
    self = [super init];
    if (self) {
        self.redButton.backgroundColor = [UIColor redColor];
    }
    
    return self;
}
-(UIButton *)redButton{
    if (_redButton) {
        return _redButton;
    }
    self.redButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.redButton];
    self.redButton.frame = CGRectMake(0, 0, 80, 100);
    
    return self.redButton;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    CGPoint buttonPoint = [self.redButton convertPoint:point fromView:self];
    if ([self.redButton pointInside:buttonPoint withEvent:event]) {
        return self.redButton;
    }
    return result;
}
@end
