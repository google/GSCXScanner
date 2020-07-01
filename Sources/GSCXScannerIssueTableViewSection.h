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

#import "GSCXScannerIssueTableViewRow.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A section in the list view. Encapsulates a list of related issues.
 */
@interface GSCXScannerIssueTableViewSection : NSObject

/**
 * The title of this section.
 */
@property(copy, nonatomic, readonly) NSString *title;

/**
 * An optional subtitle of this section.
 */
@property(copy, nonatomic, nullable, readonly) NSString *subtitle;

/**
 * The rows in this section. When expanded, these rows are displayed beneath this section.
 */
@property(copy, nonatomic, readonly) NSArray<GSCXScannerIssueTableViewRow *> *rows;

/**
 * @c YES if this section is expanded, @c NO otherwise. Expanded sections display all their rows.
 * Collapsed sections only display their headers. Defaults to @c NO.
 */
@property(assign, nonatomic, getter=isExpanded) BOOL expanded;

- (instancetype)init NS_UNAVAILABLE;

/**
 * Initializes a @c GSCXScannerIssueTableViewSection instance with the given title, subtitle, and
 * rows.
 *
 * @param title The title of this section.
 * @param subtitle Optional. The subtitle of this section.
 * @param rows The rows in this section.
 */
- (instancetype)initWithTitle:(NSString *)title
                     subtitle:(nullable NSString *)subtitle
                         rows:(NSArray<GSCXScannerIssueTableViewRow *> *)rows;

/**
 * @return The number of rows in this section. A single row may represent multiple suggestions.
 */
- (NSUInteger)numberOfRows;

/**
 * @return The total number of suggestions across all rows.
 */
- (NSUInteger)numberOfSuggestions;

@end

NS_ASSUME_NONNULL_END
