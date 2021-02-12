//
// Copyright 2019 Google Inc.
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

#import "GSCXScannerTestsUtils.h"

#import "third_party/objective_c/GSCXScanner/Tests/Common/GSCXCommonTestUtils.h"
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@implementation GSCXScannerTestsUtils

+ (GSCXScannerIssueTableViewRow *)newRow {
  GTXHierarchyResultCollection *dummyResult = [GSCXCommonTestUtils newHierarchyResultCollection];
  return [[GSCXScannerIssueTableViewRow alloc] initWithTitle:@"Title"
                                                    subtitle:@"Subtitle"
                                              originalResult:dummyResult
                                        originalElementIndex:0];
}

@end

NS_ASSUME_NONNULL_END
