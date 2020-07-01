//
// Copyright 2020 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "GSCXReport.h"

#import <XCTest/XCTest.h>

#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/Utils/GSCXWebKitWarmer.h"
#import <GTXiLib/GTXiLib.h>
/**
 * The number of seconds to wait for the web view processes to load before any tests are run.
 */
static const NSTimeInterval kGSCXReportWarmUpTimeout = 20.0;

/**
 * The number of seconds to wait for reports to be generated before failing the test.
 */
static const NSTimeInterval kGSCXReportTestsTimeout = 20.0;

/**
 * This is a unit test case, but it needs to run in the integration test suite. @c WKWebView loads
 * and renders in a separate process, which requires a test host. The integration tests run in a
 * test host but the unit tests do not.
 */
@interface GSCXReportTests : XCTestCase

/**
 * The report under test.
 */
@property(strong, nonatomic) GSCXReport *report;

@end

@implementation GSCXReportTests

+ (void)setUp {
  NSError *error;
  BOOL isWarmedUp = [GSCXWebKitWarmer warmWebViewWithTimeout:kGSCXReportWarmUpTimeout error:&error];
  GTX_ASSERT(isWarmedUp, @"could not warm up web view due to: %@", error);
}

- (void)setUp {
  [super setUp];
  UIImage *screenshot = [[UIImage alloc] init];
  GSCXScannerIssue *issue = [[GSCXScannerIssue alloc] initWithCheckNames:@[ @"Check 1" ]
                                                       checkDescriptions:@[ @"Description 1" ]
                                                          elementAddress:0
                                                            elementClass:[UIView class]
                                                     frameInScreenBounds:CGRectZero
                                                      accessibilityLabel:nil
                                                 accessibilityIdentifier:nil
                                                      elementDescription:@"Element 1"];
  GSCXScannerResult *result = [[GSCXScannerResult alloc] initWithIssues:@[ issue ]
                                                             screenshot:screenshot];
  self.report = [[GSCXReport alloc] initWithResults:@[ result ]];
}

- (void)testCanCreateHTMLReport {
  XCTestExpectation *expectation =
      [[XCTestExpectation alloc] initWithDescription:@"Create HTML Report"];
  [GSCXReport createHTMLReport:self.report
      completionBlock:^(WKWebView *webView) {
        // If this callback completes, the html report has been created successfully.
        [expectation fulfill];
      }
      errorBlock:^(NSError *error) {
        XCTFail(@"Could not create HTML report: %@", error);
        [expectation fulfill];
      }];
  [self waitForExpectations:@[ expectation ] timeout:kGSCXReportTestsTimeout];
}

- (void)testCanCreatePDFReport {
  XCTestExpectation *expectation =
      [[XCTestExpectation alloc] initWithDescription:@"Create PDF Report"];
  [GSCXReport createPDFReport:self.report
      completionBlock:^(NSURL *reportUrl) {
        // If this callback completes, the pdf report has been created successfully.
        [expectation fulfill];
      }
      errorBlock:^(NSError *error) {
        XCTFail(@"Could not create PDF report: %@", error);
        [expectation fulfill];
      }];
  [self waitForExpectations:@[ expectation ] timeout:kGSCXReportTestsTimeout];
}

@end
