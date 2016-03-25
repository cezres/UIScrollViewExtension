//
//  UIScrollViewExtension.h
//  UIScrollViewExtensionDemo
//
//  Created by 翟泉 on 16/2/19.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol UIScrollViewExtensionProtocol <NSObject>


@property (weak, nonatomic) UIScrollView *scrollView;


@optional
/**
 *  滚动偏移量发生改变时调用
 *
 *  @param contentOffset 滚动偏移量
 */
- (void)contentOffsetChanged:(CGPoint)contentOffset;
/**
 *  UIScrollView添加在其它视图上后调用
 */
- (void)scrollViewDidMoveToSuperview;

- (void)scrollViewLayoutSubviews;

@end


@class ESScrollViewAutoLoading;
@class ESScrollViewTopButton;
@class ESScrollViewPageNumber;
@class ESScrollViewNoMoreData;

@interface UIScrollView (Extension)

@property (strong, nonatomic, readonly) ESScrollViewAutoLoading *autoLoading;
@property (strong, nonatomic, readonly) ESScrollViewTopButton *topButton;
@property (strong, nonatomic, readonly) ESScrollViewPageNumber *pageNumber;
@property (strong, nonatomic, readonly) ESScrollViewNoMoreData *noMoreData;
@property (strong, nonatomic, readonly) NSMutableArray<NSObject<UIScrollViewExtensionProtocol> *> *extensions;

@end



/**
 *  滚动到一定偏移量后回调，并设为关闭状态
 */
@interface ESScrollViewAutoLoading : NSObject
<UIScrollViewExtensionProtocol>

@property (assign, nonatomic) BOOL  enable;
@property (copy, nonatomic) void (^autoLoadingBlock)(UIScrollView *scrollView);

@end

/**
 *  显示返回顶部按钮
 */
@interface ESScrollViewTopButton : NSObject
<UIScrollViewExtensionProtocol>

@property (assign, nonatomic) BOOL  enable;

@end

/**
 *  显示分页数据页码
 */
@interface ESScrollViewPageNumber : NSObject
<UIScrollViewExtensionProtocol>

@property (assign, nonatomic) BOOL  enable;
@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) NSInteger numberOfPages;

@end

/**
 *  没有更多数据
 */
@interface ESScrollViewNoMoreData : UIView
<UIScrollViewExtensionProtocol>

@property (assign, nonatomic) BOOL enable;

@end

