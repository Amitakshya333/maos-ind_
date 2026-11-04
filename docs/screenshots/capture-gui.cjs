const path = require('node:path');
const ROOT = 'C:/sub-patched';
const { _electron: electron } = require(path.join(ROOT, 'desktop/node_modules/playwright'));
const OUT = 'C:/sub-capture/out';
const step = process.argv[2] || 'explore';

(async () => {
  const app = await electron.launch({
    executablePath: require(path.join(ROOT, 'desktop/node_modules/electron')),
    args: [path.join(ROOT, 'desktop/main.cjs'), '--project-root', 'C:/sub-capture/demo'],
    timeout: 90_000,
    env: Object.fromEntries(Object.entries(process.env).filter(([k]) => k !== 'ELECTRON_RUN_AS_NODE' && k !== 'BASETEN_API_KEY')),
  });
  const page = await app.firstWindow();
  await app.evaluate(({ BrowserWindow }) => { const w = BrowserWindow.getAllWindows()[0]; w.setSize(1500, 1900); });
  page.setDefaultTimeout(60_000);
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  try {
    await page.locator('main[role="main"]').waitFor();
    const skip = page.getByRole('button', { name: /Skip/ });
    if (await skip.isVisible().catch(() => false)) await skip.click();
    await page.evaluate(() => { location.hash = '#/chat'; });
    await page.getByTestId('ring-instruction-input').waitFor();
    await page.waitForTimeout(1500);
    const shot = async (name) => { await page.getByTestId('ring-transcript').evaluate((el) => { el.scrollTop = el.scrollHeight; }); await page.waitForTimeout(400); const box = await page.getByTestId('ring-transcript').boundingBox(); console.log('BOX', name, JSON.stringify(box)); await page.getByTestId('ring-workspace').screenshot({ path: `${OUT}/${name}.png` }); console.log('SHOT', name); };
    const ask = async (text) => {
      await page.getByTestId('ring-instruction-input').fill(text);
      await page.getByTestId('ring-send-button').click();
    };
    const newThread = async () => {
      const b = page.getByTestId('ring-new-thread-button');
      if (await b.isVisible().catch(() => false)) { await b.click(); await page.waitForTimeout(800); }
    };
    if (step === 'explore') {
      await shot('00-ring-empty');
      const ids = await page.$$eval('[data-testid]', (els) => [...new Set(els.map((e) => e.dataset.testid))]);
      console.log('TESTIDS', ids.join(','));
    }
    if (step === 'all') {
      await shot('00-ring-empty');
      await ask('Check T-07 vibration and tell me if it is safe to keep running');
      await page.getByTestId('ring-final-answer').waitFor();
      await page.waitForTimeout(1500);
      await shot('01-ring-turbine');

      await newThread();
      await ask('/handover shift handover note for next crew');
      await page.getByTestId('ring-approval-card').waitFor();
      await page.waitForTimeout(1000);
      await shot('02-ring-approval');
      await page.getByTestId('ring-approval-allow').click();
      await page.getByTestId('ring-artifact-card').first().waitFor();
      await page.waitForTimeout(1500);
      await shot('03-ring-artifact');

      await newThread();
      await ask('Approve the restart of turbine T-07');
      await page.getByTestId('ring-final-answer').waitFor();
      await page.waitForTimeout(1500);
      await shot('04-ring-refusal');
    }
    console.log('ERRORS', JSON.stringify(errors));
  } catch (e) {
    console.log('FAIL', e.message);
    await page.screenshot({ path: `${OUT}/zz-fail-${step}.png` }).catch(() => {});
    console.log('ERRORS', JSON.stringify(errors));
  } finally {
    await app.close().catch(() => {});
  }
})();
