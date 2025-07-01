# rsh Changelog

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