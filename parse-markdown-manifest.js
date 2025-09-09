#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

function parseMarkdownManifest(mdFile) {
  const content = fs.readFileSync(mdFile, 'utf-8');
  const items = [];
  
  // Split by section headers (##)
  const sections = content.split(/^## /m).slice(1); // Skip the first part before any ##
  
  sections.forEach(section => {
    const lines = section.split('\n');
    const filePath = lines[0].trim();
    
    // Find the code block content
    let fileContent = '';
    let inCodeBlock = false;
    let codeBlockLines = [];
    
    for (let i = 1; i < lines.length; i++) {
      const line = lines[i];
      
      if (line.startsWith('```') && !inCodeBlock) {
        inCodeBlock = true;
        continue;
      }
      
      if (line.startsWith('```') && inCodeBlock) {
        inCodeBlock = false;
        fileContent = codeBlockLines.join('\n');
        break;
      }
      
      if (inCodeBlock) {
        codeBlockLines.push(line);
      } else if (!line.startsWith('---') && line.trim() && !line.startsWith('```')) {
        // For non-code block content (like markdown files)
        if (!fileContent && !lines[i-1]?.startsWith('```')) {
          // Start collecting non-code block content
          let contentLines = [];
          for (let j = i; j < lines.length; j++) {
            if (lines[j].startsWith('---')) break;
            contentLines.push(lines[j]);
          }
          fileContent = contentLines.join('\n').trim();
          break;
        }
      }
    }
    
    if (filePath && fileContent) {
      items.push({
        path: filePath,
        content: fileContent
      });
    }
  });
  
  return items;
}

function main() {
  const manifestDir = process.argv[2];
  const outputFile = process.argv[3];
  
  if (!manifestDir || !outputFile) {
    console.error('Usage: parse-markdown-manifest.js <manifest-dir> <output-file>');
    process.exit(1);
  }
  
  let allItems = [];
  let fileCount = 0;
  
  // Read all .md files from manifest directory
  const files = fs.readdirSync(manifestDir)
    .filter(f => f.endsWith('.md'))
    .sort();
  
  for (const file of files) {
    const filePath = path.join(manifestDir, file);
    try {
      const items = parseMarkdownManifest(filePath);
      if (items.length > 0) {
        allItems = allItems.concat(items);
        fileCount++;
        console.log(`  • Loaded ${file} (${items.length} items)`);
      }
    } catch (e) {
      console.error(`Warning: Could not load ${file}: ${e.message}`);
    }
  }
  
  // Write merged manifest as JSON for compatibility with existing bootstrap process
  fs.writeFileSync(outputFile, JSON.stringify(allItems, null, 2), 'utf8');
  console.log(`Merged ${fileCount} manifest files → ${allItems.length} total items`);
}

main();