//
//  ViewController.m
//  NIST_SocketManager
//
//  Created by 范云飞 on 2017/10/19.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "ViewController.h"

#import "NIST_GCDAsyncSocketCommunicationManager.h"
#import "NIST_GCDConnectConfig.h"

#define kDefaultChannel @"dkf"

@interface ViewController ()

@property (nonatomic, strong) NIST_GCDConnectConfig * connectConfig;

@end

@implementation ViewController

#pragma mark - Life
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    /* 1. 使用默认的连接环境 */
//    [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithToken:@"f14c4e6f6c89335ca5909031d1a6efa9" channel:kDefaultChannel];
    
    /* 2.自定义配置连接环境 */
    [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithConfig:self.connectConfig];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 30)];
    button.backgroundColor = [UIColor blackColor];
    [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Request
- (void)click:(UIButton *)sender
{
    /* 判断前一次请求是否超时，如果超时socket会自动断开，进行请求操作时 会重新连接*/
    if ([NIST_GCDAsyncSocketCommunicationManager sharedInstance].timeout)
    {
        [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithConfig:self.connectConfig];
    }
    
    /* 请求参数 */
    NSDictionary *requestBody = @{
                                  @"KEY_VERSION": @"1.0.0.0",
                                  @"KEY_USAGE":@"S",
                                  @"ALGID": @"SM2",
                                  @"KEY_BITS": @"256"
                                  };
    [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:NIST_GCDRequestType_ConnectionAuthAppraisal requestBody:requestBody completion:^(NSError * _Nullable error, id  _Nullable data) {
        /* 回调处理 */
        if (error)
        {
            NSLog(@"error:%@",error);
        }
        else
        {
            NSLog(@"data:%@",data);
        }
    }];
}

#pragma mark - Lazy
/* 配置socket连接 */
- (NIST_GCDConnectConfig *)connectConfig
{
    if (!_connectConfig)
    {
        _connectConfig = [[NIST_GCDConnectConfig alloc] init];
        _connectConfig.channels = kDefaultChannel;
        _connectConfig.currentChannel = kDefaultChannel;
        _connectConfig.host = @"192.168.10.187";
        _connectConfig.port = 7070;
        _connectConfig.socketVersion = 5;
    }
    _connectConfig.token = @"f14c4e6f6c89335ca5909031d1a6efa9";
    
    return _connectConfig;
}

@end
