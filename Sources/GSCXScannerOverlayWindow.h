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

#import "GSCXContinuousScanner.h"

/**
 * A window that forwards touch events to UI elements that lie behind this window. Touch events on
 * the specific perform scan button are handled normally. They are not forwarded.
 */
@interface GSCXScannerOverlayWindow : UIWindow

/**
 * The UI element that presents the settings page. This instance is allowed to receive touch events.
 * Touches on all other descendants are forwarded to the application window. It is the
 * responsibility of this instance's owner to set this property.
 */
@property(weak, nonatomic) UIButton *settingsButton;

/**
 * The Scanner object associated with this window, use this to interact directly with the scan
 * operations.
 */
@property(weak, nonatomic) GSCXContinuousScanner *continuousScanner;

@end
