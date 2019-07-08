//
//  ViewController.m
//  CBScanDemo
//
//  Created by TS-CBin on 2019/7/8.
//  Copyright © 2019 CBin. All rights reserved.
//

#import "ViewController.h"
#import "NELivePlayerQRScanViewController.h"

@interface ViewController ()<NELivePlayerQRScanViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NELivePlayerQRScanViewController * scan = [[NELivePlayerQRScanViewController alloc] init];
    scan.delegate = self;
    [self.navigationController pushViewController:scan animated:YES];
}

// 扫描成功后
- (void)NELivePlayerQRScanDidFinishScanner:(NSString *)string {
    NSLog(@"--- %@",string);
}

@end
