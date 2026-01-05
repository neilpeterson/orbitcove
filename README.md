# OrbitCove

[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Overview

OrbitCove is a **privacy-first, all-in-one community platform for iOS**. It enables groups such as families, sports teams, and clubs to create private digital spaces with integrated organizational tools.

## Features

### 🔒 Privacy-First Architecture
- **End-to-End Encryption**: All communications are encrypted
- **No Data Mining**: Your data is never analyzed or sold
- **Local-First Storage**: Data stored on your device by default
- **Invitation-Only Communities**: Control who joins your spaces
- **No Advertisements**: We never display ads

### 👥 Community Management
- Create multiple private communities
- Support for various group types:
  - Family circles
  - Sports teams
  - Clubs
  - Organizations
- Member management and invitations
- Customizable privacy settings

### 🛠️ Integrated Organizational Tools
Each community includes built-in tools:
- **Calendar**: Schedule events and activities
- **Messages**: Secure group messaging
- **Tasks**: Collaborative task management
- **Files**: Shared document storage
- **Events**: Event planning and coordination

## Project Structure

```
OrbitCove/
├── OrbitCoveApp.swift          # App entry point
├── Models/
│   ├── AppState.swift          # Global app state management
│   ├── Community.swift         # Community data model
│   └── User.swift              # User data model
├── Views/
│   ├── ContentView.swift       # Main view
│   ├── CommunityDetailView.swift   # Community details
│   └── AddCommunityView.swift  # Create community form
├── Components/
│   └── CommunityCardView.swift # Community list card
├── Services/
│   └── PrivacyService.swift    # Privacy management
└── Assets.xcassets/            # App assets

```

## Technical Stack

- **Language**: Swift 5.9+
- **Framework**: SwiftUI
- **Minimum iOS Version**: iOS 15.0+
- **Architecture**: MVVM with Combine

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 15.0+ device or simulator
- macOS 13.0+ (for development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/neilpeterson/orbitcove.git
cd orbitcove
```

2. Open the project in Xcode:
```bash
open OrbitCove.xcodeproj
```
Or simply open the `OrbitCove` folder in Xcode.

3. Select your target device or simulator

4. Build and run (⌘+R)

## Usage

### Creating a Community

1. Tap the **+** button in the top-right corner
2. Enter community details:
   - Name
   - Description
   - Type (Family, Sports Team, Club, etc.)
3. Configure privacy settings
4. Tap "Create Community"

### Managing Communities

- Tap any community card to view details
- Access organizational tools from the community detail view
- View member count and privacy status
- All communities are private by default

## Privacy Principles

OrbitCove is built on these core privacy principles:

1. **Data Minimization**: We only collect what's necessary
2. **User Control**: You own and control your data
3. **Transparency**: Clear privacy policies and practices
4. **Security**: Industry-standard encryption
5. **No Tracking**: We don't track your behavior

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please open an issue in the GitHub repository.

## Roadmap

- [ ] User authentication and profiles
- [ ] Real-time messaging
- [ ] Calendar integration
- [ ] File sharing and storage
- [ ] Push notifications
- [ ] iCloud sync
- [ ] iPad and Mac support

---

**OrbitCove** - Building private, meaningful connections.