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

#import "GSCXRingViewArranger.h"
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface GSCXScannerResult() {
  /**
   * The frame of the screenshot when this object was created.
   */
  CGRect _originalScreenshotFrame;
}

@end

@implementation GSCXScannerResult

- (instancetype)initWithIssues:(NSArray<GSCXScannerIssue *> *)issues
                    screenshot:(UIImage *)screenshot {
  self = [super init];
  if (self) {
    _issues = [issues copy];
    _screenshot = screenshot;
    _originalScreenshotFrame = CGRectMake(0, 0, screenshot.size.width, screenshot.size.height);
  }
  return self;
}

- (instancetype)resultWithIssuesAtPoint:(CGPoint)point {
  NSMutableArray<GSCXScannerIssue *> *filteredIssues = [[NSMutableArray alloc] init];
  for (GSCXScannerIssue *issue in self.issues) {
    if (CGRectContainsPoint(issue.frame, point)) {
      [filteredIssues addObject:issue];
    }
  }
  return [[GSCXScannerResult alloc] initWithIssues:filteredIssues screenshot:self.screenshot];
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
  GTX_ASSERT(NO, @"Should not reach end of method for count %ld at index %ld.",
             (long)self.issueCount, (long)index);
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

- (NSString *)htmlDescription:(GSCXReportContext *)context {
  NSMutableArray *htmlSnippets  = [[NSMutableArray alloc] init];
  [htmlSnippets addObject:@"<meta charset=\"UTF-8\">"];
  for (GSCXScannerIssue *issue in self.issues) {
    [htmlSnippets addObject:[issue htmlDescription]];
  }
  [htmlSnippets addObject:@"<hr>"];
  [htmlSnippets addObject:@"<h2>Window Screenshot</h2>"];
  UIImage *annotatedScreenshot = [self gscx_annotatedScreenshot];
  NSString *screenshotPath = [context pathByAddingImage:annotatedScreenshot];
  [htmlSnippets addObject:[NSString stringWithFormat:@"<img src=\"%@\" />", screenshotPath]];
  return [htmlSnippets componentsJoinedByString:@"<br/>"];
}

- (CGRect)originalScreenshotFrame {
  return _originalScreenshotFrame;
}

- (void)moveIssuesWithExistingElementsFromResult:(GSCXScannerResult *)result {
  NSMutableArray<GSCXScannerIssue *> *currentIssues = [NSMutableArray array];
  NSMutableArray<GSCXScannerIssue *> *otherIssues = [result.issues mutableCopy];
  for (GSCXScannerIssue *issue in self.issues) {
    BOOL hasFoundDuplicate = NO;
    for (NSInteger i = (NSInteger)[otherIssues count] - 1; i >= 0; i--) {
      if ([issue hasEqualElementAsIssue:otherIssues[i]]) {
        hasFoundDuplicate = YES;
        [currentIssues addObject:[issue issueByCombiningWithDuplicateIssue:otherIssues[i]]];
        [otherIssues removeObjectAtIndex:i];
        // Issues in GSCXScannerResult objects are assumed to be unique, so it is not possible to
        // find another issue with equal element.
        break;
      }
    }
    if (!hasFoundDuplicate) {
      [currentIssues addObject:issue];
    }
  }
  _issues = [NSArray arrayWithArray:currentIssues];
  result->_issues = [NSArray arrayWithArray:otherIssues];
}

+ (NSArray<GSCXScannerResult *> *)resultsArrayByDedupingResultsArray:
    (NSArray<GSCXScannerResult *> *)results {
  NSMutableArray<GSCXScannerResult *> *dedupedResults = [results mutableCopy];
  for (NSInteger i = 0; i < (NSInteger)[dedupedResults count]; i++) {
    for (NSInteger j = i + 1; j < (NSInteger)[dedupedResults count]; j++) {
      [dedupedResults[i] moveIssuesWithExistingElementsFromResult:dedupedResults[j]];
    }
    if ([dedupedResults[i].issues count] == 0) {
      [dedupedResults removeObjectAtIndex:i];
      i--;
    }
  }
  return [NSArray arrayWithArray:dedupedResults];
}

#pragma mark - Private

/**
 * @return An image highlighting all elements with accessibility issues with ring views.
 */
- (UIImage *)gscx_annotatedScreenshot {
  GSCXRingViewArranger *arranger = [[GSCXRingViewArranger alloc] initWithResult:self];
  CGRect originalCoordinates = [[UIScreen mainScreen] bounds];
  UIImageView *superview = [[UIImageView alloc] initWithImage:self.screenshot];
  return [arranger imageByAddingRingViewsToSuperview:superview fromCoordinates:originalCoordinates];
}

@end

NS_ASSUME_NONNULL_END
