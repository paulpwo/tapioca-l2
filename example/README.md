# video_editor_example

Demonstrates how to use the video_editor plugin.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Fix problems on IOS Mac M1
    ´´´
    flutter pub cache clean && flutter pub get
    cd ios && arch -x86_64 pod install --repo-update&& cd ../   
    ´´´