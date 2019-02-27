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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Encapsulates the main application window and the overlay window used to display the scanner UI.
 *  Provides functionality to change which window is the key window, which is necessary to make
 *  inputs and VoiceOver work correctly with the overlay.
 */
@interface GSCXWindowOverlayPair : NSObject

/**
 *  The scanner window overlaying the main application window.
 */
@property(weak, nonatomic, nullable) UIWindow *overlayWindow;
/**
 *  The original application window that gets scanned.
 */
@property(weak, nonatomic, nullable) UIWindow *applicationWindow;

/**
 *  Initializes a GSCXWindowOverlayPair object with overlayWindow and
 *  applicationWindow.
 */
- (instancetype)initWithOverlayWindow:(UIWindow *)overlayWindow
                    applicationWindow:(UIWindow *)applicationWindow;
/**
 *  Makes either @c overlayWindow or @c applicationWindow the key window depending on whether the
 *  overlay is transparent.
 *
 *  @param isTransparentOverlay Determines whether the overlay is transparent or not. If YES, makes
 *  overlayWindow the key window. If NO, makes applicationWindow the key window.
 */
- (void)makeKeyWindowTransparentOverlay:(BOOL)isTransparentOverlay;

@end

NS_ASSUME_NONNULL_END
