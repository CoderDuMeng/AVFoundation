
//
//  playViewController.m
//  AVExample
//
//  Created by detu on 16/6/30.
//  Copyright © 2016年 demoDu. All rights reserved.
//

#import "playViewController.h"
#import "MMPlayView.h"

@interface playViewController ()
@property (weak , nonatomic) MMPlayView *p ;
@end

@implementation playViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor =[UIColor whiteColor];
    
    MMPlayView *p = [MMPlayView playView];
    p.frame = CGRectMake(0,64, self.view.frame.size.width, 250);
    [self.view addSubview:p];
    [p playerUrl:self.url gravity:playGravityResizeAspect];
    
    [p playStateBlock:^(playState state, NSString *url, NSError *error) {
        
        NSLog(@"%zi  %@  %@",state,url , error);
    } progressBlock:nil load:^(double loadProgress) {
    }];
    
 
}












@end
