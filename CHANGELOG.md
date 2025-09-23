# rsh Changelog

## v2.11.0 - Major TAB Completion Overhaul (2025-01-23)

### 🎯 **SMART CONTEXT-AWARE COMPLETION**
- **Intelligent command context detection**: `cd`, `pushd`, `rmdir` show only directories
- **File-specific commands**: `vim`, `nano`, `cat`, `less` show only files
- **Git integration**: `git <TAB>` shows git subcommands (add, commit, push, etc.)
- **Command help**: `man`, `which`, `whatis` show only executable commands
- **Environment variables**: `export`, `unset` show `$VAR` completions

### 🚀 **PERFORMANCE & INTELLIGENCE**
- **Executable caching**: 60-second cache dramatically improves TAB speed
- **Frequency-based scoring**: Most-used commands appear first in completions
- **Fuzzy matching with fallback**: `gti<TAB>` → `git`, `chmd<TAB>` → `chmod`
- **Smart matching hierarchy**: Exact prefix → Fuzzy → Substring matching

### ⚙️ **ENHANCED FILE COMPLETION**
- **Hidden file handling**: Dotfiles only shown when starting with `.`
- **Improved ordering**: Directories first, then files, then commands
- **Environment variable completion**: `echo $P<TAB>` shows `$PATH`, `$PWD`, etc.
- **Multi-delimiter support**: Better handling of pipes, semicolons, background commands

### 🎨 **CONFIGURATION & CUSTOMIZATION**
- **Configurable completion options**:
  - `@completion_limit = 10` (max items shown)
  - `@completion_case_sensitive = false`
  - `@completion_fuzzy = true`
  - `@completion_show_descriptions = false`
- **Command frequency persistence**: Usage patterns saved across sessions
- **Better error handling**: Optional debug logging with `RSH_DEBUG=1`

### 🔧 **FIXES & IMPROVEMENTS**
- **Auto-heal regex fix**: Corrected malformed character class in .rshrc healing
- **Display formatting**: Fixed fuzzy match display showing duplicated text
- **Null safety**: Added comprehensive null checks for edge cases
- **Debug capabilities**: Enhanced debugging output for troubleshooting

### 💡 **USAGE EXAMPLES**
```bash
cd <TAB>          # Shows only directories
vim <TAB>         # Shows only files
git <TAB>         # Shows: add, branch, checkout, clone, commit...
echo $P<TAB>      # Shows: $PATH, $PWD, $PS1...
gti<TAB>          # Fuzzy matches to 'git'
```

This release represents the most significant improvement to daily shell usage in rsh history!

---

## v2.7.0 - Major Release: Ruby Functions & Advanced Shell Features (2025-01-01)

### 🎉 NEW: Ruby Functions - The Star Feature
- **Define Ruby functions as shell commands**: `:defun 'weather(*args) = system("curl -s wttr.in/#{args[0] || \"oslo\"}")'`
- **Call like any shell command**: `weather london`  
- **Full Ruby power**: Access to Ruby stdlib, file operations, JSON parsing, web requests, etc.
- **Function management**: `:defun?` to list, `:defun '-name'` to remove
- **Syntax highlighting**: Ruby functions highlighted in bold
- **Persistent storage**: Functions saved in .rshrc

### 🚀 NEW: Job Control & Process Management
- **Background jobs**: Run commands with `command &`
- **Job suspension**: Use `Ctrl-Z` to suspend running processes
- **Job management**: `:jobs`, `:fg [id]`, `:bg [id]` commands
- **Process tracking**: Full PID tracking and status monitoring
- **Proper signal handling**: SIGHUP/SIGTERM support

### 🔧 NEW: Advanced Shell Features
- **Command substitution**: `$(date)` and backtick support
- **Variable expansion**: `$HOME`, `$USER`, `$?` (exit status)
- **Conditional execution**: `cmd1 && cmd2 || cmd3`
- **Brace expansion**: `{a,b,c}` expands to `a b c`
- **Environment variable support**: Full `$VAR` and `${VAR}` expansion

### 🏠 NEW: Login Shell Support
- **Proper signal handling**: Clean exit on SIGHUP/SIGTERM
- **Profile loading**: Sources `/etc/profile`, `~/.profile`, `~/.bash_profile`, `~/.bashrc`
- **Login shell detection**: Automatic handling of login shell mode
- **Shell registration**: Can be added to `/etc/shells` and set as login shell

### 🐛 Bug Fixes
- **Fixed less command**: No more blank content when using `less filename`
- **Better error handling**: Improved exit codes and error messages
- **Command interception fix**: Prevents file auto-opening when using commands with arguments

### 📚 Documentation Updates
- **Comprehensive README**: New sections for Ruby functions and advanced features
- **Updated help system**: In-shell help reflects all new features
- **Function examples**: Practical examples for common use cases

### 🏆 What Makes This Special
rsh v2.7.0 is now a full-featured shell that combines traditional shell functionality with the unique power of Ruby programming. The Ruby functions feature is unprecedented - no other shell lets you define custom commands using a full programming language with this level of integration.

---

## v2.6.3 - Code clean-up

## v2.6.2 - Fixed issue with tabbing at bottom of screen

## v2.6.0 - Handling line longer than terminal width

## v2.0.0 - Full rewrite of tab completion engine