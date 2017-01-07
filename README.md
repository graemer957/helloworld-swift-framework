# HelloWorld Swift Framework
[![Build Status](https://img.shields.io/travis/graemer957/helloworld-swift-framework/master.svg?style=flat-square)](https://travis-ci.org/graemer957/helloworld-swift-framework)
[![Language](https://img.shields.io/badge/language-Swift%203.0-orange.svg?style=flat-square)](https://developer.apple.com/swift/)
[![Platforms](https://img.shields.io/badge/platform-ios-yellow.svg?style=flat-square)](http://www.apple.com/ios/)
[![License](https://img.shields.io/badge/license-Apache--2.0-lightgrey.svg?style=flat-square)](https://github.com/graemer957/helloworld-swift-framework/blob/master/LICENSE)

Document the process for creating a Swift Frameworks for iOS.  This repo provides an example framework in the form of the utterly useless `HelloWorld.framework`.

# Build environment
- Xcode 8.2.1
- Swift 3.0.2
- macOS 10.12.2

# Steps
1. Create new iOS Xcode project of type `Cocoa Touch Framework`. In this case I used the name `HelloWorld`.
2. Add required functionality to the framework. For demo purposes I've added a public function `HelloWorld.sayIt()`
3. Add aggregate build target called `Framework` (found under `Cross-platform`)
4. Add a new 'New Run Script Phase' to this target
5. Rename the `Run Script` to `Build Framework` and copy the following script:
```
######################
# Options
######################
set -x -e
FRAMEWORK_NAME="${PROJECT_NAME}"
CONFIGURATION=Release
SIMULATOR_LIBRARY_PATH="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${FRAMEWORK_NAME}.framework"
DEVICE_LIBRARY_PATH="${BUILD_DIR}/${CONFIGURATION}-iphoneos/${FRAMEWORK_NAME}.framework"
FRAMEWORK="${PROJECT_DIR}/${FRAMEWORK_NAME}.framework"


######################
# Build
######################
# Build for simulator
xcodebuild -target ${PROJECT_NAME} -sdk iphonesimulator -configuration ${CONFIGURATION} ARCHS="i386 x86_64" ONLY_ACTIVE_ARCH=NO clean build CONFIGURATION_BUILD_DIR=${BUILD_DIR}/${CONFIGURATION}-iphonesimulator

# Build for device
xcodebuild -scheme ${PROJECT_NAME} -sdk iphoneos -configuration ${CONFIGURATION} ARCHS="armv7 arm64" ONLY_ACTIVE_ARCH=NO clean archive CONFIGURATION_BUILD_DIR=${BUILD_DIR}/${CONFIGURATION}-iphoneos


######################
# Create universal framework
######################
mkdir "${FRAMEWORK}"


######################
# Copy files Framework
######################
cp -r "${DEVICE_LIBRARY_PATH}/." "${FRAMEWORK}"


######################
# Make universal binary
######################
lipo "${SIMULATOR_LIBRARY_PATH}/${FRAMEWORK_NAME}" "${DEVICE_LIBRARY_PATH}/${FRAMEWORK_NAME}" -create -output "${FRAMEWORK}/${FRAMEWORK_NAME}" | echo

# For Swift framework, Swiftmodule needs to be copied in the universal framework
if [ -d "${SIMULATOR_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" ]; then
	cp -fr ${SIMULATOR_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/ "${FRAMEWORK}/Modules/${FRAMEWORK_NAME}.swiftmodule/" | echo
fi

if [ -d "${DEVICE_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" ]; then
	cp -fr ${DEVICE_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/ "${FRAMEWORK}/Modules/${FRAMEWORK_NAME}.swiftmodule/" | echo
fi


######################
# Cleanup build artifacts
######################
rm -rf "${PROJECT_DIR}/build"
```

# Resources
- http://stackoverflow.com/questions/35586516/is-it-possible-to-create-a-universal-ios-framework-using-bitcode

# Notes
- The `Build Framework` script above, only builds for armv7 and arm64, **armv7s** is not included
- Use `lipo -info <path to binary>` to check the framework contains your desired platforms
- Use `otool -l -arch <arch> <path to binary> | grep __LLVM` to check bitcode is enabled

# TODO
- Gather .dSYMs from builds
- Make use of `strip_frameworks.sh` from Realm to fix consumer issue when archiving
- Clean up empty `.xcarchive`'s
