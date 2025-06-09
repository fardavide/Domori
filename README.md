# Domori 🏠

A modern, buyers' companion for property listing management app for iPhone, iPad, and macOS. Built with Swift and designed for anyones who's in the process of buying home, and needs a reliable single platform where to keep track of interesting properties.

> **AI Experiment Update**: This project started as an experiment using AI for development. **Through version 1.1, AI wrote 100% of the code** while the developer only reviewed changes using technical expertise and approved them - the developer didn't write a single line of code. However, AI has proven to be **highly unreliable**: it frequently changes unwanted parts of code, breaks 5 things while fixing 1, doesn't run tests properly, and debugging is troublesome because AI often falsely claims tests have passed. The AI also tends to write poor quality code, putting excessive logic into Views instead of following proper architecture patterns. **Starting from version 1.1, the developer will take over maintaining the project and writing code**, while **AI will only be used for drafting or creating proof-of-concepts for major changes/features**. All AI-generated code will be carefully analyzed by the developer to ensure it's well-tested, follows clean code principles, and adheres to project guidelines and best practices.

## ✨ Features

- 📝 **Property Management**: Add, edit, and organize property listings with comprehensive details
- 🏷️ **Smart Tagging System**: Custom tags with rating-based color coding, to notate pros and cons
- ⭐ **Advanced Rating System**: 5-level rating system (None, Excluded, Considering, Good, Excellent) to assign a summary rating
- 🔍 **Search & Filter**: Advanced search and multiple sorting options
- 📊 **Property Comparison**: Side-by-side analysis with automatic best value highlighting
- ☁️ **iCloud Sync**: Seamless synchronization across all devices via CloudKit
- 🌍 **International Support**: Locale-aware currency and unit formatting
- 🖥️ **Cross-Platform**: Native UI for iOS, iPadOS, and macOS

## 🛠️ Technical Stack

- **Language**: Swift 6.0
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData with CloudKit
- **Testing**: swift-testing framework
- **Platforms**: iOS 18.5+, iPadOS 18.5+, macOS 14+, visionOS 2.5+

## 🚀 Getting Started

### Prerequisites
- Xcode 16.0 or later
- Apple Developer account (for CloudKit features)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/domori.git
cd domori
```

2. Open in Xcode:
```bash open Domori.xcodeproj```

3. Configure CloudKit:
   - Set your Apple Developer Team ID in project settings
   - Enable CloudKit capabilities in your Apple Developer account

4. Build and run with `Cmd+R`

## 🧪 Testing

The project uses the modern swift-testing framework with comprehensive coverage:

- **Unit Tests**: Models, business logic, and data operations
- **Migration Tests**: Data model transitions and edge cases
- **Integration Tests**: Cross-component functionality
- **UI Tests**: User interface and screenshot automation

### Running Tests
```bash
# Run all tests
Cmd+U

# Run on specific simulator
xcodebuild test -project Domori.xcodeproj -scheme Domori -destination "platform=iOS Simulator,name=iPhone 16 Pro"
```

## 🌍 Internationalization

The app automatically adapts to your device's regional settings:

- **Currency**: Detects and uses local currency (€, £, $, ¥, etc.)
- **Measurements**: Metric (m²) or Imperial (sq ft) based on locale
- **Formatting**: Native number and currency display

## 🔄 Data Migration

Includes robust migration system that handles:
- Legacy data model transitions
- Automatic rating value mapping
- Backwards compatibility
- Validation and error handling

## 📸 App Store Screenshots

Automated screenshot generation for App Store submission is included. Screenshots showcase:
- Main property list with European properties
- Add property form with all fields completed
- Property detail view with tags and ratings
- Custom tag creation interface
- Property comparison functionality

## 🔧 Version History

For complete version history, see [CHANGELOG.md](CHANGELOG.md).

## 📚 Documentation

- [Testing Strategy](TESTING_STRATEGY.md) - Testing guidelines and best practices
- [Code Style](CODE_STYLE.md) - Coding standards and conventions
- [Development Practices](DEVELOPMENT_PRACTICES.md) - Workflow guidelines
- [UI Guidelines](UI_GUIDELINES.md) - Design standards
- [Screenshot Requirements](SCREENSHOT_REQUIREMENTS.md) - App Store specifications

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes following the code style guidelines
4. Add comprehensive tests
5. Ensure all tests pass on both iOS and macOS
6. Submit a pull request

## 📄 License

This project is available under the [MIT License](LICENSE).
