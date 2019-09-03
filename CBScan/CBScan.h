//
//  CBScan.h
//  CBScanDemo
//
//  Created by CBScan on 19/07/07.
//  Copyright © 2016年 CBScan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CBScanDelegate <NSObject>

@optional;
- (void)CBScanDidFinishScanner:(NSString *)string;

@end


@interface CBScan : UIViewController
@property (nonatomic, weak) id<CBScanDelegate> delegate;

@property (nonatomic,copy) void(^ CBScanSucBlock)(NSString * result);

@end
