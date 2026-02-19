# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A standalone PowerShell script (`FileRename.ps1`) that batch-renames files to comply with filesystem length limits. Two checks are applied in order:

1. **ファイル名 255バイト制限** (Linux NAS用): UTF-8バイト数ベース
2. **フルパス 260文字制限** (Windows MAX_PATH用): 文字数ベース

## Running

```powershell
.\FileRename.ps1
```

Configuration is at the top of the script: `$targetDir`, `$maxBytes` (255), `$maxPathChars` (260).

## Key Implementation Details

- Measures filename length in **UTF-8 bytes** using `[System.Text.Encoding]::UTF8.GetByteCount()`
- Measures full path length in **characters** (UTF-16 code units) for Windows MAX_PATH
- Truncates the stem one character at a time from the right, preserving the extension
- Handles **UTF-16 surrogate pairs**: if the last character is a low surrogate, removes 2 characters at once
- Prompts Y/N confirmation before each rename

## Maintenance Notes

- When modifying the script, keep README.md in sync with any functional changes
