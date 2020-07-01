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

#import "GSCXScannerIssue.h"
#import "GSCXScannerResult.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A row displaying information about a @c GSCXScannerIssue instance. The owner of the @c
 * GSCXScannerIssueTableViewRow instance is responsible for determining what information is
 * displayed. A single row may contain multiple suggestions. Each suggestion must be related to an
 * underlying issue in the associated
 * @c GSCXScannerIssue instance.
 *
 * @c GSCXScannerIssueTableViewSection groups multiple related @c GSCXScannerIssueTableViewRow
 * instances. This can take multiple forms depending on how the owner displays the information. If
 * the sections represent individual scans, the rows represent individual UI elements with issues,
 * and the suggestions represent the underlying issue in the associated
 * @c GSCXScannerIssue instance. If the sections represent check types, the rows represent UI
 * elements with issues, and the suggestion represents the underlying issue with that check type. In
 * this case, there will only be one suggestion.
 */
@interface GSCXScannerIssueTableViewRow : NSObject

/**
 * The title of the row.
 */
@property(copy, nonatomic, readonly) NSString *rowTitle;

/**
 * The subtitle of the row.
 */
@property(copy, nonatomic, readonly) NSString *rowSubtitle;

/**
 * Summarize the contents of each suggestion. When grouping by scan number, the titles are the
 * number of suggestions contained in this row. When grouping by check name, titles identify which
 * element has the issue.
 */
@property(copy, nonatomic, readonly) NSArray<NSString *> *suggestionTitles;

/**
 * A textual description of each suggestion. Describes what the issue is and how to fix it.
 */
@property(copy, nonatomic, readonly) NSArray<NSString *> *suggestionContents;

/**
 * The @c GSCXScannerIssue instance this row is associated with. All suggestions in
 * @c suggestionTitles and @c suggestionContents must refer to an underlying issue in @c issue.
 */
@property(copy, nonatomic) GSCXScannerIssue *issue;

/**
 * @c YES if this issue should be exported when sharing, @c NO otherwise.
 */
@property(assign, nonatomic, getter=isShared) BOOL shared;

/**
 * The original scan result containing @c issue.
 */
@property(strong, nonatomic) GSCXScannerResult *originalResult;

/**
 * The index of the original issue in @c originalResult corresponding to @c issue. The issue at this
 * index is not necessarily the same instance, but they are associated with the same UI element.
 */
@property(assign, nonatomic) NSInteger originalIssueIndex;

- (instancetype)init NS_UNAVAILABLE;

/**
 * Initializes a @c GSCXScannerIssueTableViewRow instance. The suggestions default to empty.
 * @c shared defaults to @c NO.
 *
 * @param issue The associated issue.
 * @param title The row's title.
 * @param subtitle The row's subtitle.
 * @param originalResult The original @c GSCXScannerResult instance containing the issue
 *  corresonding to @c issue.
 * @param originalIssueIndex The index of the issue corresponding to @c issue in the array of issues
 *  in @c originalResult.
 * @return An initialized @c GSCXScannerIssueTableViewRow instance.
 */
- (instancetype)initWithIssue:(GSCXScannerIssue *)issue
                        title:(NSString *)title
                     subtitle:(NSString *)subtitle
               originalResult:(GSCXScannerResult *)originalResult
           originalIssueIndex:(NSInteger)originalIssueIndex NS_DESIGNATED_INITIALIZER;

/**
 * Adds a suggestion with the given title and contents. The suggestion must refer to an underlying
 * issue in @c issue. This method does not validate that suggestions refer to an underlying issue.
 *
 * @param title A summary of this suggestion.
 * @param contents A textual description of this suggestion.
 */
- (void)addSuggestionWithTitle:(NSString *)title contents:(NSString *)contents;

/**
 * @return The number of suggestions this row represents.
 */
- (NSUInteger)numberOfSuggestions;

@end

NS_ASSUME_NONNULL_END
