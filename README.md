# rsh
![Ruby](https://img.shields.io/badge/language-Ruby-red) [![Gem Version](https://badge.fury.io/rb/ruby-shell.svg)](https://badge.fury.io/rb/ruby-shell) ![Unlicense](https://img.shields.io/badge/license-Unlicense-green) ![Stay Amazing](https://img.shields.io/badge/Stay-Amazing-important)

The Ruby SHell

# Why?
<img src="img/rsh-logo.jpg" align="left" width="150" height="150">Ruby is my goto language (pun kinda intended). I want full control over my tools and I like challenges that I can tinker with late at night. This is an incomplete project continually being improved. Feel free to add suggestions or code.

# Design principles
Simple. One file. Minimum external requirements.

# Installation
Clone this repo and drop `rsh` into your preferred bin directory. Drop `.rshrc` into your home directory and edit as you see fit.

Or simply `gem install ruby-shell`.

# Screencast
[![rsh screencast](/img/rsh-screencast.png)](https://youtu.be/4P2z8oSo1u4)

# Features

## Core Shell Features
* Aliases (called nicks in rsh) - both for commands and general nicks
* Syntax highlighting, matching nicks, system commands and valid dirs/files
* Tab completions for nicks, system commands, command switches and dirs/files
* Tab completion presents matches in a list to pick from
* When you start to write a command, rsh will suggest the first match in the history and present that in "toned down" letters - press the arrow right key to accept the suggestion.
* Writing a partial command and pressing `UP` will search history for matches.  Go down/up in the list and press `TAB` or `ENTER` to accept, `Ctrl-g` or `Ctrl-c` to discard
* History with editing, search and repeat a history command (with `!`)
* Config file (.rshrc) updates on exit (with Ctrl-d) or not (with Ctrl-e)
* Set of simple rsh specific commands like nick, nick?, history and rmhistory
* rsh specific commands and full set of Ruby commands available via :<command>
* All colors are themeable in .rshrc (see github link for possibilities)
* Copy current command line to primary selection (paste w/middle button) with `Ctrl-y`

## NEW in v3.2.0 - Plugin System & Productivity ⭐⭐⭐
* **Plugin Architecture**: Extensible plugin system with lifecycle hooks and extension points
* **Lifecycle Hooks**: on_startup, on_command_before, on_command_after, on_prompt
* **Extension Points**: add_completions (TAB completion), add_commands (custom commands)
* **Plugin Management**: `:plugins` list/reload/enable/disable/info commands
* **Auto-loading**: Plugins in `~/.rsh/plugins/` load automatically on startup
* **Safe Execution**: Isolated plugin execution with error handling, no shell crashes
* **Example Plugins**: git_prompt (branch in prompt), command_logger (audit log), kubectl_completion (k8s shortcuts)
* **Auto-correct Typos**: `:config "auto_correct", "on"` with user confirmation (Y/n) before applying
* **Command Timing Alerts**: `:config "slow_command_threshold", "5"` warns on commands > 5 seconds
* **Inline Calculator**: `:calc 2 + 2`, `:calc "Math::PI"` - full Ruby Math library support
* **Enhanced History**: `!!` (last), `!-2` (2nd to last), `!5:7` (chain commands 5-7)
* **Stats Visualization**: `:stats --graph` for colorful ASCII bar charts with intensity colors
* **Documentation**: Complete PLUGIN_GUIDE.md with API reference and examples

## v3.1.0 - Quick Wins & Polish ⭐
* **Multiple Named Sessions**: Save/load different sessions - `:save_session "project"`, `:load_session "project"`
* **Stats Export**: Export analytics to CSV/JSON - `:stats --csv` or `:stats --json`
* **Session Auto-save**: Set `@session_autosave = 300` in .rshrc for automatic 5-minute saves
* **Bookmark Import/Export**: Share bookmarks - `:bm --export bookmarks.json`, `:bm --import bookmarks.json`
* **Bookmark Statistics**: See usage patterns - `:bm --stats` shows tag distribution and analytics
* **Color Themes**: 6 preset themes - `:theme solarized|dracula|gruvbox|nord|monokai|default`
* **Config Management**: `:config` shows/sets history_dedup, session_autosave, completion settings
* **Environment Variables**: `:env` lists/sets/exports environment variables
* **Bookmark TAB Completion**: Bookmarks appear in TAB completion alongside commands
* **List Sessions**: `:list_sessions` shows all saved sessions with timestamps and paths

## v3.0.0 - Major Feature Release ⭐⭐⭐
* **Persistent Ruby Functions**: defun functions now save to .rshrc and persist across sessions
* **Smart Command Suggestions**: Typo detection with "Did you mean...?" suggestions using Levenshtein distance
* **Command Analytics**: New `:stats` command shows usage statistics, performance metrics, and most-used commands
* **Switch Completion Caching**: Command switches from --help are cached for instant completion
* **Enhanced Bookmarks**: Bookmark directories with tags - `:bookmark name path #tag1,tag2`
* **Session Management**: Save and restore entire shell sessions with `:save_session` and `:load_session`
* **Syntax Validation**: Pre-execution warnings for common mistakes, dangerous commands, and typos
* **Option Value Completion**: TAB completion for option values like `--format=<TAB>` → json, yaml, xml
* **Command Performance Tracking**: Automatically tracks execution time and shows slowest commands

## AI Integration (v2.9.0) ⭐
* **AI-powered command assistance**: Get help with commands using natural language
* **`@ <question>`**: Ask questions and get AI-generated text responses
* **`@@ <request>`**: Describe what you want to do, and AI suggests the command
* **Smart command suggestion**: AI suggestions appear directly on the command line, ready to execute
* **Local AI support**: Works with Ollama for privacy-focused local AI
* **External AI support**: Configure OpenAI or other providers via `.rshrc`
* **Syntax highlighting**: @ and @@ commands are highlighted in blue

## Enhanced Help System & Nick Management (v2.8.0)
* **Two-column help display**: Compact, organized help that fits on one screen
* **New `:info` command**: Shows introduction and feature overview
* **`:nickdel` and `:gnickdel`**: Intuitive commands to delete nicks and gnicks
* **Improved help organization**: Quick reference for keyboard shortcuts, commands, and features

## Ruby Functions (v2.7.0)
* **Define Ruby functions as shell commands**: `:defun 'weather(*args) = system("curl -s wttr.in/#{args[0] || \"oslo\"}")'`
* **Call like any shell command**: `weather london`
* **Full Ruby power**: Access to Ruby stdlib, file operations, JSON parsing, web requests, etc.
* **Function management**: `:defun?` to list, `:defun '-name'` to remove
* **Syntax highlighting**: Ruby functions highlighted in bold

## Advanced Shell Features
* **Job Control**: Background jobs (`command &`), job suspension (`Ctrl-Z`), process management
* **Job Management**: `:jobs`, `:fg [id]`, `:bg [id]` commands
* **Command Substitution**: `$(date)` and backtick support  
* **Variable Expansion**: `$HOME`, `$USER`, `$?` (exit status)
* **Conditional Execution**: `cmd1 && cmd2 || cmd3`
* **Brace Expansion**: `{a,b,c}` expands to `a b c`
* **Login Shell Support**: Proper signal handling and profile loading
  
Special functions/integrations:
* Use `r` to launch rtfm (https://github.com/isene/RTFM) - if you have it installed
* Use `f` to launch fzf (https://github.com/junegunn/fzf) - if you have it installed
* Use `=` followed by xrpn commands separated by commas (https://github.com/isene/xrpn)
* Use `:` followed by a Ruby expression to access the whole world of Ruby

Special commands:
* `:nick 'll = ls -l'` to make a command alias (ll) point to a command (ls -l)
* `:gnick 'h = /home/me'` to make a general alias (h) point to something (/home/me)
* `:nick` lists all command nicks, `:gnick` lists general nicks (NEW in v3.0)
* `:nick '-name'` delete a command nick, `:gnick '-name'` delete a general nick (NEW in v3.0)
* `:history` will list the command history, while `:rmhistory` will delete the history
* `:jobs` will list background jobs, `:fg [job_id]` brings jobs to foreground, `:bg [job_id]` resumes stopped jobs
* `:defun 'func(args) = code'` defines Ruby functions callable as shell commands (now persistent!)
* `:defun?` lists all user-defined functions, `:defun '-func'` removes functions
* `:stats` shows command execution statistics and analytics (NEW in v3.0)
* `:bm "name"` or `:bookmark "name"` bookmark current directory, `:bm "name path #tags"` with tags (NEW in v3.0)
* `:bm` lists all bookmarks, just type bookmark name to jump (e.g., `work`) (NEW in v3.0)
* `:bm "-name"` delete bookmark, `:bm "?tag"` search by tag (NEW in v3.0)
* `:save_session "name"` saves named session, `:load_session "name"` loads session (NEW in v3.0)
* `:list_sessions` shows all saved sessions, `:rmsession "name"` or `:rmsession "*"` deletes (NEW in v3.1)
* `:theme "name"` applies color scheme, `:config` manages settings, `:env` manages environment (NEW in v3.1)
* `:plugins` lists plugins, `:plugins "disable", "name"` disables, `:plugins "reload"` reloads (NEW in v3.2)
* `:info` shows introduction and feature overview
* `:version` Shows the rsh version number and the last published gem file version
* `:help` will display a compact command reference in two columns

Background jobs:
* Use `command &` to run commands in background
* Use `:jobs` to list active background jobs  
* Use `:fg` or `:fg job_id` to bring jobs to foreground
* Use `Ctrl-Z` to suspend running jobs, `:bg job_id` to resume them

## AI Configuration
The AI features work out of the box with Ollama for local AI processing. To set up:

### Local AI (Recommended)
1. Install Ollama: `curl -fsSL https://ollama.com/install.sh | sh`
2. Pull a model: `ollama pull llama3.2`
3. That's it! Use `@ What is the capital of France?` or `@@ list files by size`

### External AI (OpenAI)
Add to your `.rshrc`:
```ruby
@aimodel = "gpt-4"
@aikey = "your-api-key-here"
```

## Moving around
While you `cd` around to different directories, you can see the last 10 directories visited via the command `:dirs` or the convenient shortcut `#`. Entering the number in the list (like `6` and ENTER) will jump you to that directory. Entering `-` will jump you back to the previous dir (equivalent of `1`. Entering `~` will get you to your home dir. If you want to bookmark a special directory, you can do that via a general nick like this: `:gnick "x = /path/to/a/dir/"` - this would bookmark the directory to the single letter `x`.

## Nicks
Add command nicks (aliases) with `:nick "some_nick = some_command"`, e.g. `:nick "ls = ls --color"`. Add general nicks that will substitute anything on a command line (not just commands) like this `:gnick "some_gnick = some_command"`, e.g. `:gnick "x = /home/user/somewhere"`. List nicks with `:nick`, list gnicks with `:gnick`. Remove a nick with `:nick "-some_command"`, e.g. `:nick "-ls"` to remove an `ls` nick. Same for gnicks.

## Tab completion
You can tab complete almost anything. Hitting `TAB` will try to complete in this priority: nicks, gnicks, commands, dirs/files. Special completions:
- `ls -<TAB>` lists command switches from --help with descriptions
- `:st<TAB>` completes colon commands (:stats, etc.)
- `$HO<TAB>` completes environment variables ($HOME, etc.)
- `git <TAB>` shows git subcommands (add, commit, push, etc.)
- `--format=<TAB>` completes option values (json, yaml, xml, etc.)

You can add to (or subtract from) the search criteria while selecting matches - hit any letter to refine the search, backspace removes a letter from the criteria.

Hitting Shift-TAB will search through the command history with fuzzy matching.

## Open files
If you press `ENTER` after writing or tab-completing to a file, rsh will try to open the file in the user's EDITOR of choice (if it is a valid text file) or use `xdg-open` to open the file using the correct program. If you, for some reason want to use `run-mailcap` instead of `xdg-open` as the file opener, simply add `@runmailcap = true` to your `.rshrc`.

## History
Show the history with `:history`. Redo a history command with an exclamation mark and the number corresponding to the position in the history, like `!5` would do the 5th history command again. To delete a specific entry in history, hit `UP` and move up to that entry and hit `Ctrl-k` (for "kill").

## Ruby Functions - The Power Feature ⭐

rsh's unique Ruby functions let you define custom shell commands using the full power of Ruby:

### Basic Examples
```bash
# File operations
:defun 'count(*args) = puts Dir.glob(args[0] || "*").length'
count *.rb

# System monitoring  
:defun 'mem = puts `free -h`.lines[1].split[2]'
mem

# JSON pretty-printing
:defun 'jsonpp(file) = require "json"; puts JSON.pretty_generate(JSON.parse(File.read(file)))'
jsonpp config.json
```

### Advanced Examples
```bash
# Network tools
:defun 'ports = puts `netstat -tlnp`.lines.grep(/LISTEN/).map{|l| l.split[3]}'
ports

# Git helpers
:defun 'branches = puts `git branch`.lines.map{|l| l.strip.sub("* ", "")}'
branches

# Directory analysis
:defun 'sizes(*args) = Dir.glob(args[0] || "*").each{|f| puts "#{File.size(f).to_s.rjust(8)} #{f}" if File.file?(f)}'
sizes

# Weather (using external API)
:defun 'weather(*args) = system("curl -s wttr.in/#{args[0] || \"oslo\"}")'
weather london
```

### Function Management
```bash
:defun?           # List all defined functions
:defun '-myls'    # Remove a function
```

Ruby functions have access to:
- Full Ruby standard library
- Shell environment variables via `ENV`
- rsh internals like `@history`, `@dirs`
- File system operations
- Network requests
- JSON/XML parsing
- And everything else Ruby can do!

## Plugin System (v3.2.0+)

rsh supports a powerful plugin system for extending functionality. Plugins are Ruby classes placed in `~/.rsh/plugins/` that can:

- Add custom commands
- Add TAB completions
- Hook into command execution (before/after)
- Modify the prompt
- Access rsh internals (history, bookmarks, etc.)

**Quick Start:**
```ruby
# Create ~/.rsh/plugins/hello.rb
class HelloPlugin
  def initialize(rsh_context)
    @rsh = rsh_context
  end

  def add_commands
    {
      "hello" => lambda { |*args| "Hello, #{args[0] || 'World'}!" }
    }
  end
end
```

Then in rsh: `hello Geir` outputs `Hello, Geir!`

**Plugin Management:**
```bash
:plugins                        # List all loaded plugins
:plugins "disable", "git_prompt"  # Disable a plugin
:plugins "enable", "git_prompt"   # Enable a plugin
:plugins "reload"                 # Reload all plugins
:plugins "info", "plugin_name"    # Show plugin details
```

**Included Example Plugins:**
- **git_prompt** - Shows current git branch in prompt
- **command_logger** - Logs all commands with timestamps (`show_log` to view)
- **kubectl_completion** - Kubernetes shortcuts and completions (k, kns, kctx)

**See PLUGIN_GUIDE.md for complete development documentation.**

---

## Integrations
rsh is integrated with the [rtfm file manager](https://github.com/isene/RTFM), with [fzf](https://github.com/junegunn/fzf) and with the programming language [XRPN](https://github.com/isene/xrpn). 

Just enter the command `r` and rtfm will be launched - and when you quit the file manager, you will drop back into rsh in the directory you where you exited rtfm. 

Enter the command `f` to launch the fuzzy finder - select the directory/file you want, press `ENTER` and you will find yourself in the directory where that item resides. 

If you start a line with "=", the rest of the line will be interpreted as an XRPN program. This gives you the full power of XRPN right at your fingertips. You can do simple stuff like this: `=13,23,*,x^2` and the answer to `(13 * 23)^2` will be given (89401) in the format that you have set in your `.xrpn/conf`. Or you can do more elaborate stuff like `=fix 6,5,sto c,time,'Time now is: ',atime,aview,pse,fix 0,lbl a,rcl c,prx,dse c,gto a`. Go crazy. Use single-quotes for any Alpha entry.

## Syntax highlighting
rsh will highlight nicks, gnicks, bookmarks, commands, switches and dirs/files as they are written on the command line. Each element type has its own color (customizable in .rshrc).

## Theming
In the supplied `.rshrc`, you will find a set of colors that you can change:

Variable        | Description
----------------|-----------------------------------------
`@c_prompt`     | Color for basic prompt
`@c_cmd`        | Color for valid command
`@c_nick`       | Color for matching nick
`@c_gnick`      | Color for matching gnick
`@c_path`       | Color for valid path
`@c_switch`     | Color for command switches/options
`@c_bookmark`   | Color for bookmarks (NEW in v3.0)
`@c_colon`      | Color for colon commands (NEW in v3.1)
`@c_tabselect`  | Color for selected tabcompleted item
`@c_taboption`  | Color for unselected tabcompleted item
`@c_stamp`      | Color for time stamp/command

## The .rshrc
`.rshrc` is the configuration file for rsh and it is located in your home directory. It is created when you first start rsh and you can modify it to suit your needs. A more detailed .rshrc is found in the the [rsh github repo](https://github.com/isene/rsh) - you can drop this into your home dir if you like. Set the basic environment variables like this:
```
ENV["EDITOR"]   = "vim"
ENV["MANPAGER"] = "vim +MANPAGER -"
```
Also, a special variable for better LS_COLOR setup:
```
@lscolors = "/home/geir/.local/share/lscolors.sh"
```
Point `@lscolors` to a file that sets your LS_COLORS variable. Use [my extended LS_COLORS setup](https://github.com/isene/LS_COLORS) to make this really fancy.

You can add any Ruby code to your .rshrc.

# Enter the world of Ruby
By entering `:some-ruby-command` you have full access to the Ruby universe right from your command line. You can do anything from `:puts 2 + 13` or `:if 0.7 > Math::sin(34) then puts "OK" end` or whatever tickles you fancy.

# Not yet implemented
Lots. Of. Stuff.

# License and copyright
Forget it.
