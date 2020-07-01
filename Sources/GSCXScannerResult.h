//
// Copyright 2018 Google Inc.
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

#import <UIKit/UIKit.h>

#import "GSCXScannerIssue.h"
#import "GSCXReportContext.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Encapsulates all accessibility issues found by a scan. Because a GSCXScannerIssue can represent
 * multiple accessibility issues, GSCXScannerResult exposes methods acting on those individual
 * issues. For example, if there are 2 elements, each with 2 issues, then @c issueCount would
 * return 4. @c gtxCheckNameAtIndex:1 would return the second check name of the first
 * GSCXScannerIssue object. @c gtxCheckNameAtIndex:2 would return the first check name of the
 * second GSCXScannerIssue object. Because the frame property does not vary with individual
 * issues, @c gtxCheckNameAtIndex:0 and @c gtxCheckNameAtIndex:1 would both return the frame for
 * the first GSCXScannerIssue object.
 */
@interface GSCXScannerResult : NSObject

/**
 * A list of all issues found by the GSCXScanner. If no issues were found, issues is
 * an empty array (it is not nil).
 */
@property(copy, nonatomic, readonly) NSArray<GSCXScannerIssue *> *issues;

/**
 * An image of the screen as it appeared when the scan was completed.
 */
@property(strong, nonatomic, readonly) UIImage *screenshot;

/**
 * Initializes a @c GSCXScannerResult object with list of issues and a screenshot.
 *
 * @param issues The accessibility issues found in this scan.
 * @param screenshot An image of the screen as it appeared during this scan.
 */
- (instancetype)initWithIssues:(NSArray<GSCXScannerIssue *> *)issues
                    screenshot:(UIImage *)screenshot;

/**
 * Constructs a @c GSCXScannerResult object with this instance's issues whose frames contain the
 * given point.
 *
 * @param point A point in screen coordinates to filter frames by.
 * @return A @c GSCXScannerResult object containing only the issues whose frames contain @c point.
 */
- (instancetype)resultWithIssuesAtPoint:(CGPoint)point;

/**
 * Returns the number of issues found in the scan.
 */
- (NSUInteger)issueCount;

/**
 * Returns the name of the GTX check at the given index.
 *
 * @param index The index of the desired check. Must be less than @c issueCount.
 * @return A string representing the name of the check at the given index.
 */
- (NSString *)gtxCheckNameAtIndex:(NSUInteger)index;

/**
 * Returns the description of the GTX check at the given index.
 *
 * @param index The index of the desired check. Must be less than @c issueCount.
 * @return A string representing the description of the check at the given index.
 */
- (NSString *)gtxCheckDescriptionAtIndex:(NSUInteger)index;

/**
 * Returns the frame of the GTX check at the given index in screen coordinates.
 *
 * @param index The index of the desired check. Must be less than @c issueCount.
 * @return The frame of the check at the given index in screen coordinates.
 */
- (CGRect)frameAtIndex:(NSUInteger)index;

/**
 * Returns the accessibility label of the UI element corresponding to the issue at the given index.
 *
 * @param index The index of the desired issue. Must be less than @c issueCount.
 * @return The accessibility label of the UI element for the issue at the given index.
 */
- (NSString *)accessibilityLabelAtIndex:(NSUInteger)index;

/**
 * Returns a HTML description of the results with all images and other file resources added to the
 * given context.
 *
 * @param context The context to reciieve all file resources in the HTML description.
 * @return The HTML description of the result.
 */
- (NSString *)htmlDescription:(GSCXReportContext *)context;

/**
 * @return The original frame of the screenshot when the scan was performed.
 */
- (CGRect)originalScreenshotFrame;

/**
 * Combines issues with the same element in @c self and @c result and removes them from @c result.
 * Both @c self and @c result are modified if duplicates are found.
 *
 * @param result The scan result with which to combine issues.
 */
- (void)moveIssuesWithExistingElementsFromResult:(GSCXScannerResult *)result;

/**
 * Dedupes all pairs of results in @c results. Results with no issues after deduping are removed
 * from the returned array.
 *
 * @param results An array of @c GSCXScannerResult instances to deduplicate.
 * @return An array of results containing only unique @c GSCXScannerIssue instances.
 */
+ (NSArray<GSCXScannerResult *> *)resultsArrayByDedupingResultsArray:
    (NSArray<GSCXScannerResult *> *)results;

@end

NS_ASSUME_NONNULL_END
