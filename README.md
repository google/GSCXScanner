## What is Google Scanner for A11y?

Google Scanner for A11y abbreviated GSCX is a developer assistant, as an
objective-C library it sits in an iOS app's process scanning it for issues to
catch them before the developer even writes a test for them. The scanner comes
built-in with checks for catching accessibility issues and supports an
extensible plugin framework for adding your own checks.

## Getting Started

To install the scanner into your app create a copy of your app target and
add `GSCXScanner` library as a dependency to it.

Launch this new app target and your will notice a "Perform Scan" button overlaid
on top of the app. Tap it and Scanner will scan you app and tell you if any
issues are found.

**WARNING** You must not add this dependency directly to you app target but
only to a copy of it so as to ensure you never ship your app with accessibility
scanner installed on it.

One additional step needed will be to provide [`GTXiLib`](https://github.com/google/GTXiLib)
for the scanner framework to link to. If you have added static frameworks to
your app previously, this process will be very familiar.

### Installation Steps overview

1. Download `GSCXScanner`
2. Download [`GTXiLib`](https://github.com/google/GTXiLib)
3. Add `GSCXScanner.framework` to your App
4. Launch your app to scan its UI.

### 1. Download `GSCXScanner` repo
Download the `GSCXScanner` repo and unzip it.

### 2. Download `GTXiLib` repo
Download the [`GTXiLib`](https://github.com/google/GTXiLib), unzip it
and place it in the same parent directory as GSCXScanner. As an example, the
directory structure might look like this:

```
foo_root_dir/
    GSCXScanner/
    GTXiLib/
    ...
```

### 3. Add `GSCXScanner.framework` to your App

Add `GSCXScanner.xcodeproj` as a dependency for your app:
Either open you app's Xcode project and drag and drop the `GSCXScanner` Xcode
project file into the project navigator or choose
`File > Add Files` and select `GSCXScanner.xcodeproj`. Always choose
`add folder references` to prevent Xcode from making a copy of the project.

Under `Build Phases` of your app, add `GSCXScanner.framework` under both
`Target Dependencies` and `Link Binary With Libraries`.

### 4. Launch your app to scan its UI

Launch your app and the GSCXScanner UI will appear overlaid on top of the app's
UI. Use the app normally and at the point where you want to scan the app's UI
for accessibility issues, just press the `Scan` button located at the
bottom-left of the screen.

## Plugins

Scanner is extendable, to customize scanner use `GSCXScannerLib` instead
to the default scanner framework to avoid auto installing it on your app. and
then customize it using the APIs in `GSCXInstaller` class.

## Discuss

Please join us on the [ios-accessibility](https://groups.google.com/forum/#!forum/ios-accessibility)
Google group to discuss all things accessibility and also to keep a tab on all
updates to Scanner.

Note: This is not an official Google product.
