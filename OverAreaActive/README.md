
## 超出区域的按钮响应点击事件的处理

#### 重写父试图的hitTest方法可解决

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    CGPoint buttonPoint = [self.redButton convertPoint:point fromView:self];
    if ([self.redButton pointInside:buttonPoint withEvent:event]) {
        return self.redButton;
    }
    return result;
}
