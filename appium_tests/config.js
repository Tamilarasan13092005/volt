const path = require('path');

// WebdriverIO & Appium Configuration
const config = {
  // Appium server settings
  hostname: '127.0.0.1',
  port: 4723,
  path: '/', // Appium 2.x default path

  // Capabilities settings
  capabilities: {
    platformName: 'Android',
    'appium:automationName': 'UiAutomator2',
    'appium:deviceName': 'Android Emulator',
    'appium:app': path.join(__dirname, '..', 'build', 'app', 'outputs', 'flutter-apk', 'app-debug.apk'),
    'appium:appPackage': 'com.volunteersync.app',
    'appium:appActivity': 'com.volunteersync.app.MainActivity',
    'appium:noReset': false,
    'appium:fullReset': false,
    'appium:newCommandTimeout': 240, // Extended timeout for large test flows
  },

  // WebdriverIO client settings
  logLevel: 'info',
  waitforTimeout: 15000,
  connectionRetryTimeout: 120000,
  connectionRetryCount: 3
};

module.exports = config;
