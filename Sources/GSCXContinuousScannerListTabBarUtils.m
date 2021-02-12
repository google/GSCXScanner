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
    (NSArray<GTXHierarchyResultCollection *> *)results {
  NSMutableArray<GSCXScannerIssueTableViewSection *> *sections = [[NSMutableArray alloc] init];
  NSInteger sectionIndex = 0;
  for (GTXHierarchyResultCollection *result in results) {
    [sections addObject:[self gscx_sectionFromResult:result atIndex:sectionIndex]];
    sectionIndex++;
  }
  return sections;
}

+ (NSArray<GSCXScannerIssueTableViewSection *> *)sectionsWithGroupedByCheckResults:
    (NSArray<GTXHierarchyResultCollection *> *)results {
  GSCXRowsByCheckNameMutableDictionary *rowsByCheckName = [[NSMutableDictionary alloc] init];
  NSUInteger scanIndex = 0;
  for (GTXHierarchyResultCollection *result in results) {
    NSInteger elementResultIndex = 0;
    for (GTXElementResultCollection *elementResult in result.elementResults) {
      [GSCXContinuousScannerListTabBarUtils
          gscx_addRowsForChecksInElementResult:elementResult
                                  toDictionary:rowsByCheckName
                                     scanIndex:scanIndex
                                      inResult:result
                          originalElementIndex:elementResultIndex];
      elementResultIndex++;
    }
    scanIndex++;
  }
  return [GSCXContinuousScannerListTabBarUtils gscx_sectionsFromRowsByCheckName:rowsByCheckName];
}

#pragma mark - Private

/**
 * Converts a @c GTXHierarchyResultCollection instance into a @c GSCXScannerIssueTableViewSection
 * instance. Each row in the section corresponds to an element in @c result.
 *
 * @param result The result to convert into a section.
 * @param scanIndex The index of the scan @c result represents.
 * @return A @c GSCXScannerIssueTableViewSection instance containing rows representing the elements
 * in
 * @c result.
 */
+ (GSCXScannerIssueTableViewSection *)gscx_sectionFromResult:(GTXHierarchyResultCollection *)result
                                                     atIndex:(NSInteger)scanIndex {
  // TODO: Localize this and load it from an external resource instead of hardcoding
  // it.
  NSString *title = [NSString stringWithFormat:@"Screen %ld", (long)(scanIndex + 1)];
  NSMutableArray<GSCXScannerIssueTableViewRow *> *rows = [[NSMutableArray alloc] init];
  NSInteger elementResultIndex = 0;
  for (GTXElementResultCollection *elementResult in result.elementResults) {
    [rows addObject:[self gscx_rowFromElementResult:elementResult
                                           inResult:result
                                            atIndex:elementResultIndex]];
    elementResultIndex++;
  }
  return [[GSCXScannerIssueTableViewSection alloc] initWithTitle:title subtitle:nil rows:rows];
}

/**
 * Converts a @c GTXElementResultCollection instance into a @c GSCXScannerIssueTableViewRow
 * instance. Each suggestion in the row corresponds to an underlying accessibility issue in
 * @c elementResult.
 *
 * @param elementResult The element to convert into a row.
 * @param result The result containing @c elementResult.
 * @param elementIndex The index of the element in @c result.
 * @return A @c GSCXScannerIssueTableViewRow instance containing suggestions representing the
 *  underlying issues in @c elementResult.
 */
+ (GSCXScannerIssueTableViewRow *)gscx_rowFromElementResult:
                                      (GTXElementResultCollection *)elementResult
                                                   inResult:(GTXHierarchyResultCollection *)result
                                                    atIndex:(NSInteger)elementIndex {
  NSUInteger checkResultCount = elementResult.checkResults.count;
  NSString *subtitle =
      (checkResultCount == 1
          ? @"1 suggestion"
          : [NSString stringWithFormat:@"%lu suggestions", (unsigned long)checkResultCount]);
  GSCXScannerIssueTableViewRow *row = [[GSCXScannerIssueTableViewRow alloc]
             initWithTitle:elementResult.elementReference.elementDescription
                  subtitle:subtitle
            originalResult:result
      originalElementIndex:elementIndex];
  for (GTXCheckResult *checkResult in elementResult.checkResults) {
    [row addSuggestionWithTitle:checkResult.checkName contents:checkResult.errorDescription];
  }
  return row;
}

/**
 * Adds a row for each underlying issue in @c elementResult to @c rowsByCheckName.
 *
 * @param elementResult The element containing underlying accessibilty issues to add to
 *  @c rowsByCheckName.
 * @param rowsByCheckName A dictionary mapping check names to rows representing UI elements failing
 *  the corresponding check.
 * @param scanIndex The index of the @c GTXHierarchyResultCollection instance containing
 *  @c elementResult.
 * @param result The result containing @c elementResult.
 * @param originalElementResult The index of the element in @c result.
 */
+ (void)gscx_addRowsForChecksInElementResult:(GTXElementResultCollection *)elementResult
                                toDictionary:(GSCXRowsByCheckNameMutableDictionary *)rowsByCheckName
                                   scanIndex:(NSUInteger)scanIndex
                                    inResult:(GTXHierarchyResultCollection *)result
                        originalElementIndex:(NSInteger)originalElementIndex {
  for (NSUInteger i = 0; i < elementResult.checkResults.count; i++) {
    NSString *checkName = elementResult.checkResults[i].checkName;
    GSCXScannerIssueTableViewRow *row =
        [GSCXContinuousScannerListTabBarUtils gscx_rowFromElementResult:elementResult
                                                       onlyCheckAtIndex:i
                                                              scanIndex:scanIndex
                                                               inResult:result
                                                   originalElementIndex:originalElementIndex];
    if ([rowsByCheckName objectForKey:checkName] == nil) {
      [rowsByCheckName setObject:[[NSMutableArray alloc] init] forKey:checkName];
    }
    [[rowsByCheckName objectForKey:checkName] addObject:row];
  }
}

/**
 * Constructs a @c GSCXScannerIssueTableViewRow instance for the UI element associated with
 * @c elementResult containing only the check at @c checkIndex.
 *
 * @param elementResult The result associated with the UI element the returned row represents.
 * @param checkIndex The index of the check in @c issue to add as a suggestion to the returned row.
 * @param scanIndex The index of the @c GTXHierarchyResultCollection instance containing @c
 *  elementResult.
 * @param result The result containing @c elementResult.
 * @param originalElementIndex The index of @c elementResult in @c result.
 * @return A @c GSCXScannerIssueTableViewRow instance representing the UI element associated with
 *  @c elementResult. Contains suggestions for the accessibility issue at @c checkIndex in
 *  @c elementResult occurring in the scan result at @c scanIndex.
 */
+ (GSCXScannerIssueTableViewRow *)gscx_rowFromElementResult:
                                      (GTXElementResultCollection *)elementResult
                                           onlyCheckAtIndex:(NSUInteger)checkIndex
                                                  scanIndex:(NSUInteger)scanIndex
                                                   inResult:(GTXHierarchyResultCollection *)result
                                       originalElementIndex:(NSInteger)originalElementIndex {
  GTXElementResultCollection *copiedElementResult =
      [GSCXContinuousScannerListTabBarUtils gscx_elementResultFromResult:elementResult
                                                        onlyCheckAtIndex:checkIndex];
  // TODO: Localize this and load it from an external resource instead of hardcoding
  // it.
  NSString *subtitle = [NSString stringWithFormat:@"Screen %lu", (unsigned long)(scanIndex + 1)];
  GSCXScannerIssueTableViewRow *row = [[GSCXScannerIssueTableViewRow alloc]
             initWithTitle:copiedElementResult.elementReference.elementDescription
                  subtitle:subtitle
            originalResult:result
      originalElementIndex:originalElementIndex];
  [row addSuggestionWithTitle:elementResult.checkResults[checkIndex].checkName
                     contents:elementResult.checkResults[checkIndex].errorDescription];
  return row;
}

/**
 * Copies a @c GTXElementResultCollection instance, removing all checks except for the check at
 * @c checkIndex.
 *
 * @param elementResult The element result to copy.
 * @param checkIndex The index of the only check to include in the copied element result.
 * @return A copy of @c elementResult containing only the check at @c checkIndex.
 */
+ (GTXElementResultCollection *)gscx_elementResultFromResult:
                                    (GTXElementResultCollection *)elementResult
                                            onlyCheckAtIndex:(NSUInteger)checkIndex {
  return [[GTXElementResultCollection alloc]
      initWithElement:elementResult.elementReference
         checkResults:@[ elementResult.checkResults[checkIndex] ]];
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
