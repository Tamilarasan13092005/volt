/**
 * Selenium runner exported as an async module function (used by master_runner.js)
 */

'use strict';

const ExcelReporter = require('../utils/excel_reporter');
const { runAuthTests }      = require('./tests/auth.test');
const { runDashboardTests } = require('./tests/dashboard.test');
const {
  runVolunteersTests, runEventsTests, runAttendanceTests,
  runReportsTests, runSettingsTests, runAiChatTests
} = require('./tests/screens.test');

const BASE_URL = process.env.BASE_URL || 'https://tamilarasan13092005.github.io/volunteersync/';

module.exports = async function runSeleniumSuite() {
  const reporter = new ExcelReporter('selenium_e2e_report.xlsx', 'Selenium Web E2E');
  const suites = [
    { name: 'Auth',        fn: (r) => runAuthTests(r, BASE_URL)       },
    { name: 'Dashboard',   fn: (r) => runDashboardTests(r, BASE_URL)  },
    { name: 'Volunteers',  fn: (r) => runVolunteersTests(r, BASE_URL)  },
    { name: 'Events',      fn: (r) => runEventsTests(r, BASE_URL)      },
    { name: 'Attendance',  fn: (r) => runAttendanceTests(r, BASE_URL)  },
    { name: 'Reports',     fn: (r) => runReportsTests(r, BASE_URL)     },
    { name: 'Settings',    fn: (r) => runSettingsTests(r, BASE_URL)    },
    { name: 'AI Chat',     fn: (r) => runAiChatTests(r, BASE_URL)      },
  ];
  for (const suite of suites) {
    console.log(`\n[Selenium] ▶ ${suite.name}`);
    await suite.fn(reporter);
  }
  await reporter.finalize();
};
