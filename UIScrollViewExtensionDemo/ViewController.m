//
//  ViewController.m
//  UIScrollViewExtensionDemo
//
//  Created by 翟泉 on 16/2/19.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ViewController.h"

#import "UIScrollViewExtension.h"

@interface ViewController ()
<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    NSInteger count;
    NSInteger maxCount;
    NSInteger pageSize;
    ESScrollViewAutoLoading *ss;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    maxCount = 123;
    pageSize = 10;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:_tableView];
    
    
    _tableView.autoLoading.enable = YES;
    __weak typeof(self) weakself = self;
    [_tableView.autoLoading setAutoLoadingBlock:^(UIScrollView *scrollView) {
        [weakself loadNextPage];
    }];
    
    _tableView.topButton.enable = YES;
    
    _tableView.pageNumber.enable = YES;
    
    _tableView.pageNumber.numberOfPages = (maxCount + pageSize - 1) / pageSize;
    
    
}

- (void)loadNextPage; {
    if (count+pageSize>maxCount) {
        count = maxCount;
        [_tableView reloadData];
    }
    else {
        count += pageSize;
        [_tableView reloadData];
        _tableView.autoLoading.enable = YES;
    }
    _tableView.pageNumber.currentPage = (count + pageSize - 1) / pageSize;
    
    
    if (_tableView.pageNumber.currentPage == 13) {
        _tableView.noMoreData.enable = YES;
    }
    
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section; {
    return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; {
    return [tableView dequeueReusableCellWithIdentifier:@"Cell"];
}



#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath; {
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath; {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
