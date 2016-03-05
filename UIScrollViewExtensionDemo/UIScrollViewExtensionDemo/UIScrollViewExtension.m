//
//  UIScrollViewExtension.m
//  UIScrollViewExtensionDemo
//
//  Created by 翟泉 on 16/2/19.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "UIScrollViewExtension.h"
#import <objc/runtime.h>


#define AutoLoadingOffset  200
#define BackToTopOffset     200

#pragma mark - UIScrollView Extension
@implementation UIScrollView (Extension)

- (void)dealloc; {
    NSLog(@"%s", __FUNCTION__);
    [self removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)didMoveToSuperview; {
    [super didMoveToSuperview];
    
    for (NSObject<UIScrollViewExtensionProtocol> *extension in self.extensions) {
        if ([extension respondsToSelector:@selector(scrollViewDidMoveToSuperview)]) {
            [extension scrollViewDidMoveToSuperview];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context; {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        for (NSObject<UIScrollViewExtensionProtocol> *extension in self.extensions) {
            [extension setContentOffset:self.contentOffset];
        }
    }
}

#pragma mark - property
- (NSMutableArray<NSObject<UIScrollViewExtensionProtocol> *> *)extensions; {
    NSMutableArray<NSObject<UIScrollViewExtensionProtocol> *> *array = objc_getAssociatedObject(self, _cmd);
    if (!array) {
        array = [NSMutableArray array];
        objc_setAssociatedObject(self, _cmd, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return array;
}

- (ESScrollViewAutoLoading *)autoLoading; {
    ESScrollViewAutoLoading *autoLoading = objc_getAssociatedObject(self, _cmd);
    if (!autoLoading) {
        autoLoading = [[ESScrollViewAutoLoading alloc] init];
        autoLoading.scrollView = self;
        [self.extensions addObject:autoLoading];
        objc_setAssociatedObject(self, _cmd, autoLoading, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return autoLoading;
}

- (ESScrollViewTopButton *)topButton; {
    ESScrollViewTopButton *topButton = objc_getAssociatedObject(self, _cmd);
    if (!topButton) {
        topButton = [[ESScrollViewTopButton alloc] init];
        topButton.scrollView = self;
        [self.extensions addObject:topButton];
        objc_setAssociatedObject(self, _cmd, topButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return topButton;
}

- (ESScrollViewPageNumber *)pageNumber; {
    ESScrollViewPageNumber *pageNumber = objc_getAssociatedObject(self, _cmd);
    if (!pageNumber) {
        pageNumber = [[ESScrollViewPageNumber alloc] init];
        pageNumber.scrollView = self;
        [self.extensions addObject:pageNumber];
        objc_setAssociatedObject(self, _cmd, pageNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return pageNumber;
}

@end



#pragma mark - AutoLoading
@interface ESScrollViewAutoLoading ()
{
    __weak UIScrollView *_scrollView;
}
@end

@implementation ESScrollViewAutoLoading

@synthesize scrollView = _scrollView;

- (void)dealloc; {
    NSLog(@"%s", __FUNCTION__);
}

- (void)setEnable:(BOOL)enable; {
    _enable = enable;
    if (_enable && self.autoLoadingBlock) {
        [self setContentOffset:_scrollView.contentOffset];
    }
}

- (void)setContentOffset:(CGPoint)contentOffset; {
    if (self.enable) {
        if (_scrollView.contentSize.height - _scrollView.contentOffset.y - _scrollView.frame.size.height < AutoLoadingOffset) {
            self.enable = NO;
            if (self.autoLoadingBlock) self.autoLoadingBlock(_scrollView);
        }
    }
}

@end


#pragma mark - TopButton
@interface ESScrollViewTopButton ()
{
    __weak UIScrollView *_scrollView;
}
@property (strong, nonatomic) UIButton  *button;

@end

@implementation ESScrollViewTopButton

@synthesize scrollView = _scrollView;

- (void)dealloc; {
    NSLog(@"%s", __FUNCTION__);
}


- (void)backToTop; {
    [_scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)setEnable:(BOOL)enable; {
    _enable = enable;
    if (_enable && _scrollView.superview) {
        self.button.hidden = YES;
    }
}

- (void)setContentOffset:(CGPoint)contentOffset; {
    if (self.enable && contentOffset.y > BackToTopOffset) {
        self.button.hidden = NO;
    }
    else {
        self.button.hidden = YES;
    }
}

- (void)scrollViewDidMoveToSuperview; {
    self.button.hidden = YES;
}

- (UIButton *)button; {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        [_button setImage:[UIImage imageNamed:@"icon-up"] forState:UIControlStateNormal];
        _button.hidden = YES;
        _button.layer.cornerRadius = 38 / 2;
        _button.layer.borderColor = [UIColor colorWithRed:186/255.0 green:186/255.0 blue:186/255.0 alpha:1.0].CGColor;
        _button.layer.borderWidth = 0.5;
        [_button addTarget:self action:@selector(backToTop) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView.superview addSubview:_button];
        _button.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_button
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:40.0];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_button
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:40.0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_button
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_scrollView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:-10.0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_button
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_scrollView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:-10.0];
        [_scrollView.superview addConstraints:@[width, height, bottom, right]];
    }
    return _button;
}

@end


#pragma mark - PageNumber
@interface ESScrollViewPageNumber ()
{
    __weak UIScrollView *_scrollView;
}
@property (assign, nonatomic) NSInteger timeOut;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UILabel  *label;

@end

@implementation ESScrollViewPageNumber

@synthesize scrollView = _scrollView;

- (void)dealloc; {
    NSLog(@"%s", __FUNCTION__);
}


- (void)setCurrentPage:(NSInteger)currentPage; {
    _currentPage = currentPage;
    NSString *pageNumberText = [NSString stringWithFormat:@"%ld/%ld", _currentPage, _numberOfPages];
    self.label.text = pageNumberText;
}
- (void)setNumberOfPages:(NSInteger)numberOfPages; {
    _numberOfPages = numberOfPages;
    NSString *pageNumberText = [NSString stringWithFormat:@"%ld/%ld", _currentPage, _numberOfPages];
    self.label.text = pageNumberText;
}

- (void)setEnable:(BOOL)enable; {
    _enable = enable;
    if (_enable && _scrollView.superview) {
        self.label.hidden = YES;
    }
}

- (void)setContentOffset:(CGPoint)contentOffset; {
    if (self.enable && contentOffset.y) {
        self.timeOut = 2;
        [self timerFireMethod];
    }
}
- (NSTimer *)timer; {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFireMethod) userInfo:NULL repeats:YES];
    }
    return _timer;
}

- (void)timerFireMethod; {
    self.timeOut -= 1;
    if (self.timeOut <= 0) {
        [self.timer invalidate];
        self.timer = NULL;
        self.label.hidden = YES;
    }
    else if (self.timer) {
        self.label.hidden = NO;
    }
}


- (void)scrollViewDidMoveToSuperview; {
    self.label.hidden = YES;
}

- (UILabel *)label; {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        _label.layer.masksToBounds = YES;
        _label.layer.cornerRadius = 8;
        _label.hidden = YES;
        _label.font = [UIFont fontWithName:@"ArialMT" size:10];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        [_scrollView.superview addSubview:_label];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_label
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:40.0];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_label
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:16.0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_label
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_scrollView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:-10.0];
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:_label
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_scrollView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.0
                                                                    constant:0.0];
        
        [_scrollView.superview addConstraints:@[width, height, bottom, centerX]];
    }
    return _label;
}

@end
