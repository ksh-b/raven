# raven

News Reader

This app uses APIs and web scraping to fetch news articles.

## NOTE
If you are installing 1.0.0 please read [Status](#status) and [Anti Feature](#anti-feature) first. You can try out the latest build from Github actions.

## Features
- Multiple sources
- Category selection
- Translation
- No ads / paywalls


## Installation
Get it on
- [![IzzyOnDroid](https://img.shields.io/endpoint?url=https://apt.izzysoft.de/fdroid/api/v1/shield/kshib.raven)](https://apt.izzysoft.de/fdroid/index/apk/kshib.raven)
- [![F-Droid Version](https://img.shields.io/f-droid/v/kshib.raven?color=blue&label=F-Droid)](https://f-droid.org/en/packages/kshib.raven)
- [![Github releases](https://img.shields.io/github/v/release/ksh-b/raven?label=Github)](https://github.com/ksh-b/raven/releases/latest)
- Or via [Obtanium](https://github.com/ImranR98/Obtainium)
- [Github actions](https://github.com/ksh-b/raven/actions)

## Screenshots
<table>
  <tr>
    <td><a href="https://github.com/ksh-b/raven/blob/master/fastlane/metadata/android/en-US/images/phoneScreenshots/1.png"><img src="https://github.com/ksh-b/raven/blob/master/fastlane/metadata/android/en-US/images/phoneScreenshots/1.png?raw=true" width="200"  alt="Feed"></a></td>
    <td><a href="https://github.com/ksh-b/raven/blob/master/fastlane/metadata/android/en-US/images/phoneScreenshots/2.png"><img src="https://github.com/ksh-b/raven/blob/master/fastlane/metadata/android/en-US/images/phoneScreenshots/2.png?raw=true" width="200"  alt="Subscriptions"></a></td>
    <td><a href="https://github.com/ksh-b/raven/blob/master/fastlane/metadata/android/en-US/images/phoneScreenshots/3.png"><img src="https://github.com/ksh-b/raven/blob/master/fastlane/metadata/android/en-US/images/phoneScreenshots/3.png?raw=true" width="200"  alt="Settings"></a></td>
  </tr>
</table>
<table>
  <tr>
    <td><a href="https://github.com/ksh-b/raven/blob/master/fastlane/metadata/android/en-US/images/phoneScreenshots/4.png"><img src="https://github.com/ksh-b/raven/blob/master/fastlane/metadata/android/en-US/images/phoneScreenshots/4.png?raw=true" width="300"  alt="English Article"></a></td>
    <td><a href="https://github.com/ksh-b/raven/blob/master/fastlane/metadata/android/en-US/images/phoneScreenshots/5.png"><img src="https://github.com/ksh-b/raven/blob/master/fastlane/metadata/android/en-US/images/phoneScreenshots/5.png?raw=true" width="300"  alt="Translated Article"></a></td>
  </tr>
</table>

## Status
Thank you for your interest in this project! Please note that this project is maintained in my spare time, so updates and new features may not be as frequent.
Due to multiple requests for including various sources directly within the app, I made the decision to remove all built-in sources starting with version 1.0.0. This change simplifies maintenance and allows users to create and manage their own sources independently.<br>
For a quick start on adding and managing your own sources, please refer to our detailed guide in the [wiki](https://github.com/raven-repo/wiki/wiki) (WIP). Please do not create further issues for adding new sources. If you have any questions feel free to reach out. 

## Anti Feature
Starting from 1.0.0, raven uses GoogleML Kit for translation. This dependency [connects to firebase](https://github.com/flutter-ml/google_ml_kit_flutter/issues/198) when in use. [Steps](https://firebase.google.com/docs/perf-mon/disable-sdk?platform=android#disable-library) have been taken to prevent the logging.<br>
The earlier way of translating using [SimplyTranslate](https://simplytranslate.org/) did not work well with certain content. Hence the move, but I am open to any better alternatives.

## Contributing
All contributions are welcome! Please read [contributing.md](https://github.com/ksh-b/raven/blob/master/contributing.md) if you are interested.

## License
GNU GPLv3
