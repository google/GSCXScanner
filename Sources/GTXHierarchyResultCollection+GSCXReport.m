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

#import "GTXHierarchyResultCollection+GSCXReport.h"

#import "GSCXRingViewArranger.h"
#import "GTXElementResultCollection+GSCXReport.h"

NS_ASSUME_NONNULL_BEGIN

@implementation GTXHierarchyResultCollection (GSCXReport)

- (NSString *)htmlDescription:(GSCXReportContext *)context {
  NSMutableArray *htmlSnippets = [[NSMutableArray alloc] init];
  [htmlSnippets addObject:@"<meta charset=\"UTF-8\">"];
  for (GTXElementResultCollection *elementResult in self.elementResults) {
    [htmlSnippets addObject:[elementResult htmlDescription]];
  }
  [htmlSnippets addObject:@"<hr>"];
  [htmlSnippets addObject:@"<h2>Window Screenshot</h2>"];
  UIImage *annotatedScreenshot = [self gscx_annotatedScreenshot];
  NSString *screenshotPath = [context pathByAddingImage:annotatedScreenshot];
  [htmlSnippets addObject:[NSString stringWithFormat:@"<img src=\"%@\" />", screenshotPath]];
  return [htmlSnippets componentsJoinedByString:@"<br/>"];
}

#pragma mark - Private

/**
 * @return An image highlighting all elements with accessibility issues with ring views.
 */
- (UIImage *)gscx_annotatedScreenshot {
  GSCXRingViewArranger *arranger = [[GSCXRingViewArranger alloc] initWithResult:self];
  CGRect originalCoordinates =
      CGRectMake(0, 0, self.screenshot.size.width, self.screenshot.size.height);
  UIImageView *superview = [[UIImageView alloc] initWithImage:self.screenshot];
  return [arranger imageByAddingRingViewsToSuperview:superview fromCoordinates:originalCoordinates];
}

@end

NS_ASSUME_NONNULL_END
