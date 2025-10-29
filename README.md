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

## Key Features

### Aliases (Nicks)
**rsh uses "nicks" for aliases** - both simple command shortcuts and powerful parametrized templates:

```bash
# Simple aliases
:nick la = ls -la
:nick gs = git status

# Parametrized nicks (templates with {{placeholders}})
:nick gp = git push origin {{branch}}
gp branch=main              # Executes: git push origin main

:nick deploy = ssh {{user}}@{{host}} 'systemctl restart {{app}}'
deploy user=admin host=prod app=api

# List and manage
:nick                       # List all nicks
:nick -la                   # Delete a nick
```

### Intelligence & Learning
* **Completion Learning**: Shell learns which TAB completions you use and ranks them higher
* **Smart Suggestions**: "Did you mean...?" for typos
* **Auto-correct**: Optional auto-fix with confirmation
* **Command Analytics**: `:stats` shows usage patterns and performance

### Productivity
* **Command Recording**: `:record start name` → run commands → `:record stop` → `:replay name`
* **Sessions**: Save/load entire shell state with bookmarks, history, and functions
* **Bookmarks**: Tag directories and jump instantly
* **Multi-line Editing**: Press Ctrl-G to edit in $EDITOR
* **Shell Scripts**: Full bash support for for/while/if loops

### Extensibility
* **Plugin System**: Add custom commands, completions, and hooks
* **Ruby Functions**: Define callable functions - `:defun hello(name) = puts "Hello, #{name}!"`
* **Validation Rules**: `:validate rm -rf / = block` prevents dangerous commands
* **6 Color Themes**: solarized, dracula, gruvbox, nord, monokai, default

### Integrations
* **AI Support**: @ for questions, @@ for command suggestions (Ollama or OpenAI)
* **RTFM**: Launch file manager with `r`
* **fzf**: Fuzzy finder with `f`
* **XRPN**: Calculator with `= expression`

### Tab Completion
* Smart context-aware completion for git, apt, docker, systemctl, cargo, npm, gem
* Command switches from --help
* Option values (--format=json, --level=debug)
* Learns your patterns and adapts

### Core Shell
* Syntax highlighting for nicks, commands, paths, bookmarks
* History with search, edit, and repeat (!, !!, !-2, !5:7)
* Job control (background jobs, suspend, resume)
* Config file (.rshrc) updates on exit
* All colors themeable

---

## Quick Start

```bash
# Install
gem install ruby-shell

# Run
rsh

# Create an alias
:nick ll = ls -l
ll

# Create parametrized alias
:nick gp = git push origin {{branch}}
gp branch=main

# Get help
:help
:info

# See version and changelog
:version
```

---

## Latest Features (v3.4)
* **Define Ruby functions as shell commands**: `:defun 'weather(*args) = system("curl -s wttr.in/#{args[0] || \"oslo\"}")'`
* **Call like any shell command**: `weather london`
* **Full Ruby power**: Access to Ruby stdlib, file operations, JSON parsing, web requests, etc.
* **Function management**: `:defun` to list, `:defun -name` to remove
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
* `:nick ll = ls -l` to make a command alias (ll) point to a command (ls -l)
* `:gnick h = /home/me` to make a general alias (h) point to something (/home/me)
* `:nick` lists all command nicks, `:gnick` lists general nicks
* `:nick -name` delete a command nick, `:gnick -name` delete a general nick
* `:history` will list the command history, while `:rmhistory` will delete the history
* `:rehash` rebuilds the executable cache (useful after installing new commands)
* `:jobs` will list background jobs, `:fg [job_id]` brings jobs to foreground, `:bg [job_id]` resumes stopped jobs
* `:defun func(args) = code` defines Ruby functions callable as shell commands (persistent!)
* `:defun` lists all user-defined functions, `:defun -func` removes functions
* `:stats` shows command execution statistics, `:stats --graph` for visual charts, `:stats --clear` to reset
* `:bm name` or `:bookmark name` bookmark current directory, `:bm name path #tags` with tags
* `:bm` lists all bookmarks, just type bookmark name to jump (e.g., `work`)
* `:bm -name` delete bookmark, `:bm ?tag` search by tag, `:bm --stats` show statistics
* `:save_session name` saves named session, `:load_session name` loads session
* `:list_sessions` shows all saved sessions, `:rmsession name` or `:rmsession *` deletes
* `:theme name` applies color scheme, `:config` manages settings, `:env` manages environment
* `:plugins` lists plugins, `:plugins disable name` disables, `:plugins reload` reloads
* `:calc expression` inline calculator with Ruby Math library
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
While you `cd` around to different directories, you can see the last 10 directories visited via the command `:dirs` or the convenient shortcut `#`. Entering the number in the list (like `6` and ENTER) will jump you to that directory. Entering `-` will jump you back to the previous dir (equivalent of `1`. Entering `~` will get you to your home dir. If you want to bookmark a special directory, you can do that via a general nick like this: `:gnick x = /path/to/a/dir/` - this would bookmark the directory to the single letter `x`.

## Nicks

Nicks are powerful aliases that can be simple command shortcuts or complex parametrized templates.

### Simple Nicks
```bash
:nick ls = ls --color        # Simple alias
:nick la = ls -la            # Another shortcut
:nick                        # List all nicks
:nick -la                    # Delete a nick
```

### Parametrized Nicks (NEW in v3.3!)
Create templates with `{{placeholder}}` parameters:

```bash
# Git shortcuts with branch parameter
:nick gp = git push origin {{branch}}
gp branch=main               # Executes: git push origin main
gp branch=develop            # Executes: git push origin develop

# Deployment with multiple parameters
:nick deploy = ssh {{user}}@{{host}} 'cd {{path}} && git pull'
deploy user=admin host=prod path=/var/www
# Executes: ssh admin@prod 'cd /var/www && git pull'

# Backup with source and destination
:nick backup = rsync -av {{src}} {{dest}}
backup src=/data dest=/backup
# Executes: rsync -av /data /backup
```

**How it works:**
- Define nick with `{{param}}` placeholders
- Use with `key=value` syntax
- Parameters auto-expand and get stripped from final command
- Works with any number of parameters

### General Nicks (gnicks)
Substitute anywhere on command line (not just commands):
```bash
:gnick h = /home/user        # Directory shortcut
:gnick                       # List all gnicks
:gnick -h                    # Delete a gnick
```

## Multi-line Command Editing (v3.3.0+)

Press **Ctrl-G** to edit the current command in your $EDITOR:

```bash
# Start typing a complex command
for i in {1..10}

# Press Ctrl-G
# Your editor opens with the command
# Add more lines:
for i in {1..10}
  echo "Processing: $i"
  sleep 1
done

# Save and quit
# Command appears on command line (converted to single-line with ;)
# Press ENTER to execute
```

**Perfect for:**
- Complex shell scripts
- Long commands with many options
- Multi-line constructs (for, while, if)
- Commands you want to review/edit carefully

---

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
:defun            # List all defined functions
:defun -myls      # Remove a function
```

Ruby functions have access to:
- Full Ruby standard library
- Shell environment variables via `ENV`
- rsh internals like `@history`, `@dirs`
- File system operations
- Network requests
- JSON/XML parsing
- And everything else Ruby can do!

## Custom Validation Rules (v3.3.0+)

Create safety rules to block, confirm, warn, or log specific command patterns:

```bash
# Block dangerous commands completely
:validate rm -rf / = block

# Require confirmation for risky operations
:validate git push --force = confirm
:validate DROP TABLE = confirm

# Show warnings but allow execution
:validate sudo = warn
:validate chmod 777 = warn

# Log specific commands for audit trail
:validate npm install = log
# Logs to ~/.rsh_validation.log

# List all rules
:validate

# Delete rule by index
:validate -1
```

**Actions:**
- `block` - Prevent command execution completely
- `confirm` - Ask for confirmation (y/N)
- `warn` - Show warning but allow
- `log` - Silently log to ~/.rsh_validation.log

**Pattern matching:** Uses regex, so you can match complex patterns.

---

## Environment Variables

**Note:** rsh uses `:env` commands for environment management, not the standard `export` syntax.

```bash
# List all environment variables (shows first 20)
:env

# View specific variable
:env PATH

# Set environment variable
:env set PATH /opt/local/bin:/usr/bin:/bin

# Unset environment variable
:env unset MY_VAR

# Export all variables to shell script
:env export my_env.sh
```

**Why not `export`?**
- rsh uses colon commands (`:cmd`) for shell operations
- Standard `export VAR=value` syntax spawns a subprocess that doesn't affect parent shell
- Use `:env set VAR value` instead for persistent environment changes

**Tip:** Add `:env set` commands to your `~/.rshrc` for variables you need on every startup.

---

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

### Directory Colors in Prompt

**rsh is fully LS_COLORS compliant** - both tab completion and prompt paths use LS_COLORS for consistent theming.

You can override directory colors in the prompt using pattern matching (like RTFM's @topmatch):
```ruby
@dir_colors = [
  ["PassionFruit", 171],  # Paths containing "PassionFruit" -> magenta
  ["Dualog", 72],         # Paths containing "Dualog" -> cyan
  ["/G", 172],            # Paths containing "/G" -> orange
]
```

How it works:
- Array of `[pattern, color]` pairs
- First matching pattern wins (uses Ruby's `include?` method)
- If no pattern matches, uses LS_COLORS 'di' value (your configured directory color)
- Pattern matching is simple substring matching: "/G" matches "/home/user/Main/G/..."

This lets you visually distinguish different project directories at a glance in your prompt.

You can add any Ruby code to your .rshrc.

# Enter the world of Ruby
By entering `:some-ruby-command` you have full access to the Ruby universe right from your command line. You can do anything from `:puts 2 + 13` or `:if 0.7 > Math::sin(34) then puts "OK" end` or whatever tickles you fancy.

# Not yet implemented
Lots. Of. Stuff.

# License and copyright
Forget it.
