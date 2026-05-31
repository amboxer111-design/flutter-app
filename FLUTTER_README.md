# 🏗️ Heavy Machinery Business Management Ledger

Welcome to the **Heavy Machinery Business Management App** blueprint. This repository contains **two complete professional implementations** customized for high-accuracy transaction logging, partner accounts, and offline-first safety protocols:

1. **Native Android (Kotlin & Jetpack Compose)**: Located in `/app`. Compiled with Gradle and verified to build with zero issues out-of-the-box.
2. **Cross-Platform Flutter (Dart)**: Located in `/cross_platform_flutter`. Fully compatible with Android mobile, Windows desktop, and Web browsers, with fallback SQLite implementations.

---

## 🗄️ SQLite Database Structure & Schema

The application is engineered on an offline-first architecture. When the user creates records without an active internet connection, transactions are committed to local SQLite storage. When a connection is reestablished, conflict resolvers sync updates seamlessly.

```sql
-- 1. STAKEHOLDERS & PARTNERS
CREATE TABLE partners (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    sharePercentage REAL NOT NULL,
    mobileNumber TEXT NOT NULL,
    joiningDate TEXT NOT NULL,
    colorAssignment TEXT NOT NULL -- Yellow, Red, Black, Green as requested
);

-- 2. MACHINERY FLEET
CREATE TABLE vehicles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    registrationNumber TEXT NOT NULL,
    vehicleType TEXT NOT NULL -- Excavators, Loaders, Mazda, etc.
    purchaseDate TEXT NOT NULL,
    status TEXT NOT NULL -- Active, Repair, Inactive
);

-- 3. SITE WORK LOCATIONS
CREATE TABLE work_locations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    siteName TEXT NOT NULL,
    areaName TEXT NOT NULL,
    customerName TEXT NOT NULL,
    description TEXT
);

-- 4. INCOME LEDGER (Auto-stamps Date & Time)
CREATE TABLE daily_incomes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    time TEXT NOT NULL,
    vehicleId INTEGER NOT NULL,
    vehicleName TEXT NOT NULL,
    workLocationId INTEGER NOT NULL,
    workLocationName TEXT NOT NULL,
    customerName TEXT NOT NULL,
    incomeAmount REAL NOT NULL,
    notes TEXT,
    recordedBy TEXT NOT NULL,
    recordedByColor TEXT NOT NULL
);

-- 5. FUEL MANAGEMENT INTAKES
CREATE TABLE fuel_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    time TEXT NOT NULL,
    vehicleId INTEGER NOT NULL,
    vehicleName TEXT NOT NULL,
    workLocationId INTEGER NOT NULL,
    workLocationName TEXT NOT NULL,
    fuelQuantity REAL NOT NULL,
    fuelCost REAL NOT NULL,
    notes TEXT,
    recordedBy TEXT NOT NULL,
    recordedByColor TEXT NOT NULL
);

-- 6. PREVENTIVE MAINTENANCE & REPAIRS
CREATE TABLE repair_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    time TEXT NOT NULL,
    vehicleId INTEGER NOT NULL,
    vehicleName TEXT NOT NULL,
    workLocationId INTEGER NOT NULL,
    workLocationName TEXT NOT NULL,
    engineOilCost REAL NOT NULL,
    hydraulicOilCost REAL NOT NULL,
    brakeOilCost REAL NOT NULL,
    sparePartsCost REAL NOT NULL,
    laborCost REAL NOT NULL,
    totalCost REAL NOT NULL,
    repairDescription TEXT,
    recordedBy TEXT NOT NULL,
    recordedByColor TEXT NOT NULL
);

-- 7. PARTNER DRAWDOWN (WITHDRAWALS)
CREATE TABLE partner_payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    time TEXT NOT NULL,
    partnerId INTEGER NOT NULL,
    partnerName TEXT NOT NULL,
    amountPaid REAL NOT NULL,
    paymentMethod TEXT NOT NULL,
    notes TEXT,
    recordedBy TEXT NOT NULL,
    recordedByColor TEXT NOT NULL
);

-- 8. OUTSTANDING CREDITS & RECEIVABLES
CREATE TABLE outstanding_credits (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customerName TEXT NOT NULL,
    workLocationName TEXT NOT NULL,
    vehicleName TEXT NOT NULL,
    amountDue REAL NOT NULL,
    dueDate TEXT NOT NULL,
    paidAmount REAL NOT NULL,
    remainingAmount REAL NOT NULL,
    status TEXT NOT NULL -- Paid, Pending
);

-- 9. SECURITY SAFETY PASSCODE
CREATE TABLE app_passcode (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    passcode TEXT NOT NULL,
    isEnabled INTEGER NOT NULL DEFAULT 1
);

-- 10. SYSTEM SECURITY AUDIT LOGS
CREATE TABLE audit_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    action TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    performedBy TEXT NOT NULL,
    partnerColor TEXT NOT NULL
);

-- 11. SURGICAL EDIT ENTRY HISTORICAL TRAIL
CREATE TABLE edit_history_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tableName TEXT NOT NULL,
    recordId INTEGER NOT NULL,
    oldValue TEXT NOT NULL,
    newValue TEXT NOT NULL,
    editedBy TEXT NOT NULL,
    editedByColor TEXT NOT NULL,
    timestamp TEXT NOT NULL
);
```

---

## 📂 Step-by-Step File Structure Map

### Section A: Native Material 3 Android App Setup
Your native codebase operates under the following clean, standard components:
* **/app/src/main/AndroidManifest.xml**: Configures main app permissions and designates `MainActivity` as launcher.
* **/app/src/main/res/values/strings.xml**: Houses local display names, ensuring platform metadata aligns cleanly with the system.
* **/app/src/main/java/com/example/data/Entities.kt**: Defines matching Room entity data structures for SQLite.
* **/app/src/main/java/com/example/data/AppDaos.kt**: Connects DAOs with custom SQLite queries.
* **/app/src/main/java/com/example/data/AppDatabase.kt**: Orchestrates standard database builders.
* **/app/src/main/java/com/example/data/DataRepository.kt**: Encapsulates offline operations, JSON back up / restoration, and audit trackers.
* **/app/src/main/java/com/example/ui/LanguageSupport.kt**: Localizes all variables into easy English/Urdu lookups.
* **/app/src/main/java/com/example/ui/LedgerViewModel.kt**: Holds presentation states, auto share metrics, security checks, and filter lists.
* **/app/src/main/java/com/example/ui/MainLedgerApp.kt**: Modular Compose layout displaying PIN prompts, EasyPaisa dashboards, edit panels, and interactive Canvas double-bar graphs.

### Section B: Cross-Platform Flutter Setup
The generated multi-device Flutter project is cleanly modular:
* **/cross_platform_flutter/pubspec.yaml**: Identifies third-party dependencies, including custom FFI bridges for native Windows Laptop SQLite compilation.
* **/cross_platform_flutter/lib/language_translations.dart**: Handles translations dynamically.
* **/cross_platform_flutter/lib/database_helper.dart**: Initializes target databases and seeds default settings.
* **/cross_platform_flutter/lib/main.dart**: Main portal hosting adaptive layouts (Windows sidebar list structures and compact mobile pages), customizable grids, and analytical summaries.

---

## 💻 Windows Laptop & Web Compile Manual (Flutter)

To run your code on a Windows Laptop, web browser, or mobile:

1. **Prerequisites**: Ensure you have Flutter SDK (>=3.0.0) and visual C++ build tools installed on your Windows machine.
2. **Execute Desktop Build**:
   ```bash
   cd cross_platform_flutter
   flutter pub get
   flutter run -d windows
   ```
3. **Execute Web Build**:
   ```bash
   flutter run -d chrome
   ```
4. **Export App Build (APK or EXE)**:
   * **Android APK**: `flutter build apk --release`
   * **Windows Executable**: `flutter build windows`

---

### Key Capabilities Built:
* **EasyPaisa Style Dashboard**: Clear metrics banner with green status overlays and 9 descriptive quick action grids.
* **Dual Language (Urdu & English)**: Toggle translations dynamically on both Android (Compose) and Flutter.
* **Secure Locking System**: Encrypted passcode screen gating primary modules to block unauthorized entry.
* **Automatic Shared Ratio Calculations**: Calculates precise partner share statistics instantly based on default percentage weight.
