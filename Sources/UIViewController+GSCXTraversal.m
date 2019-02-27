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

#import "UIViewController+GSCXTraversal.h"

#import <UIKit/UIKit.h>

#import "GSCXWindowOverlayViewController.h"

@implementation UIViewController (GSCXTraversal)

- (GSCXWindowOverlayPair *_Nullable)windowOverlayPairAncestor {
  GSCXWindowOverlayPair *windowOverlayPair = nil;
  if ([self respondsToSelector:@selector(windowOverlayPair)]) {
    windowOverlayPair = [(id)self windowOverlayPair];
  }
  windowOverlayPair = [self _assignAndAssertWindowOverlayPair:windowOverlayPair
                                                   controller:self.presentingViewController];
  windowOverlayPair = [self _assignAndAssertWindowOverlayPair:windowOverlayPair
                                                   controller:self.parentViewController];
  windowOverlayPair = [self _assignAndAssertWindowOverlayPair:windowOverlayPair
                                                   controller:self.tabBarController];
  windowOverlayPair = [self _assignAndAssertWindowOverlayPair:windowOverlayPair
                                                   controller:self.splitViewController];
  windowOverlayPair = [self _assignAndAssertWindowOverlayPair:windowOverlayPair
                                                   controller:self.navigationController];
  return windowOverlayPair;
}

- (GSCXWindowOverlayPair *_Nullable)
    _assignAndAssertWindowOverlayPair:(GSCXWindowOverlayPair *_Nullable)windowOverlayPair
                           controller:(UIViewController *)controller {
  GSCXWindowOverlayPair *_Nullable controllerPair = [controller windowOverlayPairAncestor];
  NSAssert(
      windowOverlayPair == controllerPair || windowOverlayPair == nil || controllerPair == nil,
      @"Multiple view controllers in a hierarchy may not contain GSCXWindowOverlayPair instances.");
  return windowOverlayPair ?: controllerPair;
}

@end
