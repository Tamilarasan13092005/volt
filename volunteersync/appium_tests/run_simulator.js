const testCases = require('./test_cases_list');
const { generateExcelReport } = require('./reporter');

const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

async function runSimulation() {
  console.log('================================================================');
  console.log('   VOLUNTEERSYNC APPIUM TEST RUNNER - SIMULATION MODE (100 TCs) ');
  console.log('================================================================\n');
  console.log('[SIMULATOR] Booting mock Appium server on 127.0.0.1:4723...');
  await sleep(500);
  console.log('[SIMULATOR] Launching Android Emulator "Pixel_6_API_33"...');
  await sleep(800);
  console.log('[SIMULATOR] Installing App package "com.volunteersync.app"...');
  await sleep(500);
  console.log('[SIMULATOR] Starting MainActivity...');
  await sleep(400);
  console.log('[SIMULATOR] Session established. Beginning test suite execution.\n');

  const results = [];
  
  // Check if failure simulation is enabled via arguments
  const simulateFailure = process.argv.includes('--fail');
  if (simulateFailure) {
    console.log('[SIMULATOR] Note: Failure simulation is enabled via --fail argument.\n');
  }

  for (const tc of testCases) {
    console.log(`[TC] Running [${tc.id}] ${tc.name}...`);
    
    // Fast mock sleep to process 100 test cases quickly in execution while reporting realistic durations
    await sleep(20);

    let status = 'PASS';
    let errorMsg = null;

    // Simulate a failure on TC-088 (Volt AI Report Response) if failure mode is active
    if (tc.id === 'TC-088' && simulateFailure) {
      status = 'FAIL';
      errorMsg = 'Error: Timeout waiting for element "Volt AI report markdown table" after 10000ms. Chat response was not loaded.';
    }

    const durationMs = Math.floor(Math.random() * 1200) + 400; // Simulated duration between 400ms and 1600ms
    const startTime = new Date();

    if (status === 'PASS') {
      console.log(`     ↳ \x1b[32m[PASS]\x1b[0m Completed in ${durationMs}ms`);
    } else {
      console.log(`     ↳ \x1b[31m[FAIL]\x1b[0m ${errorMsg}`);
    }

    results.push({
      id: tc.id,
      feature: tc.feature,
      name: tc.name,
      description: tc.description,
      status,
      startTime: startTime.toISOString(),
      endTime: new Date(startTime.getTime() + durationMs).toISOString(),
      durationMs,
      errorMsg
    });
  }

  console.log('\n[SIMULATOR] Testing completed. Closing session...');
  await sleep(300);
  console.log('[SIMULATOR] Session closed.');

  console.log('\n[SIMULATOR] Generating Excel Report for 100 Test Cases...');
  try {
    const reportPath = await generateExcelReport(results);
    console.log(`\n================================================================`);
    console.log(`SUCCESS: Simulation execution of 100 test cases completed.`);
    console.log(`Excel analysis report saved to:`);
    console.log(`   ${reportPath}`);
    console.log(`================================================================`);
  } catch (err) {
    console.error('[SIMULATOR ERROR] Failed to write report:', err);
  }
}

runSimulation();
