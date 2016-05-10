//
//  ViewController.m
//  UIScrollViewExtension-Demo
//
//  Created by 翟泉 on 16/5/9.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ViewController.h"
#import <UIScrollViewExtension/UIScrollViewExtension.h>
#import "AppDelegate.h"

@interface ViewController ()
<UIScrollViewExtensionDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSInteger count;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:[[UIView alloc] init]];
    
    count = 20;
    
    UITableView *tableView    = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor grayColor];
    tableView.delegate        = self;
    tableView.dataSource      = self;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:tableView];
    
    tableView.extensionDelegate = self;
    
    tableView.automaticLoadingEnabled = YES;
    
    tableView.backTopEnabled = YES;
    
    tableView.currentPage = 1;
    
    tableView.numberOfPages = 6;
    
}

#pragma mark - UIScrollViewExtensionDelegate

- (void)scrollViewAutomaticLoading:(__kindof UIScrollView *)scrollView; {
    static NSInteger maxCount = 108;
    static NSInteger pageSize = 20;
    
    UITableView *tableView = scrollView;
    
    if (count < maxCount) {
        if (count + pageSize < maxCount) {
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:pageSize];
            for (NSInteger i=count; i<count+pageSize; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            count += pageSize;
            [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
            scrollView.automaticLoadingEnabled = YES;
        }
        else {
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:pageSize];
            for (NSInteger i=count; i<maxCount; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            count = maxCount;
            [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
            
            tableView.noMoreDataEnabled = YES;
        }
        
        tableView.currentPage = (count + pageSize - 1) / pageSize;
        
    }
}

- (void)scrollView:(__kindof UIScrollView *)scrollView scrollStateChanged:(UIScrollState)state; {
    if (state == UIScrollStateUp) {
        AppDelegate *app = [UIApplication sharedApplication].delegate;
        app.window.windowLevel = UIWindowLevelNormal;
        
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        scrollView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
    }
    else if (state == UIScrollStateDown) {
        AppDelegate *app = [UIApplication sharedApplication].delegate;
        app.window.windowLevel = UIWindowLevelAlert;
        
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
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
