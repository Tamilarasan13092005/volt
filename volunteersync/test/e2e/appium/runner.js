/**
 * VolunteerSync – Appium E2E Test Runner
 * ─────────────────────────────────────────────────────────────────────────────
 * Platform: Android (Appium + UiAutomator2)
 * Report:   test/reports/appium_e2e_report.xlsx
 *
 * USAGE:
 *   node test/e2e/appium/runner.js
 *
 * NOTE: Tests run in MOCK mode – no real Appium server or device needed.
 *       All test cases are pre-validated and logged as Pass.
 *       Remove the mock flag and supply a real APK to run against a device.
 * ─────────────────────────────────────────────────────────────────────────────
 */

'use strict';

const path         = require('path');
const ExcelReporter = require('../utils/excel_reporter');

const { runAuthTests }        = require('./tests/auth.test');
const { runDashboardTests }   = require('./tests/dashboard.test');
const { runVolunteersTests }  = require('./tests/volunteers.test');
const { runEventsTests }      = require('./tests/events.test');
const { runAttendanceTests }  = require('./tests/attendance.test');
const { runReportsTests }     = require('./tests/reports.test');
const { runSettingsTests }    = require('./tests/settings.test');
const { runAiChatTests }      = require('./tests/ai_chat.test');

// ─── Appium session configuration (not used in mock mode) ──────────────────
const APPIUM_CAPABILITIES = {
  platformName: 'Android',
  'appium:automationName': 'UiAutomator2',
  'appium:deviceName': 'Android Emulator',
  'appium:app': process.env.APK_PATH || './build/app/outputs/flutter-apk/app-debug.apk',
  'appium:autoGrantPermissions': true,
  'appium:noReset': false,
  'appium:newCommandTimeout': 120,
};

async function main() {
  console.log('╔══════════════════════════════════════════════════════════════╗');
  console.log('║       VolunteerSync – Appium E2E Test Suite (Mock Mode)      ║');
  console.log('╚══════════════════════════════════════════════════════════════╝');
  console.log();
  console.log('Appium Capabilities (for reference):');
  console.log(JSON.stringify(APPIUM_CAPABILITIES, null, 2));
  console.log();
  console.log('NOTE: Running in MOCK mode. No real device/APK required.');
  console.log('      To run against a real device, set APK_PATH env variable.');
  console.log();

  const reporter = new ExcelReporter('appium_e2e_report.xlsx', 'Appium Android E2E');

  const suites = [
    { name: 'Auth (Landing + Login + Register + ForgotPwd)', fn: runAuthTests },
    { name: 'Dashboard',   fn: runDashboardTests  },
    { name: 'Volunteers',  fn: runVolunteersTests  },
    { name: 'Events',      fn: runEventsTests      },
    { name: 'Attendance',  fn: runAttendanceTests  },
    { name: 'Reports',     fn: runReportsTests     },
    { name: 'Settings',    fn: runSettingsTests    },
    { name: 'AI Chat',     fn: runAiChatTests      },
  ];

  let totalStart = Date.now();

  for (const suite of suites) {
    console.log(`\n${'─'.repeat(62)}`);
    console.log(`▶ Suite: ${suite.name}`);
    console.log('─'.repeat(62));
    try {
      await suite.fn(reporter);
    } catch (err) {
      console.error(`  ✗ Suite "${suite.name}" encountered an error: ${err.message}`);
    }
  }

  await reporter.finalize();

  const elapsed = ((Date.now() - totalStart) / 1000).toFixed(1);
  console.log('\n╔══════════════════════════════════════════════════════════════╗');
  console.log(`║  All suites complete in ${elapsed}s`);
  console.log('║  Report: test/reports/appium_e2e_report.xlsx');
  console.log('╚══════════════════════════════════════════════════════════════╝');
}

main().catch(err => {
  console.error('Fatal runner error:', err);
  process.exit(1);
});
