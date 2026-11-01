# Motora 🚗⚡
> **Next-Generation Vehicle Health, 3D Digital Twin & Service Lifecycle Companion**

Motora is a premium, offline-first vehicle management application built with **Flutter**, **Drift (SQLite)**, and **Riverpod**. Designed specifically for modern connected and electric vehicles (such as the MG Comet EV), Motora bridges the gap between drivers and service centers through interactive 3D component diagnostics, defect clustering, and service handover reporting.

---

## 🌟 Key Features

### 1. 🏎️ Interactive 3D Vehicle Digital Twin
- **Interactive glTF/GLB Viewer**: Orbit, pan, and zoom around the vehicle in real-time.
- **Mesh Component Mapping**: Over 17 mapped component nodes (Battery Pack, Electric Motor, Inverter, Steering Rack, Brake Calipers, Infotainment Touchscreen, etc.).
- **Visual Defect Pinning**: Quickly isolate defective components directly on the 3D model.

### 2. 📡 Active Defect Radar & Recurring Issue Intelligence
- **Active Defect Radar**: Visual component-level cluster radar that categorizes open issues by severity (Critical, High, Medium, Low).
- **Recurrence Tracking**: Intelligent pattern detection that links returning issues to parent tickets to highlight chronic vehicle defects.
- **Advanced Search & Filtering**: Instant full-text search across titles, component tags, and technician remarks with multi-criteria sorting.

### 3. 🔧 Service Visit Workflow & PDF Handover Reports
- **Visit Tracking**: Manage active service center visits, associating multiple unresolved issues into a single ticket.
- **Technician Collaboration**: Log individual component diagnostic notes, estimated resolution times, and technician remarks.
- **Multi-Page PDF Handover Reports**: Automatically generates professional, print-ready handover documents containing vehicle telemetry, itemized defect breakdowns, technician sign-off blocks, and attached defect photos.

### 4. ⏰ Maintenance Reminders & Odometer Tracking
- **Smart Reminders**: Schedule upcoming services by date, target odometer reading, or whichever comes first.
- **Lead-time Alerts**: Native local notifications alert you prior to service deadlines.
- **Odometer History**: Log periodic mileage and track driving patterns over time.

### 5. 📂 Document Vault & Offline Backup
- **Encrypted Document Vault**: Store vehicle RC, insurance policies, pollution certificates, and extended warranty documents with expiry monitoring.
- **Offline-First Backup & Restore**: Full export and import capabilities creating portable ZIP archives containing database records and media attachments.

---

## 🛠️ Architecture & Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | [Flutter 3.x](https://flutter.dev) (Dart 3) |
| **State Management** | [Riverpod](https://riverpod.dev) 2.x with StateNotifier & AutoDispose |
| **Local Database** | [Drift (SQLite)](https://drift.simonbinder.eu/) with schema migrations |
| **Navigation** | [GoRouter](https://pub.dev/packages/go_router) declarative routing |
| **Document Generation** | [pdf](https://pub.dev/packages/pdf) & [printing](https://pub.dev/packages/printing) |
| **Notifications** | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) |
| **3D Rendering** | [flutter_cube](https://pub.dev/packages/flutter_cube) interactive viewport |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24+ recommended)
- Android SDK 34+ (for Android deployment)
- Dart SDK 3.5+

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/harsha059/Motora.git
   cd Motora
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run code generation (if modifying Drift tables):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the test suite:**
   ```bash
   flutter test
   ```

5. **Launch the application:**
   ```bash
   flutter run
   ```

---

## 🧪 Testing

Motora features comprehensive unit and widget test coverage:
```bash
flutter test test/unit/issue_repository_test.dart
flutter test test/unit/service_workflow_test.dart
flutter test test/unit/sprint3_intelligence_test.dart
flutter test test/widget_test.dart
```

---

## 📄 License
This project is licensed under the MIT License.
