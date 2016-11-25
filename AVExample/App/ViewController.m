//
//  ViewController.m
//  AVExample
//
//  Created by detu on 16/6/28.
//  Copyright © 2016年 demoDu. All rights reserved.
//
#import "ViewController.h"
#import "playViewController.h"
@interface ViewController () <UITableViewDelegate , UITableViewDataSource>
@property (weak , nonatomic)UITableView *videotableView;
@property (strong , nonatomic) NSArray *urls;
@end
@implementation ViewController
-(NSArray *)urls{
    if (!_urls) {
        self.urls = @[@"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4",
                      @"http://baobab.wdjcdn.com/1456117847747a_x264.mp4",
                      @"http://baobab.wdjcdn.com/14525705791193.mp4",
                      @"http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4",
                      @"http://baobab.wdjcdn.com/1455968234865481297704.mp4",
                      @"http://baobab.wdjcdn.com/1455782903700jy.mp4",
                      @"http://baobab.wdjcdn.com/14564977406580.mp4",
                      @"http://baobab.wdjcdn.com/1456316686552The.mp4",
                      @"http://baobab.wdjcdn.com/1456480115661mtl.mp4",
                      @"http://baobab.wdjcdn.com/1456665467509qingshu.mp4",
                      @"http://baobab.wdjcdn.com/1455614108256t(2).mp4",
                      @"http://baobab.wdjcdn.com/1456317490140jiyiyuetai_x264.mp4",
                      @"http://baobab.wdjcdn.com/1455888619273255747085_x264.mp4",
                      @"http://baobab.wdjcdn.com/1456734464766B(13).mp4",
                      @"http://baobab.wdjcdn.com/1456653443902B.mp4",
                      @"http://baobab.cdn.wandoujia.com/14468618701471.mp4",
                      @"http://bvideo.spriteapp.cn/video/2015/0902/55e69edf2d7a5_wpd.mp4",
                      @"http://media.qicdn.detu.com/@/17301281-9356-8DF4-8425-A934F01236889/2016-06-24/576d19eea1695-2048x1024.mp4"];
    }
    return _urls;
}
-(UITableView *)videotableView{
    if (!_videotableView) {
        UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate   = self;
        [self.view addSubview:_videotableView = tableView];
    }
    return _videotableView;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.urls.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    NSString *text  = self.urls[indexPath.row];
    cell.textLabel.text = text.lastPathComponent;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    playViewController *pc = [[playViewController alloc] init];
    pc.url = self.urls[indexPath.row];
    [self.navigationController pushViewController:pc animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self videotableView];
}
@end
