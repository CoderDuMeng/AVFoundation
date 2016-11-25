//
//  MMPlayView.m
//  AVExample
//
//  Created by detu on 16/6/28.
//  Copyright © 2016年 demoDu. All rights reserved.
//

#import "MMPlayView.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

static int lineWidth = 3;

#define MMPlaySrcImageFileName(fileName)\
[@"mm.bundle" stringByAppendingPathComponent:fileName]


@implementation MMPlayItems

-(UIButton *)playAndStopItem{
    if (!_playAndStopItem) {
        UIButton *playAndStopItem = [[UIButton alloc] init];
        [playAndStopItem setImage:[UIImage imageNamed:MMPlaySrcImageFileName(@"kr-video-player-play")] forState:UIControlStateNormal];
        [playAndStopItem setImage:[UIImage imageNamed:MMPlaySrcImageFileName(@"kr-video-player-pause")] forState:UIControlStateSelected];
        [self addSubview:_playAndStopItem = playAndStopItem];
    }
    return _playAndStopItem;
}

-(UILabel *)playTime{
    if (!_playTime) {
        UILabel *playTime = [[UILabel alloc] init];
        playTime.textColor  = [UIColor whiteColor];
        playTime.font     = [UIFont systemFontOfSize:11];
        playTime.adjustsFontSizeToFitWidth = YES;
        playTime.textAlignment = NSTextAlignmentCenter;
        playTime.text = @"00:00/00:00";
        [self addSubview:_playTime = playTime];
    }
    return _playTime;
}

-(UISlider *)playProgress{
    if (!_playProgress) {
        UISlider *playProgress = [[UISlider alloc] init];
        [playProgress setThumbImage:[UIImage imageNamed:MMPlaySrcImageFileName(@"detail_player_now")] forState:UIControlStateNormal];
        playProgress.maximumValue = 1;//音乐总共时长
        playProgress.minimumTrackTintColor = [UIColor whiteColor];
        playProgress.maximumTrackTintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.6];
        [self addSubview:_playProgress = playProgress];
        
    }
    return _playProgress;
}

-(CAShapeLayer *)progresssLayer{
    if (!_progresssLayer) {
        CAShapeLayer *progressLayer = [[CAShapeLayer alloc] init];
        progressLayer.strokeColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3].CGColor;
        progressLayer.lineCap = kCALineCapButt;
        progressLayer.strokeStart = 0;
        progressLayer.strokeEnd = 0;
        progressLayer.lineWidth = lineWidth;
        [self.playProgress.layer addSublayer:_progresssLayer = progressLayer];
    }
    return _progresssLayer;
}

- (UIBezierPath *)path{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(self.playProgress.bounds.size.width, 0)];
    return path;
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGSize pswh = self.playAndStopItem.currentImage.size;
    CGFloat psx = 10;
    CGFloat psy = 0;
    self.playAndStopItem.frame = CGRectMake(psx, psy, pswh.width + 10, pswh.height + 10);
    CGFloat ppx = CGRectGetMaxX(self.playAndStopItem.frame) + 10;
    CGFloat ppY = 5;
    CGFloat proH = 13;
    CGFloat PPW = self.frame.size.width - (ppx + 20);
    self.playProgress.frame = CGRectMake(ppx, ppY, PPW,proH);
    self.progresssLayer.frame = CGRectMake(0,proH / 2  + lineWidth / 2, PPW, lineWidth);
    self.progresssLayer.path = [self path].CGPath;
    CGFloat ptw = 80;
    self.playTime.frame = CGRectMake(ppx, CGRectGetMaxY(self.playProgress.frame)+5, ptw, 13);
    
    
}


@end

@interface MMPlayView ()
{
    
    playState _state;
    
}

@property (strong , nonatomic)  AVPlayerItem   *playerItem;
@property (strong , nonatomic)  AVPlayer       *player;
@property (weak   , nonatomic)  AVPlayerLayer  *playerLayer;
@property (strong , nonatomic)  NSTimer        *timer;
@property (assign , nonatomic)  CGRect         downFrame;
@property (weak   , nonatomic)  MMPlayItems    *playItems;
@property (weak   , nonatomic)  UIActivityIndicatorView *indicatorView;

@property (copy   ,nonatomic)  playBackBlock backBlock;
@property (copy   ,nonatomic)  playProgress  progress;
@property (copy   ,nonatomic)  playProgressLoad load;


@end
@implementation MMPlayView

- (NSString *)cureeTime:(CMTime )time{
    NSInteger progressMinute  = (NSInteger)CMTimeGetSeconds(time) / 60;
    NSInteger progressSecond = (NSInteger)CMTimeGetSeconds(time) % 60;
    return  [NSString stringWithFormat:@"%02zd:%02zd", progressMinute, progressSecond];
}
- (NSString *)totalTime{
    AVPlayerItem *playItem = self.playerItem;
    NSInteger durMin  = (NSInteger)playItem.duration.value / playItem.duration.timescale / 60;
    NSInteger durSec  = (NSInteger)playItem.duration.value / playItem.duration.timescale % 60;
    return [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
    
}

+(MMPlayView *)playView{
    static MMPlayView *_playView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _playView = [[MMPlayView alloc] init];
    });
    return _playView;
}
-(UIActivityIndicatorView *)indicatorView{
    if (!_indicatorView) {
        UIActivityIndicatorView * indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:_indicatorView = indicatorView];
    }
    return _indicatorView;
}
-(MMPlayItems *)playItems{
    if (self.isRemoveDefaultPlayItemsView) {
        return nil;
    }
    if (!_playItems) {
        MMPlayItems *playItems = [[MMPlayItems alloc] init];
        playItems.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
        [self addSubview:_playItems = playItems];
        [self.playItems.playAndStopItem addTarget:self action:@selector(playAndStop) forControlEvents:UIControlEventTouchUpInside];
        [self.playItems.playProgress addTarget:self action:@selector(playDown) forControlEvents:UIControlEventTouchDown];
        [self.playItems.playProgress addTarget:self action:@selector(playProgress) forControlEvents:UIControlEventValueChanged];
        [self.playItems.playProgress addTarget:self action:@selector(playProgressEnd) forControlEvents:UIControlEventTouchCancel | UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    }
    return _playItems;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.9];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)]];
    }
    return self;
}
-(void)willMoveToSuperview:(UIView *)newSuperview{
    if (newSuperview) {
        
        self.downFrame = self.frame;
    }
    
    [super willMoveToSuperview:newSuperview];
    
}

-(void)setState:(playState)state{
    _state = state;
    
    !_backBlock ? :_backBlock(state,_url,self.playerItem.error);
    
}
-(playState)state{
    return _state;
}
- (void)addTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(computeTime) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop]addTimer:self.timer forMode:NSDefaultRunLoopMode];
    
}

- (void)playerUrl:(NSString *)url{
    
    NSAssert(url.length || url!=nil,@"播放器失败 url 不能为nil");
    
    _url = [url copy];
    
    [self removeObserver];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:_url]];
    
    if (self.player) {
        
        [self.player replaceCurrentItemWithPlayerItem:nil];
        
    }
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    if (self.playerLayer) {
        
        self.playerLayer.player = self.player;
        
    }else{
        
        self.playerLayer =  [AVPlayerLayer playerLayerWithPlayer:self.player];
        
        [self.layer addSublayer:self.playerLayer];
        
    }
    
    [self addObserver];
    
    [self layout];
    
    [self play];
    
    [self.indicatorView startAnimating];
}
-(void)playerUrl:(NSString *)url gravity:(playVideoGravity)gravity{
    [self playerUrl:url];
    switch (gravity) {
        case playGravityResize:
            self.playerLayer.videoGravity = AVLayerVideoGravityResize;
            break;
        case playGravityResizeAspect:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case playGravityResizeAspectFill:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
        default:
            break;
    }
    
}

- (void)addObserver{
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationDidChangeNotification) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}


- (void)removeObserver{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        self.playerItem = nil;
        
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}
- (void)deviceOrientationDidChangeNotification{
    switch ([UIDevice currentDevice].orientation) {
        case UIInterfaceOrientationPortrait:
            self.frame = self.downFrame;
            [self layout];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            self.frame = self.superview.bounds;
            [self layout];
            break;
        default:
            break;
    }
    
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (object==self.playerItem) {
        if ([keyPath isEqualToString:@"status"]) {
            switch (self.playerItem.status) {
                case  AVPlayerItemStatusFailed:
                    self.state = playError;
                    break;
                case AVPlayerItemStatusUnknown:
                    self.state = playNone;
                    break;
                case AVPlayerItemStatusReadyToPlay:
                    self.state = playRuning;
                    [self.indicatorView stopAnimating];
                    [self afterDelay];
                    break;
                default:
                    break;
            }
            
        }
        
        //计算缓存的进度
        if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            if (self.playItems.progresssLayer.strokeEnd<1) {
                NSValue *value = self.playerItem.loadedTimeRanges.lastObject; //加载的范围
                CMTimeRange timeRange = [value CMTimeRangeValue]; //转换CMTiemRange
                CGFloat timeRangeStart = CMTimeGetSeconds(timeRange.start);
                CGFloat timeRangedurtaion = CMTimeGetSeconds(timeRange.duration); //缓冲的时间
                //缓冲完成的时间 / 总共的时间 = 缓冲的比例
                
                CGFloat loadedProgress =  (timeRangeStart + timeRangedurtaion) / CMTimeGetSeconds(self.playerItem.duration);
                if (self.playItems.progresssLayer.strokeEnd < loadedProgress) {
                    
                    self.playItems.progresssLayer.strokeEnd = loadedProgress;
                    
                }
                !self.load ? :self.load(loadedProgress);
                
            }
            
        }
    }
}
- (void)computeTime{
    if (_playerItem.duration.timescale!=0) {
        double playValue = CMTimeGetSeconds([_playerItem currentTime]) / (_playerItem.duration.value / _playerItem.duration.timescale);
        
        [self.playItems.playProgress setValue:playValue animated:YES];
        !self.progress ? : self.progress(playValue);
        NSString *toltiem = [self totalTime];
        NSString *durtime =  [self cureeTime:[_player currentTime]];
        
        self.playItems.playTime.text    = [NSString stringWithFormat:@"%@/%@",durtime,toltiem];
        
        if (self.playItems.playProgress.value>=1) {
            [self.timer invalidate];
            
            self.timer = nil;
            
            self.state = playFinish;
            
            self.playItems.playAndStopItem.selected = NO;
            
            [self.playItems.playProgress setValue:0 animated:YES];
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            
            self.playItems.hidden = NO;
            
            
        }
        
    }
    
}
- (void)playAndStop{
    switch (self.state) {
        case playRuning:
        {
            [self stop];
        }
            break;
        case playStop:
        {
            [self play];
        }
            break;
        case playFinish:
        case playNone:
        {
            [self playerUrl:_url];
        }
        default:
            break;
    }
}
#pragma mark - progress down
- (void)playDown{
    [self.timer setFireDate:[NSDate distantFuture]];
    //拖动的取消延时
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
}
//正在拖动
- (void)playProgress{
    if (!_playerItem.duration.value) {
        return;
    }
    NSInteger dragedSeconds  = floorf((_playerItem.duration.value / _playerItem.duration.timescale) * self.playItems.playProgress.value);
    NSString *currentTime = [self cureeTime:CMTimeMake(dragedSeconds, 1)];
    NSString *totalTime  =  [self totalTime];
    self.playItems.playTime.text = [NSString stringWithFormat:@"%@/%@",currentTime,totalTime];
    
}
//拖动完毕
- (void)playProgressEnd{
    //计算出拖动的当前秒数
    CGFloat total = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
    
    NSInteger dragedSeconds = floorf(total * self.playItems.playProgress.value);
    
    //转换成CMTime才能给player来控制播放进度
    
    CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
    __weak typeof(self)_self  = self;
    [self.player seekToTime:dragedCMTime completionHandler:^(BOOL finished) {
        if (finished) {
            if (_self.state==playStop || _state==playFinish) {
                [_self play];
            }
        }else{//如果没有完毕
            [_self.indicatorView startAnimating];
        }
    }];
    [self.timer setFireDate:[NSDate date]];
    [self afterDelay];
}


- (void)tapClick{
    
    [UIView animateWithDuration:2 animations:^{
        self.playItems.hidden = NO;
    }];
    [self afterDelay];
}
- (void)afterDelay{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self performSelector:@selector(hiddenPlayItem) withObject:nil afterDelay:10];
}

- (void)hiddenPlayItem{
    
    [UIView animateWithDuration:2 animations:^{
        self.playItems.hidden = YES;
        
    }];
    
}

#pragma makr - play
- (void)play{
    
    if (!self.player) {
        return;
    }
    if (!self.timer) {
        [self addTimer];
    }
    if (self.state!=playRuning) {
        [self.player play];
        self.state = playRuning;
        if (self.playItems) {
            self.playItems.playAndStopItem.selected = YES;
        }
    }
    
}
- (void)stop{
    if (!self.player) {
        return;
    }    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.state!=playStop) {
        [self.player pause];
        self.state = playStop;
        if (self.playItems) {
            self.playItems.playAndStopItem.selected = NO;
        }
        
    }
    
}

#pragma makr play - end

-(void)playStateBlock:(playBackBlock)state
        progressBlock:(playProgress)progress
                 load:(playProgressLoad)load{
    self.backBlock = state;
    self.progress  = progress;
    self.load      = load;
}
-(void)deallocSelf{
    [self remove];
}
-(void)dealloc{
    [self deallocSelf];
}
- (void)remove{
    [self removeObserver];
    if (self.state==playRuning) {
        [self.player pause];
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        
        self.playerItem = nil;
        self.player = nil;
        if (self.playItems.superview) {
            [self.playItems removeFromSuperview];
        }
        
        if (self.superview) {
            [self removeFromSuperview];
            if (self.superview) {
                [self remove];
            }
        }
        
        self.state = playNone;
        
    }
}
- (void)layout{
    [self setNeedsDisplay];
    [self setNeedsLayout];
    [self layoutSubviews];
    [self.playItems layoutSubviews];
    
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    self.playerLayer.frame = self.layer.bounds;
    CGFloat whb = 40;
    self.playItems.frame = CGRectMake(0, height - whb, width, whb);
    self.indicatorView.center = CGPointMake(width / 2, height / 2);
    
}
@end

@interface NSObject (play)

@end

@implementation NSObject (play)
+(void)exchangeImplementations:(SEL)method exchangem:(SEL)exchangem{
    Method adddealloc = class_getInstanceMethod([self class],method);
    Method playdealloc = class_getInstanceMethod([self class],exchangem);
    method_exchangeImplementations(adddealloc, playdealloc);
    
}
+(SEL)dealloc{
    return NSSelectorFromString(@"dealloc");
}
@end
@interface UIView (play)
@end
@implementation UIView (play)
+(void)load{
    [self exchangeImplementations: [self dealloc]
                        exchangem:@selector(playdealloc)];
}
- (void)playdealloc{
    [self playdealloc:self];
}

- (void)playdealloc:(UIView *)view{
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:[MMPlayView class]]) {
            MMPlayView *sub = (MMPlayView * )subView;
            [sub deallocSelf];
            break;
        }
    }
}
@end
@interface UIViewController (play)
@end
@implementation UIViewController (play)
+(void)load{
    [self exchangeImplementations:[self dealloc]
                        exchangem:@selector(playdealloc)];
}
- (void)playdealloc{
    [self.view playdealloc:self.view];
}
@end
