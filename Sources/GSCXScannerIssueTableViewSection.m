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

#import "GSCXScannerIssueTableViewSection.h"

NS_ASSUME_NONNULL_BEGIN

@implementation GSCXScannerIssueTableViewSection

- (instancetype)initWithTitle:(NSString *)title
                     subtitle:(nullable NSString *)subtitle
                         rows:(NSArray<GSCXScannerIssueTableViewRow *> *)rows {
  self = [super init];
  if (self) {
    _title = [title copy];
    _subtitle = [subtitle copy];
    _rows = [rows copy];
  }
  return self;
}

- (NSUInteger)numberOfRows {
  return self.rows.count;
}

- (NSUInteger)numberOfSuggestions {
  NSUInteger count = 0;
  for (GSCXScannerIssueTableViewRow *row in self.rows) {
    count += [row numberOfSuggestions];
  }
  return count;
}

@end

NS_ASSUME_NONNULL_END
