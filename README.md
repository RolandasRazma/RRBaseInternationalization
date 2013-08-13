RRBaseInternationalization
==========================

**iOS6** "Base Internationalization" backport to **iOS5**

Disclaimer
============
Use at your own risk. This is App Store valid. iPad version of [@YPlan](http://yplanapp.com) uses it for **iOS5** support :)

Will it slow down my iOS6+ app?
============
It will have no effect on your app. On iOS versions where "Base Internationalization" supported by default, the default implementation is used.

How to use it in my project?
============
Just drop `RRLocalizableString.h` and `RRLocalizableString.m` into your project and forget about them :)<br />
Set **Deployment tartget** to **iOS6** for **Interface Builder file** (xib or storyboard)<br />
Use **Xcode 4x** to build

This is wicked, do you have more?
============
Check out ["Container View" backport to iOS5](https://github.com/RolandasRazma/RRContainerView)<br />
Check out [iOS7 backports](https://github.com/RolandasRazma/RRiOS7Backport)
