//
//  Header.h
//  TestTaskForLabelUp
//
//  Created by Stanislav Starjevschi on 23.04.16.
//  Copyright © 2016 starxor. All rights reserved.
//


#import <Foundation/Foundation.h>

/**
 В ответ от сервера придет сообщение в формате JSON следующего вида:
 { “status”:”1” “message”:”OK” },
 если запрос был успешно обработан или
 { “status”:”0”, “message”:”Wrong request” },
 */
@interface MockAPIComunicator : NSObject

+ (void)postSaveContacts_RESPONSE_SUCCESS:(NSData *)jsonData completion:(void(^)(NSDictionary *response))completion;
+ (void)postSaveContacts_RESPONSE_FAIL:(NSData *)jsonData completion:(void(^)(NSDictionary *response))completion;

+ (NSDictionary *)successResponse;
+ (NSDictionary *)failResponse;

@end
