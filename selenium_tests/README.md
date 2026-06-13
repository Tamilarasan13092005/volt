# VolunteerSync — Selenium E2E Automation Testing Suite

End-to-End Selenium WebDriver tests for the **VolunteerSync Flutter Web** application covering all major user flows across 100 distinct test cases. Results are compiled into a professional styled Excel analysis report.

---

## 📁 Folder Structure

```
selenium_tests/
├── package.json          — NPM scripts & dependencies
├── config.js             — Browser & URL configuration
├── test_cases_list.js    — 100 E2E test case definitions
├── e2e_test.js           — Real Selenium WebDriver test runner
├── run_simulator.js      — Dry-run simulator (no browser needed)
├── reporter.js           — Excel report generator (exceljs)
└── reports/
    ├── selenium_report.xlsx        — Generated Excel report
    └── screenshots/                — Failure screenshots (FAIL_TC-XXX.png)
```

---

## 📊 Test Coverage (100 Cases)

| Module | Cases | Range |
|---|---|---|
| Landing Page | 10 | TC-001 – TC-010 |
| Auth / Login | 14 | TC-011 – TC-024 |
| Auth / Register & Forgot Password | 6 | TC-025 – TC-030 |
| Dashboard | 15 | TC-031 – TC-045 |
| Volunteers | 15 | TC-046 – TC-060 |
| Events | 12 | TC-061 – TC-072 |
| Attendance | 10 | TC-073 – TC-082 |
| Reports | 4 | TC-083 – TC-086 |
| AI Chat (Volt) | 8 | TC-087 – TC-094 |
| Settings & Logout | 6 | TC-095 – TC-100 |

---

## 🚀 Quick Start — Simulation (No Browser Needed)

```bash
cd selenium_tests
npm install
npm run test:simulate
```

Runs all 100 test cases in simulation mode and writes the styled Excel report to `reports/selenium_report.xlsx`.

---

## ▶️ Running Real Selenium E2E Tests

### Prerequisites

1. **Google Chrome** installed (latest version).
2. **ChromeDriver** matching your Chrome version (installed automatically via `chromedriver` npm package).
3. **Flutter Web server** running:
   ```bash
   cd ..
   flutter run -d web-server --web-port=8080
   ```

### Run Tests

```bash
cd selenium_tests
npm install
npm run test:real
```

The browser will open, interact with every screen automatically, then close and write the Excel report.

---

## 📈 Excel Report Features

- **Teal-themed header** matching the app's web branding
- **Execution summary block** — Total, Passed, Failed, Pass Rate %, Total Duration
- **100-row results table** with:
  - 🟢 Green PASS / 🔴 Red FAIL status cells
  - Start Time, End Time, Duration (ms) per test
  - Error message column for failures
  - Alternating Teal-50 row striping
- **EBUSY fallback** — if the file is open in Excel, saves a timestamped copy

---

*Built as part of the VolunteerSync QA Automation Framework.*
