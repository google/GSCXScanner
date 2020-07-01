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

#import <UIKit/UIKit.h>

#import "GSCXReport.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Invoked when a @c GSCXSharingDelegate instance finishes its share action.
 */
typedef void (^GSCXSharingDelegateCompletionBlock)(void);

/**
 * Determines how a @c GSCXReport instance should be shared with an external service. This instance
 * is responsible for determining what "share" means.
 */
@protocol GSCXSharingDelegate <NSObject>

/**
 * Implements the share action for @c report. @c shareReport should not be called again until the
 * share action completes. Does nothing if a share action is currently in progress.
 *
 * @param report The report to be shared.
 * @param viewController The currently visible view controller. This instance can use
 * @c viewController to display results or share sheet.
 * @param completionBlock Optional. Invoked when the share action has finished.
 * @return @c YES if the share action successfully started, @c NO if the share action could not be
 * started becasue another action was already in progress.
 */
- (BOOL)shareReport:(GSCXReport *)report
    inViewController:(UIViewController *__weak)viewController
          completion:(nullable GSCXSharingDelegateCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
