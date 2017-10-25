//
//  NIST_GCDSocketModel.m
//  NIST_SocketManager
//
//  Created by 范云飞 on 2017/10/19.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_GCDSocketModel.h"

@implementation NIST_GCDSocketModel

- (NSString *)socketModelToJSONString
{
    NSAssert(self.MSG_BODY != nil, @"Argument must be non-nil");
    if (![self.MSG_BODY isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }
    NSString * bodyString = [self dictionnaryObjectToString:self.MSG_BODY];
    self.MSG_BODY = (NSDictionary *)bodyString;
    NSString * jsonString = [self toJSONString];
    jsonString = [jsonString stringByAppendingString:@"\r\n"];
    return jsonString;
}

- (NSString *)dictionnaryObjectToString:(NSDictionary *)object
{
    NSError * error = nil;
    NSData * stringData =
    [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    if (error)
    {
        return nil;
    }
    
    NSString * jsonString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    /* 字典对象用系统JSON序列化之后的data，转UTF-8后的jsonString里面会包含"\n"及" "，需要替换掉 */
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return jsonString;
}

+ (NSDictionary *)requestDict
{
    NSDictionary * dict = @{
                            @"NIST_MESSAGE": @{
                                @"MSG_VERSION": @{
                                    @"-desc": @"协议版本号",
                                    @"#text": @"1.0"
                                },
                                @"MSG_TYPE": @{
                                    @"-desc": @"报文类型",
                                    @"#text": @"request"
                                },
                                @"REQ_SYSTEM": @{
                                    @"-desc": @"请求系统标识",
                                    @"#text": @"NIST-SVR"
                                },
                                @"REQ_SYSTEM_CODE": @{
                                    @"-desc": @"请求系统编号",
                                    @"#text": @"SVR001"
                                },
                                @"SVR_SYSTEM": @{
                                    @"-desc": @"服务系统标识",
                                    @"#text": @"NIST-SEC"
                                },
                                @"SVR_SYSTEM_CODE": @{
                                    @"-desc": @"服务系统编号",
                                    @"#text": @"SEC001"
                                },
                                @"REQ_DATE": @{
                                    @"-desc": @"发起请求日期",
                                    @"#text": @"20171012"
                                },
                                @"REQ_TIME": @{
                                    @"-desc": @"发起请求时间",
                                    @"#text": @"123059"
                                },
                                @"REQ_DEALNO": @{
                                    @"-desc": @"请求端流水号",
                                    @"#text": @"2017000001"
                                },
                                @"SVR_CLASS": @{
                                    @"-desc": @"请求服务类型",
                                    @"#text": @"SEC"
                                },
                                @"SVR_CODE": @{
                                    @"-desc": @"请求服务代码",
                                    @"#text": @"0001"
                                },
                                @"MSG_BODY": @{
                                    @"KEY_VERSION": @{
                                        @"-desc": @"密钥版本",
                                        @"#text": @"1.0.0.0"
                                    },
                                    @"KEY_USAGE": @{
                                        @"-desc": @"密钥用途",
                                        @"#text": @"S"
                                    },
                                    @"ALGID": @{
                                        @"-desc": @"算法标识",
                                        @"#text": @"SM2"
                                    },
                                    @"KEY_BITS": @{
                                        @"-desc": @"密钥长度",
                                        @"#text": @"256"
                                    }
                                },
                                @"MAC": @{
                                    @"-desc": @"报文认证码"
                                }
                            }
                        };
    return  dict;
}

@end
