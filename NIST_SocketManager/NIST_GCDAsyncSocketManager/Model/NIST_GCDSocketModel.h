//
//  NIST_GCDSocketModel.h
//  NIST_SocketManager
//
//  Created by 范云飞 on 2017/10/19.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface NIST_GCDSocketModel : JSONModel

/**
 {
 "NIST_MESSAGE": {
 "MSG_VERSION": {
 "-desc": "协议版本号",
 "#text": "1.0"
 },
 "MSG_TYPE": {
 "-desc": "报文类型",
 "#text": "request"
 },
 "REQ_SYSTEM": {
 "-desc": "请求系统标识",
 "#text": "NIST-SVR"
 },
 "REQ_SYSTEM_CODE": {
 "-desc": "请求系统编号",
 "#text": "SVR001"
 },
 "SVR_SYSTEM": {
 "-desc": "服务系统标识",
 "#text": "NIST-SEC"
 },
 "SVR_SYSTEM_CODE": {
 "-desc": "服务系统编号",
 "#text": "SEC001"
 },
 "REQ_DATE": {
 "-desc": "发起请求日期",
 "#text": "20171012"
 },
 "REQ_TIME": {
 "-desc": "发起请求时间",
 "#text": "123059"
 },
 "REQ_DEALNO": {
 "-desc": "请求端流水号",
 "#text": "2017000001"
 },
 "SVR_CLASS": {
 "-desc": "请求服务类型",
 "#text": "SEC"
 },
 "SVR_CODE": {
 "-desc": "请求服务代码",
 "#text": "0001"
 },
 "MSG_BODY": {
 "KEY_VERSION": {
 "-desc": "密钥版本",
 "#text": "1.0.0.0"
 },
 "KEY_USAGE": {
 "-desc": "密钥用途",
 "#text": "S"
 },
 "ALGID": {
 "-desc": "算法标识",
 "#text": "SM2"
 },
 "KEY_BITS": {
 "-desc": "密钥长度",
 "#text": "256"
 }
 },
 "MAC": {
 "-desc": "报文认证码"
 }
 }
 }
 */

@property (copy, nonatomic) NSString <Optional> * MSG_VERSION;     /* 协议版本号 */
@property (copy, nonatomic) NSString <Optional> * MSG_TYPE;        /* 报文类型 */
@property (copy, nonatomic) NSString <Optional> * REQ_SYSTEM;      /* 请求系统标识 */
@property (copy, nonatomic) NSString <Optional> * REQ_SYSTEM_CODE; /* 请求系统编号 */
@property (copy, nonatomic) NSString <Optional> * SVR_SYSTEM;      /* 服务系统标识 */
@property (copy, nonatomic) NSString <Optional> * SVR_SYSTEM_CODE; /* 服务系统编号 */
@property (copy, nonatomic) NSString <Optional> * REQ_DATE;        /* 发起请求日期 */
@property (copy, nonatomic) NSString <Optional> * REQ_TIME;        /* 发起请求时间 */
@property (copy, nonatomic) NSString <Optional> * REQ_DEALNO;      /* 请求端流水号 */
@property (copy, nonatomic) NSString <Optional> * SVR_CLASS;       /* 请求服务类型 */
@property (copy, nonatomic) NSString <Optional> * SVR_CODE;        /* 请求服务代码 */
@property (strong, nonatomic) NSDictionary <Optional> * MSG_BODY;  /* 请求体 */
@property (copy, nonatomic) NSString <Optional> * MAC;             /* 报文认证码 */

/**
 *  使用该方法对body对象进行两次转JSONString处理，如无body，请使用toJSONString方法直接转JSONString
 */
- (NSString *)socketModelToJSONString;

+ (NSDictionary *)requestDict;
@end
