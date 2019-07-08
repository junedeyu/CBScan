# CBScan

# 最低适配 iOS 9.0

# 支持二维码和条码扫描

# 扫描成功会有提示音

# pod 'CBScan' 

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
