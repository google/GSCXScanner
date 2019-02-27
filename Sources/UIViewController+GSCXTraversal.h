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

#import "GSCXWindowOverlayPair.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (GSCXTraversal)

/**
 *  Traverses backward through the view controller hierarchy to find the first view
 *  controller of type GSCXWindowOverlayViewController whose windowOverlayPair is not
 *  nil. Takes into account UINavigationController, UITabViewController,
 *  UISplitViewController, and any presented view controllers. If no such view
 *  controller can be found, returns nil.
 */
- (GSCXWindowOverlayPair* _Nullable)windowOverlayPairAncestor;

@end

NS_ASSUME_NONNULL_END
