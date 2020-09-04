//
//  PCQRScanView.m
//  QRCodeTest
//
//  Created by 丁丁 on 14-6-10.
//  Copyright (c) 2014年 丁丁. All rights reserved.
//

#import "PCQRScanView.h"

// 获取颜色
#define UI_ColorWithRGBA(r,g,b,a) [UIColor colorWithRed:r/255. green:g/255. blue:b/255. alpha:a]
#define ScanContentLength [[UIScreen mainScreen] bounds].size.width*0.72

@interface PCQRScanView()

@property (nonatomic,strong) UIImageView *scanLine;

@property (nonatomic,strong) UIImageView *scanBg;

@property (nonatomic,strong) UILabel *lbOftext;

@property (nonatomic,assign) BOOL isAnimateContinue;
@property (nonatomic,assign)CGFloat Height;

@end

@implementation PCQRScanView

-(id)init{

    if (self =[super init]) {
        
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}


-(void)setup{
    
    self.backgroundColor =UI_ColorWithRGBA(0, 0, 0, 0.5);//[UIColor clearColor];
    
//    self.backgroundColor = [UIColor redColor];
    
    _isAnimateContinue =YES;
    
    UIImage   *imageBg = [UIImage imageNamed:@"qr_scan_bg.png"];
    self.scanBg =[[UIImageView alloc] initWithImage:imageBg];
    [self addSubview:self.scanBg];
    
    self.scanLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"qr_scan_lineNew.png"]];
 //   CGFloat width =imageBg.size.width/2 -10;
    CGFloat interval =[[UIScreen mainScreen] bounds].size.height <=480 ? [[UIScreen mainScreen] bounds].size.height*0.14f+64.f: [[UIScreen mainScreen] bounds].size.height*0.14+64.f;

   // self.scanLine.frame =CGRectMake((self.frame.size.width -width)/2, interval,width, 2);
    [self addSubview:self.scanLine];
    
    self.lbOftext = [[UILabel alloc] init];
    self.lbOftext.text = @"将扫描框对准二维码图片，           即会进行自动扫描";
    self.lbOftext.font = [UIFont systemFontOfSize:14.f];
    self.lbOftext.textColor = [UIColor whiteColor];
    self.lbOftext.textAlignment =NSTextAlignmentCenter;
    self.lbOftext.numberOfLines=3;
    [self addSubview:self.lbOftext];
    
    
    [_scanBg setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_scanLine setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_lbOftext setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *dict = NSDictionaryOfVariableBindings(_scanBg,_scanLine,_lbOftext);

    NSString *vf0 = [NSString stringWithFormat:@"[_scanBg(%f)]",ScanContentLength];
    NSString *vf1 = [NSString stringWithFormat:@"V:|-%f-[_scanBg(%f)]",interval,ScanContentLength];
 
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vf0 options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vf1 options:0 metrics:nil views:dict]];
    
//    //水平居中
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_scanBg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    
    NSString *vf3 = [NSString stringWithFormat:@"[_scanLine(%f)]",ScanContentLength-10];
    NSString *vf4 = [NSString stringWithFormat:@"V:[_scanLine(%f)]",2.0];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vf3 options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vf4 options:0 metrics:nil views:dict]];
//
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_scanLine attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_scanBg attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
 //   [self addConstraint:[NSLayoutConstraint constraintWithItem:_scanLine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_scanBg attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
     [self addConstraint:[NSLayoutConstraint constraintWithItem:_scanLine attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_scanBg attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    NSString *vf5 = [NSString stringWithFormat:@"[_lbOftext(%f)]",imageBg.size.width/3];
    NSString *vf6 = [NSString stringWithFormat:@"V:[_lbOftext(%f)]-10-[_scanBg]",60.0];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vf5 options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vf6 options:0 metrics:nil views:dict]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_lbOftext attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_scanBg attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

//
    [self performSelector:@selector(animateTheImage) withObject:nil afterDelay:0.2];
}
-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    UIImage  *imageBg = [UIImage imageNamed:@"qr_scan_bg.png"];
    CGFloat width =imageBg.size.width/2 -10;
    CGFloat interval =[[UIScreen mainScreen] bounds].size.height <=480 ? 20.0f : [[UIScreen mainScreen] bounds].size.height*0.14;

    self.scanLine.frame =CGRectMake((self.frame.size.width -width)/2, interval,width, 2);
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{   //测试11
//    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
//    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
//    CGRect aa =CGRectMake(0, 0, width, height);

    CGRect aa =CGRectMake(0, 0, 320, 500);
    rect =aa;
    UIColor *backColor =UI_ColorWithRGBA(0, 0, 0, 0.5);
    [backColor setFill];
    UIRectFill(rect);//绘制矩形
    
    CGRect rectScan =_scanBg.frame;

    rectScan.origin.x -=0.2;
    rectScan.origin.y -=0.2;
    rectScan.size.width +=0.4;
    rectScan.size.height +=0.4;
    
    UIColor *clearColor =[UIColor clearColor];
    [clearColor setFill];
    UIRectFill(rectScan);
    
}

#pragma mark - 动画处理
-(void)animateTheImage{
    
    _Height=60;
    CGRect bottomRect = CGRectMake(_scanBg.frame.origin.x, self.scanBg.frame.origin.y +_scanBg.frame.size.height, _scanBg.frame.size.width,2);
    
    [UIView beginAnimations:@"Lineflying" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(flyToTopAnimate)];
    [_scanLine setFrame:bottomRect];
    [UIView commitAnimations];
}

-(void)flyToTopAnimate{

    if(!_isAnimateContinue){
        return;
    }
    CGRect topRect = CGRectMake(_scanBg.frame.origin.x, self.scanBg.frame.origin.y-20, _scanBg.frame.size.width,2);
    
    [UIView beginAnimations:@"Lineflying" context:nil];
    [UIView setAnimationDuration:0.01f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(flyToMidAnimate)];
    [_scanLine setHidden:YES];
    [_scanLine setFrame:topRect];
    [UIView commitAnimations];
}

-(void)flyToMidAnimate{
    
    if(!_isAnimateContinue){
        return;
    }
    
    CGRect bottomRect = CGRectMake(_scanBg.frame.origin.x , self.scanBg.frame.origin.y-5, _scanBg.frame.size.width,10);
    CGFloat time=(60.f/(_scanBg.frame.size.height))*0.1;
    [UIView beginAnimations:@"Lineflying" context:nil];
    [UIView setAnimationDuration:time];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(flyToBottomAnimate)];
    [_scanLine setHidden:NO];
    [_scanLine setFrame:bottomRect];
    [UIView commitAnimations];
}

-(void)flyToBottomAnimate{

    if(!_isAnimateContinue){
        return;
    }
   
    CGRect bottomRect = CGRectMake(_scanBg.frame.origin.x , self.scanBg.frame.origin.y +_scanBg.frame.size.height-50, _scanBg.frame.size.width,50.0);
     CGFloat time=((_scanBg.frame.size.height-60.f)/(_scanBg.frame.size.height))*1.5;
    [UIView beginAnimations:@"Lineflying" context:nil];
    [UIView setAnimationDuration:time];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(flyMidTotop)];
    [_scanLine setHidden:NO];
    [_scanLine setFrame:bottomRect];
    [UIView commitAnimations];
}
-(void)flyMidTotop{
     [_scanLine setHidden:YES];
    [self performSelector:@selector(flyToTopAnimate) withObject:nil afterDelay:0.3];

}

-(void)stopAnimation{

    _isAnimateContinue =NO;
}

@end
