# Domori 🏠

> **AI Experiment**: This entire cross-platform app was built using [Cursor AI](https://cursor.com) as a proof-of-concept for AI-powered development. From initial concept to final implementation, every line of code, architecture decision, and feature was created through AI assistance.

A modern, production-ready property listing management app for iPhone, iPad, and macOS. Built with the latest Swift technologies and designed for real estate professionals, investors, and anyone managing property portfolios.

## 🤖 About This Project

This project represents an experiment in AI-powered software development using Cursor AI. The entire application was conceived, designed, and implemented through AI assistance, demonstrating the current capabilities of AI in creating production-ready, cross-platform mobile applications.

**Development Stack:**
- **AI Assistant**: Cursor AI (Claude Sonnet 4)
- **Language**: Swift 6.0
- **Frameworks**: SwiftUI, SwiftData, CloudKit
- **Platform**: iOS 18.5+, iPadOS 18.5+, macOS 14+, visionOS 2.5+
- **Testing**: swift-testing framework

## ✨ Features

### Core Functionality
- 📝 **Property Management**: Add, edit, and organize property listings
- 🏷️ **Smart Tagging**: Custom tags with 14 color options and predefined templates
- ⭐ **Advanced Rating System**: New PropertyRating enum with 5 levels (None, Excluded, Considering, Good, Excellent)
- 📸 **Photo Organization**: 16 categorized photo types (exterior, interior, kitchen, etc.)
- 📋 **Categorized Notes**: 8 note types (pros, cons, renovation, financial, etc.)
- 🔍 **Search & Filter**: Advanced search and multiple sorting options (including rating-based)

### International Support
- 🌍 **Locale-Aware**: Automatic currency detection (USD, EUR, GBP, etc.)
- 📏 **Unit Adaptation**: Smart metric/imperial system detection with iOS 16+ measurementSystem API
- 🏛️ **Regional Formatting**: Native number and currency formatting
- 🗺️ **Country-Specific**: Appropriate defaults for different markets

### Advanced Features
- 📊 **Property Comparison**: Side-by-side analysis with best value highlighting
- ☁️ **iCloud Sync**: Seamless synchronization across all devices
- 🎯 **Smart Sorting**: Date, price, size, title, and rating-based sorting options
- 💫 **Modern UI**: Beautiful SwiftUI interface with iOS design guidelines
- 🔄 **Data Migration**: Seamless migration from legacy rating systems
- 🖥️ **Cross-Platform**: Native UI adaptations for iOS, iPadOS, and macOS

## 🛠️ Technical Implementation

### Architecture
- **SwiftData**: Modern Core Data replacement for local persistence
- **CloudKit**: Automatic iCloud synchronization
- **SwiftUI**: Declarative UI framework with conditional compilation for platform-specific features
- **swift-testing**: Modern testing framework with comprehensive coverage

### Models
- `PropertyListing`: Main property model with relationships and migration support
- `PropertyRating`: Modern enum-based rating system (replacing legacy boolean favorites)
- `PropertyNote`: Categorized notes with color coding
- `PropertyPhoto`: Photo management with categories and sorting
- `PropertyTag`: Custom tagging system
- `DataMigrationManager`: Handles smooth transitions between data model versions

### Key Technical Features
- **Cross-Platform Compatibility**: Conditional compilation for iOS/macOS differences
- **Modern APIs**: Uses latest iOS 16+ measurementSystem API with fallback support
- **Type-Safe Enums**: PropertyRating enum for better type safety than numeric ratings
- **Migration System**: Handles legacy data transitions seamlessly
- **Build Stability**: Resolved Swift compiler type-checking issues for complex UIs
- **Test Coverage**: Comprehensive unit tests including migration scenarios

## 🔄 Data Migration

The app includes a robust migration system that handles:
- Legacy `isFavorite` boolean to new `PropertyRating` enum conversion
- Automatic rating value mapping (0.0-5.0 scale to enum values)
- Backwards compatibility for existing data
- Validation and error handling for edge cases

## 🌍 Internationalization

The app automatically adapts to your device's regional settings:

- **Currency**: Detects and uses local currency (€, £, $, ¥, etc.)
- **Measurements**: 
  - Metric countries: Square meters (m²)
  - Imperial countries: Square feet (sq ft)
  - Uses modern `measurementSystem` API (iOS 16+) with `usesMetricSystem` fallback
- **Formatting**: Native number and currency display
- **Countries Supported**: Worldwide with smart defaults

## 📱 Compatibility

- **iOS**: 18.5+
- **iPadOS**: 18.5+
- **macOS**: 14.0+
- **visionOS**: 2.5+
- **Xcode**: 16.0+
- **Swift**: 6.0+

## 🚀 Getting Started

### Prerequisites
- Xcode 16.0 or later
- iOS 18.5+ / macOS 14.0+ deployment target
- Apple Developer account (for CloudKit features)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/domori.git
cd domori
```

2. Open the project in Xcode:
```bash
open Domori.xcodeproj
```

3. Build and run:
   - Select your target device or simulator
   - Press `Cmd+R` to build and run

### Configuration

The app includes CloudKit entitlements for iCloud sync. For full functionality:

1. Configure your Apple Developer Team ID in project settings
2. Enable CloudKit capabilities in your Apple Developer account
3. The app will automatically create the necessary CloudKit containers

## 📂 Project Structure

```
Domori/
├── Domori/
│   ├── Models/                 # Data models
│   │   ├── PropertyListing.swift
│   │   ├── PropertyRating.swift        # New enum-based rating system
│   │   ├── DataMigrationManager.swift  # Migration utilities
│   │   ├── PropertyNote.swift
│   │   ├── PropertyPhoto.swift
│   │   ├── PropertyTag.swift
│   │   └── PropertyListing+SampleData.swift
│   ├── Views/                  # SwiftUI views
│   │   ├── ContentView.swift
│   │   ├── PropertyDetailView.swift
│   │   ├── AddPropertyView.swift
│   │   ├── ComparePropertiesView.swift
│   │   ├── PropertyListRowView.swift
│   │   └── SettingsView.swift
│   ├── Assets.xcassets/        # App icons and images
│   ├── DomoriApp.swift         # App entry point
│   ├── Info.plist             # App configuration
│   └── Domori.entitlements    # CloudKit permissions
├── DomoriTests/               # Unit tests
│   ├── DomoriTests.swift      # Integration tests
│   ├── PropertyListingTests.swift  # Model tests
│   └── MigrationTests.swift   # Migration testing
├── DomoriUITests/             # UI tests
└── README.md                  # This file
```

## 🧪 Testing

The project includes comprehensive testing using the modern swift-testing framework:

### Test Coverage
- **Unit Tests**: Models, data operations, and business logic
- **Migration Tests**: Data migration scenarios and edge cases
- **Integration Tests**: Cross-component functionality
- **UI Tests**: User interface and navigation flows

### Testing Guidelines
- **Always use European addresses with Euro currency** in test data
- **Prefer iPhone 16 Pro simulator** for consistency
- **Target performance**: iPhone ~175s, iPad ~199s for UI tests
- **Never allow placeholder values**: "€0", "0 sqm", or "NaN/sqm"

### Running Tests
```bash
# Run all tests in Xcode
Cmd+U

# Run specific test on iPhone 16 Pro simulator
xcodebuild test -project Domori.xcodeproj -scheme Domori -destination "platform=iOS Simulator,name=iPhone 16 Pro"

# Run tests from command line
xcodebuild test -project Domori.xcodeproj -scheme Domori
```

### Test Results
✅ All tests pass on iPhone 16 Pro simulator  
✅ Migration tests verify data integrity  
✅ Cross-platform compatibility verified

## 📸 App Store Screenshots

The project includes automated screenshot generation for App Store submission. For detailed requirements and specifications, see [`SCREENSHOT_REQUIREMENTS.md`](SCREENSHOT_REQUIREMENTS.md).

### Quick Overview
- **Target Device**: iPhone 16 Pro (6.3" display)
- **Screenshots**: 3 required images
- **Requirements**: European properties with Euro currency and metric units
- **Validation**: No "€0", "0 sqm", or "NaN/sqm" values allowed

### Generated Screenshots
1. `01_MainScreen_ThreeListings.png` - Main property list with 3 European properties
2. `02_AddProperty_FilledForm.png` - Completed add property form 
3. `03_PropertyDetail.png` - Property detail view

### Running Screenshot Tests
```bash
# Generate App Store screenshots
xcodebuild test -project Domori.xcodeproj -scheme Domori -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:DomoriUITests/DomoriUITests/testAppStoreScreenshots

# Check generated screenshots
ls -la AppStoreScreenshots/*.png
```

> **⚠️ Important**: Screenshots must show realistic European property data with proper Euro formatting and square meter measurements. See the requirements document for complete specifications.

## 🎯 AI Development Notes

This project demonstrates several interesting aspects of AI-powered development:

### What AI Excelled At:
- **Architecture Design**: Created a clean, modern SwiftData architecture with migration support
- **Feature Implementation**: Built complex features like property comparison and rating systems
- **Cross-Platform Development**: Implemented conditional compilation for iOS/macOS compatibility
- **Problem Solving**: Resolved Swift compiler issues and deprecated API usage
- **Testing**: Created comprehensive test suites including edge cases
- **Code Quality**: Generated well-structured, documented, production-ready code

### Recent AI Achievements:
- **Build Stabilization**: Fixed complex Swift compiler type-checking issues
- **API Modernization**: Migrated from deprecated APIs to modern alternatives
- **Data Migration**: Designed and implemented seamless data model transitions
- **Test Suite Overhaul**: Updated entire test suite for new model structure
- **Cross-Platform Polish**: Ensured consistent experience across iOS and macOS

### Development Process:
1. **Conceptualization**: AI translated high-level requirements into technical specifications
2. **Implementation**: Generated complete, working code for all features
3. **Problem Resolution**: Diagnosed and fixed build errors and test failures
4. **Migration Planning**: Designed backward-compatible data model changes
5. **Testing**: Created comprehensive unit and integration tests
6. **Documentation**: Generated thorough documentation and README

## 🔧 Recent Improvements

### Build Stability
- ✅ Fixed Swift compiler type-checking issues in complex UI expressions
- ✅ Resolved all build errors across iOS and macOS platforms
- ✅ Updated deprecated API usage (`usesMetricSystem` → `measurementSystem`)

### New Features
- ✅ PropertyRating enum system with visual feedback
- ✅ DataMigrationManager for seamless upgrades
- ✅ Enhanced property comparison with rating-based sorting
- ✅ Cross-platform UI adaptations

### Test Suite
- ✅ All tests now pass on iPhone 16 Pro simulator
- ✅ Added comprehensive migration testing
- ✅ Updated test suite for new model structure
- ✅ Fixed ambiguous type references and improved test reliability

## 🤝 Contributing

This is an AI experiment, but contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Ensure all tests pass on both iOS and macOS
6. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- **Cursor AI**: For providing the AI development environment
- **Claude Sonnet 4**: The AI model that created this entire application
- **Apple**: For the excellent development frameworks (SwiftUI, SwiftData, CloudKit)
- **Swift Community**: For the modern swift-testing framework

## 📞 Contact

This is an experimental project built entirely with AI assistance. For questions or feedback about the AI development process, feel free to open an issue.

---

**⚡ Built entirely with AI using Cursor** - Showcasing the future of cross-platform software development 