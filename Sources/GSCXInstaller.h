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

#import <Foundation/Foundation.h>

#import "GSCXInstallerOptions.h"
#import "GSCXScannerOverlayWindow.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains methods for installing the overlay window and scanner UI into an application.
 *
 * @note It is the application's responsibility to ensure the scanner is not installed in release
 * builds.
 */
@interface GSCXInstaller : NSObject

; /**
   * Creates the scanner UI in a window overlaid on the main application window. The caller of this
   * method owns the returned window.
   *
   * @param options Configures the scanner.
   * @return A window containing the UI to manually perform scans and see scan results.
   */
+ (GSCXScannerOverlayWindow *)installScannerWithOptions:(GSCXInstallerOptions *)options;

/**
 * Creates the scanner UI in a window overlaid on the main application window. Uses the default set
 * of checks, no excludeLists, and no delegate. The overlay is installed on the current key window.
 * The caller of this method owns the returned window.
 *
 * @return A window containing the UI to manually perform scans and see scan results.
 */
+ (GSCXScannerOverlayWindow *)installScanner;

@end

NS_ASSUME_NONNULL_END
