# TailorBlend Mobile App

Flutter mobile application for TailorBlend - Your personalized nutrition journey.

## Features

- **Authentication System**
  - Login with email and password
  - Multi-step signup process with health profile
  - Password strength indicator
  - Form validation
  - Password reset functionality

- **Personalized Onboarding**
  - Personal information collection
  - Health goals selection
  - Activity level assessment
  - Dietary preferences/restrictions

- **Brand-Aligned Design**
  - Custom theme matching TailorBlend's health-focused branding
  - Forest green and teal color palette
  - Clean, modern Material Design 3
  - Smooth animations with animate_do

## Getting Started

### Prerequisites

- Flutter SDK (^3.6.1)
- Dart SDK
- iOS Simulator/Android Emulator or physical device

### Installation

1. Navigate to the project directory:
```bash
cd tbmobile/tbmobile
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Project Structure

```
lib/
├── main.dart              # App entry point and configuration
├── screens/
│   ├── login_screen.dart  # Login page with forgot password
│   └── signup_screen.dart # Multi-step signup with health profile
├── services/
│   └── auth_service.dart  # Authentication logic and state management
├── utils/
│   └── app_theme.dart     # TailorBlend brand theming
└── widgets/
    └── custom_text_field.dart # Reusable form input component
```

### Testing the App

1. **Login Flow**
   - Enter any email and password to test (mock authentication)
   - Try the "Forgot Password" feature
   - Test form validation

2. **Signup Flow**
   - Navigate through the 3-step signup process
   - Test form validation on each page
   - Try different health goals and dietary preferences
   - Check password strength indicator

### Notes

- Currently using mock authentication (no real API calls)
- Real API endpoints should be configured in `auth_service.dart`
- Replace mock responses with actual API integration when backend is ready

### Color Palette

- Primary Green: `#2D6A4F` - Health and nature
- Accent Teal: `#40B5AD` - Vitality and freshness
- Light Green: `#52B788` - Growth and wellness
- Background: `#F8FCF9` - Clean, minimal
- Text Dark: `#1B3A2F` - High contrast readability

### Next Steps

- [ ] Integrate with actual TailorBlend API
- [ ] Add biometric authentication
- [ ] Implement social login (Google, Apple)
- [ ] Add health assessment questionnaire
- [ ] Create supplement customization screens
- [ ] Add user profile management
- [ ] Implement order tracking