//
//  ViewController.m
//  ScaningTest
//
//  Created by LTC on 2020/9/2.
//  Copyright © 2020 EDZ. All rights reserved.
//

#import "ViewController.h"
#import "ScanningViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, 10, 90, 90);
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)test{
        ScanningViewController *qrVC = [[ScanningViewController alloc] init];
        qrVC.titleStr = @"iiiii";
        [self.navigationController pushViewController:qrVC animated:YES];
    
        qrVC.finishResultBlock = ^(NSString *qrData) {
            NSLog(@"===%@", qrData);
        };
}
@end
