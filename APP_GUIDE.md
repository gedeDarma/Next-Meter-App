# Next Meter - Water Token Transaction App

A modern Flutter mobile application for managing water token transactions with an intuitive UI and smooth user flow.

## Features

### ✨ Core Features
- **Intro/Splash Screen**: Beautiful welcome screen with app branding
- **Home Dashboard**: Quick access to main features and system information
- **Customer Search**: Search customers by meter ID with real-time validation
- **Transaction Management**:
  - Create new transactions
  - Input amount in Rupiah
  - Auto-calculate electric pulses (Rp 10,000 = 10 Pulse)
  - Review transaction summary before confirmation
  - Generate unique electricity tokens
- **Transaction History**: View all past transactions with details
- **Customer Management**: Browse and search all customers in the system
- **Digital Receipts**: Automatic receipt generation with electricity tokens

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
├── main.dart                 # Entry point with app theming
├── models/
│   ├── customer.dart        # Customer data model
│   └── transaction.dart     # Transaction data model
├── services/
│   ├── data_service.dart    # Mock customer database
│   └── transaction_service.dart  # Transaction calculations
└── screens/
    ├── intro_screen.dart         # Welcome/Splash screen
    ├── home_screen.dart          # Main dashboard
    ├── transaction_screen.dart   # Customer search
    ├── transaction_form_screen.dart      # Amount input form
    ├── transaction_summary_screen.dart   # Confirmation screen
    ├── receipt_screen.dart       # Receipt with token
    ├── transaction_history_screen.dart   # History view
    └── customer_list_screen.dart        # Customer list
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
- Enter amount in Rupiah
- System auto-calculates electric pulse
- Formula: Rp 10,000 = 10 Electric Pulse
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

**Electric Pulse Calculation:**
- Rp 10,000 = 10 Electric Pulse
- Rp 50,000 = 50 Electric Pulse
- Rp 100,000 = 100 Electric Pulse

**Example Transaction:**
- Customer enters: Rp 75,000
- System calculates: 75,000 ÷ 10,000 × 10 = 75 Pulse

## Technology Stack

- **Framework**: Flutter
- **Language**: Dart
- **UI**: Material Design 3
- **State Management**: StatefulWidget
- **Storage**: Mock in-memory database (can be replaced with actual database)

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
