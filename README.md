# Local Pulse - Civic Engagement Platform

Local Pulse is a comprehensive civic engagement ecosystem designed to bridge the gap between citizens and local authorities through transparent, efficient issue reporting and tracking.

##  Project Structure

```
Local-pulse/
├── local_pulse_citizen/          # Citizen mobile app (Flutter)
├── local_pulse_authority/        # Authority management app (Flutter)
├── .kiro/specs/pulsea-civic-app/ # Project specifications
│   ├── requirements.md           # Detailed requirements
│   ├── design.md                # System architecture & design
│   └── tasks.md                 # Implementation roadmap
└── README.md                    # This file
```

##  Applications

### Citizen App (`local_pulse_citizen`)
- **Purpose**: Primary interface for citizens to report and track civic issues
- **Key Features**:
  - Issue reporting with photo attachments
  - Interactive map for location selection
  - Real-time issue tracking
  - Public transparency map
  - Multi-language support
  - Dark/light theme support
  - WhatsApp integration

### Authority App (`local_pulse_authority`)
- **Purpose**: Dedicated management interface for government officials
- **Key Features**:
  - Comprehensive dashboard
  - Issue assignment and status management
  - Analytics and reporting
  - Bulk operations
  - Department management

##  Technology Stack

### Frontend (Mobile Apps)
- **Framework**: Flutter
- **State Management**: BLoC Pattern
- **Architecture**: Clean Architecture

### Backend Services
- **Firebase Authentication**: User management and role-based access
- **Cloud Firestore**: Real-time NoSQL database with geospatial support
- **Firebase Storage**: Image and file storage with CDN
- **Cloud Functions**: Serverless backend logic
- **Firebase Cloud Messaging**: Push notifications

### Key Dependencies
- `flutter_bloc`: State management
- `firebase_core`: Firebase initialization
- `cloud_firestore`: Database operations
- `google_maps_flutter`: Map integration
- `geolocator`: Location services
- `image_picker`: Photo capture
- `dartz`: Functional programming

##  Getting Started

### Prerequisites
- Flutter SDK 3.35.6 or higher
- Dart 3.9.2 or higher
- Firebase project setup
- Google Maps API key
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Local-pulse
   ```

2. **Install dependencies for Citizen App**
   ```bash
   cd local_pulse_citizen
   flutter pub get
   ```

3. **Install dependencies for Authority App**
   ```bash
   cd ../local_pulse_authority
   flutter pub get
   ```

4. **Firebase Configuration**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication, Firestore, Storage, and Cloud Messaging
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place configuration files in respective platform directories

5. **Google Maps Setup**
   - Get API key from [Google Cloud Console](https://console.cloud.google.com)
   - Enable Maps SDK for Android/iOS and Geocoding API
   - Add API key to platform-specific configuration files

### Running the Apps

**Citizen App:**
```bash
cd local_pulse_citizen
flutter run
```

**Authority App:**
```bash
cd local_pulse_authority
flutter run
```

##  Development Status

This project is currently in active development. The foundation has been established with:

 **Completed:**
- Project structure setup
- Clean architecture implementation
- Core domain entities
- Firebase service integration
- Basic UI framework
- Dual app architecture

 **In Progress:**
- Authentication system
- Issue reporting functionality
- Map integration
- Real-time tracking

 **Planned:**
- WhatsApp integration
- Multi-language support
- Analytics dashboard
- Performance optimization

##  Architecture

The project follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── core/                    # Shared utilities and services
│   ├── constants/          # App constants
│   ├── error/              # Error handling
│   ├── services/           # Firebase and other services
│   └── utils/              # Utility functions
├── domain/                 # Business logic layer
│   ├── entities/           # Core business entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/          # Business use cases
├── data/                   # Data layer
│   ├── datasources/        # Remote and local data sources
│   ├── models/             # Data models
│   └── repositories/       # Repository implementations
└── presentation/           # UI layer
    ├── bloc/               # State management
    ├── pages/              # Screen widgets
    └── widgets/            # Reusable UI components
```

##  Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

##  License

This project is just a hackathon project

##  Support

For support and questions:
- Create an issue in the repository
- Contact the development team

##  Vision

Local Pulse aims to create meaningful civic impact by:
- Improving transparency between citizens and authorities
- Streamlining issue reporting and resolution processes
- Providing real-time visibility into community problems
- Enabling data-driven decision making for local governance
- Building stronger community engagement

---
