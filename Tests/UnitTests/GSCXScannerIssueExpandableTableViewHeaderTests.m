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

#import "GSCXScannerIssueExpandableTableViewHeader.h"

#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSCXScannerIssueExpandableTableViewHeader (ExposedForTesting)

/**
 * Tap gesture events cannot be programatically triggered. Directly calling @c gscx_toggleIsExpanded
 * is the best workaround to allow tests to be written.
 */
- (BOOL)gscx_toggleIsExpanded;

@end

@interface GSCXScannerIssueExpandableTableViewHeaderTests : XCTestCase

/**
 * @c YES if the header under test set @c expanded to @c YES, @c NO otherwise. This is set by
 * @c expandHeaderToggledCallback.
 */
@property(assign, nonatomic, getter=isHeaderExpanded) BOOL headerExpanded;

/**
 * The header under test.
 */
@property(strong, nonatomic) GSCXScannerIssueExpandableTableViewHeader *header;

@end

@implementation GSCXScannerIssueExpandableTableViewHeaderTests

- (void)setUp {
  [super setUp];
  self.header = [[GSCXScannerIssueExpandableTableViewHeader alloc] initWithReuseIdentifier:nil];
  __weak __typeof__(self) weakSelf = self;
  self.header.expandHeaderToggled = ^(BOOL isExpanded) {
    weakSelf.headerExpanded = isExpanded;
  };
}

- (void)testIsExpandedDoesNotInvokeCallbackWhenNotSet {
  self.header.expandHeaderToggled = nil;
  XCTAssertEqual(self.header.isExpanded, NO);
  XCTAssertEqual(self.header.isExpandable, YES);
  XCTAssertEqual(self.header.expandHeaderToggled, nil);
  XCTAssertEqual(self.isHeaderExpanded, NO);
  BOOL didToggleSuccessfully = [self.header gscx_toggleIsExpanded];
  XCTAssertEqual(didToggleSuccessfully, NO);
  XCTAssertEqual(self.header.isExpanded, YES);
  XCTAssertEqual(self.isHeaderExpanded, NO);
}

- (void)testIsExpandedDoesNotInvokeCallbackWhenNotExpandable {
  self.header.expandable = NO;
  BOOL didToggleSuccessfully = [self.header gscx_toggleIsExpanded];
  XCTAssertEqual(didToggleSuccessfully, NO);
  XCTAssertEqual(self.header.isExpanded, NO);
  XCTAssertEqual(self.isHeaderExpanded, NO);
}

- (void)testTogglingExpandedWhenExpandableSetsIsExpandedToYes {
  BOOL didToggleSuccessfully = [self.header gscx_toggleIsExpanded];
  XCTAssertEqual(didToggleSuccessfully, YES);
  XCTAssertEqual(self.header.isExpanded, YES);
  XCTAssertEqual(self.isHeaderExpanded, YES);
}

- (void)testTogglingExpandedTwiceSetsIsExpandedToNo {
  [self.header gscx_toggleIsExpanded];
  [self.header gscx_toggleIsExpanded];
  XCTAssertEqual(self.header.isExpanded, NO);
  XCTAssertEqual(self.isHeaderExpanded, NO);
}

- (void)testDisablingExpandingSetsExpandedToNo {
  [self.header gscx_toggleIsExpanded];
  self.header.expandable = NO;
  XCTAssertEqual(self.header.isExpanded, NO);
  XCTAssertEqual(self.isHeaderExpanded, NO);
}

- (void)testButtonIsHiddenAndHintIsSetWhenIsExpandableIsNo {
  self.header.expandable = NO;
  self.header.expanded = NO;
  XCTAssertEqual(self.header.expandIcon.hidden, YES);
  XCTAssertEqualObjects(self.header.accessibilityHint, nil);
  XCTAssertEqual(self.header.accessibilityCustomActions, nil);
}

- (void)testCannotSetIsExpandedToYesWhenIsExpandableIsNo {
  self.header.expandable = NO;
  self.header.expanded = YES;
  XCTAssertEqual(self.header.expanded, NO);
  XCTAssertEqual(self.header.expandIcon.hidden, YES);
  XCTAssertEqualObjects(self.header.accessibilityHint, nil);
  XCTAssertEqual(self.header.accessibilityCustomActions, nil);
}

- (void)testButtonIsShownAndHintIsSetWhenIsExpandableIsYesAndIsExpandedIsNo {
  self.header.expandable = YES;
  self.header.expanded = NO;
  XCTAssertEqual(self.header.expandIcon.hidden, NO);
  XCTAssertEqualObjects(self.header.accessibilityHint,
                        kGSCXScannerIssueExpandableTableViewHeaderExpandHint);
  XCTAssertEqual(self.header.accessibilityCustomActions.count, 1);
  XCTAssertEqualObjects(self.header.accessibilityCustomActions[0].name,
                        kGSCXScannerIssueExpandableTableViewHeaderExpandActionName);
}

- (void)testButtonIsShownAndHintIsSetWhenIsExpandableIsYesAndIsExpandedIsYes {
  self.header.expandable = YES;
  self.header.expanded = YES;
  XCTAssertEqual(self.header.expandIcon.hidden, NO);
  XCTAssertEqualObjects(self.header.accessibilityHint,
                        kGSCXScannerIssueExpandableTableViewHeaderCollapseHint);
  XCTAssertEqual(self.header.accessibilityCustomActions.count, 1);
  XCTAssertEqualObjects(self.header.accessibilityCustomActions[0].name,
                        kGSCXScannerIssueExpandableTableViewHeaderCollapseActionName);
}

- (void)testSettingIsExpandableToYesDoesNotResetIsExpanded {
  self.header.expanded = YES;
  self.header.expandable = YES;
  XCTAssertEqual(self.header.isExpanded, YES);
}

@end

NS_ASSUME_NONNULL_END
