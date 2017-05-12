//
//  TokenCryptor.m
//  kidwatchapp
//
//  Created by tao.wang on 16/8/16.
//  Copyright © 2016年 zhengying. All rights reserved.
//

#import "AuthenCryptor.h"
#import "Encryptor.h"
#import "NSData+Base64.h"


#define kNLength                8
#define kIndexLength            10
#define kOperatorLength         4
@implementation AuthenCryptor

+ (NSString *)tokenWithUid:(NSData *)uid
{
    UInt64 timestamp = [[self class] timestamp];
    UInt8 timestampBytes[8] = {0};
    [[self class] createArray:timestampBytes base:timestamp];
    
    UInt64 sign = [[self class] sign];
    UInt8 signBytes[8] = {0};
    [[self class] createArray:signBytes base:sign];
   
    UInt8 key[FBENCRYPT_KEY_SIZE] = {0};
    [[self class] createAES128key:key sign:signBytes timestamp:timestampBytes];
    
    UInt8 iv[FBENCRYPT_KEY_SIZE] = {0};
    [[self class] createAES128iV:iv sign:signBytes timestamp:timestampBytes];
    
    NSData *keyData = [NSData dataWithBytes:key length:FBENCRYPT_KEY_SIZE];
    NSData *ivData = [NSData dataWithBytes:iv length:FBENCRYPT_KEY_SIZE];
    
    NSString *token = [[Encryptor encryptData:uid key:keyData iv:ivData] base64EncodedString];
    
    NSString *signStr = [NSString stringWithFormat:@"%d.%d.%d.%d.%d.%d.%d.%d",
                         signBytes[0], signBytes[1],signBytes[2],signBytes[3],
                         signBytes[4],signBytes[5],signBytes[6],signBytes[7]];
    NSString *timeStr = [NSString stringWithFormat:@"%lld", timestamp];
    
    NSData *signStrData = [signStr dataUsingEncoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"sign=%@;timestamp=%@;newtoken=%@", [signStrData base64EncodedString], timeStr, token];
//    return [NSDictionary dictionaryWithObjectsAndKeys:signStr,@"sign", timeStr, @"timestamp", token, @"token", nil];
}

+ (void)createAES128key:(UInt8 *)key sign:(UInt8 *)sign timestamp:(UInt8 *)timestamp
{
    UInt8 n[kNLength] = {0};
    UInt8 tH2[2] = {0};
    UInt8 signH4[4] = {0};
    UInt16 factor = 0;
    //generate n
    [[self class] createN:n timestamp:timestamp];
    
    //t_H2
    tH2[0] = timestamp[7];
    tH2[1] = timestamp[6];
    
    //signH4
    memcpy(signH4, sign, sizeof(signH4));
    
    //Factor2
    factor = [[self class] createFactor:&sign[4]];
    
    //generate key
    UInt8 *pKey = key;
    memcpy(pKey, n, kNLength);
    
    pKey += kNLength;
    memcpy(pKey, tH2, sizeof(tH2));
    
    pKey += sizeof(tH2);
    memcpy(pKey, signH4, sizeof(signH4));
    
    pKey += sizeof(signH4);
    pKey[1] = factor & 0x7F;
    pKey[0] = (factor >> 8) & 0x7F;
}

+ (void)createAES128iV:(UInt8 *)iv sign:(UInt8 *)sign timestamp:(UInt8 *)timestamp
{
    UInt8 n[kNLength] = {0};
    UInt8 tL2[2] = {0};
    UInt8 signL4[4] = {0};
    UInt16 factor = 0;
    
    //generate n
    [[self class] createN:n timestamp:timestamp];
    
    //t_L2
    tL2[0] = timestamp[1];
    tL2[1] = timestamp[0];
    
    //signL4
    memcpy(signL4, &sign[4], sizeof(signL4));
    
    //Factor1
    factor = [[self class] createFactor:sign];
    
    //generate key
    UInt8 *pIV = iv;
    memcpy(pIV, n, kNLength);
    
    pIV += kNLength;
    memcpy(pIV, tL2, sizeof(tL2));
    
    pIV += sizeof(tL2);
    memcpy(pIV, signL4, sizeof(signL4));
    
    pIV += sizeof(signL4);
    pIV[1] = factor & 0x7F;
    pIV[0] = (factor >> 8) & 0x7F;
}

+ (void)createN:(UInt8 *)n timestamp:(UInt8 *)timestamp
{
    UInt8 temp[kNLength] = {0};
    
    for (int i = 0; i < kNLength; i++) {
        if (i == (kNLength - 1)) {
            temp[i] = timestamp[i] & timestamp[0];
        }
        else{
            temp[i] = timestamp[i] & timestamp[i+1];
        }
    }
    
    memcpy(n, temp, sizeof(temp));
}

+ (UInt32)createFactor:(UInt8 *)base
{
    UInt16 index = (base[0] ^ base[3]) % kIndexLength;
    UInt16 operator = (base[1] ^ base[2]) % kOperatorLength;
    
    UInt32 factor = 0;
    if (index == 0 && operator == 0) {
        return 0x4321;
    }
    
    for (int i = 0; i < kOperatorLength; i++) {
        UInt16 offset = 12 - (i * 4);
        
        if (operator == 0) {
            factor = factor | (UInt32)(index << offset);
        }
        else{
            
            factor = factor | (UInt32)(((index + i % (operator + 1)) % kIndexLength) << offset);
        }
    }
    
    return factor;
}

+ (void)createArray:(UInt8 *)array base:(UInt64)base
{
    int len = sizeof(base);
    
    for (int i = 0, k = len - 1; i < len; i++, k--) {
        array[k] = (base >> (i * 8)) & 0x7F;
    }
}

+ (UInt64)sign
{
    return arc4random();
}

+ (UInt64)timestamp
{
    return  [[NSDate date] timeIntervalSince1970];
}

@end
