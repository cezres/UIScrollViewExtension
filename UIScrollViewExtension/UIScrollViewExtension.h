//
//  UIScrollViewExtension.h
//  UIScrollViewExtension
//
//  Created by 翟泉 on 16/5/9.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for UIScrollViewExtension.
FOUNDATION_EXPORT double UIScrollViewExtensionVersionNumber;

//! Project version string for UIScrollViewExtension.
FOUNDATION_EXPORT const unsigned char UIScrollViewExtensionVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <UIScrollViewExtension/PublicHeader.h>


typedef NS_ENUM(NSInteger, UIScrollState) {
    UIScrollStateNone = 0,
    UIScrollStateNormal,
    UIScrollStateUp,
    UIScrollStateDown,
    UIScrollStateLeft,
    UIScrollStateRight
};

@protocol UIScrollViewExtensionDelegate <NSObject>

@optional
- (void)scrollViewAutomaticLoading:(__kindof UIScrollView *)scrollView;

- (void)scrollView:(__kindof UIScrollView *)scrollView scrollStateChanged:(UIScrollState)state;

@end




@interface UIScrollView (Extension)

#pragma mark ObserveValue

@property (assign, nonatomic) BOOL observeValue;


#pragma mark Callback

@property (assign, nonatomic) id<UIScrollViewExtensionDelegate> extensionDelegate;


#pragma mark Automatic Loading

@property (assign, nonatomic) CGFloat   automaticLoadingValidOffset;

@property (assign, nonatomic) BOOL      automaticLoadingEnabled;


#pragma mark Back Top

@property (strong, nonatomic) UIButton  *backTopButton;

@property (assign, nonatomic) CGFloat   backTopValidOffset;

@property (assign, nonatomic) BOOL      backTopEnabled;


#pragma mark Page Number

@property (strong, nonatomic) UILabel   *pageNumnerLabel;

@property (assign, nonatomic) NSInteger currentPage;

@property (assign, nonatomic) NSInteger numberOfPages;


#pragma mark NoMore Data

@property (strong, nonatomic) UIView    *noMoreDataView;

@property (assign, nonatomic) BOOL      noMoreDataEnabled;


#pragma mark Scroll State

@property (assign, nonatomic) CGFloat   scrollStateValidOffset;

@property (assign, nonatomic) BOOL      scrollStateEnabled;

@end
