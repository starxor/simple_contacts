//
//  testTaskForLabelUpTests.m
//  testTaskForLabelUpTests
//
//  Created by Stanislav Starjevschi on 23.04.16.
//  Copyright © 2016 starxor. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Utils.h"

#import "MockAPIComunicator.h"

@interface testTaskForLabelUpTests : XCTestCase

@property (strong, nonatomic) XCTestExpectation *readyExpectation;

@end

@implementation testTaskForLabelUpTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



#pragma mark - 

- (void)testCopyFromBundleToDocuments
{
    XCTAssertTrue([Utils copyTestContactsListToDocumentsDirectory]);
    
    NSString *path = [Utils editableTestContactsListPath];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:nil];
    
    XCTAssertTrue([NSJSONSerialization isValidJSONObject:json]);
}

- (void)testContactsIsAMutableArray
{
    id obj = [Utils contactsArray];
    
    XCTAssertTrue([obj isKindOfClass:[NSMutableArray class]]);
}

- (void)testSaveChangesToDisk
{
    XCTAssertTrue([Utils saveChangesToDisk]);
}

- (void)testAddContact
{
    NSUInteger countBeforeAdding = [Utils contactsArray].count;
    [Utils addContact:[self exampleContact]];
    NSUInteger countAfterAdding = [Utils contactsArray].count;
    
    XCTAssertTrue(countAfterAdding == countBeforeAdding + 1);
}

- (void)testRemoveContact
{
    NSUInteger countBeforeAdding = [Utils contactsArray].count;
    [Utils removeContact:[self exampleContact]];
    NSUInteger countAfterAdding = [Utils contactsArray].count;
    
    XCTAssertTrue(countAfterAdding == countBeforeAdding - 1);
}

- (void)testSaveContactsSUCCESS
{
    _readyExpectation = [self expectationWithDescription:@"requestComplete"];
    
    [Utils saveContactsSUCCESSWithCompletion:^(BOOL success, NSDictionary *response) {
        
        XCTAssertTrue(success);
        XCTAssertTrue([response isEqualToDictionary:[MockAPIComunicator successResponse]]);
        
        [_readyExpectation fulfill];
        
    }];
    
    
    [self waitForExpectationsWithTimeout:100
                                 handler:^(NSError * _Nullable error) {
                                     [Utils printLogFile];
                                 }];
}

- (void)testSaveContactsFAIL
{
    _readyExpectation = [self expectationWithDescription:@"requestComplete"];
    
    [Utils saveContactsFAILWithCompletion:^(BOOL success, NSDictionary *response) {
        
        XCTAssertTrue(success);
        XCTAssertTrue([response isEqualToDictionary:[MockAPIComunicator failResponse]]);
        
        [_readyExpectation fulfill];
        
    }];
    
    [self waitForExpectationsWithTimeout:100
                                 handler:^(NSError * _Nullable error) {
                                     [Utils printLogFile];
                                 }];
}

#pragma mark - Logging

- (void)testCreateLogFile
{
    XCTAssertTrue([Utils createLogFile]);
}

- (void)testLogAddContact
{
    XCTAssertTrue([Utils logEventAddContact:[self exampleContact]]);
}

- (void)testLogRemoveContact
{
    XCTAssertTrue([Utils logEventRemoveContact:[self exampleContact]]);
}

- (void)testLogSaveContacts
{
    XCTAssertTrue([Utils logEventSaveContacts:[MockAPIComunicator successResponse]]);
}

#pragma mark -

- (NSDictionary *)exampleContact
{
//    { "name": { "first": "Mills", "last": "Curtis" }, "phone": "+1 (926) 562-3354", "company": "FOSSIEL", "email": "mills.curtis.io" }
    NSDictionary *name = @{@"first" : @"testFirstName",
                           @"last" : @"testLastName"};
    NSString *phone = @"+0 (000) 000-0000";
    NSString *email = @"testMail@test.test";

    return @{@"name":name,
             @"phone" : phone,
             @"email" : email
             };
}

@end
