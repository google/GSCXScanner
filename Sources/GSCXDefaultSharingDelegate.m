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

#import "GSCXDefaultSharingDelegate.h"

#import <UIKit/UIKit.h>

#import "GSCXReport.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSCXDefaultSharingDelegate ()

/**
 * @c YES if a share action is in progress, @c NO otherwise.
 */
@property(assign, nonatomic, getter=isSharing) BOOL sharing;

/**
 * Invoked when the share action completes.
 */
@property(copy, nonatomic, nullable) GSCXSharingDelegateCompletionBlock completionBlock;

@end

@implementation GSCXDefaultSharingDelegate

- (BOOL)shareReport:(GSCXReport *)report
    inViewController:(UIViewController *__weak)viewController
          completion:(nullable GSCXSharingDelegateCompletionBlock)completionBlock {
  if (self.sharing) {
    return NO;
  }
  self.sharing = YES;
  self.completionBlock = completionBlock;
  __weak __typeof__(self) weakSelf = self;
  [GSCXReport createPDFReport:report
              completionBlock:^(NSURL *reportUrl) {
                [weakSelf gscx_shareReportAtURL:reportUrl inViewController:viewController];
              }
                   errorBlock:nil];
  return YES;
}

#pragma mark - Private

/**
 * Shares the report stored at @c url by presenting an activity sheet in @c viewController. Invokes
 * @c completionBlock when the activity sheet is dismissed, if it exists.
 *
 * @param url A local file url containing the item to share.
 * @param viewController The view controller to present the activity sheet in.
 */
- (void)gscx_shareReportAtURL:(NSURL *)url
             inViewController:(UIViewController *__weak)viewController {
  NSArray *activityItems = @[ url ];
  UIActivityViewController *activityController =
      [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                        applicationActivities:nil];
  activityController.popoverPresentationController.barButtonItem =
      viewController.navigationItem.rightBarButtonItem;
  __weak __typeof__(self) weakSelf = self;
  activityController.completionWithItemsHandler =
      ^(UIActivityType _Nullable activityType, BOOL completed, NSArray<id> *_Nullable returnedItems,
        NSError *_Nullable activityError) {
        [weakSelf gscx_onSharingComplete];
      };
  [viewController presentViewController:activityController animated:YES completion:nil];
}

/**
 * Invoked when the activity controller finishes sharing. Invokes the completion block, if it
 * exists.
 */
- (void)gscx_onSharingComplete {
  self.sharing = NO;
  if (self.completionBlock != nil) {
    self.completionBlock();
    self.completionBlock = nil;
  }
}

@end

NS_ASSUME_NONNULL_END
