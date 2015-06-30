//
//  ESJsonFormarTopDownTest.m
//  ESJsonFormat
//
//  Created by Oxy Hsing_邢傑 on 2015/6/30.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ESJsonFormatManager.h"
#import "ESFormatInfo.h"

@interface ESJsonFormarTopDownTest : XCTestCase

@end

@implementation ESJsonFormarTopDownTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testParseDic{
    NSError * error = nil;
    NSString * targetJson = @"{\n\"AttendSn\":0,\n\"StartTime\":\"2015/06/29 19:30\",\n\"EndTime\":\"2015/06/29 20:15\",\n\"SessionType\":0,\n\"LobbySn\":\"65505\",\n\"Title\":\"Thematic Vocabulary Builder - Terms to Use About Your Opponents \",\n\"Material\":\"105913\",\n\"MaterialSn\":null,\n\"MaterialDescription\":null,\n\"LobbyLv\":null,\n\"RecordClassType\":\"10\",\n\"SessionPeriod\":\"45\",\n\"BrandId\":\"2\",\n\"ContractId\":\"6071\",\n\"Consultant\":null,\n\"ConsultantSn\":null,\n\"HasCheckIn\":false,\n\"JrCourse\":0,\n\"UsePoints\":\"1\",\n\"SessionSn\":null,\n\"RoomNumber\":null,\n\"ClientSn\":0,\n\"CompStatus\":null,\n\"CanCancel\":true\n}";
    NSData * binaryData = [targetJson dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * jsonDic = [NSJSONSerialization JSONObjectWithData:binaryData options:NSJSONReadingAllowFragments error:&error];
    ESFormatInfo * formatInfo = [[ESFormatInfo alloc] init];
    [formatInfo  : jsonDic];
    
    XCTAssertNotNil(formatInfo);
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
