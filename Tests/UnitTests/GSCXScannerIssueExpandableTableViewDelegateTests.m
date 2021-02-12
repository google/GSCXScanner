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

#import "GSCXScannerIssueExpandableTableViewDelegate.h"

#import <XCTest/XCTest.h>

#import "GSCXScannerIssueExpandableTableViewCell.h"
#import "GSCXScannerIssueTableViewRow.h"
#import "GSCXScannerIssueTableViewSection.h"
#import "GSCXScannerTestsUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSCXScannerIssueExpandableTableViewDelegateTests : XCTestCase

/**
 * Used as input to many delegate and data source methods that require a concrete table view.
 */
@property(strong, nonatomic) UITableView *dummyTableView;

/**
 * Wrapped by @c GSCXScannerIssueTableViewSection instances to test that
 * @c GSCXScannerIssueExpandableTableViewDelegate correctly counts the number of rows and
 * suggestions.
 */
@property(strong, nonatomic) GSCXScannerIssueTableViewRow *dummyRow;

@end

@implementation GSCXScannerIssueExpandableTableViewDelegateTests

- (void)setUp {
  [super setUp];
  self.dummyTableView = [[UITableView alloc] init];
  self.dummyRow = [GSCXScannerTestsUtils newRow];
}

- (void)testDelegateMethodsWithEmptySections {
  [self gscx_assertDelegateCalculatesCorrectCountsForSections:@[]];
}

- (void)testDelegateMethodsWithOneSectionEmptyRows {
  NSArray<GSCXScannerIssueTableViewRow *> *rows = @[];
  NSArray<GSCXScannerIssueTableViewSection *> *sections =
      @[ [[GSCXScannerIssueTableViewSection alloc] initWithTitle:@"Scan 1"
                                                        subtitle:nil
                                                            rows:rows] ];
  [self gscx_assertDelegateCalculatesCorrectCountsForSections:sections];
}

- (void)testDelegateMethodsWithOneSectionOneRow {
  GSCXScannerIssueTableViewRow *row = self.dummyRow;
  NSArray<GSCXScannerIssueTableViewSection *> *sections =
      @[ [[GSCXScannerIssueTableViewSection alloc] initWithTitle:@"Scan 1"
                                                        subtitle:nil
                                                            rows:@[ row ]] ];
  [self gscx_assertDelegateCalculatesCorrectCountsForSections:sections];
}

- (void)testDelegateMethodsWithOneSectionManyRows {
  NSArray<GSCXScannerIssueTableViewRow *> *rows = @[ self.dummyRow, self.dummyRow ];
  NSArray<GSCXScannerIssueTableViewSection *> *sections =
      @[ [[GSCXScannerIssueTableViewSection alloc] initWithTitle:@"Scan 1"
                                                        subtitle:nil
                                                            rows:rows] ];
  [self gscx_assertDelegateCalculatesCorrectCountsForSections:sections];
}

- (void)testDelegateMethodsWithManySectionsEmptyRows {
  NSArray<GSCXScannerIssueTableViewSection *> *sections = @[
    [[GSCXScannerIssueTableViewSection alloc] initWithTitle:@"Scan 1" subtitle:nil rows:@[]],
    [[GSCXScannerIssueTableViewSection alloc] initWithTitle:@"Scan 2" subtitle:nil rows:@[]],
    [[GSCXScannerIssueTableViewSection alloc] initWithTitle:@"Scan 3" subtitle:nil rows:@[]]
  ];
  [self gscx_assertDelegateCalculatesCorrectCountsForSections:sections];
}

- (void)testDelegateMethodsWithManySectionsOneRow {
  GSCXScannerIssueTableViewRow *row = self.dummyRow;
  NSArray<GSCXScannerIssueTableViewSection *> *sections = @[
    [[GSCXScannerIssueTableViewSection alloc] initWithTitle:@"Scan 1" subtitle:nil rows:@[ row ]],
    [[GSCXScannerIssueTableViewSection alloc] initWithTitle:@"Scan 2" subtitle:nil rows:@[ row ]],
    [[GSCXScannerIssueTableViewSection alloc] initWithTitle:@"Scan 3" subtitle:nil rows:@[ row ]]
  ];
  [self gscx_assertDelegateCalculatesCorrectCountsForSections:sections];
}

- (void)testDelegateMethodsWithManySectionsManyRows {
  NSArray<GSCXScannerIssueTableViewRow *> *rows = @[ self.dummyRow, self.dummyRow ];
  NSArray<GSCXScannerIssueTableViewSection *> *sections = @[
    [[GSCXScannerIssueTableViewSection alloc] initWithTitle:@"Scan 1" subtitle:nil rows:rows],
    [[GSCXScannerIssueTableViewSection alloc] initWithTitle:@"Scan 2" subtitle:nil rows:rows],
    [[GSCXScannerIssueTableViewSection alloc] initWithTitle:@"Scan 3" subtitle:nil rows:rows]
  ];
  [self gscx_assertDelegateCalculatesCorrectCountsForSections:sections];
}

- (void)testDelegateMethodsWithManySectionsSomeEmptySomeOneSomeManyRows {
  GSCXScannerIssueTableViewRow *row = self.dummyRow;
  NSArray<GSCXScannerIssueTableViewRow *> *rows = @[ row, row ];
  NSArray<GSCXScannerIssueTableViewSection *> *sections = @[
    [[GSCXScannerIssueTableViewSection alloc] initWithTitle:@"Scan 1" subtitle:nil rows:@[ row ]],
    [[GSCXScannerIssueTableViewSection alloc] initWithTitle:@"Scan 2" subtitle:nil rows:@[]],
    [[GSCXScannerIssueTableViewSection alloc] initWithTitle:@"Scan 3" subtitle:nil rows:rows]
  ];
  [self gscx_assertDelegateCalculatesCorrectCountsForSections:sections];
}

#pragma mark - Private

/**
 * Instantiates a @c GSCXScannerIssueExpandableTableViewDelegate instance. Asserts that it
 * calculates the correct number of sections in a table view and the correct number of rows in each
 * section.
 *
 * @param sections The sections passed to the delegate.
 */
- (void)gscx_assertDelegateCalculatesCorrectCountsForSections:
    (NSArray<GSCXScannerIssueTableViewSection *> *)sections {
  GSCXScannerIssueExpandableTableViewDelegateSelectionBlock dummyBlock =
      ^(GTXHierarchyResultCollection *result, NSInteger issueIndex) {
      };
  GSCXScannerIssueExpandableTableViewDelegate *delegate =
      [[GSCXScannerIssueExpandableTableViewDelegate alloc] initWithSections:sections
                                                             selectionBlock:dummyBlock];
  XCTAssertEqual([delegate numberOfSectionsInTableView:self.dummyTableView],
                 (NSInteger)sections.count);
  for (NSUInteger i = 0; i < sections.count; i++) {
    [self gscx_assertRowCountsAreCorrectForDelegate:delegate inSectionAtIndex:i sections:sections];
  }
}

/**
 * Asserts @c delegate calculates the correct number of rows in a section in a table view.
 *
 * @param delegate The delegate under test.
 * @param sectionIndex The index of the section containing the rows to assert.
 * @param sections The sections passed to the delegate.
 */
- (void)gscx_assertRowCountsAreCorrectForDelegate:
            (GSCXScannerIssueExpandableTableViewDelegate *)delegate
                                 inSectionAtIndex:(NSInteger)sectionIndex
                                         sections:(NSArray<GSCXScannerIssueTableViewSection *> *)
                                                      sections {
  XCTAssertEqual([delegate tableView:self.dummyTableView numberOfRowsInSection:sectionIndex], 0);
  sections[sectionIndex].expanded = YES;
  XCTAssertEqual([delegate tableView:self.dummyTableView numberOfRowsInSection:sectionIndex],
                 (NSInteger)[sections[sectionIndex] numberOfRows]);
}

@end

NS_ASSUME_NONNULL_END
