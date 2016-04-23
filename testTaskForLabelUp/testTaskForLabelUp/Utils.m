//
//  Utils.m
//  testTaskForLabelUp
//
//  Created by Stanislav Starjevschi on 23.04.16.
//  Copyright © 2016 starxor. All rights reserved.
//

#import "Utils.h"
#import "MockAPIComunicator.h"

NSString * const __logFileName = @"logFile.log";
//2016.04.16 13:52:12 Добавление контакта: {JSON структура}
//2016.04.16 13:52:12 Удаление контакта: {JSON структура}
//2016.04.16 13:52:12 Сохранение адресной книги: {JSON структура}
NSString * const __msgAddContact = @" Добавление контакта: ";
NSString * const __msgDelContact = @" Удаление контакта: ";
NSString * const __msgEditContact = @" Редактирование контакта: ";
NSString * const __msgSaveContacts = @" Сохранение адресной книги: ";

static NSMutableArray *__contacts;

@implementation Utils

+ (NSString *)documentsDirectoryPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSURL *)documentsDirectoryURL
{
    return [NSURL fileURLWithPath:[Utils documentsDirectoryPath]];
}

#pragma mark - Test Contacts List

+ (BOOL)copyTestContactsListToDocumentsDirectory
{
    NSString *dest = [Utils editableTestContactsListPath];
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"test_contacts" ofType:@"json"];
    
    //file exists - test will show if json data is not corrupted
    if ([[NSFileManager defaultManager] fileExistsAtPath:dest isDirectory:NULL]) {
        return YES;
    }
    
    return [[NSFileManager defaultManager] copyItemAtPath:bundlePath
                                                   toPath:dest
                                                    error:nil];
    
}

+ (NSString *)editableTestContactsListPath
{
    return [[Utils documentsDirectoryPath] stringByAppendingPathComponent:@"test_contacts.json"];
}

///simplest data manager, while data is not to large this will not be a memory problem
+ (NSMutableArray *)contactsArray
{
    if (!__contacts) {
        NSData *data = [NSData dataWithContentsOfFile:[Utils editableTestContactsListPath]];
        __contacts = [NSJSONSerialization JSONObjectWithData:data
                                                     options:NSJSONReadingMutableContainers
                                                       error:nil];
    }
    
    return __contacts;
}

+ (BOOL)saveChangesToDisk
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[Utils contactsArray]
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    return [jsonData writeToFile:[Utils editableTestContactsListPath] atomically:YES];
}


/**
 
 {
 "name": {
 "first": "Mills",
 "last": "Curtis"
 },
 "phone": "+1 (926) 562-3354",
 "company": "FOSSIEL",
 "email": "mills.curtis@fossiel.io"
 }
 
 */
+ (void)addContact:(NSDictionary *)newContact
{
    [[Utils contactsArray] addObject:newContact];
    [Utils saveChangesToDisk];
    [Utils logEventAddContact:newContact];
}

+ (void)removeContact:(NSDictionary *)contactToRemove
{
    [[Utils contactsArray] removeObject:contactToRemove];
    [Utils saveChangesToDisk];
    [Utils logEventRemoveContact:contactToRemove];
}

+ (void)saveContactsSUCCESSWithCompletion:(void(^)(BOOL success, NSDictionary *response))completion
{
    NSError *error = nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:[Utils contactsArray]
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    
    if (error) {
        NSLog(@"%@",error);
        completion(NO, nil);
    }else{
        [MockAPIComunicator postSaveContacts_RESPONSE_SUCCESS:data completion:^(NSDictionary *response) {
            [Utils logEventSaveContacts:response];
            completion(YES, response);
        }];
    }
}

+ (void)saveContactsFAILWithCompletion:(void(^)(BOOL success, NSDictionary *response))completion
{
    NSError *error = nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:[Utils contactsArray]
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    
    if (error) {
        NSLog(@"%@",error);
        completion(NO, nil);
    }else{
        [MockAPIComunicator postSaveContacts_RESPONSE_FAIL:data completion:^(NSDictionary *response) {
            [Utils logEventSaveContacts:response];
            completion(YES, response);
        }];
    }
}

#pragma mark - Logging

+ (NSString *)logFilePath
{
    return [[Utils documentsDirectoryPath] stringByAppendingPathComponent:__logFileName];
}

+ (BOOL)createLogFile
{
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[Utils logFilePath] isDirectory:NULL];
    
    return fileExists ? fileExists :  [@"" writeToFile:[Utils logFilePath]
                                            atomically:YES
                                              encoding:NSUTF8StringEncoding
                                                 error:nil];
}

+ (NSFileHandle *)fileHandleForUpdatingLogFile
{
    return [NSFileHandle fileHandleForUpdatingAtPath:[Utils logFilePath]];
}

+ (BOOL)writeDataToLogFile:(NSData *)dataToWrite
{
    if (!dataToWrite) {
        NSLog(@"%s, Empty data",__PRETTY_FUNCTION__);
        return NO;
    }
    
    NSFileHandle *fh = [Utils fileHandleForUpdatingLogFile];
    
    if (!fh) {
        return NO;
    }
    
    [fh seekToEndOfFile];
    @try {
        [fh writeData:dataToWrite];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
        return NO;
    }
    
    NSLog(@"%@", [[NSString alloc] initWithData:dataToWrite encoding:NSUTF8StringEncoding]);
    
    return YES;
}

+ (NSData *)dataToLogWithDate:(NSDate *)date
                      message:(NSString *)message
           jsonObjectToAppend:(id)obj
{
    NSString *string = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                      dateStyle:NSDateFormatterMediumStyle
                                                      timeStyle:NSDateFormatterMediumStyle];
    
    string = [string stringByAppendingString:message];
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    
    if (error) {
        NSLog(@"%@",error);
        return nil;
    }
    
    NSMutableData *dataToWrite = [NSMutableData data];
    [dataToWrite appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    [dataToWrite appendData:data];
    [dataToWrite appendData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    return dataToWrite;
}

+ (BOOL)logEventAddContact:(NSDictionary *)contact
{
    return [Utils writeDataToLogFile:[Utils dataToLogWithDate:[NSDate date]
                                                      message:__msgAddContact
                                           jsonObjectToAppend:contact]];
}

+ (BOOL)logEventRemoveContact:(NSDictionary *)contact
{
    return [Utils writeDataToLogFile:[Utils dataToLogWithDate:[NSDate date]
                                                      message:__msgDelContact
                                           jsonObjectToAppend:contact]];
}

+ (BOOL)logEventEditContact:(NSDictionary *)contact
{
    return [Utils writeDataToLogFile:[Utils dataToLogWithDate:[NSDate date]
                                                      message:__msgEditContact
                                           jsonObjectToAppend:contact]];
}

/**
 saveResult :
 В ответ от сервера придет сообщение в формате JSON следующего вида:
 { “status”:”1” “message”:”OK” },
 если запрос был успешно обработан или
 { “status”:”0”, “message”:”Wrong request” },
 */
+ (BOOL)logEventSaveContacts:(NSDictionary *)saveResult
{
    return [Utils writeDataToLogFile:[Utils dataToLogWithDate:[NSDate date]
                                                      message:__msgSaveContacts
                                           jsonObjectToAppend:saveResult]];
}

+ (void)printLogFile
{
    NSLog(@"%@",[NSString stringWithContentsOfFile:[Utils logFilePath]
                                          encoding:NSUTF8StringEncoding
                                             error:nil]);
}

@end
