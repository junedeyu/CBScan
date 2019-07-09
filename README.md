# CBScan

# 最低适配 iOS 9.0

# 支持二维码和条码扫描

# 扫描成功会有提示音

# pod 'CBScan' 

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
