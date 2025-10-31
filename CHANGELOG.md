# rsh Changelog

## v3.6.0 - Multi-line Prompt Support (2025-10-30)

### ✓ **MULTI-LINE PROMPT SUPPORT**
- Full support for prompts with newlines
- Example: `@prompt = "#{Dir.pwd}\n> ".c(196)` works perfectly
- Inspired by rcurses ANSI code handling
- Reported by rapha from #ruby IRC

### ✓ **READLINE REFACTOR**
- getstr() optimized: print prompt once (not every keystroke)
- Major performance improvement: 50% fewer screen updates
- Cleaner code: prompt rendering separated from command editing
- Works for both single and multi-line prompts

### ✓ **ANSI CODE PRESERVATION**
- Color codes preserved across newline splits
- Automatic reapplication to lines after `\n`
- Follows rcurses.rb patterns for colored multi-line text
- Accurate visible length calculations

### ✓ **IMPROVED :info**
- Cleaned up from verbose version history
- Concise feature overview with bullet points
- Quick Start section
- Much more scannable (50 → 40 lines)

### ✓ **BUG FIXES**
- No duplicate prompts in multi-line mode
- Cursor positioning correct (row and column)
- Tab completion shows correct prompt line only
- Backspace works to beginning
- All cursor movements (HOME, END, arrows) work
- Ctrl-L reprints multi-line prompts correctly

---

## v3.5.0 - Polish & Performance (2025-10-30)

### ✓ **NICK/HISTORY EXPORT**
- :nick --export filename.json - Export nicks to share across machines
- :nick --import filename.json - Import nicks from file
- :history --export history.txt - Export command history
- Useful for backing up and sharing configurations

### ✓ **EXPANDED COMPLETIONS**
- Added 9 new tool completions: kubectl, terraform, aws, brew, yarn, make, ansible, poetry, pipenv
- Total: 18 tools with smart subcommand completion
- Instant value for modern development workflows

### ✓ **VALIDATION TEMPLATES**
- :validate --templates shows common safety rules
- Quick-add examples for blocking dangerous commands
- Templates for: safety (rm -rf /), confirmation (git push --force), warnings (sudo), logging

### ✓ **STARTUP TIPS**
- Random helpful tips on first command (30% chance)
- Discover features organically
- :config show_tips on|off to toggle
- Tips shown in gray, non-intrusive

### ✓ **IMPROVED :info**
- :info --quick for brief version
- :info --features for feature list only
- :info for full introduction (default)
- Faster reference lookup

### ✓ **PERFORMANCE OPTIMIZATION**
- Aggressive suggest_command optimization for huge PATHs (18K+ executables)
- Length + first letter pre-filtering
- Hard 100-command limit for suggestions
- Prevents 70s hangs on typos → instant response

### ✓ **TIMESTAMP ACCURACY**
- Timestamp now shows CORRECTED command after auto-fix
- "21:48:02: ls" not "21:48:02: ll"
- See what actually executed

### ✓ **BUG FIXES**
- Fixed suggest_command performance for massive @exe arrays
- Fixed timestamp to show post-correction command
- Removed conflicting default nicks

---

## v3.4.9 - Improved Calculator (2025-10-29)

### ✓ **SAFER :calc EVALUATION**
- Math sandbox using `Object.new.extend(Math)` instead of raw eval
- Prevents arbitrary code execution
- Only Math operations allowed in sandbox
- Suggested by havenwood from #ruby IRC channel

### ✓ **BETTER ERROR MESSAGES**
- Division by zero: Clear "Error: Division by zero" message
- Unknown functions: "Error: Unknown function 'foo'" + list of available functions
- Syntax errors: "Error: Invalid expression syntax" + helpful hints
- Type errors: Clear messages for type mismatches
- Argument errors: Specific error details

### ✓ **IMPROVED HELP**
- :calc with no args shows usage and available functions
- Lists all Math functions: sqrt, sin, cos, tan, log, exp, abs, ceil, floor, round
- Shows constants: PI, E
- Better examples including sin(PI/4)

---

## v3.4.8 - Code Refactoring & Feedback (2025-10-29)

### ✓ **CODE QUALITY IMPROVEMENTS**
- Added `ensure_type()` helper - DRY for type validation (~20 lines → 8 lines)
- Added `persist_var()` helper - DRY for config persistence (~30 lines → 15 lines)
- Cleaner, more maintainable codebase
- ~35 lines net savings through refactoring

### ✓ **USER FEEDBACK**
- Nick/gnick operations now show confirmation messages
- Create: "Nick 'la' → 'ls -la'"
- Delete: "Nick 'la' deleted" or "Nick 'la' not found"
- Better UX, know what happened

### ✓ **BUG FIXES**
- Fixed @plugin_enabled → @plugin_disabled (copy-paste bug, 2 locations)
- All type validations now consistent

---

## v3.4.7 - Rehash Command (2025-10-29)

### ✓ **NEW FEATURES**
- **Added `:rehash` command**: Manually rebuild executable cache on demand
- Works like zsh's built-in `rehash` command
- Useful after installing new executables when you want immediate tab completion
- Forces cache rebuild without waiting for automatic refresh (60s interval)
- Displays count of cached executables after rebuild

### ✓ **BUG FIXES**
- Fixed issue where typing `rehash` would execute OpenSSL's `c_rehash` utility instead of rebuilding rsh's cache
- rsh now intercepts `rehash` as a built-in command like other shells

---

## v3.4.6 - Plugin System Enhancements (2025-10-26)

### ✓ **PLUGIN SYSTEM**
- **Plugin help system**: New `:plugins help <name>` command shows usage and commands
- Extracts help from plugin file header comments automatically
- Lists available commands from plugin code
- **4 new bundled plugins**:
  - `venv` - Virtual environment indicators (Python/Ruby/Node/Conda) in prompt
  - `extract` - Universal archive handler (tar.gz/zip/rar/7z/deb/rpm/etc)
  - `docker` - Container management shortcuts (dps/dex/dlogs/dstop/dclean)
  - `clipboard` - Cross-platform clipboard access (clip/clipp/clipf)
- **Plugins disabled by default**: New users must explicitly enable plugins (whitelist model)
- Changed from `@plugin_disabled` (blacklist) to `@plugin_enabled` (whitelist)
- `:plugins` command shows all available plugins with enabled/disabled status
- Full documentation for all plugins in PLUGIN_GUIDE.md

### ✓ **BUG FIXES**
- **Fixed double prompt issue**: Plugin prompt additions no longer duplicate
- **Fixed Ctrl-W behavior**: Now handles consecutive word deletions correctly
- Ctrl-W now skips trailing spaces before deleting word
- Can press Ctrl-W multiple times to delete multiple words

---

## v3.4.5 - Dynamic Directory Colors in Prompt (2025-10-26)

### ✓ **PROMPT & COMMAND LINE ENHANCEMENTS**
- **rsh is now fully LS_COLORS compliant**: Prompt, command line, and tab completion use consistent LS_COLORS theming
- **LS_COLORS integration for prompt paths**: Directory paths in prompt now use LS_COLORS 'di' value
- **Pattern-based directory colors**: Color directories by pattern matching (like RTFM's @topmatch)
- Works everywhere: prompt paths, command arguments (e.g., "cd Claude"), and tab completion
- Configure in .rshrc: `@dir_colors = [["PassionFruit", 171], ["Dualog", 72], ["/G", 172]]`
- First matching pattern wins (uses string include? check)
- Example: Typing "cd Claude/PassionFruit" will color "Claude/PassionFruit" in 171 (magenta)
- Falls back to LS_COLORS directory color automatically if no pattern matches
- Files continue to use `@c_path` color, only directories use pattern matching
- Zero performance impact (simple pattern matching)

---

## v3.4.4 - Configuration Split & Performance (2025-10-25)

### ✓ **CONFIGURATION IMPROVEMENTS**
- **Separated .rshrc and .rshstate files**
- `.rshrc` - User-editable config (portable: prompt, nicks, bookmarks, defuns, settings)
- `.rshstate` - Auto-managed runtime data (history, stats, cache, learning weights)
- **Auto-migration**: Seamlessly migrates from old single-file format on first run
- Prevents custom prompt/config from being wiped by auto-save
- Makes .rshrc portable between machines

### ✓ **PERFORMANCE IMPROVEMENTS**
- Window title: Direct print vs system spawn (~2-5ms per prompt)
- Cached user/node info (~0.1ms per prompt)
- Reuse Dir.pwd call (already cached as current_dir)
- Faster, snappier prompt loop

### ✓ **TAB COMPLETION**
- Symlink color detection (shows gray per LS_COLORS)
- Symlinked directories properly distinguished from regular directories

---

## v3.4.3 - Enhanced Tab Completion (2025-10-25)

### ✓ **TAB COMPLETION ENHANCEMENTS**
- **LS_COLORS integration**: Completions use your LS_COLORS for consistent file type coloring
- Supports both 256-color format (38;5;X) and ANSI format (01;34)
- **File type indicators**: Executables shown with `*`, directories with `/`
- **Visual selection**: Selected item shown in BOLD, others in regular weight
- **Optional metadata**: `:config completion_show_metadata on` shows file sizes and directory counts
- **Smart context**: Commands only complete at start of line or after pipes/separators
- After typing a command, TAB prioritizes files/directories
- Example: `convert <TAB>` shows image files first, not all commands
- **Auto-complete**: `cd ..<TAB>` instantly completes to `cd ../`
- **Regex fix**: Proper escaping for paths with special characters (dots, etc.)

### ✓ **CONFIGURATION IMPROVEMENTS**
- **Separated .rshrc and .rshstate files**
- `.rshrc` - User-editable config (portable: prompt, nicks, bookmarks, defuns, settings)
- `.rshstate` - Auto-managed runtime data (history, stats, cache, learning weights)
- **Auto-migration**: Seamlessly migrates from old single-file format on first run
- Prevents custom prompt/config from being wiped by auto-save
- Makes .rshrc portable between machines
- Safer, cleaner configuration management

### ✓ **PERFORMANCE IMPROVEMENTS**
- Eliminated system spawn for window title updates (~2-5ms per prompt)
- Cached user/node info (~0.1ms per prompt)
- Reuse Dir.pwd call (already cached as current_dir)
- Symlink color detection added

### ✓ **DOCUMENTATION**
- Added Environment Variables section explaining `:env` commands
- Clarified why `export VAR=value` doesn't work (subprocess limitation)
- Show correct `:env set VAR value` syntax for persistent variables
- Closed GitHub issue #5 with documentation
- Added performance directive to project CLAUDE.md

---

## v3.4.2 - Improved defun Syntax (2025-10-23)

### ✓ **IMPROVED SYNTAX**
- `:defun` now lists all defined functions (was `:defun?`)
- `:defun -name` removes a function without quotes (was `:defun '-name'`)
- Cleaner, more intuitive command syntax
- `:defun?` kept as alias for backwards compatibility
- Updated `:help` to show all operations for :nick and :defun (create/list/delete)

### ✓ **TAB COMPLETION IMPROVEMENTS**
- Commands only complete at start of line or after pipes/separators
- After typing a command, TAB now prioritizes files/directories
- Example: `convert <TAB>` shows image files first, not all commands
- **LS_COLORS integration**: Completions use your LS_COLORS for consistent coloring
- **File type indicators**: Executables shown with `*`, directories with `/`
- **Visual selection**: Selected item shown in BOLD, others in regular weight
- **Optional metadata**: `:config completion_show_metadata on` shows sizes/counts
- Smarter context-aware completion for better UX

### ✓ **DOCUMENTATION**
- Added Environment Variables section explaining `:env` commands
- Clarified why `export VAR=value` doesn't work (subprocess limitation)
- Show correct `:env set VAR value` syntax for persistent variables

---

## v3.4.1 - Performance & Documentation (2025-10-23)

### ✓ **PERFORMANCE IMPROVEMENTS**
- 50-60% faster startup time (~300-500ms down from ~800-1000ms)
- Command output caching with `cached_command()` helper (5min TTL)
- Persistent executable cache saves to .rshrc for instant startup
- Optimized .rshrc reload - only on directory change (not every command)
- ~50ms per-command improvement from reduced reloads
- Based on optimization techniques from RTFM file manager

### ✓ **DOCUMENTATION IMPROVEMENTS**
- README reorganized by feature category (not version)
- Aliases (nicks) section prominent at top (fixes GitHub issue #4)
- Quick Start section with immediate examples
- More scannable and user-friendly
- Easier for new users to discover core features
- Clear examples of simple and parametrized nicks

### ✓ **BUG FIXES**
- Performance optimizations ensure smooth operation
- No functional changes, pure optimization

---

## v3.4.0 - Completion Learning (2025-10-22)

### ✓ **INTELLIGENT TAB COMPLETION**
- Shell learns which completions you use most
- Frequently-selected options appear first in TAB list
- Tracks selections per context (git, ls, docker, etc.)
- Persists learning data to .rshrc across sessions

### ✓ **COMPLETION STATISTICS**
- `:completion_stats` shows learned patterns
- Visual bar charts for completion weights
- Groups by command context
- Shows usage frequency per option

### ✓ **LEARNING MANAGEMENT**
- `:config completion_learning on|off` to enable/disable
- `:completion_reset` to clear all learning data
- Enabled by default for better UX
- Learning data in .rshrc

### ✓ **SMART SORTING**
- Works for all completion types (commands, switches, subcommands)
- Context-aware: git completions separate from ls completions
- Handles switches with descriptions correctly
- Alphabetical fallback when no learning data

### ✓ **COMMAND RECORDING & REPLAY**
- `:record start name` begins recording commands
- `:record stop` stops and saves recording
- `:record show name` displays recorded commands
- `:replay name` executes recorded sequence
- `:record -name` deletes recording
- Only records successful commands (exit 0)
- Error handling with continue/abort prompts
- Persists to .rshrc

### ✓ **3-COLUMN HELP REDESIGN**
- Balanced layout fits vertically on screen (~25 lines)
- Column 1: Keyboard + Commands + Jobs
- Column 2: Sessions + Bookmarks + Recording + Features
- Column 3: Config options + Integrations + Expansions
- Wider columns (36 chars) for better readability
- Common config options documented
- More scannable and organized

### ✓ **SMART COMPLETIONS**
- :record <TAB> shows: start, stop, status, show, recording names
- :replay <TAB> shows recording names
- :plugins <TAB> shows reload, info, enable/disable options
- Context-aware completions for colon commands

### ✓ **PERFORMANCE OPTIMIZATIONS**
- Command output caching - Cache expensive shell outputs (5min TTL, 50 entry limit)
- Persisted executable cache - @exe saves/loads from .rshrc for instant startup
- Optimized .rshrc reload - Only reload on directory change (not every command)
- Lazy JSON loading - Already optimized (require only when needed)
- **50-60% faster startup** (~300-500ms vs ~800-1000ms)
- **~50ms faster per-command** from reduced .rshrc reloads

### ✓ **BUG FIXES**
- Fixed Shift-TAB history search (tabbing → tab function rename)
- Fixed completion learning for switches with descriptions
- Fixed switch sorting in learning algorithm

### ✓ **IMPLEMENTATION**
- Tracks every TAB completion selection
- Weight-based sorting algorithm
- Context detection from command being completed
- Switch description extraction for proper matching
- ~200 lines added (learning + recording + optimizations)

---

## v3.3.0 - Quote-less Syntax (2025-10-22)

### ✓ **SIMPLIFIED COLON COMMAND SYNTAX**
- **No more quotes required** for colon command arguments
- Old syntax: `:nick "la = ls -la"` → New syntax: `:nick la = ls -la`
- Old syntax: `:config "auto_correct", "on"` → New syntax: `:config auto_correct on`
- Old syntax: `:bm "work /tmp #dev"` → New syntax: `:bm work /tmp #dev`
- Backward compatible - old quote syntax still works
- Applies to all colon commands: nick, gnick, defun, bm, config, theme, env, plugins, etc.

### ✓ **IMPROVED USER EXPERIENCE**
- Less typing, more natural syntax
- Cleaner command examples
- Easier to remember and use
- Consistent with shell command style
- Updated all help text and documentation

### ✓ **IMPLEMENTATION**
- Smart parsing: single-string commands (nick, gnick, defun, bm) get full arg string
- Variadic commands (config, theme, stats, etc.) get args split by whitespace
- Known commands list for proper routing (since respond_to? doesn't work)
- Fallback to eval() for arbitrary Ruby expressions (:puts 2+2 still works)

### ✓ **CTRL-G EDIT IN $EDITOR**
- Press Ctrl-G to edit current command line in your $EDITOR
- Perfect for complex multi-line commands
- Creates temp file, opens editor, reads back edited content
- Multi-line commands automatically converted to single-line with semicolons
- Uses $EDITOR environment variable (falls back to vi)
- Temp file auto-deleted after editing

### ✓ **PARAMETRIZED NICKS**
- Nicks now support {{placeholder}} parameters
- `:nick gp = git push origin {{branch}}`
- Use with: `gp branch=main` → executes `git push origin main`
- Multiple parameters: `:nick deploy = ssh {{user}}@{{host}} '{{cmd}}'`
- Parameters auto-stripped after expansion (clean execution)
- All within :nick - no separate :alias or :template command needed

### ✓ **CUSTOM VALIDATION RULES**
- User-defined safety rules with `:validate pattern = action`
- Actions: block (prevent), confirm (ask), warn (show), log (record)
- `:validate rm -rf / = block` - Completely prevents dangerous commands
- `:validate git push --force = confirm` - Requires user confirmation
- `:validate sudo = warn` - Shows warning but allows execution
- `:validate npm install = log` - Logs to ~/.rsh_validation.log
- List rules: `:validate`, Delete by index: `:validate -1`
- Persists to .rshrc

### ✓ **SHELL SCRIPT SUPPORT**
- Full bash syntax support for for/while/if loops
- Commands with shell keywords execute via `bash -c`
- Skips rsh expansions (braces, variables, nicks) for shell scripts
- Example: `for i in {1..5}; do echo $i; done` works perfectly
- Auto-detects: for, while, if, case, function, until keywords
- Shell keywords protected from auto-correction

### ✓ **SIMPLIFIED ARCHITECTURE**
- Removed :template command (merged into :nick)
- Templates are now just parametrized nicks
- One unified command for simple aliases and complex templates
- ~100 lines of code removed
- Simpler to understand and use

### ✓ **POLISH & UX**
- Silent autosave (no more noise)
- Clean .rshrc output (removed empty lines)
- Auto-correct skips shell keywords
- Backward compatible with quoted syntax

### ✓ **DOCUMENTATION**
- All examples updated to quote-less syntax
- :help updated with Ctrl-G and new features
- :info updated with v3.3 section
- README.md updated with new syntax
- Backward compatibility clearly documented

---

## v3.2.0 - Plugin System (2025-10-22)

### ✓ **PLUGIN ARCHITECTURE**
- Extensible plugin system for customizing and extending rsh
- Plugins are Ruby classes in `~/.rsh/plugins/`
- Auto-discovery and loading on startup
- Safe isolated execution with comprehensive error handling
- Zero crashes from bad plugins - graceful degradation

### ✓ **LIFECYCLE HOOKS**
- `on_startup` - Called when plugin loads
- `on_command_before(cmd)` - Called before command execution, can block or modify
- `on_command_after(cmd, exit_code)` - Called after command completes
- `on_prompt` - Called when generating prompt, can append to prompt

### ✓ **EXTENSION POINTS**
- `add_completions` - Add TAB completions for custom commands
- `add_commands` - Register new shell commands as lambdas
- Full access to rsh context (history, bookmarks, config, etc.)
- Commands execute before defuns and system commands

### ✓ **PLUGIN MANAGEMENT**
- `:plugins` - List all loaded plugins with status
- `:plugins "reload"` - Reload all plugins without restarting shell
- `:plugins "enable", "name"` - Enable disabled plugin
- `:plugins "disable", "name"` - Disable plugin
- `:plugins "info", "name"` - Show plugin details (hooks, extensions)
- Disabled plugins list persists to .rshrc

### ✓ **EXAMPLE PLUGINS INCLUDED**
- **git_prompt.rb** - Shows current git branch in prompt
- **command_logger.rb** - Logs all commands to ~/.rsh_command.log with show_log command
- **kubectl_completion.rb** - kubectl/k8s completions and shortcuts (k, kns, kctx)

### ✓ **COMPREHENSIVE DOCUMENTATION**
- PLUGIN_GUIDE.md - Complete API reference
- Plugin templates for all patterns
- Security best practices
- Debugging guide
- 5 complete working examples

### ✓ **AUTO-CORRECT TYPOS**
- Automatically suggests corrections for mistyped commands
- Enable with `:config "auto_correct", "on"`
- Uses Levenshtein distance to find closest match
- Prompts for confirmation before applying (Y/n)
- Shows "AUTO-CORRECTING: 'gti' → 'gtf'" in orange
- Works with system commands, nicks, and user defuns

### ✓ **COMMAND TIMING ALERTS**
- Warns when commands exceed time threshold
- Configure with `:config "slow_command_threshold", "5"` (seconds)
- Shows: "⚠ Command took 7.2s (threshold: 5s)" in orange
- Helps identify performance bottlenecks
- Set to 0 to disable (default)

### ✓ **INLINE CALCULATOR**
- Ruby-powered calculator with Math library
- `:calc 2 + 2` → 4
- `:calc "Math::PI * 2"` → 6.283185307179586
- `:calc "Math.sqrt(16)"` → 4.0
- Full Ruby expressions supported
- Safer than eval, proper error handling

### ✓ **ENHANCED HISTORY COMMANDS**
- `!!` - Repeat last command
- `!-2` - Repeat 2nd to last command
- `!5:7` - Chain commands 5, 6, 7 with &&
- Shows "Chaining: cmd1 && cmd2 && cmd3" before execution
- All original !N syntax still works

### ✓ **STATS VISUALIZATION**
- `:stats --graph` shows colorful ASCII bar charts
- Usage graph: Color-coded by intensity (gray → yellow → orange → red)
- Performance graph: Color-coded by speed (green → orange → red)
- Uses █ blocks for visual appeal
- Scaled to terminal width (40 chars max)

### ✓ **COLON COMMAND THEMING**
- New `@c_colon` color variable for :commands
- All 6 themes updated with colon colors
- Consistent visual language across shell
- :calc added to colon TAB completion

### ✓ **CODE QUALITY**
- Clean plugin API design
- Comprehensive test suite (test_plugins.rb)
- All example plugins tested and working
- ~400 lines of new infrastructure
- Zero breaking changes from v3.1

---

## v3.1.0 - Quick Wins & Polish (2025-10-22)

### ✓ **MULTIPLE NAMED SESSIONS**
- Save sessions with names: `:save_session "project-name"`
- Load specific sessions: `:load_session "project-name"`
- List all sessions: `:list_sessions` shows name, timestamp, and path
- Delete sessions: `:rmsession "name"` or `:delete_session "name"`
- Delete all sessions: `:rmsession "*"` (keeps default and autosave)
- Sessions stored in `~/.rsh/sessions/` directory
- Each session is independent JSON file
- Cannot delete default or autosave sessions (protected)

### ✓ **STATS EXPORT**
- Export to JSON: `:stats --json` or `:stats --export stats.json`
- Export to CSV: `:stats --csv` or `:stats --export stats.csv`
- Format auto-detected from file extension
- Includes frequency, performance, and history data
- Perfect for analysis in spreadsheets or scripts

### ✓ **SESSION AUTO-SAVE**
- Configure in .rshrc: `@session_autosave = 300` (seconds)
- Automatically saves to 'autosave' session at interval
- Set to 0 to disable (default)
- Check config with `:config`
- No interruption to workflow

### ✓ **BOOKMARK ENHANCEMENTS**
- Import bookmarks: `:bm --import bookmarks.json`
- Export bookmarks: `:bm --export bookmarks.json`
- Bookmark statistics: `:bm --stats` shows tag distribution and path analysis
- TAB completion: Bookmarks now appear in completion list
- Search enhancements integrated into existing `:bm "?tag"` syntax

### ✓ **COLOR SCHEME PRESETS**
- Six beautiful themes: default, solarized, dracula, gruvbox, nord, monokai
- Apply instantly: `:theme dracula`
- Preview current colors: `:theme`
- Add to .rshrc to make permanent
- All colors carefully selected for readability

### ✓ **CONFIG MANAGEMENT**
- New `:config` command to view/change settings
- View all settings: `:config`
- Set history dedup: `:config "history_dedup" "off|full|smart"`
- Set auto-save interval: `:config "session_autosave" "300"`
- Set completion limit: `:config "completion_limit" "10"`
- Settings persist to .rshrc

### ✓ **HISTORY DEDUPLICATION OPTIONS**
- Three modes: 'off' (keep all), 'full' (remove all dupes), 'smart' (keep recent, default)
- Configure with `:config "history_dedup" "smart"`
- Smart mode preserves order while removing duplicates
- Persists to .rshrc

### ✓ **ENVIRONMENT VARIABLE MANAGEMENT**
- List variables: `:env` (shows first 20)
- View specific: `:env "PATH"`
- Set variable: `:env "set MYVAR value"`
- Unset variable: `:env "unset MYVAR"`
- Export all: `:env "export env.sh"` creates shell script
- Integrates with existing $VAR completion

### ✓ **IMPROVED TAB COMPLETION**
- Colon commands complete: `:st<TAB>` → :stats, :save_session
- Bookmarks complete: `wo<TAB>` → work (if bookmark exists)
- All new commands in completion list
- Faster, smarter, more comprehensive

### ✓ **DOCUMENTATION**
- Updated `:info` with v3.1 features
- Updated `:help` with all new commands
- README.md enhanced with examples
- CHANGELOG comprehensive and detailed

---

## v3.0.0 - Major Feature Release (2025-10-22)

### ✓ **PERSISTENT RUBY FUNCTIONS**
- User-defined Ruby functions now automatically save to .rshrc
- Functions persist across shell sessions
- Auto-loaded on startup with full state preservation

### ✓ **SMART COMMAND SUGGESTIONS**
- Typo detection using Levenshtein distance algorithm
- "Did you mean...?" suggestions for mistyped commands
- Shows up to 3 closest matches automatically
- Example: `gti status` → "Did you mean: git?"

### ✓ **COMMAND ANALYTICS & STATISTICS**
- New `:stats` command shows comprehensive usage data
- Top 10 most-used commands with visual bar charts
- Performance metrics: total time, average time per command
- Slowest commands tracking
- History statistics and exit status tracking
- All data persists to .rshrc

### ✓ **SWITCH COMPLETION CACHING**
- Command switches cached for 1 hour for instant completion
- Helper function `get_command_switches()` for reusable parsing
- Supports both `--help` and `-h` fallback
- Handles git-style inline switches
- 40-100x performance improvement for repeated completions

### ✓ **ENHANCED BOOKMARKS WITH TAGS**
- Create bookmarks: `:bm "name path #tag1,tag2"`
- Jump to bookmarks: just type the bookmark name
- List bookmarks: `:bm`
- Search by tag: `:bm "?tag"`
- Delete bookmarks: `:bm "-name"`
- Bookmarks colored distinctly (magenta)
- Persistent across sessions

### ✓ **SESSION MANAGEMENT**
- `:save_session` saves complete shell state to JSON
- `:load_session` restores pwd, history, bookmarks, and defuns
- Session file: ~/.rsh_session
- Perfect for switching between projects

### ✓ **SYNTAX VALIDATION**
- Pre-execution warnings for common mistakes
- Detects: unmatched quotes, parentheses, brackets, braces
- Warns about dangerous patterns (rm -rf /, sudo with redirection)
- Integrates with typo detection
- Critical warnings require user confirmation

### ✓ **OPTION VALUE COMPLETION**
- TAB completion for option values
- `--format=<TAB>` → json, yaml, xml, csv, plain
- `--level=<TAB>` → debug, info, warn, error, fatal
- `--color=<TAB>` → auto, always, never
- Extensible pattern matching system

### ✓ **COMMAND PERFORMANCE TRACKING**
- Automatic execution time tracking
- Per-command statistics (count, total time, average)
- Only tracks commands > 10ms to avoid clutter
- Visible in `:stats` output

### ✓ **UNIFIED COMMAND SYNTAX**
- Consistent pattern for :nick, :gnick, and :bm
- Call without args to list all
- Call with "-name" to delete
- Removed :nick? and :gnick? (use :nick and :gnick instead)
- Removed :nickdel and :gnickdel (use :nick "-name" format)

### ✓ **BOOKMARK SHORTCUTS & NAVIGATION**
- Added `:bm` as shortcut for `:bookmark`
- Bookmark names take priority: commands > nicks > bookmarks > paths
- Visual feedback when jumping to bookmarks
- Bookmark coloring in command line (color 13 - magenta)

### ✓ **IMPROVED HELP & INFO**
- Updated `:info` for v3.0 with new features section
- Updated `:help` with all new commands
- Cleaner, more organized presentation
- Removed obsolete references

### ✓ **BUG FIXES**
- Fixed runtime data preservation across .rshrc reloads
- Fixed @cmd_frequency and @cmd_stats wiped on each command
- Fixed @bookmarks and @defuns not preserved in main loop
- Fixed session restore bookmark loading
- Fixed git switch completion (added usage line parsing)
- Fixed spacing in validation warnings

### ✓ **THEMING**
- New @c_bookmark color variable (default: 13 - magenta)
- Updated firstrun() with bookmark color
- Updated README with new color option

### ✓ **CODE QUALITY**
- Added helper function for switch extraction
- Improved code organization and readability
- All features fully tested
- Comprehensive test plan created

---

## v2.12.0 - Extensible Command Completion System (2025-10-22)

### ✓ **SMART SUBCOMMAND COMPLETION**
- **Comprehensive command support**: Tab completion now works for common commands
  - `git <TAB>` shows: add, bisect, branch, checkout, clone, commit, diff, fetch, grep, init, log, merge, mv, pull, push, rebase, reset, restore, rm, show, stash, status, switch, tag
  - `apt <TAB>` shows: install, remove, update, upgrade, search, show, list, autoremove, purge
  - `apt-get <TAB>` shows: install, remove, update, upgrade, dist-upgrade, autoremove, purge, clean, autoclean
  - `docker <TAB>` shows: build, run, ps, images, pull, push, start, stop, restart, rm, rmi, exec, logs, inspect, network, volume
  - `systemctl <TAB>` shows: start, stop, restart, reload, status, enable, disable, is-active, is-enabled, list-units
  - `cargo <TAB>` shows: build, run, test, check, clean, doc, new, init, add, search, publish, install, update
  - `npm <TAB>` shows: install, uninstall, update, run, build, test, start, init, publish
  - `gem <TAB>` shows: install, uninstall, update, list, search, build, push
  - `bundle <TAB>` shows: install, update, exec, check, config
- **Extensible architecture**: Users can add custom command completions in .rshrc:
  ```ruby
  @cmd_completions["mycommand"] = %w[start stop restart status]
  ```
- **Consistent behavior**: All completions respect existing settings like case-sensitivity and fuzzy matching

### ✓ **IMPROVEMENTS**
- Replaced hardcoded git completion with flexible system
- Smart context detection now uses @cmd_completions hash
- Better code organization and maintainability

### ✓ **DOCUMENTATION**
- Updated help text to show smart completion examples
- Enhanced info text with new completion features
- Clear examples for extending completions

## v2.11.1 - Critical Nick Persistence Bugfix (2025-10-04)

### 🐛 **BUGFIX**
- **Fixed nick persistence issue**: Nicks are now correctly saved to .rshrc even when the file doesn't end with a newline
- **Root cause**: The regex pattern `/^@nick.*\n/` only matched lines ending with newline, causing `sub!` to return nil and duplicate @nick lines to accumulate
- **Solution**: Updated regex to `/^@nick.*(\n|$)/` to match lines with or without trailing newline
- **Impact**: Applies to @nick, @gnick, @cmd_frequency, and @history persistence

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