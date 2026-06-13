const ExcelJS = require('exceljs');
const path = require('path');
const fs = require('fs');

/**
 * Generates a styled Excel report for E2E testing results.
 * @param {Array} results Array of test result objects:
 *  { id, feature, name, description, status, startTime, endTime, durationMs, errorMsg }
 */
async function generateExcelReport(results) {
  const reportsDir = path.join(__dirname, 'reports');
  if (!fs.existsSync(reportsDir)) {
    fs.mkdirSync(reportsDir, { recursive: true });
  }

  const workbook = new ExcelJS.Workbook();
  workbook.creator = 'VolunteerSync Appium Test Automation';
  workbook.created = new Date();

  const worksheet = workbook.addWorksheet('E2E Test Analysis');

  // Page setup
  worksheet.views = [{ showGridLines: true }];

  // ── 1. TITLE BLOCK ────────────────────────────────────────────────────────
  worksheet.mergeCells('A1:I1');
  const titleCell = worksheet.getCell('A1');
  titleCell.value = 'VolunteerSync Android E2E Appium Test Report';
  titleCell.font = { name: 'Segoe UI', size: 16, bold: true, color: { argb: 'FFFFFFFF' } };
  titleCell.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FF4F46E5' } // Indigo-600
  };
  titleCell.alignment = { vertical: 'middle', horizontal: 'center' };
  worksheet.getRow(1).height = 40;

  // ── 2. SUMMARY CARD HEADER ────────────────────────────────────────────────
  worksheet.mergeCells('A3:I3');
  const summaryTitleCell = worksheet.getCell('A3');
  summaryTitleCell.value = ' EXECUTION SUMMARY';
  summaryTitleCell.font = { name: 'Segoe UI', size: 11, bold: true, color: { argb: 'FF1E293B' } };
  summaryTitleCell.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FFF1F5F9' } // Slate-100
  };
  summaryTitleCell.alignment = { vertical: 'middle', horizontal: 'left' };
  worksheet.getRow(3).height = 24;

  // ── 3. SUMMARY CARDS METRICS ──────────────────────────────────────────────
  const total = results.length;
  const passed = results.filter(r => r.status === 'PASS').length;
  const failed = total - passed;
  const passRate = total > 0 ? (passed / total) : 0;
  const totalDurationMs = results.reduce((acc, curr) => acc + curr.durationMs, 0);
  const totalDurationSec = (totalDurationMs / 1000).toFixed(2) + 's';

  worksheet.getRow(4).values = ['Total Tests', total, '', 'Passed', passed, '', 'Failed', failed, ''];
  worksheet.getRow(5).values = ['Pass Rate', passRate, '', 'Total Duration', totalDurationSec, '', 'Execution Time', new Date().toLocaleString(), ''];

  const summaryLabelStyle = { name: 'Segoe UI', size: 10, bold: true, color: { argb: 'FF475569' } };
  const summaryValStyle = { name: 'Segoe UI', size: 10, bold: false, color: { argb: 'FF0F172A' } };

  ['A4', 'D4', 'G4', 'A5', 'D5', 'G5'].forEach(cellRef => {
    const c = worksheet.getCell(cellRef);
    c.font = summaryLabelStyle;
    c.alignment = { horizontal: 'right', vertical: 'middle' };
  });

  ['B4', 'E4', 'H4', 'B5', 'E5', 'H5'].forEach(cellRef => {
    const c = worksheet.getCell(cellRef);
    c.font = summaryValStyle;
    c.alignment = { horizontal: 'left', vertical: 'middle' };
    if (cellRef === 'B5') {
      c.numFmt = '0.0%';
    }
  });

  worksheet.getRow(4).height = 20;
  worksheet.getRow(5).height = 20;

  // Outer border for Summary block
  for (let r = 3; r <= 5; r++) {
    for (let c = 1; c <= 9; c++) {
      const cell = worksheet.getCell(r, c);
      cell.border = {
        top: r === 3 ? { style: 'thin', color: { argb: 'FFCBD5E1' } } : undefined,
        bottom: r === 5 ? { style: 'thin', color: { argb: 'FFCBD5E1' } } : undefined,
        left: c === 1 ? { style: 'thin', color: { argb: 'FFCBD5E1' } } : undefined,
        right: c === 9 ? { style: 'thin', color: { argb: 'FFCBD5E1' } } : undefined,
      };
    }
  }

  // ── 4. TEST CASES TABLE HEADER ────────────────────────────────────────────
  const headers = ['Test ID', 'Screen/Feature', 'Test Case Name', 'Description', 'Status', 'Start Time', 'End Time', 'Duration (ms)', 'Details / Error Message'];
  const headerRowNumber = 7;
  const headerRow = worksheet.getRow(headerRowNumber);
  headerRow.values = headers;
  headerRow.height = 28;

  headerRow.eachCell((cell) => {
    cell.font = { name: 'Segoe UI', size: 10, bold: true, color: { argb: 'FFFFFFFF' } };
    cell.fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FF1E293B' } // Slate-800
    };
    cell.alignment = { vertical: 'middle', horizontal: 'left' };
    cell.border = {
      top: { style: 'thin', color: { argb: 'FF000000' } },
      bottom: { style: 'medium', color: { argb: 'FF000000' } },
      left: { style: 'thin', color: { argb: 'FF475569' } },
      right: { style: 'thin', color: { argb: 'FF475569' } }
    };
  });
  worksheet.getCell('E7').alignment = { vertical: 'middle', horizontal: 'center' };
  worksheet.getCell('H7').alignment = { vertical: 'middle', horizontal: 'right' };

  // ── 5. POPULATE DATA ROWS ─────────────────────────────────────────────────
  results.forEach((item, index) => {
    const rowNumber = headerRowNumber + 1 + index;
    const row = worksheet.getRow(rowNumber);
    row.height = 22;

    row.values = [
      item.id,
      item.feature,
      item.name,
      item.description,
      item.status,
      item.startTime,
      item.endTime,
      item.durationMs,
      item.errorMsg || 'No errors. Flow completed successfully.'
    ];

    // Style the data row cells
    for (let col = 1; col <= headers.length; col++) {
      const cell = row.getCell(col);
      cell.font = { name: 'Segoe UI', size: 9 };
      cell.border = {
        top: { style: 'thin', color: { argb: 'FFE2E8F0' } },
        bottom: { style: 'thin', color: { argb: 'FFE2E8F0' } },
        left: { style: 'thin', color: { argb: 'FFE2E8F0' } },
        right: { style: 'thin', color: { argb: 'FFE2E8F0' } }
      };
      
      // Zebra striping
      if (index % 2 === 1) {
        cell.fill = {
          type: 'pattern',
          pattern: 'solid',
          fgColor: { argb: 'FFF8FAFC' } // Slate-50 for alternate rows
        };
      }
    }

    row.getCell(1).alignment = { horizontal: 'center', vertical: 'middle' }; // ID
    row.getCell(5).alignment = { horizontal: 'center', vertical: 'middle' }; // Status
    row.getCell(8).alignment = { horizontal: 'right', vertical: 'middle' };  // Duration

    // Special status styling
    const statusCell = row.getCell(5);
    if (item.status === 'PASS') {
      statusCell.fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: 'FFDCFCE7' } // Green-100
      };
      statusCell.font = { name: 'Segoe UI', size: 9, bold: true, color: { argb: 'FF166534' } }; // Green-800
    } else {
      statusCell.fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: 'FFFEE2E2' } // Red-100
      };
      statusCell.font = { name: 'Segoe UI', size: 9, bold: true, color: { argb: 'FF991B1B' } }; // Red-800
    }
  });

  // Set explicit column widths for layout perfection
  worksheet.getColumn(1).width = 10;  // Test ID
  worksheet.getColumn(2).width = 20;  // Screen/Feature
  worksheet.getColumn(3).width = 28;  // Test Case Name
  worksheet.getColumn(4).width = 45;  // Description
  worksheet.getColumn(5).width = 12;  // Status
  worksheet.getColumn(6).width = 24;  // Start Time
  worksheet.getColumn(7).width = 24;  // End Time
  worksheet.getColumn(8).width = 16;  // Duration (ms)
  worksheet.getColumn(9).width = 50;  // Details/Error

  const reportPath = path.join(reportsDir, 'test_report.xlsx');
  try {
    await workbook.xlsx.writeFile(reportPath);
    console.log(`Excel report successfully generated: ${reportPath}`);
    return reportPath;
  } catch (error) {
    if (error.code === 'EBUSY') {
      console.warn(`[WARNING] Primary report file is locked/busy: ${reportPath}`);
      const timestamp = new Date().toISOString().slice(0, 19).replace(/[:T]/g, '_');
      const fallbackPath = path.join(reportsDir, `test_report_${timestamp}.xlsx`);
      await workbook.xlsx.writeFile(fallbackPath);
      console.log(`Excel report successfully generated at fallback path: ${fallbackPath}`);
      return fallbackPath;
    }
    throw error;
  }
}

module.exports = { generateExcelReport };
