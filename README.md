# Intern Progress Tracker

## Project Overview
The Intern Progress Tracker is a Flutter-based mobile application designed to help organizations manage and track intern work activities efficiently. It provides a comprehensive platform for both interns and supervisors to monitor progress, log work hours, and maintain detailed records of internship activities.

## Key Features
- Beautiful, animated UI with gradient themes
- Real-time data synchronization using Firebase
- Role-based access (Interns and Supervisors)
- Detailed analytics and progress tracking
- File attachment support for work documentation

## Core Pages

### 1. Home Screen (`home_screen.dart`)
- Main dashboard for interns
- Displays daily quotes for motivation
- Quick access to key features
- Beautiful animated UI elements
- Shows user profile and work summary

### 2. Add Work Entry Screen (`add_work_screen.dart`)
- Form to log daily work activities
- Fields for:
  * Work title and type
  * Hours worked
  * Date selection
  * Detailed description
  * File attachments
- Input validation and error handling
- Smooth animations and transitions

### 3. Personal Summary Screen (`personal_summary_screen.dart`)
- Individual progress dashboard
- Visual charts and statistics
- Work history and trends
- Filtering options by date and work type
- Export functionality for reports
- Analytics visualization using charts

### 4. Supervisor Dashboard Screen (`supervisor_dashboard_screen.dart`)
- Overview of all interns' progress
- Comparative analysis tools
- Team performance metrics
- Individual intern detailed views
- Activity monitoring and tracking
- Data export capabilities

## Technical Features
- Firebase integration for data storage
- Real-time updates and synchronization
- File upload and storage capabilities
- Chart visualizations using fl_chart
- Custom animations and transitions
- Form validation and error handling
- Responsive design for various screen sizes

## Color Scheme (`app_colors.dart`)
- Consistent color theming across the app
- Gradient definitions for UI elements
- Work type color coding
- Accent colors for different actions

## Data Models
- WorkEntry: Represents individual work records
- TimeEntry: Tracks time-based activities
- InternData: Manages intern profiles and statistics

## Target Users
1. **Interns**
   - Log daily work activities
   - Track personal progress
   - Submit work documentation
   - View personal analytics

2. **Supervisors**
   - Monitor intern progress
   - Review work entries
   - Generate reports
   - Manage team performance

## Future Enhancements
- Integration with calendar for scheduling
- Push notifications for reminders
- Advanced reporting features
- Team collaboration tools
- Mobile responsive design
- Multi-language support

## Development Status
The application is currently in development with core features implemented and ready for testing. Firebase integration is prepared but commented out for demonstration purposes.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
#
