//
//  ViewController.m
//  CBScanDemo
//
//  Created by TS-CBin on 2019/7/8.
//  Copyright © 2019 CBin. All rights reserved.
//

#import "ViewController.h"
#import "CBScan.h"

@interface ViewController ()<CBScanDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CBScan * scan = [[CBScan alloc] init];
    scan.delegate = self;
    [self.navigationController pushViewController:scan animated:YES];
}

// 扫描成功后
- (void)CBScanDidFinishScanner:(NSString *)string {
    NSLog(@"--- %@",string);
}

@end
