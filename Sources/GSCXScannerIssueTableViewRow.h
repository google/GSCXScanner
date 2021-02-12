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

#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

/**
 * A row displaying information about a @c GTXElementResultCollection instance. The owner of the
 * @c GSCXScannerIssueTableViewRow instance is responsible for determining what information is
 * displayed. A single row may contain multiple suggestions. Each suggestion must be related to an
 * underlying check in the associated @c GTXElementResultCollection instance.
 *
 * @c GSCXScannerIssueTableViewSection groups multiple related @c GSCXScannerIssueTableViewRow
 * instances. This can take multiple forms depending on how the owner displays the information. If
 * the sections represent individual scans, the rows represent individual UI elements with issues,
 * and the suggestions represent the underlying checks in the associated
 * @c GTXElementResultCollection instance. If the sections represent check types, the rows represent
 * UI elements with issues, and the suggestion represents the underlying issue with that check type.
 * In this case, there will only be one suggestion.
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
 * @c YES if this issue should be exported when sharing, @c NO otherwise.
 */
@property(assign, nonatomic, getter=isShared) BOOL shared;

/**
 * The original scan result containing element associated with this row.
 */
@property(strong, nonatomic) GTXHierarchyResultCollection *originalResult;

/**
 * The index of the original issue in @c originalResult corresponding to the element associated with
 * this row.
 */
@property(assign, nonatomic) NSInteger originalElementIndex;

- (instancetype)init NS_UNAVAILABLE;

/**
 * Initializes a @c GSCXScannerIssueTableViewRow instance. The suggestions default to empty.
 * @c shared defaults to @c NO.
 *
 * @param title The row's title.
 * @param subtitle The row's subtitle.
 * @param originalResult The original @c GSCXScannerResult instance containing the element
 * associated with this row.
 * @param originalElementIndex The index of the element corresponding to this row in the array of
 * elements in @c originalResult.
 * @return An initialized @c GSCXScannerIssueTableViewRow instance.
 */
- (instancetype)initWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
               originalResult:(GTXHierarchyResultCollection *)originalResult
         originalElementIndex:(NSInteger)originalElementIndex NS_DESIGNATED_INITIALIZER;

/**
 * Adds a suggestion with the given title and contents. The suggestion must refer to an issue on the
 * element associated with this row. This method does not validate that suggestions refer to an
 * underlying issue.
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
