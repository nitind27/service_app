# JeevanSeva Mobile App (Flutter)

A modern, mobile-first Flutter application for **JeevanSeva — All-in-One Life Services Marketplace** (from birth to death, home care to outside services), connecting directly with the Next.js REST API backend (`d:\all service`).

---

## 🚀 Key Highlights & Features

### 1. Customer Experience Flow
- **10 Indian Life Stages Catalog**: Browse services from Newborn/Babysitting, Home Care, Education, Events, Legal/Finance, to 24x7 Ambulance & Funeral Rites.
- **Doorstep 4-Digit Security OTP**: Generates a tamper-proof 4-digit security code for every booking. Technicians can start the service job only after verifying this code at the customer's door.
- **Pincode SLA Turnaround Checker**: Verifies 6-digit Indian PIN codes (e.g., `110001`, `201301`, `400001`, `560001`) and confirms technician arrival time (30-45 mins).
- **Interactive Location Selector**: Supports 1-tap GPS auto-detection and a split state-city selector covering all **28 Indian States**.
- **Customer Wallet & Instant Refunds**: Pay using wallet balance or Cash on Delivery / Cashfree. Any cancelled booking is **100% instantly refunded** back to the wallet with 0 bank delay.
- **In-App Live Chat**: Real-time communication between customer and assigned technician with quick preset chips ("I have reached your doorstep", "Where can I park?").

### 2. Service Partner / Technician Portal
- **Role-Based Partner View**: Dedicated technician interface without admin clutter.
- **Job Status Management**: View To-Do, In Progress, and Completed orders with direct customer calling and address navigation.
- **Doorstep OTP Verification**: Enforces entering the customer's 4-digit code before transitioning any job to `in_progress`.
- **Earnings & Payouts**: Real-time 85% net earnings tracking, withdrawable balance calculations, and 1-tap Bank / UPI transfer requests.

### 3. Smart Server Connectivity
- **Multi-Platform Network Detection**:
  - Android Emulator: Automatically targets `http://10.0.2.2:3000/api`
  - Physical Mobile Phone: Connects to local Wi-Fi IP `http://192.168.1.14:3000/api`
  - Windows Desktop / Web: Automatically targets `http://localhost:3000/api`
- **In-App Server Settings**: Change backend IP/port at runtime via the Settings dialog from the Profile screen.

---

## 📱 How to Run

### Step 1: Ensure Backend Server is Running
```bash
cd "d:\all service"
npm run dev
```

### Step 2: Run Flutter App
```bash
cd "d:\all_service_app"

# For Android Emulator or Connected Device:
flutter run

# For Windows Desktop:
flutter run -d windows

# For Chrome Web:
flutter run -d chrome
```

---

## 🔑 Demo Test Credentials (1-Tap Buttons Available on Login Screen)
- **Customer**: `customer@jeevanseva.in` / `Customer@123`
- **Service Partner**: `rajesh.provider@jeevanseva.in` / `Provider@123`
