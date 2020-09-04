//
//  ScanningViewController.h
//  PNCMobileBank
//
//

#import <UIKit/UIKit.h>
#import "ZBarReaderController.h"


@interface ScanningViewController : UIViewController

@property (nonatomic, copy) void (^finishResultBlock)(NSString *qrData);

@property (nonatomic,copy)NSString *titleStr;

/**
 是否停止扫描
 */
- (void)stopScanAction:(BOOL)stop;
@end
