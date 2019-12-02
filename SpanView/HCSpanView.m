//
//  HCSpanView.m
//  HotCoin
//
//  Created by iMac on 2019/11/28.
//  Copyright © 2019 Jefferson. All rights reserved.
//

#import "HCSpanView.h"

@interface HCSpanView(){
    CGFloat width;
}
@property (nonatomic, weak)  UIView  *superView;
@property (nonatomic, copy) void(^targetAction)(void);
@end

@implementation HCSpanView

+ (HCSpanView *)showSpanViewOnView:(UIView *)view action:(void(^)(void))action{
    return [[HCSpanView alloc] initWithSuperView:view action:action];
}

- (instancetype)initWithSuperView:(UIView *)superView action:(void(^)(void))action{
    self = [super init];
    if (self) {
        width = 50;
        self.layer.cornerRadius = width / 2.0;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor cyanColor];
        self.frame = CGRectMake(KSCREEN_WIDTH - width - 10, KSCREEN_HEIGHT - BottomSafeAreaHeight - width - 100, width, width);
        [superView addSubview:self];
        self.superView = superView;
        
        self.targetAction = action;
        
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGestureRecongnizerAction:)];
        [self addGestureRecognizer:panGes];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        tapGes.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGes];
    }
    
    return self;
}

- (void)tapAction{
    if (self.targetAction) {
        self.targetAction();
    }
}

- (void)onPanGestureRecongnizerAction:(UIPanGestureRecognizer *)ges{
    CGPoint offset = [ges translationInView:self.superView];
    __block  CGPoint center = CGPointMake(self.center.x+offset.x, self.center.y+offset.y);
    if(ges.state== UIGestureRecognizerStateChanged) {
        //translationInView：获取到的是手指移动后，在相对坐标中的偏移量
        //判断横坐标是否超出屏幕
        if(center.x <= width / 2.0) {
            center.x = width / 2.0;
            
        } else if(center.x >= self.superView.bounds.size.width - width / 2.0) {
            center.x = self.superView.bounds.size.width - width / 2.0;
        }
        
        //判断纵坐标是否超出屏幕
        if(center.y <= statusBarHeight + navViewHeight + width / 2.0) {
            center.y = statusBarHeight + navViewHeight + width / 2.0;
        } else if(center.y >= self.superView.bounds.size.height - width / 2.0) {
            center.y = self.superView.bounds.size.height - width / 2.0;
        }
        
        [self setCenter:center];
    }else if (ges.state == UIGestureRecognizerStateEnded){
        if (center.x < self.superView.frame.size.width / 2.0) {
            [UIView animateWithDuration:0.3 animations:^{
                center.x = self->width / 2.0;
                [self setCenter:center];
            }];
        }
        
        if (center.x >= self.superView.frame.size.width / 2.0) {
            [UIView animateWithDuration:0.3 animations:^{
                center.x = self.superView.bounds.size.width - self->width / 2.0;
                [self setCenter:center];
            }];
        }
    }
    
    //设置位置
    [ges setTranslation:CGPointMake(0, 0) inView:self.superView];
}

@end
