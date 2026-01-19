---
description: Comprehensive single-pass repository exploration with structured output
allowed-tools: Read, Glob, Grep, Bash, Write
---

# Explore Repository

Perform comprehensive exploration of a repository and generate a structured report.

## Instructions

1. **Take target path and objectives from user**
   - Repository/directory to explore
   - Specific focus areas (agents, commands, configs, etc.)
   - Output file path for report (optional)

2. **Single-pass exploration** (do NOT spawn multiple agents):
   - Map directory structure (tree or recursive ls)
   - Identify key files (README, config files, data files)
   - Read catalog/index files (CSV tables, TOC files, etc.)
   - Sample representative files from each category
   - Search for user's specific objectives

3. **Generate structured markdown report** with:
   - Executive summary
   - Directory structure overview
   - Resource catalog (organized by category)
   - Key findings relevant to objectives
   - Actionable recommendations

4. **Write report to specified output file** (if provided)

5. **Present summary to user** with path to full report

## Important

- Complete exploration in ONE pass, don't break into multiple agent sessions
- Read catalog files ONCE and extract all relevant information
- Prioritize breadth over depth - sample don't exhaustively read everything
- Save detailed findings to report file, show user executive summary only
- Use direct Read/Grep/Glob operations, NOT the Task tool with Explore agents
