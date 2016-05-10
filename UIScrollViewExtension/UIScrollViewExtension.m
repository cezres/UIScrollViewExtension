//
//  UIScrollViewExtension.m
//  UIScrollViewExtension
//
//  Created by 翟泉 on 16/5/9.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "UIScrollViewExtension.h"
#import <objc/runtime.h>


#define KVOContentOffset @"contentOffset"

@implementation UIScrollView (Extension)

- (void)willMoveToSuperview:(UIView *)newSuperview; {
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [self scrollView].observeValue = NO;
        [objc_getAssociatedObject([self scrollView], @selector(backTopButton)) removeFromSuperview];
        [objc_getAssociatedObject([self scrollView], @selector(pageNumnerLabel)) removeFromSuperview];
    }
}

- (void)layoutSubviews; {
    [super layoutSubviews];
    [[self scrollView] backTopButtonLayout];
    [[self scrollView] pageNumnerLabelLayout];
    [[self scrollView] noMoreDataViewLayout];
}

- (UIScrollView *)scrollView; {
    UIScrollView *scrollView = self;
    if ([self isKindOfClass:NSClassFromString(@"UITableViewWrapperView")]) {
        scrollView = (UIScrollView *)self.superview;
    }
    return scrollView;
}

#pragma mark callback

- (id<UIScrollViewExtensionDelegate>)extensionDelegate; {
    return objc_getAssociatedObject(self, @selector(extensionDelegate));
}

- (void)setExtensionDelegate:(id<UIScrollViewExtensionDelegate>)extensionDelegate; {
    objc_setAssociatedObject(self, @selector(extensionDelegate), extensionDelegate, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - ObserveValue
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context; {
    if ([keyPath isEqualToString:KVOContentOffset]) {
        [[self scrollView] checkAutomaticLoading];
        [[self scrollView] checkBackTop];
        [[self scrollView] checkPageNumner];
        [[self scrollView] checkScrollState];
    }
}



- (BOOL)observeValue; {
    return [objc_getAssociatedObject(self, @selector(observeValue)) boolValue];
}

- (void)setObserveValue:(BOOL)observeValue; {
    if (observeValue == self.observeValue) {
        return;
    }
    if (observeValue) {
        [self addObserver:self forKeyPath:KVOContentOffset options:NSKeyValueObservingOptionNew context:NULL];
    }
    else {
        [self removeObserver:self forKeyPath:KVOContentOffset];
    }
    objc_setAssociatedObject(self, @selector(observeValue), @(observeValue), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark Automatic Loading

- (void)checkAutomaticLoading; {
    if (!self.automaticLoadingEnabled) {
        return;
    }
    if (self.contentOffset.y == 0) {
        return;
    }
    CGFloat distanceBottomOffset = self.contentSize.height - self.contentOffset.y - self.frame.size.height;
    if (distanceBottomOffset < self.automaticLoadingValidOffset) {
        self.automaticLoadingEnabled = NO;
        if ([self.extensionDelegate respondsToSelector:@selector(scrollViewAutomaticLoading:)]) {
            [self.extensionDelegate scrollViewAutomaticLoading:self];
        }
    }
}

- (BOOL)automaticLoadingEnabled; {
    return [objc_getAssociatedObject(self, @selector(automaticLoadingEnabled)) boolValue];
}

- (void)setAutomaticLoadingEnabled:(BOOL)automaticLoadingEnabled; {
    if (automaticLoadingEnabled) {
        self.observeValue = YES;
    }
    objc_setAssociatedObject(self, @selector(automaticLoadingEnabled), @(automaticLoadingEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)automaticLoadingValidOffset; {
    CGFloat automaticLoadingValidOffset = [objc_getAssociatedObject(self, @selector(automaticLoadingValidOffset)) floatValue];
    if (automaticLoadingValidOffset == 0.0) {
        automaticLoadingValidOffset = 200.0;
        self.automaticLoadingValidOffset = automaticLoadingValidOffset;
    }
    return automaticLoadingValidOffset;
}

- (void)setAutomaticLoadingValidOffset:(CGFloat)automaticLoadingValidOffset; {
    objc_setAssociatedObject(self, @selector(automaticLoadingValidOffset), @(automaticLoadingValidOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark Back Top

- (void)checkBackTop; {
    if (self.backTopEnabled) {
        self.backTopButton.hidden = self.contentOffset.y < self.backTopValidOffset;
    }
}

- (void)backTopButtonLayout; {
    if (self.backTopButton.frame.origin.x != self.frame.size.width - 54 + self.frame.origin.x) {
        self.backTopButton.frame = CGRectMake(self.frame.size.width - 54 + self.frame.origin.x, self.frame.size.height - 54 + self.frame.origin.y, 40, 40);
    }
    if (!self.backTopButton.superview && self.superview) {
        [self.superview insertSubview:self.backTopButton aboveSubview:self];
    }
}

- (void)backTop; {
    [self setContentOffset:CGPointZero animated:YES];
}

- (UIButton *)backTopButton; {
    UIButton *button = objc_getAssociatedObject(self, @selector(backTopButton));
    if (!button) {
#pragma mark 视图-返回顶部按钮
        button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tintColor = [UIColor blackColor];
        button.layer.borderColor = [UIColor blackColor].CGColor;
        button.layer.borderWidth = 0.5;
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 20;
        button.hidden = YES;
        [button setTitle:@"Top" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backTop) forControlEvents:UIControlEventTouchUpInside];
        self.backTopButton = button;
    }
    return button;
}

- (void)setBackTopButton:(UIButton *)backTopButton; {
    objc_setAssociatedObject(self, @selector(backTopButton), backTopButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)backTopEnabled; {
    return objc_getAssociatedObject(self, @selector(backTopEnabled));
}

- (void)setBackTopEnabled:(BOOL)backTopEnabled; {
    if (backTopEnabled) {
        self.observeValue = YES;
    }
    objc_setAssociatedObject(self, @selector(backTopEnabled), @(backTopEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)backTopValidOffset; {
    CGFloat backTopValidOffset = [objc_getAssociatedObject(self, @selector(backTopValidOffset)) floatValue];
    if (backTopValidOffset == 0.0) {
        backTopValidOffset = 200.0;
        self.backTopValidOffset = backTopValidOffset;
    }
    return backTopValidOffset;
}

- (void)setBackTopValidOffset:(CGFloat)backTopValidOffset; {
    objc_setAssociatedObject(self, @selector(backTopValidOffset), @(backTopValidOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark Page Number

- (void)checkPageNumner; {
    if (self.contentOffset.y <= 0) {
        return;
    }
    self.pageNumnerLabel.hidden = NO;
    
    objc_setAssociatedObject(self, @"PageNumber_TimeoutInterval", @(1.5), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSTimer *timer = objc_getAssociatedObject(self, @"PageNumber_Timer");
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timeInterval) userInfo:NULL repeats:YES];
        objc_setAssociatedObject(self, @"PageNumber_Timer", timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)timeInterval; {
    NSTimeInterval timeoutInterval = [objc_getAssociatedObject(self, @"PageNumber_TimeoutInterval") doubleValue];
    timeoutInterval -= 0.5;
    objc_setAssociatedObject(self, @"PageNumber_TimeoutInterval", @(timeoutInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (timeoutInterval <= 0) {
        NSTimer *timer = objc_getAssociatedObject(self, @"PageNumber_Timer");
        [timer invalidate];
        objc_setAssociatedObject(self, @"PageNumber_Timer", NULL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [UIView animateWithDuration:0.6 animations:^{
            self.pageNumnerLabel.alpha = 0;
        } completion:^(BOOL finished) {
            self.pageNumnerLabel.hidden = YES;
            self.pageNumnerLabel.alpha = 1;
        }];
    }
}

- (void)pageNumnerLabelLayout; {
    if (self.pageNumnerLabel.frame.origin.x != (self.frame.size.width-100)/2 + self.frame.origin.x) {
        self.pageNumnerLabel.frame = CGRectMake((self.frame.size.width-100)/2 + self.frame.origin.x, self.frame.size.height - 40 + self.frame.origin.y, 100, 20);
    }
    if (!self.pageNumnerLabel.superview && self.superview) {
        [self.superview insertSubview:self.pageNumnerLabel aboveSubview:self];
    }
}

- (void)changePageNumnerText; {
    if (!self.currentPage && !self.numberOfPages) {
        return;
    }
    else {
        self.observeValue = YES;
        NSString *pageNumberText = [NSString stringWithFormat:@"%ld/%ld", self.currentPage, self.numberOfPages];
        self.pageNumnerLabel.text = pageNumberText;
    }
}

- (UILabel *)pageNumnerLabel; {
    UILabel *label = objc_getAssociatedObject(self, @selector(pageNumnerLabel));
    if (!label) {
#pragma mark 视图-页码
        label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:10];
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = 10;
        label.text = @"16/40";
        label.hidden = YES;
        self.pageNumnerLabel = label;
    }
    return label;
}

- (void)setPageNumnerLabel:(UILabel *)pageNumnerLabel; {
    objc_setAssociatedObject(self, @selector(pageNumnerLabel), pageNumnerLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)currentPage; {
    return [objc_getAssociatedObject(self, @selector(currentPage)) integerValue];
}

- (void)setCurrentPage:(NSInteger)currentPage; {
    objc_setAssociatedObject(self, @selector(currentPage), @(currentPage), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self changePageNumnerText];
}

- (NSInteger)numberOfPages; {
    return [objc_getAssociatedObject(self, @selector(numberOfPages)) integerValue];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages; {
    objc_setAssociatedObject(self, @selector(numberOfPages), @(numberOfPages), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self changePageNumnerText];
}


#pragma mark NoMore Data

- (void)noMoreDataViewLayout; {
    self.noMoreDataView.hidden = self.contentSize.height < self.frame.size.height;
    if (!self.noMoreDataView.hidden) {
        CGRect rect = CGRectMake(0, self.contentSize.height, self.frame.size.width, self.noMoreDataView.frame.size.height);
        if (!CGRectEqualToRect(rect, self.noMoreDataView.frame)) {
            self.noMoreDataView.frame = rect;
        }
    }
}

- (UIView *)noMoreDataView; {
    UIView *view = objc_getAssociatedObject(self, @selector(noMoreDataView));
    if (!view) {
#pragma mark 视图-没有更多数据
        view = [[UIView alloc] init];
        view.backgroundColor = [UIColor orangeColor];
        view.hidden = YES;
        view.frame = CGRectMake(0, 0, 0, 50);
        
        UILabel *label = [[UILabel alloc] init];
        label.text = @"没有更多数据了";
        label.textAlignment = NSTextAlignmentCenter;
        label.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50);
        [view addSubview:label];
        
        self.noMoreDataView = view;
    }
    return view;
}

- (void)setNoMoreDataView:(UIView *)noMoreDataView; {
    objc_setAssociatedObject(self, @selector(noMoreDataView), noMoreDataView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)noMoreDataEnabled; {
    return [objc_getAssociatedObject(self, @selector(noMoreDataEnabled)) boolValue];
}

- (void)setNoMoreDataEnabled:(BOOL)noMoreDataEnabled; {
    objc_setAssociatedObject(self, @selector(noMoreDataEnabled), @(noMoreDataEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.noMoreDataEnabled) {
        if (!self.noMoreDataView.superview) {
            [self addSubview:self.noMoreDataView];
        }
    }
    else {
        if (self.noMoreDataView.superview) {
            [self.noMoreDataView removeFromSuperview];
        }
    }
}


#pragma mark Scroll State

- (void)checkScrollState; {
    CGPoint lastPoint = [objc_getAssociatedObject(self, @"ScrollState_LastPoint") CGPointValue];
    UIScrollState state = [objc_getAssociatedObject(self, @"ScrollState_State") integerValue];
    CGPoint currentPoint = self.contentOffset;
    
    
    if (state == UIScrollStateNone) {
        objc_setAssociatedObject(self, @"ScrollState_LastPoint", [NSValue valueWithCGPoint:currentPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, @"ScrollState_State", @(UIScrollStateNormal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else {
        if (currentPoint.x > lastPoint.x) {
            // right
            if (state == UIScrollStateRight) {
                if (currentPoint.x - lastPoint.x > self.scrollStateValidOffset) {
                    NSLog(@"Right");
                }
            }
            else {
                objc_setAssociatedObject(self, @"ScrollState_State", @(UIScrollStateRight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
        else if (currentPoint.x < lastPoint.x) {
            // left
        }
        else if (currentPoint.y > lastPoint.y) {
            // down
            if (state == UIScrollStateDown) {
                UIScrollState lastState = [objc_getAssociatedObject(self, @"ScrollState_LastState") integerValue];
                if (lastState == state) {
                    objc_setAssociatedObject(self, @"ScrollState_LastPoint", [NSValue valueWithCGPoint:currentPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    return;
                }
                if (currentPoint.y - lastPoint.y > self.scrollStateValidOffset) {
                    NSLog(@"Down:%lf -- %lf", lastPoint.y, currentPoint.y);
                    objc_setAssociatedObject(self, @"ScrollState_LastPoint", [NSValue valueWithCGPoint:currentPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    objc_setAssociatedObject(self, @"ScrollState_State", @(UIScrollStateNormal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    objc_setAssociatedObject(self, @"ScrollState_LastState", @(state), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    if ([self.extensionDelegate respondsToSelector:@selector(scrollView:scrollStateChanged:)]) {
                        [self.extensionDelegate scrollView:self scrollStateChanged:state];
                    }
                }
            }
            else {
                
                objc_setAssociatedObject(self, @"ScrollState_State", @(UIScrollStateDown), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
        else if (currentPoint.y < lastPoint.y) {
            // up
            if (state == UIScrollStateUp) {
                UIScrollState lastState = [objc_getAssociatedObject(self, @"ScrollState_LastState") integerValue];
                if (lastState == state) {
                    objc_setAssociatedObject(self, @"ScrollState_LastPoint", [NSValue valueWithCGPoint:currentPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    return;
                }
                if (lastPoint.y - currentPoint.y > self.scrollStateValidOffset) {
                    NSLog(@"Up:%lf -- %lf", lastPoint.y, currentPoint.y);
                    objc_setAssociatedObject(self, @"ScrollState_LastPoint", [NSValue valueWithCGPoint:currentPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    objc_setAssociatedObject(self, @"ScrollState_State", @(UIScrollStateNormal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    objc_setAssociatedObject(self, @"ScrollState_LastState", @(state), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    if ([self.extensionDelegate respondsToSelector:@selector(scrollView:scrollStateChanged:)]) {
                        [self.extensionDelegate scrollView:self scrollStateChanged:state];
                    }
                }
            }
            else {
                
                objc_setAssociatedObject(self, @"ScrollState_State", @(UIScrollStateUp), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
    }
}

- (BOOL)scrollStateEnabled; {
    return [objc_getAssociatedObject(self, @selector(scrollStateEnabled)) boolValue];
}

- (void)setScrollStateEnabled:(BOOL)scrollStateEnabled; {
    objc_setAssociatedObject(self, @selector(scrollStateEnabled), @(scrollStateEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (scrollStateEnabled) {
        self.observeValue = YES;
    }
}

- (CGFloat)scrollStateValidOffset; {
    CGFloat offset = [objc_getAssociatedObject(self, @selector(scrollStateValidOffset)) floatValue];
    if (offset == 0.0) {
        offset = 140.0;
        self.scrollStateValidOffset = offset;
    }
    return offset;
}

- (void)setScrollStateValidOffset:(CGFloat)scrollStateValidOffset; {
    objc_setAssociatedObject(self, @selector(scrollStateValidOffset), @(scrollStateValidOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end







