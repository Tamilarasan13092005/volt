const path = require('path');

// Selenium WebDriver Configuration for VolunteerSync Flutter Web App
const config = {
  // Base URL of the running Flutter Web app (served locally or deployed)
  baseUrl: 'http://localhost:8080',

  // Browser settings
  browser: 'chrome',

  // ChromeDriver options
  chromeOptions: {
    args: [
      '--window-size=1280,900',
      '--disable-gpu',
      '--no-sandbox',
      '--disable-dev-shm-usage',
      // Uncomment below to run headlessly (no browser window):
      // '--headless',
    ]
  },

  // Demo credentials (from README)
  demoEmail: 'alex@volunteersync.io',
  demoPassword: 'password123',

  // Timeouts (ms)
  implicitWait: 5000,
  pageLoadTimeout: 30000,
  elementTimeout: 10000,

  // Screenshot directory (saved on failure)
  screenshotDir: path.join(__dirname, 'reports', 'screenshots'),
};

module.exports = config;
