# VolunteerSync Appium E2E Automation Testing Suite

This directory contains the End-to-End (E2E) testing suite for the VolunteerSync Android mobile application, built using Appium and WebdriverIO (Node.js).

It is structured to execute a complete user flow across all major features of the application, and then generate a professional, styled Excel sheet containing detailed analysis of the results.

---

## Features Tested
The test suite drives the app through a complete user flow:
1. **Landing & Auth Journey**: Navigate through the landing screen, login using the demo credentials, and navigate the register/forgot-password pages.
2. **Dashboard**: Verify KPIs, charts, and summary statistics display correctly.
3. **Volunteers Module**: Navigate to the list, perform search/filter queries, inspect details sheets.
4. **Events Module**: Check event listings and progress indicators.
5. **Attendance Module**: View attendance check-in records.
6. **Reports Module**: Review analytics graphs and statistics.
7. **Volt AI Assistant**: Send chat prompts, check for responses from the AI.
8. **Settings & Logout**: Toggle preferences (push notifications, email settings), verify About info, and trigger a secure sign-out.

---

## Folder Structure
- [package.json](file:///c:/Projects/volunteersync/appium_tests/package.json) - NPM dependencies and test run commands.
- [test_cases_list.js](file:///c:/Projects/volunteersync/appium_tests/test_cases_list.js) - Dataset defining the 100 E2E test cases.
- [config.js](file:///c:/Projects/volunteersync/appium_tests/config.js) - WebdriverIO capabilities configurations.
- [reporter.js](file:///c:/Projects/volunteersync/appium_tests/reporter.js) - Styled Excel sheet report generator.
- [e2e_test.js](file:///c:/Projects/volunteersync/appium_tests/e2e_test.js) - Real E2E Appium automation script.
- [run_simulator.js](file:///c:/Projects/volunteersync/appium_tests/run_simulator.js) - Dry-run simulator to test reporting and logging without a real emulator.
- `reports/` - Generated reports directory containing the Excel analysis (`test_report.xlsx`).

---

## Quick Start (Simulation / Dry-Run Mode)
To verify the Excel report generation and review the test runner flow without setting up an emulator or starting the Appium server, run:
```bash
npm install
npm run test:simulate
```
This executes the simulated suite, prints logs to the terminal, and writes the Excel report to `reports/test_report.xlsx`.

---

## Running Real Appium E2E Tests

### Prerequisites
1. **Node.js**: Installed (v18+ recommended).
2. **Android SDK & Emulator**:
   - Ensure `ANDROID_HOME` environment variable is set.
   - Run an Android Virtual Device (AVD) via Android Studio.
3. **Appium Server**:
   - Start Appium using command: `npx appium`
   - Ensure the `uiautomator2` driver is installed: `npx appium driver install uiautomator2`

### Setup & Run
1. Build the Flutter debug APK:
   ```bash
   cd ..
   flutter build apk --debug
   ```
2. Navigate to this directory and install dependencies:
   ```bash
   cd appium_tests
   npm install
   ```
3. Run the E2E test suite:
   ```bash
   npm run test:real
   ```
4. Review the generated styled Excel report in `reports/test_report.xlsx`.
