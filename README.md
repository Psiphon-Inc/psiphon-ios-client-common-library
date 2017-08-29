# PsiphonClientCommonLibrary

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first. Then open `PsiphonClientCommonLibrary.xcworkspace` in Xcode.

## Requirements

[CocoaPods](https://cocoapods.org/).

## Installation

To install, simply add the following line to your Podfile:

```ruby
pod 'PsiphonClientCommonLibrary', :git => "https://github.com/Psiphon-Inc/psiphon-ios-client-common-library.git"
```

## App Integration

### Psiphon Settings

Copy `psiphon-ios-client-common-library/Example/PsiphonClientCommonLibrary/InAppSettings.bundle` into your project and customize it to fit the needs of the project it is being used in. You can find more information on how InAppSettingsKit works [here](https://github.com/Psiphon-Inc/InAppSettingsKit/blob/master/README.md).

Use `PsiphonSettingsViewController` for displaying the shared settings menu. Subclass it to provide any functionality for new project specific settings.

## Development

### Getting Started
```bash
cd ./Example
pod install
open PsiphonClientCommonLibrary.xcworkspace
```
Now you can start making changes to the pod by working with the files in `Pods/Development Pods` in the Xcode project.

### Adding a new server region

1. In Xcode, under the Resources group, click on `Images.xcassets`. Note the assets list that appears.
2. In Finder, go to `psiphon-ios-client-common-library/External/flag-icon-css/flags/4x3`. Select the files `flag-zz.png`, `flag-zz@2x.png`, and `flag-zz@3x.png`, where `zz` is the region you want.
3. Drag the selected files onto the assets list in Xcode.
4. In `RegionAdapter.m`, update the `init` and `getLocalizedRegionTitles` functions with the new region.
5. Compile the app, so that the strings files get updated.

## Author

Psiphon Inc.

## License

PsiphonClientCommonLibrary is available under the GPLv3 license. See the LICENSE file for more info.
