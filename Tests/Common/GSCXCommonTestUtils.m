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

#import "third_party/objective_c/GSCXScanner/Tests/Common/GSCXCommonTestUtils.h"

NS_ASSUME_NONNULL_BEGIN

@implementation GSCXCommonTestUtils

+ (GTXHierarchyResultCollection *)newHierarchyResultCollection {
  GTXElementReference *dummyElementReference =
      [[GTXElementReference alloc] initWithElementAddress:0
                                             elementClass:[UIView class]
                                       accessibilityLabel:@"Label"
                                  accessibilityIdentifier:@"Identifier"
                                       accessibilityFrame:CGRectZero
                                       elementDescription:@"Description"];
  GTXCheckResult *dummyCheckResult =
      [[GTXCheckResult alloc] initWithCheckName:@"Check" errorDescription:@"Check Description"];
  GTXElementResultCollection *dummyElementResult =
      [[GTXElementResultCollection alloc] initWithElement:dummyElementReference
                                             checkResults:@[ dummyCheckResult ]];
  // Use a non-zero sized image so calculations and rendering do not crash.
  UIGraphicsBeginImageContext(CGSizeMake(1.0, 1.0));
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return [[GTXHierarchyResultCollection alloc] initWithElementResults:@[ dummyElementResult ]
                                                           screenshot:image];
}

@end

NS_ASSUME_NONNULL_END
