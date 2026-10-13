# CSE101 Final Project Documentation: ServeEase Restaurant POS

## 1. Project Title & Overview
- **Project Title:** ServeEase Restaurant POS (Point-of-Sale & Management System)
- **Course:** CSE101 Final Project — Group Elective
- **Platform:** Flutter (Responsive Tablet UI, Android, Windows, Web)
- **Target Audience:** Restaurant Cashiers & Restaurant Owners / Managers

ServeEase is a front-end Restaurant POS application developed strictly adhering to **CSE101 Modules 1 to 15**. It demonstrates understanding of core Flutter widgets, responsive layouts, page navigation, custom forms with validation, and runtime state management using pure `setState()` and in-memory data structures without external database engines.

---

## 2. Compliance with CSE101 Guidelines

| Requirement | Implementation Detail |
| :--- | :--- |
| **Allowed Modules (1–15 Only)** | Uses core widgets (`Text`, `Icon`, `Image`, `Container`, `Card`, `ElevatedButton`, `TextField`, `TextFormField`, `AppBar`, `Drawer`, `BottomNavigationBar`, `Column`, `Row`, `ListView`, `GridView`, `Expanded`, `Stack`). |
| **Strict No-Database Rule** | **Zero databases used**. No SQLite, Hive, Firebase, Supabase, or MySQL. All state is held in runtime Dart memory lists (`List<MenuItem>`, `List<OrderReceipt>`, `List<Employee>`). |
| **Screens (Minimum 3)** | Implements **18 unique screens/modals** (Role Access, Owner Login, Cashier Dashboard, POS Terminal, Item Customizer, Checkout Discount Form, Cash Tender, Card Terminal, QR Pay, Virtual Thermal Receipt, Receipt History, Owner Dashboard, Menu CRUD, Staff CRUD, System Settings). |
| **Form Feature & Validation** | Contains **5 validated forms**: (1) Owner Login, (2) Discount ID Verification, (3) Cash Amount Tendered, (4) Add/Edit Menu Item, (5) Add/Edit Employee. |
| **Responsive Tablet Design** | Features a dual-pane landscape split layout (60% Menu Grid on the left, 40% Live Cart on the right) optimized for tablet POS terminals. |

---

## 3. Key Feature Walkthrough

### 3.1 Role Selection & Access Portal
- **Cashier Button:** Directly launches the Cashier POS Terminal.
- **Owner Button:** Secure gateway protected by Owner Login.
  - Default Username: `enchang`
  - Default Password: `enchang` (with password visibility toggle and form validation).

### 3.2 Cashier Interface & POS Terminal
1. **Cashier Dashboard:** Displays metrics for Today's Orders, Total Sales (₱), Pending Orders, and Completed Orders. Includes a prominent **NEW ORDER** button and quick action shortcuts.
2. **Menu Catalog:** Search bar with real-time text query and category filtering across 9 categories (Burgers, Pizza, Pasta, Chicken, Rice Meals, Snacks, Desserts, Coffee, Drinks) with at least 2 default items per category.
3. **Availability Badging:** Menu items show green "Available" or red "Not Available" tags. Out-of-stock items cannot be ordered.
4. **Item Customizer (Modal):** Select between **Small, Medium, and Large** sizes with dynamic price recalculation, quantity counter, and a custom special notes field (e.g., "Less ice, extra milk").
5. **Order Type Selector:** Toggle between **Dine In** (with Table Number selection 1–12), **Takeout**, and **Delivery**.
6. **Checkout & Discount (Modal):** Allows applying a 20% discount with required ID validation (Senior Citizen, PWD, Solo Parent, Employee, Promo) and recalculates the grand total.
7. **Payment Methods (Modal):**
   - **Cash:** Cash tender input with real-time change calculation and quick bill chips (Exact, ₱500, ₱1,000).
   - **Card:** Simulated card terminal tap/swipe with approval flow.
   - **QR Pay:** High-contrast QR code display with simulated success/failure buttons.
8. **Virtual Thermal Receipt:** Formats an authentic thermal receipt displaying store header, order ID, cashier ID, itemized order with notes, subtotal, discount details, and change. Includes "Print Receipt", "New Order", and "Done" actions.
9. **Receipt History:** Persistent runtime log of completed transactions with search, filter chips, and one-tap receipt reprint modal.

### 3.3 Owner / Admin Interface
1. **Admin Dashboard:** Business overview cards (Sales, Orders, Completed, Pending), stock overview (Available vs Out of Stock), and a pure Flutter weekly sales bar chart (Mon–Sun).
2. **Menu Management (CRUD):** Add, edit, or delete menu items. Toggling the "Available" switch immediately updates the Cashier POS screen in real time.
3. **Employees Management (CRUD):** Manage staff credentials, roles (Cashier, Server, Cook, Manager), and Active/Inactive status.
4. **Settings:** Light Mode / Dark Mode toggle and editable restaurant business profile (Store Name, Contact Number, Address).

---

## 4. Group Member Roles (Template)

| Member Name | Role & Contribution |
| :--- | :--- |
| **Member 1** | Project Lead, Architecture Setup & Cashier POS Dual-Pane Layout |
| **Member 2** | Forms & Dialogs (Owner Login, Item Customizer, Discount ID Verification) |
| **Member 3** | Payment Workflows (Cash with Change, Card Simulation, QR Pay, Virtual Receipt) |
| **Member 4** | Owner Portal & CRUD Operations (Menu Management, Staff Management, Settings) |

---

## 5. How to Run the App

1. Ensure the Flutter SDK is installed and configured.
2. In the project root (`new_elex`), execute:
   ```bash
   flutter pub get
   flutter test
   flutter run -d chrome     # Run in browser
   # OR
   flutter run -d windows    # Run as desktop application
   # OR
   flutter run -d <device>   # Run on connected tablet or Android emulator
   ```
