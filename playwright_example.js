const { chromium } = require('playwright');

(async () => {
  // 启动浏览器
  const browser = await chromium.launch({
    headless: false, // 显示浏览器窗口
    slowMo: 1000 // 每个操作延迟 1000ms，方便观察
  });

  // 创建新页面
  const page = await browser.newPage();

  // 访问百度首页
  console.log('正在访问百度首页...');
  await page.goto('https://www.baidu.com');

  // 等待页面加载
  await page.waitForLoadState('networkidle');

  // 截图
  console.log('正在截图...');
  await page.screenshot({
    path: 'baidu_homepage.png',
    fullPage: false // 只截取视口
  });

  // 在搜索框输入内容
  console.log('正在输入搜索内容...');
  const searchInput = await page.locator('#kw');
  await searchInput.fill('Playwright 自动化测试');

  // 点击搜索按钮
  console.log('正在点击搜索按钮...');
  const searchButton = await page.locator('#su');
  await searchButton.click();

  // 等待搜索结果加载
  await page.waitForLoadState('networkidle');

  // 截取搜索结果
  console.log('正在截取搜索结果...');
  await page.screenshot({
    path: 'baidu_search_results.png',
    fullPage: false
  });

  // 获取搜索结果标题
  console.log('正在获取搜索结果标题...');
  const titles = await page.locator('div.result h3 a').allTextContents();
  console.log('搜索结果标题：');
  titles.slice(0, 5).forEach((title, index) => {
    console.log(`${index + 1}. ${title}`);
  });

  // 关闭浏览器
  console.log('正在关闭浏览器...');
  await browser.close();

  console.log('示例执行完成！');
})();
