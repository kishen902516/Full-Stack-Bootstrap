# Mcp Manifest

This manifest contains the file structure and content for the mcp components.

## mcp/config.json

```json
{
  "version": 1,
  "deny": ["bash", "sh", "powershell", "curl", "wget"],
  "mcpServers": {
    "github": { "command": "npx", "args": ["mcp-github"], "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }, "transport": "stdio" },
    "atlassian": { "command": "npx", "args": ["mcp-atlassian"], "env": { "ATLASSIAN_HOST": "${ATLASSIAN_HOST}", "ATLASSIAN_EMAIL": "${ATLASSIAN_EMAIL}", "ATLASSIAN_API_TOKEN": "${ATLASSIAN_API_TOKEN}" }, "transport": "stdio" },
    "playwright": { "command": "node", "args": [".claude/tools/mcp/playwright-server.js"], "transport": "stdio" },
    "context7": { "command": "node", "args": [".claude/tools/mcp/context7-server.js"], "env": { "CTX7_STORE": "${CTX7_STORE:./.context7}" }, "transport": "stdio" }
  },
  "tools": [
    { "id": "arch_check",          "cmd": "bash -lc 'cd app-frontend && npm run arch:check && cd - >/dev/null && dotnet test ./app-api/tests/ArchitectureTests'" },
    { "id": "api_contract_verify", "cmd": "bash -lc 'cd app-frontend && npm run api:lint && npm run api:diff'" },
    { "id": "test_pyramid",        "cmd": "node .chubb/tools/metrics/check-pyramid.js" },
    { "id": "security_scan",       "cmd": "gitleaks detect --no-git --redact --config .chubb/tools/security/gitleaks.toml && semgrep --config .chubb/tools/security/semgrep.yml" },
    { "id": "git_feature",         "cmd": "bash .chubb/tools/git/flow.sh feature ${args}" },
    { "id": "git_release",         "cmd": "bash .chubb/tools/git/flow.sh release ${args}" },
    { "id": "plan_create",         "cmd": "node .claude/tools/mcp/plan-create.js ${args}" },
    { "id": "plan_check",          "cmd": "node .claude/tools/mcp/plan-check.js ${args}" }
  ]
}

```

---

## tools/mcp/playwright-server.js

```javascript
#!/usr/bin/env node
const { spawn } = require('child_process');
function run(cmd,args,cwd){return new Promise((res,rej)=>{const p=spawn(cmd,args,{cwd,stdio:['ignore','pipe','pipe']});let out='',err='';p.stdout.on('data',d=>out+=d.toString());p.stderr.on('data',d=>err+=d.toString());p.on('close',c=>c===0?res(out.trim()):rej(new Error(err||out)));});}
process.stdin.on('data', async (chunk)=>{const lines=chunk.toString().split('
').filter(Boolean);for(const line of lines){let req;try{req=JSON.parse(line);}catch{continue;}try{let resStr='';if(req.tool==='run_e2e') resStr=await run('npm',['run','e2e','--silent'],'app-frontend');
else if(req.tool==='show_report') resStr='app-frontend/playwright-report/index.html';
else if(req.tool==='show_trace') resStr=await run('npx',['playwright','show-trace', req.args?.[0] || 'trace.zip'],'app-frontend');
else throw new Error('unknown tool');
process.stdout.write(JSON.stringify({id:req.id, ok:true, stdout:resStr})+'
');}catch(e){process.stdout.write(JSON.stringify({id:req.id, ok:false, error:e.message})+'
');}}});

```

---

## tools/mcp/context7-index.js

```javascript
#!/usr/bin/env node
const fs=require('fs'), globby=require('globby');(async()=>{const cfg=fs.readFileSync('.claude/context7/sources.yaml','utf8');const include=[...cfg.matchAll(/- "([^"]+)"/g)].map(m=>m[1]);const files=await globby(include,{gitignore:true});fs.mkdirSync('.context7',{recursive:true});fs.writeFileSync('.context7/manifest.json',JSON.stringify({files},null,2));console.log(`Indexed ${files.length} files for Context7`);})();

```

---

## tools/mcp/context7-server.js

```javascript
#!/usr/bin/env node
const fs=require('fs'), { spawnSync }=require('child_process'), globby=require('globby');
async function refresh(){ spawnSync('node',['.claude/tools/mcp/context7-index.js'],{stdio:'inherit'}); return 'OK'; }
async function search(glob){ const files=await globby(glob,{gitignore:true}); return files.slice(0,50); }
function read(p,start=0,end=2000){ return fs.readFileSync(p,'utf8').slice(Number(start),Number(end)); }
process.stdin.on('data', async (chunk)=>{ const lines=chunk.toString().split('
').filter(Boolean); for(const line of lines){ let req; try{ req=JSON.parse(line);}catch{continue;} try{ let out; if(req.tool==='ctx7.refresh') out=await refresh(); else if(req.tool==='ctx7.search') out=await search(req.args?.[0]||'docs/**/*.md'); else if(req.tool==='ctx7.read') out=read(req.args?.[0],req.args?.[1],req.args?.[2]); else throw new Error('unknown tool'); process.stdout.write(JSON.stringify({id:req.id, ok:true, stdout:out})+'
'); } catch(e){ process.stdout.write(JSON.stringify({id:req.id, ok:false, error:e.message})+'
'); } }});

```

---

## tools/mcp/plan-create.js

```javascript
#!/usr/bin/env node
const fs=require('fs'),path=require('path');const args=process.argv.slice(2).join(' ').trim()||'Change Plan';const id=new Date().toISOString().replace(/[:.]/g,'').slice(0,15);const file=path.join('plans',`${id}.md`);fs.mkdirSync('plans',{recursive:true});fs.writeFileSync(file,`# ${args}

## Steps
1. 
2. 
3. 

## Affected Areas
- 

## Tests
- Unit: 
- Contract: 
- E2E: 
`);console.log(id);

```

---

## tools/mcp/plan-check.js

```javascript
#!/usr/bin/env node
const fs=require('fs');const id=process.argv[2];if(!id||!fs.existsSync(`.chubb/plans/${id}.md`)){ console.error('Missing or invalid plan. Create one with /plan create "<title>".'); process.exit(1);} console.log('Plan OK');

```

---

## context7/sources.yaml

```yaml
include:
  - "api/**/*.yaml"
  - "standards/**/*.md"
  - "docs/**/*.md"
  - "app-api/**/*.cs"
  - "app-frontend/src/**/*.ts"
exclude:
  - "**/node_modules/**"
  - "**/bin/**"
  - "**/obj/**"

```

---

## context7/.gitkeep



