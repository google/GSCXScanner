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

#import "GSCXContinuousScannerListTabBarUtils.h"

/**
 * Data type for mapping the name of an @c id<GTXChecking> instance to all the rows associated with
 * that check.
 */
typedef NSMutableDictionary<NSString *, NSMutableArray<GSCXScannerIssueTableViewRow *> *>
    GSCXRowsByCheckNameMutableDictionary;

NS_ASSUME_NONNULL_BEGIN

@implementation GSCXContinuousScannerListTabBarUtils

+ (NSArray<GSCXScannerIssueTableViewSection *> *)sectionsWithGroupedByScanResults:
    (NSArray<GSCXScannerResult *> *)results {
  NSMutableArray<GSCXScannerIssueTableViewSection *> *sections = [[NSMutableArray alloc] init];
  NSInteger sectionIndex = 0;
  for (GSCXScannerResult *result in results) {
    [sections addObject:[self gscx_sectionFromResult:result atIndex:sectionIndex]];
    sectionIndex++;
  }
  return sections;
}

+ (NSArray<GSCXScannerIssueTableViewSection *> *)sectionsWithGroupedByCheckResults:
    (NSArray<GSCXScannerResult *> *)results {
  GSCXRowsByCheckNameMutableDictionary *rowsByCheckName = [[NSMutableDictionary alloc] init];
  NSUInteger scanIndex = 0;
  for (GSCXScannerResult *result in results) {
    NSInteger issueIndex = 0;
    for (GSCXScannerIssue *issue in result.issues) {
      [GSCXContinuousScannerListTabBarUtils gscx_addRowsForChecksInIssue:issue
                                                            toDictionary:rowsByCheckName
                                                               scanIndex:scanIndex
                                                                inResult:result
                                                      originalIssueIndex:issueIndex];
      issueIndex++;
    }
    scanIndex++;
  }
  return [GSCXContinuousScannerListTabBarUtils gscx_sectionsFromRowsByCheckName:rowsByCheckName];
}

#pragma mark - Private

/**
 * Converts a @c GSCXScannerResult instance into a @c GSCXScannerIssueTableViewSection instance.
 * Each row in the section corresponds to an issue in @c result.
 *
 * @param result The result to convert into a section.
 * @param scanIndex The index of the scan @c result represents.
 * @return A @c GSCXScannerIssueTableViewSection instance containing rows representing the issues in
 * @c result.
 */
+ (GSCXScannerIssueTableViewSection *)gscx_sectionFromResult:(GSCXScannerResult *)result
                                                     atIndex:(NSInteger)scanIndex {
  // TODO: Localize this and load it from an external resource instead of hardcoding
  // it.
  NSString *title = [NSString stringWithFormat:@"Screen %ld", (long)(scanIndex + 1)];
  NSMutableArray<GSCXScannerIssueTableViewRow *> *rows = [[NSMutableArray alloc] init];
  NSInteger issueIndex = 0;
  for (GSCXScannerIssue *issue in result.issues) {
    [rows addObject:[self gscx_rowFromIssue:issue inResult:result atIndex:issueIndex]];
    issueIndex++;
  }
  return [[GSCXScannerIssueTableViewSection alloc] initWithTitle:title subtitle:nil rows:rows];
}

/**
 * Converts a @c GSCXScannerIssue instance into a @c GSCXScannerIssueTableViewRow instance. Each
 * suggestion in the row corresponds to an underlying accessibility issue in @c issue.
 *
 * @param issue The issue to convert into a row.
 * @param result The result containing @c issue.
 * @param issueIndex The index of the issue in @c result.
 * @return A @c GSCXScannerIssueTableViewRow instance containing suggestions representing the
 *  underlying issues in @c issue.
 */
+ (GSCXScannerIssueTableViewRow *)gscx_rowFromIssue:(GSCXScannerIssue *)issue
                                           inResult:(GSCXScannerResult *)result
                                            atIndex:(NSInteger)issueIndex {
  NSString *subtitle = issue.underlyingIssueCount == 1
                           ? @"1 suggestion"
                           : [NSString stringWithFormat:@"%lu suggestions",
                                                        (unsigned long)issue.underlyingIssueCount];
  GSCXScannerIssueTableViewRow *row =
      [[GSCXScannerIssueTableViewRow alloc] initWithIssue:issue
                                                    title:issue.elementDescription
                                                 subtitle:subtitle
                                           originalResult:result
                                       originalIssueIndex:issueIndex];
  for (NSUInteger issueIndex = 0; issueIndex < [issue underlyingIssueCount]; issueIndex++) {
    [row addSuggestionWithTitle:issue.gtxCheckNames[issueIndex]
                       contents:issue.gtxCheckDescriptions[issueIndex]];
  }
  return row;
}

/**
 * Adds a row for each underlying issue in @c issue to @c rowsByCheckName.
 *
 * @param issue The issue containing underlying accessibilty issues to add to @c rowsByCheckName.
 * @param rowsByCheckName A dictionary mapping check names to rows representing UI elements failing
 *  the corresponding check.
 * @param scanIndex The index of the @c GSCXScannerResult instance containing @c issue.
 * @param result The result containing @c issue.
 * @param originalIssueIndex The index of the issue in @c result.
 */
+ (void)gscx_addRowsForChecksInIssue:(GSCXScannerIssue *)issue
                        toDictionary:(GSCXRowsByCheckNameMutableDictionary *)rowsByCheckName
                           scanIndex:(NSUInteger)scanIndex
                            inResult:(GSCXScannerResult *)result
                  originalIssueIndex:(NSInteger)originalIssueIndex {
  for (NSUInteger i = 0; i < issue.underlyingIssueCount; i++) {
    NSString *checkName = issue.gtxCheckNames[i];
    GSCXScannerIssueTableViewRow *row =
        [GSCXContinuousScannerListTabBarUtils gscx_rowFromIssue:issue
                                               onlyCheckAtIndex:i
                                                      scanIndex:scanIndex
                                                       inResult:result
                                             originalIssueIndex:originalIssueIndex];
    if ([rowsByCheckName objectForKey:checkName] == nil) {
      [rowsByCheckName setObject:[[NSMutableArray alloc] init] forKey:checkName];
    }
    [[rowsByCheckName objectForKey:checkName] addObject:row];
  }
}

/**
 * Constructs a @c GSCXScannerIssueTableViewRow instance for the UI element associated with @c issue
 * containing only the check at @c checkIndex.
 *
 * @param issue The issue associated with the UI element the returned row represents.
 * @param checkIndex The index of the check in @c issue to add as a suggestion to the returned row.
 * @param scanIndex The index of the @c GSCXScannerResult instance containing @c issue.
 * @param result The result containing @c issue.
 * @param originalIssueIndex The index of @c issue in @c result.
 * @return A @c GSCXScannerIssueTableViewRow instance representing the UI element associated with
 *  @c issue. Contains suggestions for the accessibility issue at @c checkIndex in @c issue
 *  occurring in the scan result at @c scanIndex.
 */
+ (GSCXScannerIssueTableViewRow *)gscx_rowFromIssue:(GSCXScannerIssue *)issue
                                   onlyCheckAtIndex:(NSUInteger)checkIndex
                                          scanIndex:(NSUInteger)scanIndex
                                           inResult:(GSCXScannerResult *)result
                                 originalIssueIndex:(NSInteger)originalIssueIndex {
  GSCXScannerIssue *issueWithOneCheck =
      [GSCXContinuousScannerListTabBarUtils gscx_issueFromIssue:issue onlyCheckAtIndex:checkIndex];
  // TODO: Localize this and load it from an external resource instead of hardcoding
  // it.
  NSString *subtitle = [NSString stringWithFormat:@"Screen %lu", (unsigned long)(scanIndex + 1)];
  GSCXScannerIssueTableViewRow *row =
      [[GSCXScannerIssueTableViewRow alloc] initWithIssue:issueWithOneCheck
                                                    title:issue.elementDescription
                                                 subtitle:subtitle
                                           originalResult:result
                                       originalIssueIndex:checkIndex];
  [row addSuggestionWithTitle:issue.gtxCheckNames[checkIndex]
                     contents:issue.gtxCheckDescriptions[checkIndex]];
  return row;
}

/**
 * Copies a @c GSCXScannerIssue instance, removing all checks except for the check at @c checkIndex.
 *
 * @param issue The issue to copy.
 * @param checkIndex The index of the only check to include in the copied issue.
 * @return A copy of @c issue containing only the check at @c checkIndex.
 */
+ (GSCXScannerIssue *)gscx_issueFromIssue:(GSCXScannerIssue *)issue
                         onlyCheckAtIndex:(NSUInteger)checkIndex {
  return [[GSCXScannerIssue alloc] initWithCheckNames:@[ issue.gtxCheckNames[checkIndex] ]
                                    checkDescriptions:@[ issue.gtxCheckDescriptions[checkIndex] ]
                                       elementAddress:issue.elementAddress
                                         elementClass:issue.elementClass
                                  frameInScreenBounds:issue.frame
                                   accessibilityLabel:issue.accessibilityLabel
                              accessibilityIdentifier:issue.accessibilityIdentifier
                                   elementDescription:issue.elementDescription];
}

/**
 * Converts a dictionary mapping check names to associated table view rows to an array of
 * @c GSCXScannerIssueTableViewSection instance. The array is ordered alphabetically by check name.
 *
 * @param rowsByCheckName The dictionary to convert to an array of sections. Each key-value pair
 *  represents one section, where the key is the check name associated with that section and the
 *  value is an array of rows in that section.
 * @return An array of @c GSCXScannerIssueTableViewSection instances representing the checks in
 *  @c rowsByCheckName, ordered alphabetically by check name.
 */
+ (NSArray<GSCXScannerIssueTableViewSection *> *)gscx_sectionsFromRowsByCheckName:
    (GSCXRowsByCheckNameMutableDictionary *)rowsByCheckName {
  NSArray<NSString *> *sortedCheckNames =
      [[rowsByCheckName allKeys] sortedArrayUsingSelector:@selector(compare:)];
  NSMutableArray<GSCXScannerIssueTableViewSection *> *sections = [[NSMutableArray alloc] init];
  for (NSString *checkName in sortedCheckNames) {
    [sections addObject:[[GSCXScannerIssueTableViewSection alloc]
                            initWithTitle:checkName
                                 subtitle:nil
                                     rows:rowsByCheckName[checkName]]];
  }
  return sections;
}

@end

NS_ASSUME_NONNULL_END
