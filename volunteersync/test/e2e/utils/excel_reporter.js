/**
 * ExcelReporter - Unified Excel Report Generator for VolunteerSync E2E Tests
 * Generates a rich, color-coded .xlsx report saved to the test/reports folder.
 */

const ExcelJS = require('exceljs');
const fs = require('fs');
const path = require('path');

class ExcelReporter {
  /**
   * @param {string} reportName - Name of the output .xlsx file
   * @param {string} suiteName  - Name of the test suite (e.g. "Appium", "Selenium")
   */
  constructor(reportName, suiteName = 'E2E Tests') {
    // Always output to test/reports regardless of where runner is called from
    const reportsDir = path.join(__dirname, '..', 'reports');
    if (!fs.existsSync(reportsDir)) {
      fs.mkdirSync(reportsDir, { recursive: true });
    }

    this.reportPath = path.join(reportsDir, reportName);
    this.suiteName  = suiteName;
    this.workbook   = new ExcelJS.Workbook();

    // ── Workbook metadata ─────────────────────────────────────────────────────
    this.workbook.creator  = 'VolunteerSync QA Automation';
    this.workbook.created  = new Date();
    this.workbook.modified = new Date();

    // ── Summary sheet ─────────────────────────────────────────────────────────
    this.summarySheet = this.workbook.addWorksheet('📊 Summary', {
      pageSetup: { fitToPage: true }
    });

    // ── Test results sheet ────────────────────────────────────────────────────
    this.worksheet = this.workbook.addWorksheet('📋 Test Results', {
      pageSetup: { fitToPage: true }
    });

    this._setupResultsSheet();
    this._passCount = 0;
    this._failCount = 0;
    this._skipCount = 0;
    this._rows = [];
  }

  // ── Private: Column definitions ─────────────────────────────────────────────
  _setupResultsSheet() {
    this.worksheet.columns = [
      { header: 'Test ID',         key: 'id',         width: 12  },
      { header: 'Screen',          key: 'screen',     width: 22  },
      { header: 'Test Case',       key: 'testCase',   width: 52  },
      { header: 'Test Type',       key: 'testType',   width: 16  },
      { header: 'Priority',        key: 'priority',   width: 12  },
      { header: 'Steps',           key: 'steps',      width: 60  },
      { header: 'Expected Result', key: 'expected',   width: 40  },
      { header: 'Actual Result',   key: 'actual',     width: 40  },
      { header: 'Status',          key: 'status',     width: 12  },
      { header: 'Duration (ms)',   key: 'duration',   width: 14  },
      { header: 'Timestamp',       key: 'timestamp',  width: 26  },
      { header: 'Notes',           key: 'notes',      width: 30  },
    ];

    // Header row styling
    const headerRow = this.worksheet.getRow(1);
    headerRow.height = 22;
    headerRow.eachCell((cell) => {
      cell.fill = {
        type: 'pattern', pattern: 'solid',
        fgColor: { argb: 'FF1E293B' }  // dark slate
      };
      cell.font   = { bold: true, color: { argb: 'FFF8FAFC' }, size: 11 };
      cell.border = {
        bottom: { style: 'medium', color: { argb: 'FF6366F1' } }
      };
      cell.alignment = { vertical: 'middle', horizontal: 'center', wrapText: false };
    });

    // Freeze the header row
    this.worksheet.views = [{ state: 'frozen', ySplit: 1 }];
  }

  // ── Public: Add a single test-result row ────────────────────────────────────
  async addRow(result) {
    const {
      id, screen, testCase, testType = 'Functional', priority = 'Medium',
      steps, expected, actual, status, duration = 0, notes = ''
    } = result;

    // Track counts
    if (status === 'Pass')   this._passCount++;
    else if (status === 'Fail') this._failCount++;
    else this._skipCount++;

    const rowData = {
      id, screen, testCase, testType, priority,
      steps, expected, actual, status,
      duration,
      timestamp: new Date().toISOString(),
      notes
    };
    this._rows.push(rowData);

    const row = this.worksheet.addRow(rowData);
    row.height = 18;

    // Status-based row colouring
    const bgColor = status === 'Pass'
      ? 'FF0F4C2E'   // dark green tint
      : status === 'Fail'
        ? 'FF4C1414'  // dark red tint
        : 'FF2D2D1A'; // dark yellow tint (skip/blocked)

    const statusFg = status === 'Pass'
      ? 'FF4ADE80'
      : status === 'Fail'
        ? 'FFEF4444'
        : 'FFFBBF24';

    row.eachCell((cell, colNum) => {
      cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: bgColor } };
      cell.font = { color: { argb: 'FFE2E8F0' }, size: 10 };
      cell.border = { bottom: { style: 'thin', color: { argb: 'FF334155' } } };
      cell.alignment = { vertical: 'middle', wrapText: colNum === 6 };
    });

    // Highlight the Status cell
    const statusCell = row.getCell('status');
    statusCell.font = { bold: true, color: { argb: statusFg }, size: 10 };

    await this._save();
  }

  // ── Public: Finalise report (write summary sheet) ───────────────────────────
  async finalize() {
    this._writeSummarySheet();
    await this._save();
    console.log(`\n✅ Report saved → ${this.reportPath}`);
    console.log(`   Pass: ${this._passCount}  Fail: ${this._failCount}  Skip: ${this._skipCount}`);
  }

  // ── Private: Build the summary sheet ───────────────────────────────────────
  _writeSummarySheet() {
    const total = this._passCount + this._failCount + this._skipCount;
    const passRate = total > 0 ? ((this._passCount / total) * 100).toFixed(1) : '0.0';

    // Title
    const titleRow = this.summarySheet.addRow([`${this.suiteName} – Test Execution Summary`]);
    titleRow.getCell(1).font = { bold: true, size: 16, color: { argb: 'FF6366F1' } };
    this.summarySheet.addRow([]);

    // Meta info
    this.summarySheet.addRow(['Generated At', new Date().toLocaleString()]);
    this.summarySheet.addRow(['Suite',        this.suiteName]);
    this.summarySheet.addRow(['Total Tests',  total]);
    this.summarySheet.addRow(['Pass',         this._passCount]);
    this.summarySheet.addRow(['Fail',         this._failCount]);
    this.summarySheet.addRow(['Skip',         this._skipCount]);
    this.summarySheet.addRow(['Pass Rate',    `${passRate}%`]);
    this.summarySheet.addRow([]);

    // Per-screen breakdown
    const screenMap = {};
    for (const r of this._rows) {
      if (!screenMap[r.screen]) screenMap[r.screen] = { pass: 0, fail: 0, skip: 0 };
      if (r.status === 'Pass') screenMap[r.screen].pass++;
      else if (r.status === 'Fail') screenMap[r.screen].fail++;
      else screenMap[r.screen].skip++;
    }

    const hdr = this.summarySheet.addRow(['Screen', 'Pass', 'Fail', 'Skip', 'Total', 'Pass Rate']);
    hdr.eachCell(c => {
      c.font = { bold: true, color: { argb: 'FFF8FAFC' } };
      c.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF1E293B' } };
    });

    for (const [screen, counts] of Object.entries(screenMap)) {
      const t = counts.pass + counts.fail + counts.skip;
      const pr = t > 0 ? ((counts.pass / t) * 100).toFixed(0) + '%' : '0%';
      this.summarySheet.addRow([screen, counts.pass, counts.fail, counts.skip, t, pr]);
    }

    this.summarySheet.columns = [
      { width: 30 }, { width: 10 }, { width: 10 }, { width: 10 }, { width: 10 }, { width: 12 }
    ];
  }

  // ── Private: Write to disk ──────────────────────────────────────────────────
  async _save() {
    await this.workbook.xlsx.writeFile(this.reportPath);
  }
}

module.exports = ExcelReporter;
