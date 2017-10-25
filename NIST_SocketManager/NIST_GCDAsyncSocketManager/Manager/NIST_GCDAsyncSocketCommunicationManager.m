//
//  NIST_GCDAsyncSocketCommunicationManager.m
//  NIST_SocketManager
//
//  Created by 范云飞 on 2017/10/19.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIST_GCDAsyncSocketCommunicationManager.h"

/* 基于GCD的socket通信框架 */
#import "GCDAsyncSocket.h"

/* token(设备的唯一标识)保存类 */
#import "NIST_GCDKeyChainManager.h"

/* 负责和socket通信管理 */
#import "NIST_GCDAsyncSocketManager.h"

/* socket请求报文模型 */
#import "NIST_GCDSocketModel.h"

/* 网络连接的监听 */
#import "AFNetworkReachabilityManager.h"

/* 错误码管理 */
#import "NIST_GCDErrorManager.h"

/* XML和NSDictionary 相互转化工具 */
#import "XMLDictionary.h"

/* XML转NSDictionary */
#import "XMLReader.h"

/* NSDictionary转XML字符串 */
#import "XMLWriter.h"

/**
 *  默认通信协议版本号
 */
static NSUInteger PROTOCOL_VERSION = 7;

@interface NIST_GCDAsyncSocketCommunicationManager ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) NSString * socketAuthAppraisalChannel;/* socket验证通道，支持多通道 */
@property (nonatomic, strong) NSMutableDictionary * requestsMap;
@property (nonatomic, strong) NIST_GCDAsyncSocketManager * socketManager;
@property (nonatomic, assign) NSTimeInterval interval; /* 服务器与本地时间的差值 */
@property (nonatomic, strong, nonnull) NIST_GCDConnectConfig * connectConfig;

@end

@implementation NIST_GCDAsyncSocketCommunicationManager
@dynamic connectStatus;

#pragma mark - init

+ (NIST_GCDAsyncSocketCommunicationManager *)sharedInstance
{
    static NIST_GCDAsyncSocketCommunicationManager * instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    self.socketManager = [NIST_GCDAsyncSocketManager sharedInstance];
    self.requestsMap = [NSMutableDictionary dictionary];
    [self startMonitoringNetwork];
    return self;
}

#pragma mark - socket actions

- (void)createSocketWithConfig:(nonnull NIST_GCDConnectConfig *)config
{
    if (!config.token.length || !config.channels.length || !config.host.length) {
        return;
    }
    
    self.connectConfig = config;
    self.socketAuthAppraisalChannel = config.channels;
    [NIST_GCDKeyChainManager sharedInstance].token = config.token;
    [self.socketManager changeHost:config.host port:config.port];
    PROTOCOL_VERSION = config.socketVersion;
    
    [self.socketManager connectSocketWithDelegate:self];
}

- (void)createSocketWithToken:(nonnull NSString *)token channel:(nonnull NSString *)channel
{
    if (!token || !channel)
    {
        return;
    }
    
    self.socketAuthAppraisalChannel = channel;
    [NIST_GCDKeyChainManager sharedInstance].token = token;
    [self.socketManager changeHost:@"online socket address" port:7070];
    
    [self.socketManager connectSocketWithDelegate:self];
}

- (void)disconnectSocket
{
    [self.socketManager disconnectSocket];
}

- (void)socketWriteDataWithRequestType:(NIST_GCDRequestType)type
                           requestBody:(nonnull NSDictionary *)body
                            completion:(nullable SocketDidReadBlock)callback
{
    if (self.socketManager.connectStatus == -1)
    {
        NSLog(@"socket 未连通");
        if (callback)
        {
            callback([NIST_GCDErrorManager errorWithErrorCode:3],
                     nil);
        }
        return;
    }
    
//    NSString * blockRequestID = [self createRequestID];
    NSString * blockRequestID = @"2017000001";
    if (callback)
    {
        [self.requestsMap setObject:callback forKey:blockRequestID];
    }
    
    NIST_GCDSocketModel * socketModel = [[NIST_GCDSocketModel alloc]init];
    socketModel.MSG_VERSION = @"1.0";
    socketModel.MSG_TYPE = @"request";
    socketModel.REQ_SYSTEM = @"NIST-SVR";
    socketModel.REQ_SYSTEM_CODE = @"SVR001";
    socketModel.SVR_SYSTEM = @"NIST-SEC";
    socketModel.SVR_SYSTEM_CODE = @"SEC001";
    socketModel.REQ_DATE = @"20171012";
    socketModel.REQ_TIME =@"123059";
    socketModel.REQ_DEALNO = @"2017000001";
    socketModel.SVR_CLASS = @"SEC";
    socketModel.SVR_CODE = @"0001";
    socketModel.MSG_BODY = body;
    socketModel.MAC = @"报文认证码";
    
    /* 第一种NSDictionary 转 XML字符串的方法 */
    NSString * requestBody = [NSDictionary convertDictionaryToXML:[socketModel toDictionary] withStartElement:@"NIST_MESSAGE" isFirstElement:YES];

    /* 第二种NSDictionary 转XML字符串的方法 */
//    NSDictionary * dict = @{
//                            @"NIST_MESSAGE": @{
//                                    @"MSG_VERSION": @"1.0",
//                                    @"MSG_TYPE": @"request",
//                                    @"REQ_SYSTEM": @"NIST-SVR",
//                                    @"REQ_SYSTEM_CODE":  @"SVR001",
//                                    @"SVR_SYSTEM": @"NIST-SEC",
//                                    @"SVR_SYSTEM_CODE": @"SEC001",
//                                    @"REQ_DATE": @"20171012",
//                                    @"REQ_TIME": @"123059",
//                                    @"REQ_DEALNO": @"2017000001",
//                                    @"SVR_CLASS": @"SEC",
//                                    @"SVR_CODE": @"0001",
//                                    @"MSG_BODY": body,
//                                    @"MAC": @"报文认证码"
//                                    }
//                            };
//    
//    NSString * requestBody = [XMLWriter XMLStringFromDictionary:dict withHeader:YES];
    NSLog(@"writeDataXML:%@",requestBody);
    [self.socketManager socketWriteData:requestBody];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"socket:%p didConnectToHost:%@ port:%hu", socket, host, port);
    /* 数据成功回调时，置为NO，表示socket连接 */
    [NIST_GCDAsyncSocketCommunicationManager sharedInstance].timeout = NO;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)err
{
    NSLog(@"socketDidDisconnect:%p withError: %@", socket, err);
    NSLog(@"socket 断开连接");
    [NIST_GCDAsyncSocketCommunicationManager sharedInstance].timeout = YES;/* 响应超时断开 */
    self.socketManager.connectStatus = -1;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"readData:%@",data);

    NSString * string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"string:%@",string);
    NSError * error = nil;
    NSLog(@"ReadDataJSON:%@",[XMLReader dictionaryForXMLString:string error:&error]);
    NSDictionary * dict = [XMLReader dictionaryForXMLString:string error:&error];
    NSString * jsonString = [XMLReader JSONStringFromDictionary:dict];
    if (error)
    {
        [self.socketManager socketBeginReadData];
        NSLog(@"json 解析错误: --- error %@", error);
        return;
    }
    
    /* 下面的4个变量，用来提取服务器返回的数据中的关键信息 */
    NSInteger requestType = 2;
    NSInteger errorCode = 0;
    NSDictionary * resp_time_Dict = [dict objectForKey:@"RESP_TIME"];
    NSDictionary * body = @{};
    
    /* 从缓存中取出回调的block(根据请求的时间戳为Key) */
//    SocketDidReadBlock didReadBlock = self.requestsMap[requestID];
    SocketDidReadBlock didReadBlock = self.requestsMap[@"2017000001"];
    
    if (errorCode != 0)
    {
        NSError * error = [NIST_GCDErrorManager errorWithErrorCode:errorCode];
        if (requestType == NIST_GCDRequestType_ConnectionAuthAppraisal &&
            [self.socketDelegate respondsToSelector:@selector(connectionAuthAppraisalFailedWithErorr:)])
        {
            [self.socketDelegate connectionAuthAppraisalFailedWithErorr:[NIST_GCDErrorManager errorWithErrorCode:1005]];
        }
        if (didReadBlock)
        {
            didReadBlock(error, jsonString);
        }
        return;
    }
    
    switch (requestType)
    {
        case NIST_GCDRequestType_ConnectionAuthAppraisal:
        {
            [self didConnectionAuthAppraisal];
            
            NSDictionary * systemTimeDic = [resp_time_Dict mutableCopy];
            [self differenceOfLocalTimeAndServerTime:[systemTimeDic[@"text"] longLongValue]];
        }
            break;
        case NIST_GCDRequestType_Beat:
        {
            [self.socketManager resetBeatCount];
        }
            break;
        case NIST_GCDRequestType_GetConversationsList:
        {
            if (didReadBlock)
            {
                didReadBlock(nil, jsonString);
            }
        }
            break;
        default:
        {
            if ([self.socketDelegate respondsToSelector:@selector(socketReadedData:forType:)])
            {
                [self.socketDelegate socketReadedData:body forType:requestType];
            }
        }
            break;
    }
    
    [self.socketManager socketBeginReadData];
}

#pragma mark - private method
- (NSString *)createRequestID
{
    NSInteger timeInterval = [NSDate date].timeIntervalSince1970 * 1000000;
    NSString * randomRequestID = [NSString stringWithFormat:@"%ld%d", timeInterval, arc4random() % 100000];
    return randomRequestID;
}

- (void)differenceOfLocalTimeAndServerTime:(long long)serverTime
{
    if (serverTime == 0)
    {
        self.interval = 0;
        return;
    }
    
    NSTimeInterval localTimeInterval = [NSDate date].timeIntervalSince1970 * 1000;
    self.interval = serverTime - localTimeInterval;
}

- (long long)simulateServerCreateTime
{
    NSTimeInterval localTimeInterval = [NSDate date].timeIntervalSince1970 * 1000;
    localTimeInterval += 3600 * 8;
    localTimeInterval += self.interval;
    return localTimeInterval;
}

- (void)didConnectionAuthAppraisal
{
    if ([self.socketDelegate respondsToSelector:@selector(socketDidConnect)])
    {
        [self.socketDelegate socketDidConnect];
    }

    NIST_GCDSocketModel * socketModel = [[NIST_GCDSocketModel alloc]init];
    socketModel.MSG_VERSION = @"1.0";
    socketModel.MSG_TYPE = @"request";
    socketModel.REQ_SYSTEM = @"NIST-SVR";
    socketModel.REQ_SYSTEM_CODE = @"SVR001";
    socketModel.SVR_SYSTEM = @"NIST-SEC";
    socketModel.SVR_SYSTEM_CODE = @"SEC001";
    socketModel.REQ_DATE = @"20171012";
    socketModel.REQ_TIME =@"123059";
    socketModel.REQ_DEALNO = @"2017000001";
    socketModel.SVR_CLASS = @"SEC";
    socketModel.SVR_CODE = @"0001";
    socketModel.MSG_BODY = @{
                             @"KEY_VERSION": @"1.0.0.0",
                             @"KEY_USAGE":@"S",
                             @"ALGID": @"SM2",
                             @"KEY_BITS": @"256"
                             };
    socketModel.MAC = @"报文认证码";
    
    /* 转化为xml字符串 */
    NSString * requestBody = [XMLWriter XMLStringFromDictionary:[socketModel toDictionary] withStartElement:@"NIST_MESSAGE" isFirstElement:YES];
    
    [self.socketManager socketDidConnectBeginSendBeat:requestBody];
}

- (void)startMonitoringNetwork
{
    AFNetworkReachabilityManager * networkManager = [AFNetworkReachabilityManager sharedManager];
    [networkManager startMonitoring];
    __weak __typeof(&*self) weakSelf = self;
    [networkManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         switch (status)
         {
             case AFNetworkReachabilityStatusNotReachable:
                 if (weakSelf.socketManager.connectStatus != -1)
                 {
                     [self disconnectSocket];
                 }
                 break;
             case AFNetworkReachabilityStatusReachableViaWWAN:
             case AFNetworkReachabilityStatusReachableViaWiFi:
                 if (weakSelf.socketManager.connectStatus == -1)
                 {
                     [self createSocketWithToken:[NIST_GCDKeyChainManager sharedInstance].token
                                         channel:self.socketAuthAppraisalChannel];
                 }
                 break;
             default:
                 break;
         }
     }];
}

#pragma mark - getter
- (NIST_GCDSocketConnectStatus)connectStatus
{
    return self.socketManager.connectStatus;
}

@end
