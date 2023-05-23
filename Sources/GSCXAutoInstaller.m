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

#import "GSCXAutoInstaller.h"

#import "GSCXInstaller.h"
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

#pragma mark - GSCXAutoInstallerAppListener Interface

/**
 * Listens to app notifications and installs scanner when app is launched.
 */
@interface GSCXAutoInstallerAppListener : NSObject

/**
 * Begin listening for app notifications.
 */
+ (void)gscx_startListening;

@end

#pragma mark - GSCXAutoInstallerAppListener Implementation

@implementation GSCXAutoInstallerAppListener {
  UIWindow *_overlayWindow;
}

+ (instancetype)gscx_defaultListener {
  static dispatch_once_t onceToken;
  static GSCXAutoInstallerAppListener *defaultInstance;
  dispatch_once(&onceToken, ^{
    defaultInstance = [[GSCXAutoInstallerAppListener alloc] init];
  });
  return defaultInstance;
}

+ (void)gscx_startListening {
  NSString *notificationName = UIApplicationDidFinishLaunchingNotification;
  if (@available(iOS 13.0, *)) {
    // on iOS 13 and on, all apps use UIScene. Even if the developer does not
    // manually handle scenes using UISceneDelegate, the operating system still
    // constructs a scene and sends the did activate notification.
    notificationName = UISceneDidActivateNotification;
  }
  [[NSNotificationCenter defaultCenter]
      addObserver:[GSCXAutoInstallerAppListener gscx_defaultListener]
         selector:@selector(applicationDidFinishLaunching:)
             name:notificationName
           object:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  if (_overlayWindow != nil) {
    // In UIScene applications, it is valid for this method to be called multiple times.
    // Log but do not crash with an assertion.
    [[GTXLogger defaultLogger] logWithLevel:GTXLogLevelDeveloper
                                     format:@"iOS Scanner was already installed."];
    return;
  }
  _overlayWindow = [GSCXInstaller installScanner];
}

@end

#pragma mark - GSCXAutoInstaller Implementation

@implementation GSCXAutoInstaller

+ (void)load {
  [GSCXAutoInstallerAppListener gscx_startListening];
}

@end

NS_ASSUME_NONNULL_END
