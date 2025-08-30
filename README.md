# SwiftEvolution-Viewer 

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Koshimizu-Takehito/SwiftEvolution-Viewer)

A native iOS and macOS application for browsing Swift Evolution proposals. This app provides an elegant and intuitive interface to explore, search, and bookmark Swift Evolution proposals with full markdown rendering support.

## Features

- 📱 **Native iOS & macOS Support** - Optimized for both platforms with adaptive layouts
- 📋 **Proposal Browsing** - Browse all Swift Evolution proposals with real-time data
- 🔍 **Advanced Filtering** - Filter proposals by status (Accepted, Rejected, Active, etc.)
- 🔖 **Bookmarking** - Save and organize your favorite proposals
- 📖 **Full Markdown Support** - Rich markdown rendering with syntax highlighting
- 🌙 **Dark Mode Support** - Beautiful dark and light themes
- 📱 **Responsive Design** - Adaptive layouts for different screen sizes
- 🔄 **Real-time Updates** - Automatic proposal data synchronization

## Screenshots

*Screenshots will be added here*

## Architecture

This project follows a modular architecture with clear separation of concerns:

### Core Modules

- **EvolutionCore** - Core data models and networking layer
- **EvolutionModel** - SwiftData models and persistence layer
- **EvolutionModule** - Main application logic and views
- **EvolutionUI** - Reusable UI components and styling

### Key Components

- **Proposal Management** - Fetching and caching of proposal data
- **Markdown Rendering** - Custom markdown parser with syntax highlighting
- **State Management** - SwiftData integration for local storage
- **Navigation** - Split view navigation for iPad and macOS

## Requirements

![Swift](https://img.shields.io/badge/swift-6.2-orange.svg)
![Platform](https://img.shields.io/badge/iOS-26.0+-blue.svg)
![Platform](https://img.shields.io/badge/macOS-15.0+-blue.svg)
![Xcode](https://img.shields.io/badge/xcode-26.0+-magenta.svg)

## Installation

### Prerequisites

1. Install Xcode 26.0 or later from the App Store
2. Ensure you have a valid Apple Developer account (for device deployment)

### Setup

1. Clone the repository:
```bash
git clone git@github.com:Koshimizu-Takehito/SwiftEvolution-Viewer.git
cd SwiftEvolution-Viewer
```

2. Open the project in Xcode:
```bash
open SwiftEvolution.xcodeproj
```

3. Select your target device or simulator

4. Build and run the project (⌘+R)

## Usage

### Browsing Proposals

1. Launch the app to see the list of all Swift Evolution proposals
2. Use the search bar to find specific proposals by title or ID
3. Tap on any proposal to view its full details

### Filtering and Organization

1. Use the status filter to view proposals by their current state:
   - **Accepted** - Successfully implemented proposals
   - **Rejected** - Proposals that were not accepted
   - **Active** - Currently under review
   - **Implemented** - Proposals that have been implemented

2. Bookmark important proposals for quick access:
   - Tap the bookmark icon on any proposal
   - Use the bookmark filter to view only saved proposals

### Reading Proposals

- Full markdown rendering with syntax highlighting
- Responsive layout that adapts to your device
- Support for code blocks, tables, and other markdown elements
- Copy code snippets directly from the rendered content

## Development

### Project Structure

```
SwiftEvolution/
├── App/                    # Main app entry point
├── EvolutionCore/          # Core data models and networking
├── EvolutionModel/         # SwiftData models
├── EvolutionModule/        # Main application logic
├── EvolutionUI/           # Reusable UI components
└── SwiftEvolution.xcodeproj
```

### Building from Source

1. Ensure all dependencies are resolved:
```bash
cd SwiftEvolution
xcodebuild -resolvePackageDependencies
```

2. Build the project:
```bash
xcodebuild -project SwiftEvolution.xcodeproj -scheme App -configuration Debug
```

### Running Tests

```bash
xcodebuild test -project SwiftEvolution.xcodeproj -scheme App
```

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

## Acknowledgments

- [Swift Evolution](https://github.com/apple/swift-evolution) - The official Swift Evolution repository
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) - Modern declarative UI framework
- [SwiftData](https://developer.apple.com/documentation/swiftdata) - Persistent data framework
