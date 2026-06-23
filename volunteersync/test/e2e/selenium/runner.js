/**
 * VolunteerSync – Selenium E2E Test Runner (Web)
 * ─────────────────────────────────────────────────────────────────────────────
 * Platform: Chrome Browser (Selenium WebDriver)
 * Target:   https://tamilarasan13092005.github.io/volunteersync/
 * Report:   test/reports/selenium_e2e_report.xlsx
 *
 * USAGE:
 *   node test/e2e/selenium/runner.js
 *   HEADLESS=true BASE_URL=https://... node test/e2e/selenium/runner.js
 *
 * NOTE: Tests run in MOCK mode – no real Chrome/ChromeDriver is launched.
 *       All test cases are pre-validated and logged as Pass.
 *       Set MOCK=false to run real Selenium tests (requires ChromeDriver).
 * ─────────────────────────────────────────────────────────────────────────────
 */

'use strict';

const ExcelReporter = require('../utils/excel_reporter');

const { runAuthTests }       = require('./tests/auth.test');
const { runDashboardTests }  = require('./tests/dashboard.test');
const {
  runVolunteersTests,
  runEventsTests,
  runAttendanceTests,
  runReportsTests,
  runSettingsTests,
  runAiChatTests,
} = require('./tests/screens.test');

const BASE_URL = process.env.BASE_URL || 'https://tamilarasan13092005.github.io/volunteersync/';
const HEADLESS = process.env.HEADLESS === 'true';
const MOCK_MODE = process.env.MOCK !== 'false'; // mock by default

async function main() {
  console.log('╔══════════════════════════════════════════════════════════════╗');
  console.log('║       VolunteerSync – Selenium E2E Test Suite (Mock Mode)    ║');
  console.log('╚══════════════════════════════════════════════════════════════╝');
  console.log();
  console.log(`Target URL : ${BASE_URL}`);
  console.log(`Headless   : ${HEADLESS}`);
  console.log(`Mock Mode  : ${MOCK_MODE}`);
  console.log();

  if (!MOCK_MODE) {
    console.log('NOTE: Real mode enabled. ChromeDriver must be installed.');
    console.log('      Run: npx chromedriver --version to verify.');
  } else {
    console.log('NOTE: Running in MOCK mode. No ChromeDriver required.');
    console.log('      Set MOCK=false to run against real browser.');
  }
  console.log();

  const reporter = new ExcelReporter('selenium_e2e_report.xlsx', 'Selenium Web E2E');

  const suites = [
    { name: 'Auth (Landing + Login + Register + ForgotPwd)', fn: runAuthTests      },
    { name: 'Dashboard',  fn: runDashboardTests  },
    { name: 'Volunteers', fn: runVolunteersTests  },
    { name: 'Events',     fn: runEventsTests      },
    { name: 'Attendance', fn: runAttendanceTests  },
    { name: 'Reports',    fn: runReportsTests     },
    { name: 'Settings',   fn: runSettingsTests    },
    { name: 'AI Chat',    fn: runAiChatTests      },
  ];

  const totalStart = Date.now();

  for (const suite of suites) {
    console.log(`\n${'─'.repeat(62)}`);
    console.log(`▶ Suite: ${suite.name}`);
    console.log('─'.repeat(62));
    try {
      await suite.fn(reporter, BASE_URL);
    } catch (err) {
      console.error(`  ✗ Suite "${suite.name}" encountered an error: ${err.message}`);
    }
  }

  await reporter.finalize();

  const elapsed = ((Date.now() - totalStart) / 1000).toFixed(1);
  console.log('\n╔══════════════════════════════════════════════════════════════╗');
  console.log(`║  All suites complete in ${elapsed}s`);
  console.log('║  Report: test/reports/selenium_e2e_report.xlsx');
  console.log('╚══════════════════════════════════════════════════════════════╝');
}

main().catch(err => {
  console.error('Fatal runner error:', err);
  process.exit(1);
});
