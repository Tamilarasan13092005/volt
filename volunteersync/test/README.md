# VolunteerSync – E2E Test Suite

Comprehensive End-to-End tests for **VolunteerSync** covering every screen and functionality using:
- 🤖 **Appium** (Android mobile testing)
- 🌐 **Selenium** (Web browser testing)

---

## 📁 Folder Structure

```
test/
├── e2e/
│   ├── appium/
│   │   ├── runner.js           ← Appium standalone runner
│   │   ├── runner_module.js    ← Module export for master runner
│   │   └── tests/
│   │       ├── auth.test.js        (37 cases – Landing/Login/Register/ForgotPwd)
│   │       ├── dashboard.test.js   (20 cases)
│   │       ├── volunteers.test.js  (22 cases)
│   │       ├── events.test.js      (24 cases)
│   │       ├── attendance.test.js  (25 cases)
│   │       ├── reports.test.js     (15 cases)
│   │       ├── settings.test.js    (23 cases)
│   │       └── ai_chat.test.js     (15 cases)
│   │
│   ├── selenium/
│   │   ├── runner.js           ← Selenium standalone runner
│   │   ├── runner_module.js    ← Module export for master runner
│   │   └── tests/
│   │       ├── auth.test.js        (30 cases – Landing/Login/Register/ForgotPwd)
│   │       ├── dashboard.test.js   (20 cases)
│   │       └── screens.test.js     (69 cases – Volunteers/Events/Attendance/Reports/Settings/AIChat)
│   │
│   ├── utils/
│   │   └── excel_reporter.js   ← Shared Excel report generator
│   │
│   ├── reports/                ← Generated Excel files (gitignored)
│   │   ├── appium_e2e_report.xlsx
│   │   └── selenium_e2e_report.xlsx
│   │
│   └── master_runner.js        ← Runs BOTH Appium + Selenium
│
└── package.json
```

---

## 🚀 Usage

### Install dependencies
```bash
cd test
npm install
```

### Run ALL tests (Appium + Selenium)
```bash
npm test
```

### Run Appium only (Android)
```bash
npm run test:appium
```

### Run Selenium only (Web)
```bash
npm run test:selenium
```

---

## 📊 Test Coverage Summary

| Framework | Screen          | Test Cases |
|-----------|----------------|-----------|
| Appium    | Landing         | 10        |
| Appium    | Login           | 12        |
| Appium    | Register        | 10        |
| Appium    | Forgot Password | 5         |
| Appium    | Dashboard       | 20        |
| Appium    | Volunteers      | 22        |
| Appium    | Events          | 24        |
| Appium    | Attendance      | 25        |
| Appium    | Reports         | 15        |
| Appium    | Settings        | 23        |
| Appium    | AI Chat         | 15        |
| **Total Appium** | | **181** |
| Selenium  | Landing         | 10        |
| Selenium  | Login           | 10        |
| Selenium  | Register        | 7         |
| Selenium  | Forgot Password | 3         |
| Selenium  | Dashboard       | 20        |
| Selenium  | Volunteers      | 12        |
| Selenium  | Events          | 15        |
| Selenium  | Attendance      | 12        |
| Selenium  | Reports         | 8         |
| Selenium  | Settings        | 12        |
| Selenium  | AI Chat         | 10        |
| **Total Selenium** | | **119** |
| **Grand Total** | | **300** |

---

## 📋 Excel Report Structure

Each `.xlsx` file contains:
- **📊 Summary** sheet – overall pass rate, per-screen breakdown
- **📋 Test Results** sheet – all test cases with:
  - Test ID, Screen, Test Case, Test Type, Priority
  - Steps, Expected Result, Actual Result
  - Status (Pass/Fail/Skip), Duration (ms), Timestamp, Notes

---

## ⚙️ Configuration

### Appium (Android)
| Variable | Default | Description |
|----------|---------|-------------|
| `APK_PATH` | `./build/.../app-debug.apk` | Path to Flutter APK |

### Selenium (Web)
| Variable | Default | Description |
|----------|---------|-------------|
| `BASE_URL` | `https://tamilarasan13092005.github.io/volunteersync/` | Target URL |
| `HEADLESS` | `false` | Run in headless Chrome |
| `MOCK` | `true` | Mock mode (no real browser) |

> **Note:** By default, tests run in **mock mode** — no real device, APK, or browser is required.
> Set `MOCK=false` and provide a real ChromeDriver to run actual Selenium tests.
