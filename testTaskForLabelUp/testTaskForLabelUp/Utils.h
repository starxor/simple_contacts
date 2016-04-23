//
//  Utils.h
//  testTaskForLabelUp
//
//  Created by Stanislav Starjevschi on 23.04.16.
//  Copyright © 2016 starxor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (NSString *)documentsDirectoryPath;
+ (NSURL *)documentsDirectoryURL;


+ (BOOL)copyTestContactsListToDocumentsDirectory;

+ (NSString *)editableTestContactsListPath;


+ (NSMutableArray *)contactsArray;
+ (BOOL)saveChangesToDisk;

+ (void)addContact:(NSDictionary *)newContact;
+ (void)removeContact:(NSDictionary *)contactToRemove;

+ (void)saveContactsSUCCESSWithCompletion:(void(^)(BOOL success, NSDictionary *response))completion;
+ (void)saveContactsFAILWithCompletion:(void(^)(BOOL success, NSDictionary *response))completion;


#pragma mark - Logging

+ (BOOL)createLogFile;

+ (BOOL)logEventAddContact:(NSDictionary *)contact;
+ (BOOL)logEventRemoveContact:(NSDictionary *)contact;
+ (BOOL)logEventEditContact:(NSDictionary *)contact;
/**
 saveResult :
 В ответ от сервера придет сообщение в формате JSON следующего вида:
 { “status”:”1” “message”:”OK” },
 если запрос был успешно обработан или
 { “status”:”0”, “message”:”Wrong request” },
 */
+ (BOOL)logEventSaveContacts:(NSDictionary *)saveResult;


+ (void)printLogFile;
@end
