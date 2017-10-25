//
//  NIST_GCDConnectConfig.h
//  NIST_SocketManager
//
//  Created by 范云飞 on 2017/10/19.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIST_GCDConnectConfig : NSObject

@property (nonatomic, strong) NSString * token;/* socket配置 */

@property (nonatomic, strong) NSString * channels;/* 建连时的通道 */

@property (nonatomic, strong) NSString * currentChannel;/* 当前使用的通道 */

@property (nonatomic, strong) NSString * host;/* 通信地址 */

@property (nonatomic, assign) uint16_t port;/* 通信端口号 */

@property (nonatomic, assign) NSInteger socketVersion;/* 通信协议版本号 */

@end
