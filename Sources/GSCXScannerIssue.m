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

#import "GSCXScannerIssue.h"

NS_ASSUME_NONNULL_BEGIN

@implementation GSCXScannerIssue

- (instancetype)initWithCheckNames:(NSArray<NSString *> *)gtxCheckNames
                 checkDescriptions:(NSArray<NSString *> *)gtxCheckDescriptions
                    elementAddress:(NSUInteger)elementAddress
                      elementClass:(Class)elementClass
               frameInScreenBounds:(CGRect)frameInScreenBounds
                accessibilityLabel:(nullable NSString *)accessibilityLabel
           accessibilityIdentifier:(nullable NSString *)accessibilityIdentifier
                elementDescription:(NSString *)elementDescription {
  self = [super init];
  if (self) {
    NSParameterAssert(gtxCheckNames.count == gtxCheckDescriptions.count);
    NSParameterAssert(gtxCheckNames.count > 0);
    _gtxCheckNames = [gtxCheckNames copy];
    _gtxCheckDescriptions = [gtxCheckDescriptions copy];
    _elementAddress = elementAddress;
    _elementClass = elementClass;
    _frame = frameInScreenBounds;
    _accessibilityLabel = [accessibilityLabel copy];
    _accessibilityIdentifier = [accessibilityIdentifier copy];
    _elementDescription = [elementDescription copy];
  }
  return self;
}

+ (instancetype)issueWithCheckNames:(NSArray<NSString *> *)gtxCheckNames
                  checkDescriptions:(NSArray<NSString *> *)gtxCheckDescriptions
                     elementAddress:(NSUInteger)elementAddress
                       elementClass:(Class)elementClass
                frameInScreenBounds:(CGRect)frameInScreenBounds
                 accessibilityLabel:(nullable NSString *)accessibilityLabel
            accessibilityIdentifier:(nullable NSString *)accessibilityIdentifier {
  NSString *elementDescription = accessibilityLabel ?: (accessibilityIdentifier ?: @"Unknown");
  return [[GSCXScannerIssue alloc] initWithCheckNames:gtxCheckNames
                                    checkDescriptions:gtxCheckDescriptions
                                       elementAddress:elementAddress
                                         elementClass:elementClass
                                  frameInScreenBounds:frameInScreenBounds
                                   accessibilityLabel:accessibilityLabel
                              accessibilityIdentifier:accessibilityIdentifier
                                   elementDescription:elementDescription];
}

+ (instancetype)issueWithCheckNames:(NSArray<NSString *> *)gtxCheckNames
                  checkDescriptions:(NSArray<NSString *> *)gtxCheckDescriptions
                     elementAddress:(NSUInteger)elementAddress
                       elementClass:(Class)elementClass
                frameInScreenBounds:(CGRect)frameInScreenBounds
                 accessibilityLabel:(nullable NSString *)accessibilityLabel
            accessibilityIdentifier:(nullable NSString *)accessibilityIdentifier
                 elementDescription:(NSString *)elementDescription {
  // @TODO Instead of passing in @c elementDescription, pass in an element and define a description
  // method on it. Ditto above as well.
  return [[GSCXScannerIssue alloc] initWithCheckNames:gtxCheckNames
                                    checkDescriptions:gtxCheckDescriptions
                                       elementAddress:elementAddress
                                         elementClass:elementClass
                                  frameInScreenBounds:frameInScreenBounds
                                   accessibilityLabel:accessibilityLabel
                              accessibilityIdentifier:accessibilityIdentifier
                                   elementDescription:elementDescription];
}

- (instancetype)issueByCombiningWithDuplicateIssue:(GSCXScannerIssue *)duplicateIssue {
  // It is assumed the gtxCheckNames property contains only unique elements for an individual
  // GSCXScannerIssue instance.
  NSMutableArray<NSString *> *combinedCheckNames = [self.gtxCheckNames mutableCopy];
  NSMutableArray<NSString *> *combinedCheckDescriptions = [self.gtxCheckDescriptions mutableCopy];
  NSSet<NSString *> *usedCheckNames = [NSSet setWithArray:self.gtxCheckNames];
  for (NSUInteger i = 0; i < [duplicateIssue.gtxCheckNames count]; i++) {
    if (![usedCheckNames containsObject:duplicateIssue.gtxCheckNames[i]]) {
      [combinedCheckNames addObject:duplicateIssue.gtxCheckNames[i]];
      [combinedCheckDescriptions addObject:duplicateIssue.gtxCheckDescriptions[i]];
    }
  }
  NSArray<NSString *> *checkNames = [NSArray arrayWithArray:combinedCheckNames];
  NSArray<NSString *> *checkDescriptions = [NSArray arrayWithArray:combinedCheckDescriptions];
  return [[GSCXScannerIssue alloc] initWithCheckNames:checkNames
                                    checkDescriptions:checkDescriptions
                                       elementAddress:self.elementAddress
                                         elementClass:self.elementClass
                                  frameInScreenBounds:self.frame
                                   accessibilityLabel:self.accessibilityLabel
                              accessibilityIdentifier:self.accessibilityIdentifier
                                   elementDescription:self.elementDescription];
}

- (NSUInteger)underlyingIssueCount {
  return [self.gtxCheckNames count];
}

- (NSString *)htmlDescription {
  NSMutableArray *htmlSnippets  = [[NSMutableArray alloc] init];
  NSString *elementDesc = [NSString stringWithFormat:@"<h2>%@</h2>", self.elementDescription];
  [htmlSnippets addObject:elementDesc];
  [htmlSnippets addObject:@"<ul>"];
  for (NSUInteger i = 0; i < _gtxCheckNames.count; i++) {
    [htmlSnippets addObject:[NSString stringWithFormat:@"<li><b>%@</b>: %@</li>",
                                                       _gtxCheckNames[i],
                                                       _gtxCheckDescriptions[i]]];
  }
  [htmlSnippets addObject:@"</ul>"];
  return [htmlSnippets componentsJoinedByString:@"<br/>"];
}

- (BOOL)hasEqualElementAsIssue:(GSCXScannerIssue *)issue {
  if (issue == nil) {
    return NO;
  }
  // The following cases are deterministic, or a best deterministic approximation. If any of these
  // cases hold, we know the elements are equal or not.
  //
  // Regarding the ordering, elements of a different class can never be the same. If they share the
  // same memory address, it must be a coincidence. One element must have been deallocated, and the
  // second element now points to the same address.
  if (self.elementClass != issue.elementClass) {
    return NO;
  } else if (self.elementAddress == issue.elementAddress) {
    // Technically, it is possible for elements with the same address to represent different
    // elements. For example, table views recycle their cells, so different logical elements could
    // have the same address. However, it is a strong enough heuristic that we return YES.
    return YES;
  } else if (self.accessibilityIdentifier != nil && issue.accessibilityIdentifier != nil &&
             ![self.accessibilityIdentifier isEqualToString:issue.accessibilityIdentifier]) {
    // It is possible for elements with different accessibility identifiers to represent the same
    // issue (potentially due to a developer error). However, it is a strong enough heuristic that
    // we return NO.
    return NO;
  }

  // The following cases are weaker heuristics. It is possible for them to be YES but represent
  // different elements. It is possible for them to be NO but represent identical elements. These
  // are the best approximations. Real world profiling is required to determine if these heuristics
  // are useful.
  if (self.accessibilityIdentifier != nil && issue.accessibilityIdentifier != nil &&
      [self.accessibilityIdentifier isEqualToString:issue.accessibilityIdentifier]) {
    // It is possible for elements with the same accessibility identifiers to represent
    // different elements. They are not required to be unique, or there could be a developer error.
    // Once the above cases are ruled out, we consider this a strong enough heuristic to return YES.
    return YES;
  } else if ([self.accessibilityLabel isEqualToString:issue.accessibilityLabel] &&
             CGRectEqualToRect(self.frame, issue.frame)) {
    return YES;
  }
  return NO;
}

+ (NSArray<GSCXScannerIssue *> *)arrayByDedupingArray:(NSArray<GSCXScannerIssue *> *)array {
  NSMutableArray<GSCXScannerIssue *> *dedupedArray = [NSMutableArray array];
  for (GSCXScannerIssue *originalIssue in array) {
    BOOL wasFound = NO;
    for (NSInteger j = 0; j < (NSInteger)[dedupedArray count]; j++) {
      if ([originalIssue hasEqualElementAsIssue:dedupedArray[j]]) {
        dedupedArray[j] = [originalIssue issueByCombiningWithDuplicateIssue:dedupedArray[j]];
        wasFound = YES;
        break;
      }
    }
    if (!wasFound) {
      [dedupedArray addObject:originalIssue];
    }
  }
  return [NSArray arrayWithArray:dedupedArray];
}

@end

NS_ASSUME_NONNULL_END
