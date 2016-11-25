//
//  MMPlayView.h
//  AVExample
//
//  Created by detu on 16/6/28.
//  Copyright © 2016年 demoDu. All rights reserved.
//

#import <UIKit/UIKit.h>   

@interface MMPlayItems : UIView
@property (weak , nonatomic) UIButton  *playAndStopItem;
@property (weak , nonatomic) UILabel   *playTime;
@property (weak , nonatomic) UISlider  *playProgress;
@property (weak , nonatomic) UIProgressView *progressView;
@property (weak , nonatomic) CAShapeLayer *progresssLayer;
@end



typedef enum{
    playNone,
    playRuning,
    playStop,
    playError,
    playFinish
    
  
}playState;

typedef enum {
    playGravityResize,
    playGravityResizeAspect,
    playGravityResizeAspectFill
}playVideoGravity;

typedef void (^playBackBlock)(playState state ,NSString * url ,NSError *error);
typedef void (^playProgress)(double progress);
typedef void (^playProgressLoad)(double loadProgress);

@interface MMPlayView : UIView

+(MMPlayView *)playView;

@property (assign, nonatomic) BOOL isRemoveDefaultPlayItemsView; //default is NO;

@property (copy , nonatomic ,readonly) NSString *url;

@property (assign , nonatomic , readonly)  playState state;


- (void)playStateBlock:(playBackBlock )state
          progressBlock:(playProgress)progress
                   load:(playProgressLoad)load;


- (void)playerUrl:(NSString *)url gravity:(playVideoGravity)gravity;


- (void)play;
- (void)stop;

/**
 *  这个方法在内部已经处理 处理结果是内部监听了控制器的dealloc方法并会自动调用这个方法
 */
- (void)deallocSelf;



@end


