
## 超出区域的按钮响应点击事件的处理

#### 重写父试图的hitTest方法可解决

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event { <br>
    UIView *result = [super hitTest:point withEvent:event]; <br>
    CGPoint buttonPoint = [self.redButton convertPoint:point fromView:self]; <br>
    if ([self.redButton pointInside:buttonPoint withEvent:event]) { <br>
        return self.redButton； <br>
    } <br>
    return result; <br>
 } <br>
