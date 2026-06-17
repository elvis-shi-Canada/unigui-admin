const { chromium } = require('playwright');

(async () => {
  console.log('=== Playwright 简单示例 ===\n');

  // 启动浏览器（无头模式）
  const browser = await chromium.launch({
    headless: true,
    args: ['--no-sandbox']
  });

  // 创建新页面
  const page = await browser.newPage();

  // 设置视口大小
  await page.setViewportSize({ width: 1280, height: 720 });

  // 示例 1: 访问网页并获取标题
  console.log('示例 1: 访问网页并获取标题');
  console.log('正在访问 example.com...');
  await page.goto('https://example.com');
  
  const title = await page.title();
  console.log('页面标题:', title);
  console.log('页面 URL:', page.url());
  console.log();

  // 示例 2: 截图
  console.log('示例 2: 截取页面');
  await page.screenshot({
    path: 'example_com_screenshot.png',
    fullPage: true
  });
  console.log('截图已保存到: example_com_screenshot.png\n');

  // 示例 3: 获取页面内容
  console.log('示例 3: 获取页面内容');
  const content = await page.content();
  console.log('页面 HTML 长度:', content.length, '字符');
  console.log('页面文本内容前 100 字符:', await page.locator('body').innerText().then(text => text.substring(0, 100)));
  console.log();

  // 示例 4: 使用选择器定位元素
  console.log('示例 4: 使用选择器定位元素');
  const h1Text = await page.locator('h1').textContent();
  console.log('H1 标签内容:', h1Text);
  console.log();

  // 示例 5: 评估 JavaScript
  console.log('示例 5: 在页面中执行 JavaScript');
  const jsResult = await page.evaluate(() => {
    return {
      location: window.location.href,
      documentReady: document.readyState,
      title: document.title
    };
  });
  console.log('JavaScript 执行结果:', JSON.stringify(jsResult, null, 2));
  console.log();

  // 关闭浏览器
  console.log('正在关闭浏览器...');
  await browser.close();

  console.log('✓ 所有示例执行完成！');
})();
