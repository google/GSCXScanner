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

#import "GSCXScannerIssueTableViewRow.h"

#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@implementation GSCXScannerIssueTableViewRow

- (instancetype)initWithIssue:(GSCXScannerIssue *)issue
                        title:(NSString *)title
                     subtitle:(NSString *)subtitle
               originalResult:(GSCXScannerResult *)originalResult
           originalIssueIndex:(NSInteger)originalIssueIndex {
  GTX_ASSERT(
      originalIssueIndex >= 0 && (NSUInteger)originalIssueIndex < [originalResult issueCount],
      @"originalIssueIndex is out of range.");
  self = [super init];
  if (self) {
    _rowTitle = [title copy];
    _rowSubtitle = [subtitle copy];
    _suggestionTitles = @[];
    _suggestionContents = @[];
    _issue = issue;
    _originalResult = originalResult;
    _originalIssueIndex = originalIssueIndex;
  }
  return self;
}

- (void)addSuggestionWithTitle:(NSString *)title contents:(NSString *)contents {
  _suggestionTitles = [self.suggestionTitles arrayByAddingObject:[title copy]];
  _suggestionContents = [self.suggestionContents arrayByAddingObject:[contents copy]];
}

- (NSUInteger)numberOfSuggestions {
  return [self.suggestionTitles count];
}

@end

NS_ASSUME_NONNULL_END
