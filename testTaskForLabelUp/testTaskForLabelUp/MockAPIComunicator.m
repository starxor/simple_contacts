//
//  MockAPIComunicator.m
//  TestTaskForLabelUp
//
//  Created by Stanislav Starjevschi on 23.04.16.
//  Copyright © 2016 starxor. All rights reserved.
//

#import "MockAPIComunicator.h"

@implementation MockAPIComunicator

+ (NSDictionary *)successResponse
{
    return @{ @"status":@"1", @"message":@"OK" };
}

+ (NSDictionary *)failResponse
{
    return @{ @"status":@"0", @"message":@"Wrong request" };
}

+ (void)postSaveContacts_RESPONSE_SUCCESS:(NSData *)jsonData completion:(void (^)(NSDictionary *))completion
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completion([MockAPIComunicator successResponse]);
    });
}

+ (void)postSaveContacts_RESPONSE_FAIL:(NSData *)jsonData completion:(void (^)(NSDictionary *))completion
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completion([MockAPIComunicator failResponse]);
    });
}

@end

