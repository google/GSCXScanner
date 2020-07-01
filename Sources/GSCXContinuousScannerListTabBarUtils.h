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

#import <Foundation/Foundation.h>

#import "GSCXScannerIssueTableViewSection.h"
#import "GSCXScannerResult.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains factory methods for constructing @c GSCXScannerIssueTableViewSection objects to display
 * in the list view.
 */
@interface GSCXContinuousScannerListTabBarUtils : NSObject

/**
 * Converts an array of @c GSCXScannerResult instances to an array of
 * @c GSCXScannerIssueTableViewSection instances. Each @c GSCXScannerIssueTableViewSection
 * represents a single scan on a single screen. Each row in a section represents a single UI element
 * with accessibility issues found in that scan. Each suggestion in a row represents a single
 * underlying accessibility issue and a suggested fix.
 *
 * @param results The results to convert to table view sections.
 * @return An array of table view sections each representing a single scan in the same order as
 * @c results.
 */
+ (NSArray<GSCXScannerIssueTableViewSection *> *)sectionsWithGroupedByScanResults:
    (NSArray<GSCXScannerResult *> *)results;

/**
 * Converts an array of @c GSCXScannerResult instances to an array of
 * @c GSCXScannerIssueTableViewSection instances. Each @c GSCXScannerIssueTableViewSection
 * represents a single @c id<GTXChecking> instance representing an accessibility issue. Each row in
 * a section represents a single UI element with the corresponding accessibility issue. Each row
 * contains a single suggestion describing the accessibility issue in question and a suggested fix.
 *
 * @param results The results to convert to table view sections.
 * @return An array of table view sections each representing a single accessibility check.
 */
+ (NSArray<GSCXScannerIssueTableViewSection *> *)sectionsWithGroupedByCheckResults:
    (NSArray<GSCXScannerResult *> *)results;

@end

NS_ASSUME_NONNULL_END
