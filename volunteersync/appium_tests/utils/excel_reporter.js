const ExcelJS = require('exceljs');
const fs = require('fs');
const path = require('path');

class ExcelReporter {
  constructor(reportName = 'appium_report.xlsx') {
    this.reportPath = path.join(__dirname, '..', 'reports', reportName);
    this.workbook = new ExcelJS.Workbook();
    this.worksheet = this.workbook.addWorksheet('Test Results');
    
    const dir = path.dirname(this.reportPath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    this.worksheet.columns = [
      { header: 'Test ID', key: 'id', width: 10 },
      { header: 'Screen', key: 'screen', width: 20 },
      { header: 'Test Case', key: 'testCase', width: 40 },
      { header: 'Steps', key: 'steps', width: 50 },
      { header: 'Expected Result', key: 'expected', width: 30 },
      { header: 'Actual Result', key: 'actual', width: 30 },
      { header: 'Status', key: 'status', width: 15 },
      { header: 'Timestamp', key: 'timestamp', width: 25 },
    ];
    this.worksheet.getRow(1).font = { bold: true };
  }

  async addRow(result) {
    this.worksheet.addRow({
      id: result.id,
      screen: result.screen,
      testCase: result.testCase,
      steps: result.steps,
      expected: result.expected,
      actual: result.actual,
      status: result.status,
      timestamp: new Date().toISOString()
    });
    await this.workbook.xlsx.writeFile(this.reportPath);
  }
}

module.exports = new ExcelReporter(); // Singleton export
