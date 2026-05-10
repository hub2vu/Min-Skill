const fs = require("fs");
const path = require("path");
const { chromium } = require("playwright");

const repoRoot = path.resolve(__dirname, "..", "..", "..", "..");
const outDir = path.join(repoRoot, "output", "playwright", "pro-model-check");
const profileDir = path.join(process.env.USERPROFILE || process.env.HOME, ".oracle", "browser-profile");
const chromeCandidates = [
  "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
  "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe",
  "C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe",
  "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe",
];

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function writeJson(name, value) {
  fs.writeFileSync(path.join(outDir, name), JSON.stringify(value, null, 2), "utf8");
}

async function collectButtons(page) {
  return page.locator("button").evaluateAll((nodes) =>
    nodes.map((node, index) => {
      const rect = node.getBoundingClientRect();
      return {
        index,
        text: (node.innerText || node.textContent || "").replace(/\s+/g, " ").trim(),
        ariaLabel: node.getAttribute("aria-label") || "",
        title: node.getAttribute("title") || "",
        testId: node.getAttribute("data-testid") || "",
        visible: !!(rect.width && rect.height),
        rect: {
          x: Math.round(rect.x),
          y: Math.round(rect.y),
          width: Math.round(rect.width),
          height: Math.round(rect.height),
        },
      };
    })
  );
}

function pickComposerModelButton(buttons) {
  return buttons
    .filter((button) => button.visible)
    .filter((button) => button.rect.x > 900)
    .filter((button) => button.rect.y > 250 && button.rect.y < 800)
    .filter((button) => button.rect.width > 40 && button.rect.width < 180)
    .filter((button) => button.rect.height > 20 && button.rect.height < 70)
    .find((button) => (button.text || "").trim().length > 0);
}

async function main() {
  ensureDir(outDir);
  const executablePath = chromeCandidates.find((candidate) => fs.existsSync(candidate));
  if (!executablePath) {
    throw new Error(`No Chrome/Edge executable found. Checked: ${chromeCandidates.join(", ")}`);
  }

  const context = await chromium.launchPersistentContext(profileDir, {
    headless: false,
    executablePath,
    viewport: { width: 1500, height: 1000 },
    args: [
      "--disable-blink-features=AutomationControlled",
      "--no-first-run",
      "--no-default-browser-check",
    ],
  });

  const page = context.pages()[0] || await context.newPage();
  const result = {
    profileDir,
    startedAt: new Date().toISOString(),
    selected: false,
    beforeButton: null,
    afterButton: null,
  };

  try {
    await page.goto("https://chatgpt.com/", { waitUntil: "domcontentloaded", timeout: 90000 });
    await page.waitForLoadState("networkidle", { timeout: 30000 }).catch(() => {});
    await page.waitForTimeout(8000);
    await page.keyboard.press("Escape").catch(() => {});

    const beforeButtons = await collectButtons(page);
    const modelButton = pickComposerModelButton(beforeButtons);
    result.beforeButton = modelButton || null;
    if (!modelButton) {
      throw new Error("Could not find ChatGPT composer model/mode button.");
    }

    if (modelButton.text !== "Pro") {
      await page.locator("button").nth(modelButton.index).click({ timeout: 10000 });
      await page.waitForTimeout(1500);
      const proOption = page.locator('[data-testid="model-switcher-gpt-5-5-pro"]');
      const count = await proOption.count();
      result.proOptionCount = count;
      if (!count) {
        await page.screenshot({ path: path.join(outDir, "ensure_pro_missing_option.png"), fullPage: true });
        throw new Error("ChatGPT Pro option was not found in the model/mode menu.");
      }
      await proOption.first().click({ timeout: 10000 });
      await page.waitForTimeout(4000);
    }

    const afterButtons = await collectButtons(page);
    result.afterButton = pickComposerModelButton(afterButtons) || null;
    result.selected = !!result.afterButton && result.afterButton.text === "Pro";
    await page.screenshot({ path: path.join(outDir, "ensure_pro_after.png"), fullPage: true });
    writeJson("ensure_pro_result.json", result);

    if (!result.selected) {
      throw new Error(`Pro was not selected. Current button: ${JSON.stringify(result.afterButton)}`);
    }

    console.log(JSON.stringify(result, null, 2));
  } finally {
    await context.close();
  }
}

main().catch((err) => {
  ensureDir(outDir);
  fs.writeFileSync(path.join(outDir, "ensure_pro_error.txt"), `${err.stack || err.message}\n`, "utf8");
  console.error(err.stack || err.message);
  process.exit(1);
});
