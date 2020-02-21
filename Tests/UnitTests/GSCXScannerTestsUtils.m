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

NS_ASSUME_NONNULL_BEGIN

@implementation GSCXScannerTestsUtils

+ (BOOL)issues:(NSArray<GSCXScannerIssue *> *)firstArray
    equalIssuesUnordered:(NSArray<GSCXScannerIssue *> *)secondArray {
  NSMutableArray<GSCXScannerIssue *> *firstRemainingElements = [firstArray mutableCopy];
  NSMutableArray<GSCXScannerIssue *> *secondRemainingElements = [secondArray mutableCopy];
  while ([firstRemainingElements count] > 0) {
    BOOL didFindElement = NO;
    for (NSUInteger i = 0; i < [secondRemainingElements count]; i++) {
      if ([GSCXScannerTestsUtils gscxtest_issue:[firstRemainingElements lastObject]
                                 isEqualToIssue:secondRemainingElements[i]]) {
        [firstRemainingElements removeLastObject];
        [secondRemainingElements removeObjectAtIndex:i];
        didFindElement = YES;
        break;
      }
    }
    if (!didFindElement) {
      return NO;
    }
  }
  return YES;
}

#pragma mark - Private

/**
 * Determines if two issues are equal based on @c hasEqualElementAsIssue: and the GTX check names
 * and descriptions.
 *
 * @param firstIssue An issue to compare.
 * @param secondIssue An issue to compare.
 * @return @c YES if the issues are considered equal, @c NO otherwise.
 */
+ (BOOL)gscxtest_issue:(GSCXScannerIssue *)firstIssue
        isEqualToIssue:(GSCXScannerIssue *)secondIssue {
  if (![firstIssue hasEqualElementAsIssue:secondIssue]) {
    return NO;
  }
  NSSet<NSString *> *firstNames = [NSSet setWithArray:firstIssue.gtxCheckNames];
  NSSet<NSString *> *firstDescriptions = [NSSet setWithArray:firstIssue.gtxCheckDescriptions];
  NSSet<NSString *> *secondNames = [NSSet setWithArray:secondIssue.gtxCheckNames];
  NSSet<NSString *> *secondDescriptions = [NSSet setWithArray:secondIssue.gtxCheckDescriptions];
  return
      [firstNames isEqualToSet:secondNames] && [firstDescriptions isEqualToSet:secondDescriptions];
}

@end

NS_ASSUME_NONNULL_END
