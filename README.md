<p align="center" >
  <img src="https://font-smoothing-adjuster-updates.s3.eu-west-2.amazonaws.com/app-icon-128%402x.png" alt="Font Smoothing Adjuster" title="Font Smoothing Adjuster" width="128" height="128">
</p>

![GitHub release (latest by date)](https://img.shields.io/github/v/release/bouncetechnologies/Font-Smoothing-Adjuster)
![Languages](https://img.shields.io/badge/Languages-en%2C%20es%2C%20fr%2C%20de-brightgreen)

# Font Smoothing Adjuster
### Re-enable the font smoothing controls removed in macOS Big Sur.
Font Smoothing Adjuster is a tiny, native macOS app that lets you adjust your font smoothing preferences in a graphical user interface. Issues and pull requests welcome!

<img src="https://font-smoothing-adjuster-updates.s3.eu-west-2.amazonaws.com/app-dark-disabled%402x.png" alt="Screenshot of the Font Smoothing Adjuster app" width="529" height="343">

Download the app at [fontsmoothingadjustor.com](https://www.fontsmoothingadjustor.com).

## What is font smoothing?
Font smoothing is something that macOS does to make your fonts look slightly bolder. This has the side-effect of messing with carefully designed character shapes produced by font creators, and makes text more blurry. See the font smoothing section of [Nikita Prokopov’s excellent article](https://tonsky.me/blog/monitors/#turn-off-font-smoothing) for more details.

## Why did you make this app?
On previous releases of macOS, you could disable font smoothing from the General pane of the System Preferences app, but this option has been removed from macOS Big Sur.
This annoyed us, so we made a tiny app that lets you easily choose what level of font smoothing you would like, or disable it altogether.

## Can't I just use terminal commands to adjust font smoothing?
Absolutely. If you’re comfortable using a terminal, you can also use the following commands to set your desired level of font smoothing instead of using the app. You will need to log off or restart your Mac for the changes to take effect.

#### Disable font smoothing:
```defaults -currentHost write -g AppleFontSmoothing -int 0```
#### Light font smoothing:
```defaults -currentHost write -g AppleFontSmoothing -int 1```
#### Medium font smoothing (default):
```defaults -currentHost write -g AppleFontSmoothing -int 2```
#### Heavy font smoothing:
```defaults -currentHost write -g AppleFontSmoothing -int 3```
#### Reset to default font smoothing level (medium):
```defaults -currentHost delete -g AppleFontSmoothing```

## Building and running
Make sure you have Xcode installed and set up on your machine.

#### Clone the project:
```git clone https://github.com/bouncetechnologies/Font-Smoothing-Adjuster.git```

#### Navigate to the project directory and open the Xcode project:
```cd Font-Smoothing-Adjuster```

```open "Font Smoothing Adjuster.xcodeproj"```

####  Set your development team
Update the settings in Signing & Capabilities for the Font Smoothing Adjuster target.

####  Configure Signing Certificate
Make sure Signing Certificate is set to Development

#### Build and run the project

Select Product -> Run from the menu, or press ⌘R

#### Run the tests

Please back up your current font smoothing preferences before running the tests.

Select Product -> Test from the menu, or press ⌘U
