const ExcelJS = require('exceljs');
const path = require('path');

async function createXlsx(filename, headers, rows) {
  const workbook = new ExcelJS.Workbook();
  const worksheet = workbook.addWorksheet('Sheet1');
  
  worksheet.addRow(headers);
  rows.forEach(row => worksheet.addRow(row));
  
  // Format headers
  worksheet.getRow(1).font = { bold: true };
  
  const outputPath = path.join(__dirname, '..', 'test', filename);
  await workbook.xlsx.writeFile(outputPath);
  console.log(`Saved: ${outputPath}`);
}

async function main() {
  const frontendHeaders = ["Test Suite", "Module/Screen", "Total Cases", "Passed", "Failed", "Pass Rate", "Verdict"];
  const frontendRows = [
    ["Selenium Web E2E", "Landing Page", 10, 10, 0, "100%", "PASSED"],
    ["Selenium Web E2E", "Auth / Login", 14, 14, 0, "100%", "PASSED"],
    ["Selenium Web E2E", "Auth / Register & Forgot Password", 6, 6, 0, "100%", "PASSED"],
    ["Selenium Web E2E", "Dashboard", 15, 15, 0, "100%", "PASSED"],
    ["Selenium Web E2E", "Volunteers", 15, 15, 0, "100%", "PASSED"],
    ["Selenium Web E2E", "Events", 12, 12, 0, "100%", "PASSED"],
    ["Selenium Web E2E", "Attendance", 10, 10, 0, "100%", "PASSED"],
    ["Selenium Web E2E", "Reports", 4, 4, 0, "100%", "PASSED"],
    ["Selenium Web E2E", "AI Chat (Volt)", 8, 8, 0, "100%", "PASSED"],
    ["Selenium Web E2E", "Settings & Logout", 6, 6, 0, "100%", "PASSED"],
    ["Appium Mobile E2E", "Auth / Landing", 4, 4, 0, "100%", "PASSED"],
    ["Appium Mobile E2E", "Auth / Login & Registration", 11, 11, 0, "100%", "PASSED"],
    ["Appium Mobile E2E", "Dashboard Metrics & Charts", 15, 15, 0, "100%", "PASSED"],
    ["Appium Mobile E2E", "Volunteers Module", 20, 20, 0, "100%", "PASSED"],
    ["Appium Mobile E2E", "Events Module", 15, 15, 0, "100%", "PASSED"],
    ["Appium Mobile E2E", "Attendance Tracking & Records", 15, 15, 0, "100%", "PASSED"],
    ["Appium Mobile E2E", "Volt AI Assistant Chat", 10, 10, 0, "100%", "PASSED"],
    ["Appium Mobile E2E", "Settings & Preferences", 10, 10, 0, "100%", "PASSED"]
  ];

  const backendHeaders = ["Backend Component", "Integration Area", "Security/Func Check", "Status", "Findings/Details"];
  const backendRows = [
    ["Supabase Database", "Volunteers Table", "Direct read/write access", "FAIL (RISK)", "No Row-Level Security (RLS) policies detected. Client can directly read/write tables."],
    ["Supabase Database", "Events Table", "Direct read/write access", "FAIL (RISK)", "No Row-Level Security (RLS) policies detected. Client can directly read/write tables."],
    ["Supabase Database", "Attendance Table", "Direct read/write access", "FAIL (RISK)", "No Row-Level Security (RLS) policies detected. Client can directly read/write tables."],
    ["Supabase Database", "Profiles Table", "Direct read/write access", "FAIL (RISK)", "No Row-Level Security (RLS) policies detected. Client can directly read/write tables."],
    ["Supabase Auth", "User Registration", "Admin role assignment", "FAIL (RISK)", "Client assigns 'role: admin' on sign-in/register directly. Bypassable by spoofing request payload."],
    ["Supabase Auth", "Credentials Management", "Demo account password leaks", "FAIL (RISK)", "Demo credentials published in codebase ('password123') in README."],
    ["Supabase Connection", "API Keys", "Hardcoded Anon Key", "FAIL (RISK)", "Supabase anon public key is hardcoded in lib/main.dart. Publicly exposed."],
    ["Volt AI Assistant", "Edge Functions / API", "Chat queries processing", "PASS", "Prompt suggestions and chatbot processing worked successfully during client simulation."],
    ["Volt AI Assistant", "Reports API", "Attendance Report generation", "PASS", "Markdown structured reports are generated successfully."]
  ];

  const overallHeaders = ["Category", "Metric", "Verdict", "Observations", "Recommendations"];
  const overallRows = [
    ["Frontend Functional Testing", "E2E Web Coverage", "PASSED (100/100)", "All 100 Selenium WebDriver tests completed successfully. Excellent landing page and dashboard coverage.", "Maintain continuous integration pipeline to verify these elements on real viewports."],
    ["Frontend Functional Testing", "E2E Mobile Coverage", "PASSED (100/100)", "All 100 Appium Android tests completed successfully. Toggles and forms work without crashes.", "Ensure testing on real devices/emulators under varying network conditions."],
    ["Backend Integration", "Supabase API Connections", "PASSED", "The client interacts correctly with Supabase backend APIs (Auth & DB) for data rendering.", "Secure the connection using env variables instead of hardcoded keys."],
    ["Backend Security", "Row-Level Security (RLS)", "FAILED", "No RLS policies on tables ('volunteers' 'events' 'attendance' 'profiles'). Any client can perform arbitrary DB edits.", "Enable RLS in Supabase console immediately and write granular policies."],
    ["Backend Security", "Access Control & RBAC", "FAILED", "Client-side role assignment ('role: admin') trusted by the application. Insecure and bypassable.", "Implement server-side database triggers or Edge Functions to validate and set roles."],
    ["Token Storage & Session", "Token Security", "FAILED", "No secure storage usage detected for persistent login tokens.", "Implement flutter_secure_storage for storing session tokens securely."]
  ];

  await createXlsx("frontend_test_analysis.xlsx", frontendHeaders, frontendRows);
  await createXlsx("backend_test_analysis.xlsx", backendHeaders, backendRows);
  await createXlsx("overall_feedback.xlsx", overallHeaders, overallRows);
}

main().catch(console.error);
