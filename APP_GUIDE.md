# Next Meter - Water Token Transaction App

A modern Flutter mobile application for managing water token transactions with an intuitive UI and smooth user flow.

## Features

### ✨ Core Features
- **Intro/Splash Screen**: App welcome and onboarding
- **Home Dashboard**: Summary cards (Transactions this month, Customers), quick actions, and a Settings button
- **Settings**:
  - Configure currency symbol, service fee, base amount
  - Configure pulses per base amount (pulse formula)
- **Customer Management**:
  - Add, edit, delete customers (Hive persistence)
  - Search by name/ID/meter ID
  - Scan meter ID via camera (QR)
- **Transaction Management**:
  - Create transactions with amount input using app currency
  - Auto-calculate water pulse using Settings formula
  - Summary confirmation and token generation
  - Receipt page with WhatsApp sharing and PDF share/print
- **Transaction History**:
  - Grouped by date
  - Filters: Today, Last 7 days, Custom date range
  - Detail modal with WhatsApp share
- **Backup & Restore**:
  - Backup all boxes (customers, transactions, settings) to JSON
  - Restore latest backup from app documents directory
- **Dark/Light Theme**: Toggle from AppBar

### 📊 Key Functionalities
1. **Customer Search**: Find customers by meter ID and view their details
2. **Amount Input**: Enter transaction amount with automatic pulse calculation
3. **Transaction Summary**: Review all details before confirming
4. **Receipt Generation**: Get unique electricity token after confirmation
5. **Transaction History**: Track all completed transactions
6. **Customer Database**: View all registered customers and their information

## Project Structure

```
lib/
├── main.dart                 # Entry point with app theming and routes
├── models/
│   ├── customer.dart        # Customer data model (Hive adapter typeId=1)
│   ├── transaction.dart     # Transaction data model (Hive adapter typeId=2)
│   └── app_settings.dart    # App settings model (Hive adapter typeId=3)
├── services/
│   ├── data_service.dart    # Local boxes and helpers
│   ├── transaction_service.dart  # Calculations and formatting using Settings
│   └── backup_service.dart  # JSON backup/restore
└── screens/
    ├── intro_screen.dart         # Welcome/Splash screen
    ├── home_screen.dart          # Main dashboard (with Settings button)
    ├── settings_screen.dart      # Configure currency/fees/pulse formula
    ├── transaction_screen.dart   # Customer search
    ├── transaction_form_screen.dart      # Amount input form
    ├── transaction_summary_screen.dart   # Confirmation screen
    ├── receipt_screen.dart       # Receipt with token and PDF share
    ├── transaction_history_screen.dart   # History view
    └── customer_manager_screen.dart      # Customer management
```

## Getting Started

### Prerequisites
- Flutter SDK (version 3.9.2 or higher)
- Android SDK with API level 21 or higher
- Android device with USB Debugging enabled

### Installation

1. **Clone the repository** (or navigate to existing project):
```bash
cd "c:\Users\ThinkPad\Documents\Flutter Project\next_meter"
```

2. **Get dependencies**:
```bash
flutter pub get
```

3. **Run the app**:
```bash
flutter run
```

## Running on Real Android Device

### Step 1: Prepare Your Device
1. Go to **Settings** → **About phone** → Tap **Build number** 7 times
2. Go back to **Settings** → **Developer options**
3. Enable **USB Debugging**
4. Connect your device to your computer via USB cable

### Step 2: Verify Device Connection
```bash
flutter devices
```
Your device should appear in the list.

### Step 3: Run the App
```bash
flutter run
```

Or run in release mode for better performance:
```bash
flutter run --release
```

### Troubleshooting

**Device not detected:**
```bash
flutter clean
flutter pub get
flutter run
```

**Build issues:**
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

**Run with verbose output for debugging:**
```bash
flutter run -v
```

## App Usage Guide

### 1. **Intro Screen**
- First screen when launching the app
- Click "Get Started" to proceed to home

### 2. **Home Screen**
- View quick action cards for different features
- Navigate using bottom navigation bar
- See system information about calculations

### 3. **New Transaction Flow**

#### Step 1: Customer Search
- Enter meter ID (e.g., 1234567890)
- Click "Search" to find customer
- View customer details
- Click "Continue to Transaction"

#### Step 2: Amount Input
- Enter amount using the configured currency symbol
- System auto-calculates water pulse based on Settings
- Default formula: Rp 10,000 = 30 Pulse (customizable in Settings)
- Click "Proceed to Summary"

#### Step 3: Summary Confirmation
- Review all transaction details
- Customer information displayed
- Transaction details shown
- Click "Confirm Transaction" to proceed

#### Step 4: Receipt & Token
- Transaction successful message
- Receipt with transaction details
- Unique electricity token displayed (20 characters)
- Option to share receipt
- Click "Back to Home" to continue

### 4. **Transaction History**
- View all completed transactions
- Click on any transaction for detailed view
- See customer name, amount, pulse, and date
- View token information in details

### 5. **Customer Management**
- Browse all registered customers
- Search by name, ID, or meter ID
- Click on customer to view details
- See contact and address information

## Mock Data

The app comes with 5 pre-loaded customers:
- Budi Santoso (Meter: 1234567890)
- Siti Nurhaliza (Meter: 1234567891)
- Ahmad Wijaya (Meter: 1234567892)
- Rina Dewi (Meter: 1234567893)
- Hendra Kusuma (Meter: 1234567894)

## Calculation Formula

Pulse calculation is driven by Settings.
- Base Amount → Pulses per Base (e.g., 10,000 → 30 Pulses by default)
- Example: Amount ÷ BaseAmount × PulsesPerBase

Examples with defaults:
- Rp 10,000 = 30 Pulse
- Rp 50,000 = 150 Pulse
- Rp 100,000 = 300 Pulse

## Technology Stack

- **Framework**: Flutter
- **Language**: Dart
- **UI**: Material Design 3
- **State Management**: StatefulWidget + ValueListenableBuilder
- **Storage**: Hive (local persistence) via `hive` and `hive_flutter`
- **Device**: Camera scanning via `mobile_scanner`
- **Share**: WhatsApp share via `url_launcher`

## UI/UX Highlights

- **Modern Design**: Clean and intuitive interface
- **Color Scheme**: Professional blue (#0066CC) with complementary colors
- **Responsive Layout**: Adaptive design for different screen sizes
- **Smooth Animations**: Transitions and progress indicators
- **User Feedback**: Toast messages and dialog boxes
- **Dark/Light Support**: Material 3 theming

## Future Enhancements

- Persistent database integration (Firebase/SQLite)
- Push notifications for transaction updates
- PDF receipt generation
- Multiple language support
- Biometric authentication
- Transaction analytics and reports
- Real payment gateway integration
- Offline mode support

## Support

For issues or questions, please refer to:
- Flutter Documentation: https://flutter.dev/docs
- Dart Documentation: https://dart.dev/guides

## License

This project is provided as-is for educational and commercial use.

---

**Version**: 1.0.0  
**Last Updated**: November 2025
