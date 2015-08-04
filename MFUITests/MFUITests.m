/**
 * Copyright (C) 2010 Sopra (support_movalys@sopra.com)
 *
 * This file is part of Movalys MDK.
 * Movalys MDK is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * Movalys MDK is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 * You should have received a copy of the GNU Lesser General Public License
 * along with Movalys MDK. If not, see <http://www.gnu.org/licenses/>.
 */


#import <XCTest/XCTest.h>

#import <MFCore/MFCoreFoundationExt.h>

//Converters
#import <MFUI/MFUI.h>

@interface MFUITests : XCTestCase

@end

static NSString *const CONST_DATE_FORMAT = @"yyyy'-'MM'-'dd";

@implementation MFUITests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreateList
{
    XCTAssertTrue(YES);
}


-(void)testDateStringConverter {
    NSString *dateString = @"2014-02-05";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:CONST_DATE_FORMAT];
    NSDate *convertedDate = [MFStringConverter toDate:dateString withFormatter:dateFormatter];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *convertedDateComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:convertedDate];
    
    XCTAssertEqual([convertedDateComponents day], 5);
    XCTAssertEqual([convertedDateComponents month], 2);
    XCTAssertEqual([convertedDateComponents year], 2014);
    
    NSString *newDateString = [MFDateConverter toString:convertedDate withCustomFormat:CONST_DATE_FORMAT];
    
    XCTAssertEqualObjects(dateString, newDateString);
}

-(void)testNumberStringConverter {
    NSString *numberString = @"13.5";
    NSNumber *convertedNumber = [MFStringConverter toNumber:numberString];
    XCTAssertEqualObjects(convertedNumber, @(13.5));
    
    NSString *newNumberString = [MFNumberConverter toString:convertedNumber];
    XCTAssertEqualObjects(numberString, newNumberString);
}

-(void)testBOOLHelper {
    BOOL valid = YES;
    BOOL invalid = NO;
    
    NSString *validString1 = @"YES";
    NSString *validString2 = @"true";
    NSString *validString3 = @"1";
    
    NSString *invalidString1 = @"NO";
    NSString *invalidString2 = @"false";
    NSString *invalidString3 = @"0";
    
    NSString *otherinvalid = @"Other";
    
    XCTAssertTrue([MFHelperBOOL booleanValue:validString1]);
    XCTAssertTrue([MFHelperBOOL booleanValue:validString2]);
    XCTAssertTrue([MFHelperBOOL booleanValue:validString3]);
    
    XCTAssertFalse([MFHelperBOOL booleanValue:invalidString1]);
    XCTAssertFalse([MFHelperBOOL booleanValue:invalidString2]);
    XCTAssertFalse([MFHelperBOOL booleanValue:invalidString3]);
    XCTAssertFalse([MFHelperBOOL booleanValue:otherinvalid]);
    
    XCTAssertEqualObjects(validString1, [MFHelperBOOL asString:valid]);
    XCTAssertEqualObjects(invalidString1, [MFHelperBOOL asString:invalid]);
}
@end
