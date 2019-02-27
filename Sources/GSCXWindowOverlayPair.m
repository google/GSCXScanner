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

@implementation GSCXWindowOverlayPair

- (instancetype)initWithOverlayWindow:(UIWindow *_Nonnull)overlayWindow
                    applicationWindow:(UIWindow *_Nonnull)applicationWindow {
  self = [super init];
  if (self) {
    _overlayWindow = overlayWindow;
    _applicationWindow = applicationWindow;
  }
  return self;
}

- (void)makeKeyWindowTransparentOverlay:(BOOL)isTransparentOverlay {
  if (isTransparentOverlay) {
    [self.applicationWindow makeKeyWindow];
  } else {
    [self.overlayWindow makeKeyWindow];
  }
}

@end
