# Domori 🏠

> **AI Experiment**: This entire iOS app was built using [Cursor AI](https://cursor.com) as a proof-of-concept for AI-powered development. From initial concept to final implementation, every line of code, architecture decision, and feature was created through AI assistance.

A modern, cross-platform property listing management app for iPhone, iPad, and macOS. Built with the latest Swift technologies and designed for real estate professionals, investors, and anyone managing property portfolios.

## 🤖 About This Project

This project represents an experiment in AI-powered software development using Cursor AI. The entire application was conceived, designed, and implemented through AI assistance, demonstrating the current capabilities of AI in creating production-ready mobile applications.

**Development Stack:**
- **AI Assistant**: Cursor AI (Claude Sonnet 4)
- **Language**: Swift 6.0
- **Frameworks**: SwiftUI, SwiftData, CloudKit
- **Platform**: iOS 17+, iPadOS 17+, macOS 14+, visionOS 2.5+

## ✨ Features

### Core Functionality
- 📝 **Property Management**: Add, edit, and organize property listings
- 🏷️ **Smart Tagging**: Custom tags with 14 color options and predefined templates
- ⭐ **Rating System**: 5-star rating system for property evaluation
- 📸 **Photo Organization**: 16 categorized photo types (exterior, interior, kitchen, etc.)
- 📋 **Categorized Notes**: 8 note types (pros, cons, renovation, financial, etc.)
- 🔍 **Search & Filter**: Advanced search and multiple sorting options

### International Support
- 🌍 **Locale-Aware**: Automatic currency detection (USD, EUR, GBP, etc.)
- 📏 **Unit Adaptation**: Smart metric/imperial system detection
- 🏛️ **Regional Formatting**: Native number and currency formatting
- 🗺️ **Country-Specific**: Appropriate defaults for different markets

### Advanced Features
- 📊 **Property Comparison**: Side-by-side analysis with best value highlighting
- ☁️ **iCloud Sync**: Seamless synchronization across all devices
- 🎯 **Smart Sorting**: Date, price, size, title, and favorites-first options
- 💫 **Modern UI**: Beautiful SwiftUI interface with iOS design guidelines

## 🛠️ Technical Implementation

### Architecture
- **SwiftData**: Modern Core Data replacement for local persistence
- **CloudKit**: Automatic iCloud synchronization
- **SwiftUI**: Declarative UI framework for all platforms
- **swift-testing**: Modern testing framework

### Models
- `PropertyListing`: Main property model with relationships
- `PropertyNote`: Categorized notes with color coding
- `PropertyPhoto`: Photo management with categories
- `PropertyTag`: Custom tagging system

### Key Features
- Locale-aware currency and measurement formatting
- Automatic metric/imperial unit detection
- Cross-platform compatibility (iOS, iPadOS, macOS, visionOS)
- Modern Swift 6.0 language features
- Comprehensive unit tests

## 🌍 Internationalization

The app automatically adapts to your device's regional settings:

- **Currency**: Detects and uses local currency (€, £, $, ¥, etc.)
- **Measurements**: 
  - Metric countries: Square meters (m²)
  - Imperial countries: Square feet (sq ft)
- **Formatting**: Native number and currency display
- **Countries Supported**: Worldwide with smart defaults

## 📱 Compatibility

- **iOS**: 17.0+
- **iPadOS**: 17.0+
- **macOS**: 14.0+
- **visionOS**: 2.5+
- **Xcode**: 16.0+
- **Swift**: 6.0+

## 🚀 Getting Started

### Prerequisites
- Xcode 16.0 or later
- iOS 17.0+ / macOS 14.0+ deployment target
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
└── README.md                  # This file
```

## 🧪 Testing

The project includes comprehensive unit tests using the modern swift-testing framework:

```bash
# Run tests in Xcode
Cmd+U

# Run tests from command line
xcodebuild test -project Domori.xcodeproj -scheme Domori
```

## 🎯 AI Development Notes

This project demonstrates several interesting aspects of AI-powered development:

### What AI Excelled At:
- **Architecture Design**: Created a clean, modern SwiftData architecture
- **Feature Implementation**: Built complex features like property comparison
- **Internationalization**: Implemented sophisticated locale detection
- **Code Quality**: Generated well-structured, documented code
- **Problem Solving**: Handled complex requirements and edge cases

### Development Process:
1. **Conceptualization**: AI translated high-level requirements into technical specifications
2. **Implementation**: Generated complete, working code for all features
3. **Testing**: Created comprehensive unit tests
4. **Refinement**: Iteratively improved code based on feedback
5. **Documentation**: Generated thorough documentation and README

## 🤝 Contributing

This is an AI experiment, but contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- **Cursor AI**: For providing the AI development environment
- **Claude Sonnet 4**: The AI model that created this entire application
- **Apple**: For the excellent development frameworks (SwiftUI, SwiftData, CloudKit)

## 📞 Contact

This is an experimental project built entirely with AI assistance. For questions or feedback about the AI development process, feel free to open an issue.

---

**⚡ Built entirely with AI using Cursor** - Showcasing the future of software development 