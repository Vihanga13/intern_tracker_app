# Authentication Screens Documentation

## Overview
The authentication system provides secure and user-friendly login and registration interfaces with modern design elements and smooth animations. This includes both the Login Screen and Register Screen.

## Features

### 🎨 Design Elements
- **Gradient Background**: Beautiful gradients (royal blue to coral for login, coral to royal blue for register)
- **Animated Components**: Smooth fade, slide, and scale animations
- **Glass-morphism Effect**: Semi-transparent form containers
- **Modern UI**: Rounded corners, shadows, and clean typography
- **Consistent Theming**: Uses app's color palette throughout

### 🔐 Authentication Features

#### Login Screen
- **Email Validation**: Built-in email format validation
- **Password Security**: 
  - Minimum 6 characters required
  - Toggle visibility option
  - Secure input masking
- **Remember Me**: Option to save login state (placeholder for future implementation)
- **Form Validation**: Real-time validation with error messages

#### Register Screen
- **Personal Information**: First name, last name, email, phone
- **Role Selection**: Intern, Supervisor, Manager dropdown
- **Enhanced Password Security**: 
  - Minimum 8 characters required
  - Must contain uppercase, lowercase, and number
  - Password confirmation with matching validation
  - Toggle visibility for both password fields
- **Terms & Conditions**: Required agreement checkbox with styled links
- **Comprehensive Validation**: Real-time validation for all fields

### ✨ User Experience
- **Loading States**: Visual feedback during login process
- **Haptic Feedback**: Tactile response on button press
- **Success Animation**: Smooth transition to home screen
- **Error Handling**: User-friendly error messages
- **Responsive Design**: Adapts to different screen sizes

## Screen Flow

```
LoginScreen ←→ RegisterScreen
     ↓              ↓
[Authentication] → HomePage
     ↓
[Forgot Password] (Coming Soon)
```

## Form Fields

### Login Screen Fields

#### Email Field
- **Input Type**: Email keyboard
- **Validation**: Email format regex
- **Icon**: Email outline icon with royal blue accent
- **Required**: Yes

#### Password Field
- **Input Type**: Secure text (with toggle)
- **Validation**: Minimum 6 characters
- **Icon**: Lock outline icon with coral orange accent
- **Visibility Toggle**: Eye icon to show/hide password
- **Required**: Yes

### Register Screen Fields

#### Name Fields
- **First Name**: Text input with person icon, minimum 2 characters
- **Last Name**: Text input with person icon, minimum 2 characters
- **Layout**: Side-by-side in a responsive row

#### Contact Information
- **Email**: Email validation with email icon
- **Phone**: Phone number input with phone icon, minimum 10 digits

#### Account Setup
- **Role Selection**: Dropdown with Intern, Supervisor, Manager options
- **Password**: Enhanced validation (8+ chars, uppercase, lowercase, number)
- **Confirm Password**: Must match the password field
- **Terms Agreement**: Required checkbox with styled links

## Animations

### Login Screen
1. **Fade Animation** (1200ms): Overall screen fade-in
2. **Slide Animation** (1000ms): Form slides up from bottom
3. **Scale Animation** (800ms): Logo and form scale in with elastic effect

### Register Screen
1. **Fade Animation** (1200ms): Overall screen fade-in
2. **Slide Animation** (1000ms): Form slides up from bottom
3. **Scale Animation** (800ms): Logo and form scale in with elastic effect
4. **Transition Animations**: Smooth slide transitions between login/register

## Current Implementation

### Demo Authentication

#### Login
- **Email**: Any valid email format (e.g., user@example.com)
- **Password**: Any password with 6+ characters
- **Backend**: Currently simulated (2-second delay)

#### Registration
- **All Fields**: Accept any valid input matching validation rules
- **Backend**: Currently simulated (3-second delay)
- **Role Selection**: Stores selected role for future use

### Navigation
- **Login Success**: Navigates to HomePage with slide transition
- **Register Success**: Navigates to HomePage with slide transition
- **Between Screens**: Smooth slide transitions between login and register
- **Failure**: Shows error message in SnackBar

## Future Enhancements

### Authentication Integration
- [ ] Connect to Firebase Auth or custom backend
- [ ] Social login options (Google, Apple)
- [ ] Biometric authentication support

### Additional Features
- [x] **Login and Register screens** with full navigation
- [ ] Forgot password functionality
- [ ] Email verification
- [ ] Multi-factor authentication
- [ ] Remember me persistence
- [ ] Social login options
- [ ] Account recovery

## Code Structure

```
Authentication System
├── LoginScreen
│   ├── Animation Controllers (fade, slide, scale)
│   ├── Form Validation
│   ├── UI Components
│   │   ├── Header (logo + welcome text)
│   │   ├── Login Form
│   │   │   ├── Email Field
│   │   │   ├── Password Field
│   │   │   ├── Remember Me Checkbox
│   │   │   └── Login Button
│   │   ├── Forgot Password Link
│   │   └── Sign Up Navigation
│   └── Authentication Logic
└── RegisterScreen
    ├── Animation Controllers (fade, slide, scale)
    ├── Form Validation
    ├── UI Components
    │   ├── Header (logo + create account text)
    │   ├── Registration Form
    │   │   ├── Name Fields (First + Last)
    │   │   ├── Email Field
    │   │   ├── Phone Field
    │   │   ├── Role Dropdown
    │   │   ├── Password Field
    │   │   ├── Confirm Password Field
    │   │   ├── Terms Checkbox
    │   │   └── Register Button
    │   └── Login Navigation
    └── Registration Logic
```

## Usage

The login screen is set as the initial screen in `main.dart`. Users can navigate between login and register screens seamlessly.

### To test Login:
1. Enter any valid email (e.g., intern@company.com)
2. Enter any password with 6+ characters
3. Tap "Sign In"
4. Wait for the 2-second simulation
5. You'll be redirected to the HomePage

### To test Registration:
1. From login screen, tap "Sign Up"
2. Fill out all required fields:
   - First Name (2+ characters)
   - Last Name (2+ characters)
   - Valid email address
   - Valid phone number (10+ digits)
   - Select a role from dropdown
   - Create password (8+ chars with uppercase, lowercase, number)
   - Confirm password (must match)
   - Agree to terms and conditions
3. Tap "Create Account"
4. Wait for the 3-second simulation
5. You'll be redirected to the HomePage

## Color Scheme

The login screen uses the app's established color palette:
- **Primary**: Royal Blue (#1565C0)
- **Secondary**: Coral Orange (#FF7043)
- **Background**: Light Gray (#F5F5F5)
- **Text**: Dark Gray (#212121) and Medium Gray (#757575)
- **Error**: Rich Red for validation errors
