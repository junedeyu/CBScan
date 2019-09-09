//
//  CBScan.m
//  CBScanDemo
//
//  Created by CBScan on 19/07/07.
//  Copyright © 2016年 CBScan. All rights reserved.
//

#import "CBScan.h"
#import <Masonry/Masonry.h>
#import <AVFoundation/AVFoundation.h>

#ifdef DEBUG
#define CBLog(...) NSLog(__VA_ARGS__)
#define CBMsg object[@"RetMessage"]
#else
#define CBLog(...)
#endif

#define IMAGE_Resource_PATH(NAME) [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] pathForResource:NAME ofType:@"png"]]

@interface CBScan () <AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureDevice * captureDevice;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, strong) UIImageView *scanMask;
@property (nonatomic, assign) BOOL isStop;
@end

@implementation CBScan {
    CGSize  screenSize;
    CGFloat scanFrameW;
    CGFloat scanFrameH;
    CGFloat scanFrameX;
    CGFloat scanFrameY;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.clipsToBounds = YES;
    [self.navigationController setNavigationBarHidden:YES];
    
    self.isStop = NO;
    [self startMaskAnimation];

    
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:nil];
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:input]) {
        [_session addInput:input];
    }
    if ([_session canAddOutput:output]) {
        [_session addOutput:output];
    }
    
    output.metadataObjectTypes = @[AVMetadataObjectTypeUPCECode,
                                   AVMetadataObjectTypeCode39Code,
                                   AVMetadataObjectTypeCode39Mod43Code,
                                   AVMetadataObjectTypeCode93Code,
                                   AVMetadataObjectTypePDF417Code,
                                   AVMetadataObjectTypeQRCode,
                                   AVMetadataObjectTypeEAN13Code,
                                   AVMetadataObjectTypeEAN8Code,
                                   AVMetadataObjectTypeCode128Code,
                                   AVMetadataObjectTypeAztecCode,
                                   AVMetadataObjectTypeInterleaved2of5Code,
                                   AVMetadataObjectTypeITF14Code,
                                   AVMetadataObjectTypeDataMatrixCode,
                                   ];
    
    // 设置扫描框
    screenSize = [[UIScreen mainScreen] bounds].size;
    scanFrameW = screenSize.width - 80;
    scanFrameH = screenSize.width - 80;
    scanFrameX = (screenSize.width - scanFrameW) / 2;
    scanFrameY = (screenSize.height - scanFrameH) / 2;
    
    CGRect scanFrame = CGRectMake(scanFrameX, scanFrameY, scanFrameW, scanFrameH);
    CGRect ScanInterest = CGRectMake(scanFrame.origin.y / screenSize.height, scanFrame.origin.x / screenSize.width, scanFrameH / screenSize.height, scanFrameW / screenSize.width);
    output.rectOfInterest = ScanInterest;
    
    //扫描框周围颜色设置
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, scanFrame.origin.y)];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, scanFrame.origin.y, scanFrame.origin.x, scanFrameH)];
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(scanFrame), scanFrame.origin.y, CGRectGetWidth(leftView.frame), scanFrameH)];
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(leftView.frame), screenSize.width, CGRectGetHeight(topView.frame))];
    
    topView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    bottomView.backgroundColor = topView.backgroundColor;
    leftView.backgroundColor = topView.backgroundColor;
    rightView.backgroundColor = topView.backgroundColor;
    
    [self.view addSubview:topView];
    [self.view addSubview:leftView];
    [self.view addSubview:rightView];
    [self.view addSubview:bottomView];
    
    //取景框
    CGFloat edgeLength = 17;
    //左上角
    UIImageView *topLeft = [[UIImageView alloc] initWithFrame:CGRectMake(scanFrame.origin.x, scanFrame.origin.y, edgeLength, edgeLength)];
    
    topLeft.image =  [UIImage imageNamed:@"CBScan.bundle/app_scan_corner_top_left"];
    //右上角
    UIImageView *topRight = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(scanFrame) - edgeLength, scanFrame.origin.y, edgeLength, edgeLength)];
    topRight.image = [UIImage imageNamed:@"CBScan.bundle/app_scan_corner_top_right"];
    //左下角
    UIImageView *bottomLeft = [[UIImageView alloc] initWithFrame:CGRectMake(scanFrame.origin.x, CGRectGetMaxY(scanFrame) - edgeLength, edgeLength, edgeLength)];
    bottomLeft.image = [UIImage imageNamed:@"CBScan.bundle/app_scan_corner_bottom_left"];
    //右下角
    UIImageView *bottomRight = [[UIImageView alloc] initWithFrame:CGRectMake(topRight.frame.origin.x, bottomLeft.frame.origin.y, edgeLength, edgeLength)];
    bottomRight.image = [UIImage imageNamed:@"CBScan.bundle/app_scan_corner_bottom_right"];
    
    [self.view addSubview:topLeft];
    [self.view addSubview:topRight];
    [self.view addSubview:bottomLeft];
    [self.view addSubview:bottomRight];
    
    //扫描掩模
    CGFloat scanMaskWidth = scanFrameW;
    CGFloat scanMaskHeight = scanFrameW;
    UIImageView *scanMask = [[UIImageView alloc] initWithFrame:CGRectMake((screenSize.width - scanMaskWidth) / 2, scanFrame.origin.y, scanMaskWidth, scanMaskHeight)];
    scanMask.image = [UIImage imageNamed:@"CBScan.bundle/scan_net"];
    self.scanMask = scanMask;
    [self.view addSubview:scanMask];
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    [_session startRunning];
    
    //返回
    CGFloat backImageViewWidth = 40;
    CGFloat backImageViewY = 30;
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    back.frame = CGRectMake(scanFrame.origin.x/2, backImageViewY, backImageViewWidth, backImageViewWidth);
    [back setImage:[UIImage imageNamed:@"CBScan.bundle/btn_player_quit"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(onClickback) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
    
    // 闪光灯
    UIButton * lightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lightBtn.backgroundColor = [UIColor clearColor];
    [self.view addSubview:lightBtn];
    [lightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-30);
        make.height.width.equalTo(@50);
    }];
    [lightBtn setImage:[UIImage imageNamed:@"CBScan.bundle/lightDef"] forState:UIControlStateNormal];
    [lightBtn setImage:[UIImage imageNamed:@"CBScan.bundle/lightSelect"] forState:UIControlStateSelected];
    [lightBtn addTarget:self action:@selector(lightAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)lightAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        if([self.captureDevice hasTorch] && [self.captureDevice hasFlash])
        {
            if(self.captureDevice.torchMode == AVCaptureTorchModeOff)
            {
                [self.captureDevice lockForConfiguration:nil];
                [self.captureDevice setTorchMode:AVCaptureTorchModeOn];
                [self.captureDevice setFlashMode:AVCaptureFlashModeOn];
                [self.captureDevice unlockForConfiguration];
            }
        }
    }else{
        [self stopLight];
    }
}

- (void)stopLight {
    [self.captureDevice lockForConfiguration:nil];
    if(self.captureDevice.torchMode == AVCaptureTorchModeOn)
    {
        [self.captureDevice setTorchMode:AVCaptureTorchModeOff];
        [self.captureDevice setFlashMode:AVCaptureFlashModeOff];
    }
    [self.captureDevice unlockForConfiguration];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startMaskAnimation
{
    if (self.isStop) {
        return;
    }
    self.scanMask.alpha = 0.25;
    [UIView animateWithDuration:1.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scanMask.transform = CGAffineTransformTranslate(self.scanMask.transform, 0, self.scanMask.frame.size.height);
                         self.scanMask.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                        self.scanMask.alpha = 0.0;
                         self.scanMask.frame = CGRectMake(self.scanMask.frame.origin.x, -(self.scanMask.frame.size.height-self.scanMask.frame.origin.y), self.scanMask.frame.size.width, self.scanMask.frame.size.height);
                         // 在底部稍微停留一点时间，再继续
                         [UIView animateWithDuration:0.5 animations:^{
                         } completion:^(BOOL finished) {
                            [self startMaskAnimation];
                         }];
                     }];
}

- (void)onClickback {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1) {
        if ([viewControllers objectAtIndex:viewControllers.count-1] == self) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    self.isStop = YES;
    if(self.captureDevice.torchMode == AVCaptureTorchModeOn)
    {
        [self stopLight];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSString *strValue;
    NSArray *viewControllers = self.navigationController.viewControllers;
    if ([metadataObjects count] > 0) {
        //停止扫描
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject *object = [metadataObjects objectAtIndex:0];
        strValue = object.stringValue;
        
        if([object.type isEqualToString:AVMetadataObjectTypeEAN13Code]){
            if ([strValue hasPrefix:@"0"] && [strValue length] > 1)
                strValue = [strValue substringFromIndex:1];
        }
        
        if (viewControllers.count > 1) {
            if ([viewControllers objectAtIndex:viewControllers.count-1] == self) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
        // 发出声音
        NSURL * url = [[NSBundle mainBundle] URLForResource:@"CBScan.bundle/scanSuccess.mp3" withExtension:nil];
        //2.加载音效文件，创建音效ID（SoundID,一个ID对应一个音效文件）
        SystemSoundID soundID = 8787;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
        //3.播放音效文件
        //下面的两个函数都可以用来播放音效文件，第一个函数伴随有震动效果
        //            AudioServicesPlayAlertSound(soundID);
        AudioServicesPlaySystemSound(soundID);
        
        //通知代理
        if ([self.delegate respondsToSelector:@selector(CBScanDidFinishScanner:)]) {
            [self.delegate CBScanDidFinishScanner:strValue];
        }else{
            self.CBScanSucBlock(strValue);
        }
        
        self.isStop = YES;
        if(self.captureDevice.torchMode == AVCaptureTorchModeOn) {
            [self stopLight];
        }
    }
}

- (void)dealloc {
    CBLog(@"%s",__FUNCTION__);
}

@end
