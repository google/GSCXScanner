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

#import "GSCXScannerResult.h"

NS_ASSUME_NONNULL_BEGIN

@implementation GSCXScannerResult

- (instancetype)initWithIssues:(NSArray<GSCXScannerIssue *> *)issues
                    screenshot:(UIView *_Nullable)screenshot {
  self = [super init];
  if (self) {
    _issues = issues;
    _screenshot = screenshot;
  }
  return self;
}

+ (instancetype)resultWithIssues:(NSArray<GSCXScannerIssue *> *)issues
                      screenshot:(UIView *_Nullable)screenshot {
  return [[GSCXScannerResult alloc] initWithIssues:issues screenshot:screenshot];
}

- (instancetype)resultWithIssuesAtPoint:(CGPoint)point {
  NSMutableArray<GSCXScannerIssue *> *filteredIssues = [[NSMutableArray alloc] init];
  for (GSCXScannerIssue *issue in self.issues) {
    if (CGRectContainsPoint(issue.frame, point)) {
      [filteredIssues addObject:issue];
    }
  }
  return [GSCXScannerResult resultWithIssues:filteredIssues screenshot:self.screenshot];
}

- (NSUInteger)issueCount {
  NSUInteger count = 0;
  for (GSCXScannerIssue *issue in self.issues) {
    count += issue.underlyingIssueCount;
  }
  return count;
}

- (NSString *)gtxCheckNameAtIndex:(NSUInteger)index {
  NSParameterAssert(index < self.issueCount);
  NSUInteger count = 0;
  for (GSCXScannerIssue *issue in self.issues) {
    for (NSString *gtxCheckName in issue.gtxCheckNames) {
      if (index == count) {
        return gtxCheckName;
      }
      count++;
    }
  }
  return nil;
}

- (NSString *)gtxCheckDescriptionAtIndex:(NSUInteger)index {
  NSParameterAssert(index < self.issueCount);
  NSUInteger count = 0;
  for (GSCXScannerIssue *issue in self.issues) {
    for (NSString *gtxCheckDescription in issue.gtxCheckDescriptions) {
      if (index == count) {
        return gtxCheckDescription;
      }
      count++;
    }
  }
  return nil;
}

- (CGRect)frameAtIndex:(NSUInteger)index {
  NSParameterAssert(index < self.issueCount);
  NSUInteger count = 0;
  for (GSCXScannerIssue *issue in self.issues) {
    if (count + issue.underlyingIssueCount > index) {
      return issue.frame;
    }
    count += issue.underlyingIssueCount;
  }
  NSAssert(NO, @"Should not reach end of method for count %ld at index %ld.", (long)self.issueCount,
           (long)index);
  return CGRectNull;
}

- (NSString *)accessibilityLabelAtIndex:(NSUInteger)index {
  NSParameterAssert(index < self.issueCount);
  NSUInteger count = 0;
  for (GSCXScannerIssue *issue in self.issues) {
    if (count + issue.underlyingIssueCount > index) {
      return issue.accessibilityLabel;
    }
    count += issue.underlyingIssueCount;
  }
  return nil;
}

@end

NS_ASSUME_NONNULL_END
