const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

async function scrapeUniguiDocumentation() {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();

  const docs = [
    {
      name: 'developer-manual',
      mainUrl: 'https://www.unigui.com/doc/online_help/index.html',
      contentUrl: 'https://www.unigui.com/doc/online_help/introduction.htm'
    },
    {
      name: 'component-reference-manual',
      mainUrl: 'https://www.unigui.com/doc/online_help/index.html',
      contentUrl: 'https://www.unigui.com/doc/online_help/introduction.htm'
    }
  ];

  for (const doc of docs) {
    console.log(`正在抓取: ${doc.name}`);
    console.log(`主URL: ${doc.mainUrl}`);
    console.log(`内容URL: ${doc.contentUrl}`);
    
    try {
      await page.goto(doc.contentUrl, { waitUntil: 'domcontentloaded', timeout: 120000 });
      
      await page.waitForTimeout(3000);
      
      const pageContent = await page.content();
      console.log(`页面标题: ${await page.title()}`);
      console.log(`页面URL: ${page.url()}`);
      console.log(`页面内容长度: ${pageContent.length}`);
      
      const htmlPath = path.join(__dirname, `${doc.name}-full.html`);
      fs.writeFileSync(htmlPath, pageContent, 'utf-8');
      console.log(`已保存完整HTML: ${htmlPath}`);
      
      const content = await page.evaluate(() => {
        const result = {
          title: document.title,
          url: window.location.href,
          content: '',
          allText: document.body.innerText
        };
        
        const selectors = [
          'main', 'article', '.content', '#content', 
          '.documentation', '.docs', '.wiki', '.manual',
          '.wiki-content', '.page-content', '.doc-content',
          '.markdown-body', '.prose', '.article-content',
          '[class*="content"]', '[id*="content"]',
          '.body-content', '.main-content', '.text-content',
          '.topic-content', '.help-content', '.manual-content'
        ];
        
        let mainContent = null;
        for (const selector of selectors) {
          const element = document.querySelector(selector);
          if (element && element.innerText.length > 100) {
            mainContent = element;
            console.log(`找到主要内容区域: ${selector}, 长度: ${element.innerText.length}`);
            break;
          }
        }
        
        if (mainContent) {
          result.content = mainContent.innerText;
        } else {
          result.content = document.body.innerText;
          console.log('使用body内容');
        }
        
        const headings = Array.from(document.querySelectorAll('h1, h2, h3, h4, h5, h6')).map(h => ({
          tag: h.tagName,
          text: h.textContent.trim(),
          id: h.id || ''
        }));
        
        result.headings = headings;
        
        const codeBlocks = Array.from(document.querySelectorAll('pre, code, .code-block, .code, .highlight, .syntaxhighlighter')).map(code => ({
          text: code.textContent.trim(),
          className: code.className
        }));
        
        result.codeBlocks = codeBlocks;
        
        const links = Array.from(document.querySelectorAll('a[href]')).map(a => ({
          text: a.textContent.trim(),
          href: a.href
        }));
        
        result.links = links.slice(0, 100);
        
        return result;
      });
      
      console.log(`提取到 ${content.headings.length} 个标题`);
      console.log(`提取到 ${content.codeBlocks.length} 个代码块`);
      console.log(`内容长度: ${content.content.length}`);
      
      const markdownContent = convertToMarkdown(content);
      
      const outputPath = path.join(__dirname, `${doc.name}.md`);
      fs.writeFileSync(outputPath, markdownContent, 'utf-8');
      console.log(`已保存: ${outputPath}`);
      
    } catch (error) {
      console.error(`抓取 ${doc.name} 时出错:`, error.message);
      console.error(`错误堆栈:`, error.stack);
      
      try {
        const errorPath = path.join(__dirname, `${doc.name}-error.html`);
        const errorContent = await page.content();
        fs.writeFileSync(errorPath, errorContent, 'utf-8');
        console.log(`已保存错误页面: ${errorPath}`);
      } catch (saveError) {
        console.error(`保存错误页面失败:`, saveError.message);
      }
    }
  }

  await browser.close();
}

function convertToMarkdown(content) {
  let markdown = `# ${content.title}\n\n`;
  markdown += `来源: ${content.url}\n\n`;
  markdown += `---\n\n`;
  
  if (content.headings && content.headings.length > 0) {
    markdown += `## 目录结构\n\n`;
    content.headings.forEach(h => {
      const level = parseInt(h.tag.charAt(1));
      const indent = '  '.repeat(level - 1);
      markdown += `${indent}- ${h.text}\n`;
    });
    markdown += `\n---\n\n`;
  }
  
  if (content.links && content.links.length > 0) {
    markdown += `## 相关链接\n\n`;
    content.links.forEach(link => {
      markdown += `- [${link.text}](${link.href})\n`;
    });
    markdown += `\n---\n\n`;
  }
  
  markdown += `## 文档内容\n\n`;
  markdown += content.content;
  
  if (content.codeBlocks && content.codeBlocks.length > 0) {
    markdown += `\n\n## 代码示例\n\n`;
    content.codeBlocks.forEach((code, index) => {
      markdown += `### 代码示例 ${index + 1}\n\n`;
      markdown += '```\n';
      markdown += code.text;
      markdown += '\n```\n\n';
    });
  }
  
  return markdown;
}

scrapeUniguiDocumentation().catch(console.error);