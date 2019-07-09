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

@implementation GSCXScannerIssue {
  NSString *_elementDescription;
}

- (instancetype)initWithCheckNames:(NSArray<NSString *> *)gtxCheckNames
                 checkDescriptions:(NSArray<NSString *> *)gtxCheckDescriptions
               frameInScreenBounds:(CGRect)frameInScreenBounds
                accessibilityLabel:(nullable NSString *)accessibilityLabel
                elementDescription:(nonnull NSString *)elementDescription {
  self = [super init];
  if (self) {
    NSParameterAssert(gtxCheckNames.count == gtxCheckDescriptions.count);
    NSParameterAssert(gtxCheckNames.count > 0);
    _gtxCheckNames = [gtxCheckNames copy];
    _gtxCheckDescriptions = [gtxCheckDescriptions copy];
    _frame = frameInScreenBounds;
    _accessibilityLabel = [accessibilityLabel copy];
    _elementDescription = [elementDescription copy];
  }
  return self;
}

+ (instancetype)issueWithCheckNames:(NSArray<NSString *> *)gtxCheckNames
                  checkDescriptions:(NSArray<NSString *> *)gtxCheckDescriptions
                frameInScreenBounds:(CGRect)frameInScreenBounds
                 accessibilityLabel:(nullable NSString *)accessibilityLabel {
  return [[GSCXScannerIssue alloc] initWithCheckNames:gtxCheckNames
                                    checkDescriptions:gtxCheckDescriptions
                                  frameInScreenBounds:frameInScreenBounds
                                   accessibilityLabel:accessibilityLabel
                                   elementDescription:accessibilityLabel ?: @"Unknown"];
}

+ (instancetype)issueWithCheckNames:(NSArray<NSString *> *)gtxCheckNames
                  checkDescriptions:(NSArray<NSString *> *)gtxCheckDescriptions
                frameInScreenBounds:(CGRect)frameInScreenBounds
                 accessibilityLabel:(nullable NSString *)accessibilityLabel
                 elementDescription:(nonnull NSString *)elementDescription {
  // @TODO Instead of passing in @c elementDescription, pass in an element and define a description
  // method on it. Ditto above as well.
  return [[GSCXScannerIssue alloc] initWithCheckNames:gtxCheckNames
                                    checkDescriptions:gtxCheckDescriptions
                                  frameInScreenBounds:frameInScreenBounds
                                   accessibilityLabel:accessibilityLabel
                                   elementDescription:elementDescription];
}

- (NSUInteger)underlyingIssueCount {
  return [self.gtxCheckNames count];
}

- (NSString *)htmlDescription {
  NSMutableArray *htmlSnippets  = [[NSMutableArray alloc] init];
  NSString *elementDesc = [NSString stringWithFormat:@"<h2>%@</h2>", _elementDescription];
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

@end

NS_ASSUME_NONNULL_END
