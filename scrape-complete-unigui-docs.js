const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

async function scrapeCompleteUniguiDocumentation() {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();

  const baseUrl = 'https://www.unigui.com/doc/online_help/';
  
  console.log('正在访问导航页面...');
  await page.goto(`${baseUrl}hmcontent.htm`, { waitUntil: 'domcontentloaded', timeout: 120000 });
  await page.waitForTimeout(3000);
  
  const navLinks = await page.evaluate(() => {
    const links = Array.from(document.querySelectorAll('a[href]'))
      .map(a => ({
        text: a.textContent.trim(),
        href: a.getAttribute('href')
      }))
      .filter(link => 
        link.href && 
        !link.href.startsWith('http') && 
        link.href.endsWith('.htm') &&
        link.text.length > 0
      );
    return links;
  });
  
  console.log(`找到 ${navLinks.length} 个文档链接`);
  
  const uniqueLinks = [];
  const seenHrefs = new Set();
  
  for (const link of navLinks) {
    if (!seenHrefs.has(link.href)) {
      seenHrefs.add(link.href);
      uniqueLinks.push(link);
    }
  }
  
  console.log(`去重后 ${uniqueLinks.length} 个唯一链接`);
  
  const allContent = {
    title: 'uniGUI Developer Manual',
    url: `${baseUrl}index.html`,
    sections: []
  };
  
  for (let i = 0; i < Math.min(uniqueLinks.length, 50); i++) {
    const link = uniqueLinks[i];
    const fullUrl = `${baseUrl}${link.href}`;
    
    console.log(`[${i + 1}/${Math.min(uniqueLinks.length, 50)}] 正在抓取: ${link.text}`);
    console.log(`URL: ${fullUrl}`);
    
    try {
      await page.goto(fullUrl, { waitUntil: 'domcontentloaded', timeout: 60000 });
      await page.waitForTimeout(2000);
      
      const sectionContent = await page.evaluate(() => {
        const result = {
          title: document.title,
          url: window.location.href,
          content: '',
          headings: [],
          codeBlocks: []
        };
        
        const bodyText = document.body.innerText;
        result.content = bodyText;
        
        const headings = Array.from(document.querySelectorAll('h1, h2, h3, h4, h5, h6')).map(h => ({
          tag: h.tagName,
          text: h.textContent.trim()
        }));
        result.headings = headings;
        
        const codeBlocks = Array.from(document.querySelectorAll('pre, code')).map(code => ({
          text: code.textContent.trim()
        }));
        result.codeBlocks = codeBlocks;
        
        return result;
      });
      
      sectionContent.navText = link.text;
      sectionContent.navHref = link.href;
      
      allContent.sections.push(sectionContent);
      
      console.log(`  - 标题: ${sectionContent.title}`);
      console.log(`  - 内容长度: ${sectionContent.content.length}`);
      console.log(`  - 标题数量: ${sectionContent.headings.length}`);
      
    } catch (error) {
      console.error(`  - 抓取失败: ${error.message}`);
    }
  }
  
  const markdownContent = convertCompleteToMarkdown(allContent);
  
  const outputPath = path.join(__dirname, 'unigui-developer-manual-complete.md');
  fs.writeFileSync(outputPath, markdownContent, 'utf-8');
  console.log(`\n已保存完整文档: ${outputPath}`);
  
  await browser.close();
}

function convertCompleteToMarkdown(content) {
  let markdown = `# ${content.title}\n\n`;
  markdown += `来源: ${content.url}\n\n`;
  markdown += `---\n\n`;
  
  markdown += `## 文档目录\n\n`;
  content.sections.forEach((section, index) => {
    markdown += `${index + 1}. [${section.navText}](#section-${index + 1})\n`;
  });
  markdown += `\n---\n\n`;
  
  content.sections.forEach((section, index) => {
    markdown += `## ${index + 1}. ${section.navText}\n\n`;
    markdown += `### ${section.title}\n\n`;
    markdown += `来源: ${section.url}\n\n`;
    
    if (section.headings && section.headings.length > 0) {
      markdown += `#### 小节标题\n\n`;
      section.headings.forEach(h => {
        const level = parseInt(h.tag.charAt(1));
        const indent = '  '.repeat(level);
        markdown += `${indent}- ${h.text}\n`;
      });
      markdown += `\n`;
    }
    
    markdown += `#### 内容\n\n`;
    markdown += section.content;
    markdown += `\n\n`;
    
    if (section.codeBlocks && section.codeBlocks.length > 0) {
      markdown += `#### 代码示例\n\n`;
      section.codeBlocks.forEach((code, codeIndex) => {
        markdown += `**代码 ${codeIndex + 1}:**\n\n`;
        markdown += '```\n';
        markdown += code.text;
        markdown += '\n```\n\n';
      });
    }
    
    markdown += `---\n\n`;
  });
  
  return markdown;
}

scrapeCompleteUniguiDocumentation().catch(console.error);