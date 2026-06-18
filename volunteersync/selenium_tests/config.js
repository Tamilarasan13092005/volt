const path = require('path');

// Selenium WebDriver Configuration for VolunteerSync Flutter Web App
const config = {
  // Base URL — overridable via BASE_URL env var (used in CI against deployed site)
  baseUrl: process.env.BASE_URL || 'http://localhost:8080',

  // Browser settings
  browser: 'chrome',

  // ChromeDriver options — HEADLESS=true enables headless mode in CI
  chromeOptions: {
    args: [
      '--window-size=1280,900',
      '--disable-gpu',
      '--no-sandbox',
      '--disable-dev-shm-usage',
      ...(process.env.HEADLESS === 'true' ? ['--headless=new'] : []),
    ]
  },

  // Demo credentials (from README)
  demoEmail: process.env.TEST_EMAIL || 'alex@volunteersync.io',
  demoPassword: process.env.TEST_PASSWORD || 'password123',

  // Timeouts (ms)
  implicitWait: 5000,
  pageLoadTimeout: 30000,
  elementTimeout: 10000,

  // Screenshot directory (saved on failure)
  screenshotDir: path.join(__dirname, 'reports', 'screenshots'),
};

module.exports = config;
