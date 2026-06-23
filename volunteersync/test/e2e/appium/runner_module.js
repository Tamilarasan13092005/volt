/**
 * Appium runner exported as an async module function (used by master_runner.js)
 */

'use strict';

const ExcelReporter = require('../utils/excel_reporter');
const { runAuthTests }       = require('./tests/auth.test');
const { runDashboardTests }  = require('./tests/dashboard.test');
const { runVolunteersTests } = require('./tests/volunteers.test');
const { runEventsTests }     = require('./tests/events.test');
const { runAttendanceTests } = require('./tests/attendance.test');
const { runReportsTests }    = require('./tests/reports.test');
const { runSettingsTests }   = require('./tests/settings.test');
const { runAiChatTests }     = require('./tests/ai_chat.test');

module.exports = async function runAppiumSuite() {
  const reporter = new ExcelReporter('appium_e2e_report.xlsx', 'Appium Android E2E');
  const suites = [
    { name: 'Auth',        fn: runAuthTests       },
    { name: 'Dashboard',   fn: runDashboardTests  },
    { name: 'Volunteers',  fn: runVolunteersTests  },
    { name: 'Events',      fn: runEventsTests      },
    { name: 'Attendance',  fn: runAttendanceTests  },
    { name: 'Reports',     fn: runReportsTests     },
    { name: 'Settings',    fn: runSettingsTests    },
    { name: 'AI Chat',     fn: runAiChatTests      },
  ];
  for (const suite of suites) {
    console.log(`\n[Appium] ▶ ${suite.name}`);
    await suite.fn(reporter);
  }
  await reporter.finalize();
};
