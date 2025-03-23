# RookRadar3 Development Guide

## Build & Test Commands
- Build: `xcodebuild -project RookRadar3.xcodeproj -scheme RookRadar3 build`
- Run: `xcodebuild -project RookRadar3.xcodeproj -scheme RookRadar3 run`
- Test all: `xcodebuild -project RookRadar3.xcodeproj -scheme RookRadar3 test`
- Run single test: `xcodebuild -project RookRadar3.xcodeproj -scheme RookRadar3 test -only-testing:RookRadar3Tests/[TestClass]/[testMethod]`

## Code Style Guidelines
- **Imports**: Group SwiftUI/Foundation imports first, then other frameworks
- **Formatting**: 4-space indentation, braces on same line
- **Types**: Use Swift's strong type system, avoid `Any` where possible
- **Naming**: 
  - `camelCase` for variables/functions
  - `PascalCase` for types/protocols
  - Use descriptive names that convey purpose
- **Documentation**: Use `// MARK: -` for section organization
- **Error Handling**: Use proper Swift error handling with do/catch blocks
- **Architecture**: Follow MVVM pattern where appropriate
- **SwiftUI Practices**: Prefer @State, @Binding, @ObservedObject for UI state management

## Project Overview
iBeacon-based location tracking for consultants to monitor time spent in different work contexts (home, office, car).