#!/usr/bin/env node

const path = require('path');
const fs = require('fs');

// Simple BMad CLI wrapper for v6-alpha
const bmadDir = path.join(__dirname, 'bmad');
const configPath = path.join(bmadDir, 'config.json');

if (!fs.existsSync(configPath)) {
  console.error('❌ BMad not properly installed. Please run the installer.');
  process.exit(1);
}

const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));

// Parse command line arguments
const args = process.argv.slice(2);
if (args.length === 0) {
  console.log(`
BMad v6-alpha CLI

Available commands:
  bmad analyst <workflow>     - Run analyst workflows
  bmad pm <workflow>          - Run project manager workflows  
  bmad architect <workflow>   - Run architect workflows
  bmad sm <workflow>          - Run scrum master workflows
  bmad dev <workflow>         - Run developer workflows

Workflows:
  workflow-status             - Check current workflow status (START HERE!)
  brainstorm-project          - Brainstorm project ideas
  plan-project               - Plan your project
  solution-architecture      - Create solution architecture
  create-story               - Create user story
  dev-story                  - Implement story

Example:
  bmad analyst workflow-status
`);
  process.exit(0);
}

const [agent, workflow, ...workflowArgs] = args;

if (!agent || !workflow) {
  console.error('❌ Usage: bmad <agent> <workflow>');
  console.error('Example: bmad analyst workflow-status');
  process.exit(1);
}

// Check if agent exists
const agentPath = path.join(bmadDir, 'bmm', 'agents', `${agent}.agent.yaml`);
if (!fs.existsSync(agentPath)) {
  console.error(`❌ Agent '${agent}' not found. Available agents: analyst, pm, architect, sm, dev`);
  process.exit(1);
}

// Check if workflow exists
const workflowPath = path.join(bmadDir, 'bmm', 'workflows');
const workflowFiles = fs.readdirSync(workflowPath, { recursive: true })
  .filter(file => file.endsWith('.yaml'))
  .map(file => file.replace('.yaml', ''));

const workflowExists = workflowFiles.some(file => file.includes(workflow));

if (!workflowExists) {
  console.error(`❌ Workflow '${workflow}' not found.`);
  console.error('Available workflows:', workflowFiles.slice(0, 10).join(', '), '...');
  process.exit(1);
}

console.log(`🤖 Running ${agent} agent with ${workflow} workflow...`);
console.log(`📁 Project: ${config.projectRoot}`);
console.log(`📋 Modules: ${config.installedModules.join(', ')}`);
console.log('');

// For now, just show the workflow file location
const workflowFile = workflowFiles.find(file => file.includes(workflow));
console.log(`📄 Workflow file: ${path.join(workflowPath, workflowFile + '.yaml')}`);
console.log('');
console.log('💡 This is a basic CLI wrapper. For full functionality, you can:');
console.log('1. Open the workflow file in Cursor');
console.log('2. Follow the instructions in the workflow');
console.log('3. Use Cursor\'s AI features to execute the workflow');
console.log('');
console.log('🚀 Ready to start your BMad workflow!');
