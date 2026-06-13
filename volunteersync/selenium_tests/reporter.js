const ExcelJS = require('exceljs');
const path = require('path');
const fs = require('fs');

/**
 * Generates a styled Excel report for Selenium E2E testing results.
 * @param {Array} results  Array of test result objects
 */
async function generateExcelReport(results) {
  const reportsDir = path.join(__dirname, 'reports');
  if (!fs.existsSync(reportsDir)) fs.mkdirSync(reportsDir, { recursive: true });

  const workbook = new ExcelJS.Workbook();
  workbook.creator = 'VolunteerSync Selenium Test Automation';
  workbook.created = new Date();

  const ws = workbook.addWorksheet('Selenium E2E Analysis');
  ws.views = [{ showGridLines: true }];

  // ── TITLE ROW ─────────────────────────────────────────────────────────────
  ws.mergeCells('A1:I1');
  const title = ws.getCell('A1');
  title.value = 'VolunteerSync Flutter Web — Selenium E2E Test Report';
  title.font = { name: 'Segoe UI', size: 16, bold: true, color: { argb: 'FFFFFFFF' } };
  title.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF0F766E' } }; // Teal-700
  title.alignment = { vertical: 'middle', horizontal: 'center' };
  ws.getRow(1).height = 42;

  // Sub-header — run info
  ws.mergeCells('A2:I2');
  const subTitle = ws.getCell('A2');
  subTitle.value = `  Browser: Chrome  |  Target: Flutter Web (localhost:8080)  |  Generated: ${new Date().toLocaleString()}`;
  subTitle.font = { name: 'Segoe UI', size: 9, italic: true, color: { argb: 'FF475569' } };
  subTitle.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFF0FDF4' } }; // Green-50
  subTitle.alignment = { vertical: 'middle', horizontal: 'left' };
  ws.getRow(2).height = 18;

  // ── SUMMARY SECTION ───────────────────────────────────────────────────────
  ws.mergeCells('A4:I4');
  const sumHeader = ws.getCell('A4');
  sumHeader.value = '  EXECUTION SUMMARY';
  sumHeader.font = { name: 'Segoe UI', size: 11, bold: true, color: { argb: 'FF134E4A' } };
  sumHeader.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFCCFBF1' } }; // Teal-100
  sumHeader.alignment = { vertical: 'middle', horizontal: 'left' };
  ws.getRow(4).height = 26;

  const total = results.length;
  const passed = results.filter(r => r.status === 'PASS').length;
  const failed = total - passed;
  const passRate = total > 0 ? passed / total : 0;
  const totalMs = results.reduce((s, r) => s + r.durationMs, 0);
  const totalSec = (totalMs / 1000).toFixed(2) + 's';

  ws.getRow(5).values = ['Total Tests', total, '', 'Passed', passed, '', 'Failed', failed, ''];
  ws.getRow(6).values = ['Pass Rate', passRate, '', 'Total Duration', totalSec, '', 'Run At', new Date().toLocaleString(), ''];

  const labelStyle = { name: 'Segoe UI', size: 10, bold: true, color: { argb: 'FF0F766E' } };
  const valueStyle = { name: 'Segoe UI', size: 10, color: { argb: 'FF0F172A' } };

  ['A5', 'D5', 'G5', 'A6', 'D6', 'G6'].forEach(ref => {
    ws.getCell(ref).font = labelStyle;
    ws.getCell(ref).alignment = { horizontal: 'right', vertical: 'middle' };
  });
  ['B5', 'E5', 'H5', 'B6', 'E6', 'H6'].forEach(ref => {
    ws.getCell(ref).font = valueStyle;
    ws.getCell(ref).alignment = { horizontal: 'left', vertical: 'middle' };
  });
  ws.getCell('B6').numFmt = '0.0%';

  for (let r = 4; r <= 6; r++) {
    for (let c = 1; c <= 9; c++) {
      ws.getCell(r, c).border = {
        top:    r === 4 ? { style: 'thin', color: { argb: 'FF99F6E4' } } : undefined,
        bottom: r === 6 ? { style: 'thin', color: { argb: 'FF99F6E4' } } : undefined,
        left:   c === 1 ? { style: 'thin', color: { argb: 'FF99F6E4' } } : undefined,
        right:  c === 9 ? { style: 'thin', color: { argb: 'FF99F6E4' } } : undefined,
      };
    }
  }
  ws.getRow(5).height = 20;
  ws.getRow(6).height = 20;

  // ── TABLE HEADER ──────────────────────────────────────────────────────────
  const headers = ['Test ID', 'Feature / Screen', 'Test Case Name', 'Description',
    'Status', 'Start Time', 'End Time', 'Duration (ms)', 'Details / Error Message'];
  const hdrRow = ws.getRow(8);
  hdrRow.values = headers;
  hdrRow.height = 30;

  hdrRow.eachCell(cell => {
    cell.font   = { name: 'Segoe UI', size: 10, bold: true, color: { argb: 'FFFFFFFF' } };
    cell.fill   = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF134E4A' } }; // Teal-900
    cell.alignment = { vertical: 'middle', horizontal: 'left' };
    cell.border = {
      top:    { style: 'thin',   color: { argb: 'FF000000' } },
      bottom: { style: 'medium', color: { argb: 'FF000000' } },
      left:   { style: 'thin',   color: { argb: 'FF0F766E' } },
      right:  { style: 'thin',   color: { argb: 'FF0F766E' } },
    };
  });
  ws.getCell('E8').alignment = { vertical: 'middle', horizontal: 'center' };
  ws.getCell('H8').alignment = { vertical: 'middle', horizontal: 'right' };

  // ── DATA ROWS ─────────────────────────────────────────────────────────────
  results.forEach((item, idx) => {
    const rowNum = 9 + idx;
    const row = ws.getRow(rowNum);
    row.height = 22;
    row.values = [
      item.id, item.feature, item.name, item.description,
      item.status, item.startTime, item.endTime,
      item.durationMs,
      item.errorMsg || 'No errors. Flow completed successfully.'
    ];

    for (let c = 1; c <= headers.length; c++) {
      const cell = row.getCell(c);
      cell.font = { name: 'Segoe UI', size: 9 };
      cell.border = {
        top:    { style: 'thin', color: { argb: 'FFE2E8F0' } },
        bottom: { style: 'thin', color: { argb: 'FFE2E8F0' } },
        left:   { style: 'thin', color: { argb: 'FFE2E8F0' } },
        right:  { style: 'thin', color: { argb: 'FFE2E8F0' } },
      };
      // Zebra stripe
      if (idx % 2 === 1) {
        cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFF0FDFA' } }; // Teal-50
      }
    }

    row.getCell(1).alignment = { horizontal: 'center', vertical: 'middle' };
    row.getCell(5).alignment = { horizontal: 'center', vertical: 'middle' };
    row.getCell(8).alignment = { horizontal: 'right',  vertical: 'middle' };

    // Status cell colour
    const statusCell = row.getCell(5);
    if (item.status === 'PASS') {
      statusCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFDCFCE7' } };
      statusCell.font = { name: 'Segoe UI', size: 9, bold: true, color: { argb: 'FF166534' } };
    } else {
      statusCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFFEE2E2' } };
      statusCell.font = { name: 'Segoe UI', size: 9, bold: true, color: { argb: 'FF991B1B' } };
    }
  });

  // Column widths
  ws.getColumn(1).width = 10;
  ws.getColumn(2).width = 22;
  ws.getColumn(3).width = 32;
  ws.getColumn(4).width = 50;
  ws.getColumn(5).width = 12;
  ws.getColumn(6).width = 26;
  ws.getColumn(7).width = 26;
  ws.getColumn(8).width = 16;
  ws.getColumn(9).width = 55;

  // ── WRITE FILE (with EBUSY fallback) ──────────────────────────────────────
  const primaryPath = path.join(reportsDir, 'selenium_report.xlsx');
  try {
    await workbook.xlsx.writeFile(primaryPath);
    console.log(`\nExcel report saved: ${primaryPath}`);
    return primaryPath;
  } catch (err) {
    if (err.code === 'EBUSY') {
      const ts = new Date().toISOString().slice(0, 19).replace(/[:T]/g, '_');
      const fallback = path.join(reportsDir, `selenium_report_${ts}.xlsx`);
      await workbook.xlsx.writeFile(fallback);
      console.log(`\n[WARNING] Primary file locked. Report saved to fallback: ${fallback}`);
      return fallback;
    }
    throw err;
  }
}

module.exports = { generateExcelReport };
