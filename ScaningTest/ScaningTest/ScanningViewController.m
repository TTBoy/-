//
//  ScanningViewController.m
//  PNCMobileBank
//
//

#import "ScanningViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PCQRScanView.h"
#import "ZBarReaderView.h"
//新增 二维码校验 接口
@interface ScanningViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIAlertViewDelegate,AVCaptureVideoDataOutputSampleBufferDelegate, ZBarReaderViewDelegate>
{
    
}
@property (nonatomic,strong)AVCaptureDevice * device;
@property (nonatomic,strong)AVCaptureDeviceInput * input;
@property (nonatomic,strong)AVCaptureMetadataOutput * output;
@property (nonatomic,strong)AVCaptureSession * session;
@property (nonatomic,strong)AVCaptureVideoPreviewLayer * preview;
@property (nonatomic,strong)ZBarReaderView *reader;
@property (nonatomic,strong) PCQRScanView *overlayView ;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property(nonatomic,strong) UIActivityIndicatorView *waitingView;
@property(nonatomic,strong) UILabel *lbOfTips;
@property (weak, nonatomic) IBOutlet UIButton *ReceivablesBtn;
@property (weak, nonatomic) IBOutlet UIButton *PaymentBtn;
/**
 读相册按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *btn_readXiangce;
/**
 拍一拍按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *btn_paiyipai;

//传播式营销 用
@property(strong,nonatomic)NSString *xuliehao;//序列号
@property (weak, nonatomic) IBOutlet UILabel *lab_navTitle;

@property (weak, nonatomic) IBOutlet UIButton *btn_person_navMore;
// iphoneX 适配
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nav_titleTopFixConst;
// 标题lab
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lab_navCenterYConst;
@property (weak, nonatomic) IBOutlet UIButton *btn_back;

@property (weak, nonatomic) IBOutlet UILabel *flashLabel;
@property (weak, nonatomic) IBOutlet UIButton *flashBtn;


@end

@implementation ScanningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.titleStr) {
        self.title = self.titleStr;
        self.lab_navTitle.text = self.titleStr;
    } else {
        self.title =@"扫一扫";
    }
//    [self initReaderView];
    [self getQRcodeFromPhoto];
    //10.58 之后更改
    self.btn_readXiangce.hidden = YES;
    self.btn_paiyipai.hidden = YES;
    //开始隐藏 闪光灯按钮和字体
    self.flashBtn.hidden = YES;
    self.flashLabel.hidden = YES;
    
    [self showWaitingView:YES];
    
//    [self initHomePageNavBar];
    [self.PaymentBtn setImage:[UIImage imageNamed:@"homepage_receivablesHight.png"] forState:UIControlStateNormal];
//    [self.PaymentBtn setTitleColor:[UIColor colorWithHex:0x00c6ff] forState:UIControlStateNormal];
    
//    if (ISIPhoneXORLATER) {
//        self.nav_titleTopFixConst.constant = 88.0f;
//        self.btn_back.imageEdgeInsets = UIEdgeInsetsMake(40, 0, 0, 0);
//        self.btn_person_navMore.titleEdgeInsets = UIEdgeInsetsMake(40, 0, 0, 0);
//        [self.btn_person_navMore setTitle:@"相册" forState:(UIControlStateNormal)];
//        self.lab_navCenterYConst.constant = 20.0f;
//    }else {
        self.nav_titleTopFixConst.constant = 64.0f;
        self.btn_back.imageEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 0);
        self.btn_person_navMore.imageEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 0);
        self.btn_person_navMore.titleEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 0);
        [self.btn_person_navMore setTitle:@"相册" forState:(UIControlStateNormal)];
        self.lab_navCenterYConst.constant = 10.0f;
        
//    }
    //感光显示手电筒
    [self lightSensitive];
    //添加通知
    [self addNotification];
}
#pragma mark - ZBarReaderView
- (void)readerView:(ZBarReaderView*)view didReadSymbols:(ZBarSymbolSet*)syms fromImage:(UIImage*) img{
    for(ZBarSymbol *sym in syms) {
        NSString *stringValue = sym.data;
        if (stringValue.length > 0) {
            [self scanCompleteWithResult:stringValue];
        } else {
            [self scanCompleteWithResult:@""];
        }
        [_reader stop];
        break;
    }
}

#pragma mark - NotificationManagement
- (void)addNotification {
    //锁屏
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LockScreenNotificationHandle:) name:LockScreenNotification object:nil];
}

//锁屏
- (void)LockScreenNotificationHandle:(NSNotification *)notification {
    if ([notification.object isEqualToString:@"0"]) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch]) {
            [self.flashBtn setSelected:NO];
            self.flashLabel.text = @"轻触开启";
            self.flashLabel.textColor = [UIColor whiteColor];
            [self.flashBtn setBackgroundImage:[UIImage imageNamed:@"close_shou_dian"] forState:UIControlStateNormal];
            [device lockForConfiguration:nil];
            [device setTorchMode: AVCaptureTorchModeOff];//关
            [device unlockForConfiguration];
        }
    }
}

- (void)removeNotification {
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:LockScreenNotification object:nil];
}

#pragma mark ==  右上角Action
- (IBAction)scanNavRightAction:(UIButton *)sender {
    
    [self openXiangCe];
}

- (void)stopScanAction:(BOOL)stop {
    if (stop) {
        [self stopScan];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self canScanStart];
}
- (void)canScanStart {
    if([[UIDevice currentDevice].systemVersion floatValue] >= 7.0){
//        [self setupCamera];
        [self setupReader];
    }
    [self showWaitingView:NO];
}

- (void)setupReader{
    _reader = [ZBarReaderView new];
    _reader.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _reader.readerDelegate = self;
    _reader.allowsPinchZoom = NO;
    _reader.tracksSymbols = NO;
    _reader.trackingColor = UIColor.clearColor;
    [self.view addSubview:_reader];
    [self.view sendSubviewToBack: _reader];
//    [_reader mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
//    }];
    [_reader start];
}

//初始化首页导航条
-(void)initHomePageNavBar{
//    self.topItem=[[PNCNavItem alloc]initWithImg:[UIImage imageNamed:@"qr_scan_navbar.png"]];
//    self.navBar.hidden=YES;
//    self.navBar.backgroundColor=[UIColor clearColor];
}
-(void)leftButtonPressed:(id)sender{
    
}
-(void)rightButtonPressed:(id)sender{
    
}
//初始化扫描页面样式
-(void)initReaderView{
    if ([self.overlayView isDescendantOfView:self.view]) {
        [self.overlayView removeFromSuperview];
    }
    self.overlayView = [[PCQRScanView alloc] initWithFrame:CGRectZero];
//    [self.view insertSubview:self.overlayView belowSubview:self.navBar];
    [self.view sendSubviewToBack:self.overlayView];
    
    [_overlayView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *dict = NSDictionaryOfVariableBindings(_overlayView,_bottomView);
    
    NSString *vf0 = @"|-0-[_overlayView]-0-|";
    NSString *vf1 = @"V:[_overlayView]-(0)-|";
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vf0 options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vf1 options:0 metrics:nil views:dict]];
    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_overlayView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.navBar attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
  
    self.flashLabel.textAlignment = NSTextAlignmentCenter;
    self.flashLabel.font = [UIFont systemFontOfSize:14];
    self.flashLabel.textColor = [UIColor whiteColor];
    //self.flashLabel.text = @"闪光灯已关闭";
    self.flashLabel.text = @"轻触开启";
    self.flashLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openFlashBtn)];
    [self.flashLabel addGestureRecognizer:tapGestureRecognizer];
 
    [self.flashBtn setBackgroundImage:[UIImage imageNamed:@"close_shou_dian.png"] forState:UIControlStateNormal];
  
    
    
    
}
- (IBAction)toucchFlashBtn:(UIButton *)sender {
    [self openFlashBtn];
}

- (void)openFlashBtn{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
       if ([device hasTorch]) {
           if (!self.flashBtn.selected) {
               //self.flashBtn.hidden = NO;
               //self.flashLabel.text = @"闪光灯已开启";
               self.flashLabel.text = @"轻触关闭";
               //[self.flashBtn setBackgroundImage:[UIImage imageNamed:@"icon_闪光灯_open.png"] forState:UIControlStateNormal];
               [self.flashBtn setBackgroundImage:[UIImage imageNamed:@"open_shou_dian"] forState:UIControlStateNormal];
//               self.flashLabel.textColor = RGBCOLOR(40, 178, 243);
               [self.flashBtn setSelected:YES];
               [device lockForConfiguration:nil];
               [device setTorchMode: AVCaptureTorchModeOn];//开
               [device unlockForConfiguration];
           }else{
               //self.flashBtn.hidden = YES;
               [self.flashBtn setSelected:NO];
               //self.flashLabel.text = @"闪光灯已关闭";
               self.flashLabel.text = @"轻触开启";
               self.flashLabel.textColor = [UIColor whiteColor];
               //[self.flashBtn setBackgroundImage:[UIImage imageNamed:@"icon_闪光灯_close"] forState:UIControlStateNormal];
               [self.flashBtn setBackgroundImage:[UIImage imageNamed:@"close_shou_dian"] forState:UIControlStateNormal];
               [device lockForConfiguration:nil];
               [device setTorchMode: AVCaptureTorchModeOff];//关
               [device unlockForConfiguration];
           }
       }
    
    
}

//iOS7以上使用AVCaptureDevice
- (void)setupCamera{
    //checkAVAuthorization
    if (![self checkAVAuthorization])return;
    // Device
    if (_device ==nil) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    // Input
    if (_input ==nil) {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    // Output
    if (_output ==nil) {
        _output = [[AVCaptureMetadataOutput alloc]init];
    }
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // Session
    if (_session ==nil) {
        _session = [[AVCaptureSession alloc]init];
    }
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    if (!TARGET_IPHONE_SIMULATOR) {
        // 条码类型 AVMetadataObjectTypeQRCode
        //_output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
//        NSArray *types = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
//        _output.metadataObjectTypes = types;
        _output.metadataObjectTypes = [NSArray arrayWithObject:AVMetadataObjectTypeQRCode];
    }
    // Preview
    if (_preview ==nil) {
        _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _preview.frame = self.view.bounds; //摄像头的区域
        [self.view.layer insertSublayer:self.preview atIndex:0];
    }
    // Start
    [_session startRunning];
}

#pragma mark- 光感
- (void)lightSensitive {
    // 1.获取硬件设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 2.创建输入流
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc]initWithDevice:device error:nil];
    // 3.创建设备输出流
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    // AVCaptureSession属性
    self.session = [[AVCaptureSession alloc]init];
    // 设置为高质量采集率
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    // 添加会话输入和输出
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    }
    // 9.启动会话
    [self.session startRunning];
}


//检查相机的权限
-(BOOL)checkAVAuthorization{
    BOOL isAllowed =YES;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted){
        //未允许使用相机
        isAllowed =NO;
        //NSString *tips =PNCisIOS8Later?@"前往打开":nil;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的相机隐私授权尚未打开，若要打开请前往 设置-隐私-相机 中打开。" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"前往打开", nil];
        alertView.tag = 100;
        [alertView show];
    }
    return isAllowed;
}
#pragma mark -等待层
-(UIActivityIndicatorView *)waitingView{
    if (_waitingView==nil) {
        _waitingView =[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        CGRect rect =[[UIScreen mainScreen] bounds];
        _waitingView.center =CGPointMake(rect.size.width/2-40,(rect.size.height-20)/2);
        [self.view addSubview:_waitingView];
    }
    return _waitingView;
}
-(UILabel *)lbOfTips{
    if (_lbOfTips==nil) {
        _lbOfTips =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 21)];
        _lbOfTips.backgroundColor =[UIColor clearColor];
        _lbOfTips.font =[UIFont systemFontOfSize:15];
        _lbOfTips.text =@"相机准备中...";
        _lbOfTips.textColor =[UIColor whiteColor];
        _lbOfTips.center =CGPointMake(self.waitingView.center.x+66, self.waitingView.center.y);
    }
    return _lbOfTips;
}
-(void)showWaitingView:(BOOL)needShow{
    if (needShow) {
        [self.waitingView startAnimating];
        self.view.backgroundColor =[UIColor lightGrayColor];
        if (![self.lbOfTips isDescendantOfView:self.view])
            [self.view addSubview:self.lbOfTips];
    }else{
        [self.waitingView stopAnimating];
        [self.waitingView removeFromSuperview];
        [self.lbOfTips removeFromSuperview];
        self.view.backgroundColor =[UIColor clearColor];
    }
}
#pragma mark -从相册中选择
- (IBAction)takeFromPhotoAblum:(id)sender {
    UIActionSheet *moreAction = [[UIActionSheet alloc]initWithTitle:nil delegate:(id)self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"从相册中选取",@"取消", nil];
    moreAction.destructiveButtonIndex = 2;
    [moreAction showInView:self.view.window];
}
#pragma mark -去相册
-(void)getQRcodeFromPhoto{
    UIImagePickerController *reader = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        reader.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    reader.delegate =self;
    reader.allowsEditing = YES;
    [self presentViewController:reader animated:YES completion:NULL];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
        UIImage *image = info[UIImagePickerControllerEditedImage];
        
        if (!image) {
            image = info[UIImagePickerControllerOriginalImage];
        }
        ZBarReaderController *read = [ZBarReaderController new];
        CGImageRef cgImage = image.CGImage;
        ZBarSymbol *symbol = nil;
        NSString *scannedResult;
        for (symbol in [read scanImage:cgImage]) {
            scannedResult = symbol.data;
        }
        [picker dismissViewControllerAnimated:YES completion:^{
            //二维码字符串
            // 触发回调
            if (scannedResult.length > 0) {
                [self scanCompleteWithResult:scannedResult];
            } else {
                [self scanCompleteWithResult:@""];

            }
            
        }];
        return;
    }
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    if(0 == buttonIndex) {
        [self getQRcodeFromPhoto];
    }
}
#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSString *stringValue=@"";
    if ([metadataObjects count] >0) {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
//    if (![PNCUtil strNilOrEmpty:stringValue]) {
        //停止扫描
        [self stopScan];
        [self scanCompleteWithResult:stringValue];
//    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    NSLog(@"%f",brightnessValue);
   
    // 根据brightnessValue的值来打开和关闭闪光灯
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    BOOL result = [device hasTorch];// 判断设备是否有闪光灯
    if ((brightnessValue < 0) && result) {// 打开闪光灯
        //NSLog(@"打开闪光灯");
//        self.flashBtn.hidden = NO;
//        self.flashLabel.hidden = NO;
    }else if((brightnessValue > 0) && result) {// 关闭闪光灯
        
//        if (!self.flashBtn.selected) {
//            self.flashBtn.hidden = YES;
//            self.flashLabel.hidden = YES;
//        } else {
//            //self.flashBtn.hidden = YES;
//        }
        
    //NSLog(@"关闭闪光登录");
        
    }
}

#pragma mark - 扫码完成之后逻辑操作
-(void)scanCompleteWithResult:(NSString *)valueString{
    
    if (self.finishResultBlock) {
        self.finishResultBlock(valueString);
    }
}

- (IBAction)ComeBackToHome:(UIButton *)sender {
    
    [self.tabBarController.navigationController popViewControllerAnimated:YES];
}

#pragma mark -MemoryManger

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ReceivablesBtnClick:(UIButton *)sender {
    [self.PaymentBtn setImage:[UIImage imageNamed:@"homepage_receivablesUsual.png"] forState:UIControlStateNormal];
    [self.PaymentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.ReceivablesBtn setImage:[UIImage imageNamed:@"homepage_paymentHight.png"] forState:UIControlStateNormal];
//    [self.ReceivablesBtn setTitleColor:[UIColor colorWithHex:0x00c6ff] forState:UIControlStateNormal];
    [self stopScan];
    
//    if(PNCisIOS7Later){
//        self.preview.hidden=YES;
//    }
    self.overlayView.hidden=YES;
}

- (IBAction)PaymentBtnClick:(UIButton *)sender{
    [self.PaymentBtn setImage:[UIImage imageNamed:@"homepage_receivablesHight.png"] forState:UIControlStateNormal];
//    [self.PaymentBtn setTitleColor:[UIColor colorWithHex:0x00c6ff] forState:UIControlStateNormal];
    [self.ReceivablesBtn setImage:[UIImage imageNamed:@"homepage_paymentUsual.png"] forState:UIControlStateNormal];
    [self.ReceivablesBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self startScan];
//    if(PNCisIOS7Later){
//        self.preview.hidden=NO;
//    }
    self.overlayView.hidden=NO;
}
-(void)startScan{
    NSLog(@"打开扫描会话 %s",__func__);
//    if (PNCisIOS7Later ) {
//        [self.session startRunning];
//    }
        [self.reader start];
    
}
-(void)stopScan{
    NSLog(@"停止扫描会话 %s",__func__);
//    if (PNCisIOS7Later ) {
//        [self.session stopRunning];
//    }
         [self.reader stop];
     
}
//打开相册
- (IBAction)daxiangce:(UIButton *)sender {
    
    [self openXiangCe];
}
//听一听
- (IBAction)tingyinting:(UIButton *)sender {
    
}

// 打开相册
- (void)openXiangCe {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        //打开相册选择照片
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self.tabBarController.navigationController presentViewController:picker animated:YES completion:nil];
        
    }
}

-(void)dealloc{
    [self removeNotification];
    [self.session stopRunning];
    [self.overlayView stopAnimation];
    [self.session removeInput:self.input];
    [self.session removeOutput:self.output];
    [self.output setMetadataObjectsDelegate:nil queue:dispatch_get_main_queue()];
}

@end
