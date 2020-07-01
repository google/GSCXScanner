//
// Copyright 2019 Google Inc.
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

#import "GSCXReportContext.h"
#import "GSCXScannerIssue.h"
#import "GSCXScannerResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSCXReport (ExposedForTesting)
+ (NSURL *)gscx_createLocalSiteWithHTMLString:(NSString *)html context:(GSCXReportContext *)context;
@end

@interface GSCXReportTests : XCTestCase
@end

@implementation GSCXReportTests

- (void)testReportContextSavesAllImages {
  GSCXReportContext *context = [[GSCXReportContext alloc] init];
  UIImage *image1 = [[UIImage alloc] init];
  UIImage *image2 = [[UIImage alloc] init];

  NSString *filename1 = [context pathByAddingImage:image1];
  NSString *filename2 = [context pathByAddingImage:image2];

  __block NSInteger count = 0;
  [context forEachImageWithHandler:^(UIImage *image, NSString *filename) {
    count += 1;
    if (image1 == image) {
      XCTAssertEqual(filename, filename1);
    }
    if (image2 == image) {
      XCTAssertEqual(filename, filename2);
    }
  }];
  XCTAssertEqual(count, 2);
}

- (void)testReportContextWithZeroImages {
  GSCXReportContext *context = [[GSCXReportContext alloc] init];
  __block NSInteger count = 0;
  [context forEachImageWithHandler:^(UIImage *image, NSString *filename) {
    count += 1;
  }];
  XCTAssertEqual(count, 0);
}

- (void)testReportCanCreateHTMLForPDF {
  GSCXReportContext *context = [[GSCXReportContext alloc] init];
  NSString *expectedContents = @"<div>testing...</div>";
  NSURL *siteURL = [GSCXReport gscx_createLocalSiteWithHTMLString:expectedContents context:context];
  NSURL *pageURL = [siteURL URLByAppendingPathComponent:@"index.html"];
  NSError *error;
  NSString *actualContents = [NSString stringWithContentsOfURL:pageURL
                                                    encoding:NSASCIIStringEncoding
                                                       error:&error];
  XCTAssertEqualObjects(actualContents, expectedContents);
}

@end

NS_ASSUME_NONNULL_END
