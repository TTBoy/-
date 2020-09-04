//
//  AppDelegate.m
//  ScaningTest
//
//  Created by LTC on 2020/9/2.
//  Copyright © 2020 EDZ. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
     
    //1.创建Tab导航条控制器
    UITabBarController *tabControl = [[UITabBarController alloc] init];
    tabControl.tabBar.barStyle = UIBarStyleBlack;
     
    //2.创建相应的子控制器（viewcontroller）
    ViewController *control = [[ViewController alloc] init];
    control.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"first" image:[UIImage imageNamed:@"icon_contact_normal"] selectedImage:[UIImage imageNamed:@"icon_contact_normal"]];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController: control];
     
     
    //将Tab导航条控制器设为window根控制器
    self.window.rootViewController = nav;
    return YES;
}



@end
