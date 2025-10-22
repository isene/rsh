# rsh Plugin Development Guide

## Overview

rsh v3.2.0+ supports a powerful plugin system that allows you to extend the shell with custom functionality. Plugins are Ruby classes that hook into rsh's lifecycle and can add commands, completions, and modify behavior.

---

## Quick Start

### 1. Create Plugin Directory

Plugins live in `~/.rsh/plugins/`:
```bash
mkdir -p ~/.rsh/plugins
```

### 2. Create Your First Plugin

```ruby
# ~/.rsh/plugins/hello.rb
class HelloPlugin
  def initialize(rsh_context)
    @rsh = rsh_context
  end

  def on_startup
    puts "Hello plugin loaded!"
  end

  def add_commands
    {
      "hello" => lambda do |*args|
        name = args[0] || "World"
        "Hello, #{name}!"
      end
    }
  end
end
```

### 3. Use It

```bash
rsh
# Output: Hello plugin loaded!

hello
# Output: Hello, World!

hello Geir
# Output: Hello, Geir!
```

---

## Plugin API Reference

### Class Naming Convention

**File:** `plugin_name.rb`
**Class:** `PluginNamePlugin`

Examples:
- `git_prompt.rb` → `GitPromptPlugin`
- `my_tools.rb` → `MyToolsPlugin`
- `k8s.rb` → `K8sPlugin`

### Constructor

```ruby
def initialize(rsh_context)
  @rsh = rsh_context
end
```

**rsh_context** provides:
```ruby
{
  version: "3.2.0",           # rsh version
  history: [...],             # Command history array
  bookmarks: {...},           # Bookmarks hash
  nick: {...},                # Nicks hash
  gnick: {...},               # Gnicks hash
  pwd: "/current/dir",        # Current directory
  config: <Method>,           # Access to :config
  rsh: <main>                 # Main rsh object
}
```

---

## Lifecycle Hooks

### on_startup

Called once when plugin is loaded.

```ruby
def on_startup
  puts "Initializing my plugin..."
  @custom_data = load_data()
end
```

**Use cases:**
- Initialize data structures
- Load configuration
- Check dependencies
- Display startup messages

### on_command_before(cmd)

Called before every command executes.

```ruby
def on_command_before(cmd)
  # Return false to block command
  return false if cmd =~ /dangerous_pattern/

  # Return modified command to change what executes
  return cmd.gsub('old', 'new') if cmd.include?('old')

  # Return nil to allow command unchanged
  nil
end
```

**Return values:**
- `false` - Block command execution
- `String` - Replace command with this string
- `nil` - Allow command unchanged

**Use cases:**
- Command validation
- Auto-correction
- Command logging
- Security checks

### on_command_after(cmd, exit_code)

Called after every command completes.

```ruby
def on_command_after(cmd, exit_code)
  if exit_code != 0
    log_error(cmd, exit_code)
  end

  # Can track statistics, log commands, etc.
end
```

**Parameters:**
- `cmd` - The command that was executed
- `exit_code` - Integer exit status (0 = success)

**Use cases:**
- Command logging
- Error tracking
- Statistics collection
- Notifications

### on_prompt

Called when generating the prompt.

```ruby
def on_prompt
  return "" unless Dir.exist?('.git')

  branch = `git branch --show-current`.chomp
  " [#{branch}]"
end
```

**Return:** String to append to prompt (use ANSI codes for colors)

**ANSI Color Format:**
```ruby
"\001\e[38;5;11m\002[text]\001\e[0m\002"
# \001 and \002 wrap escape codes for Readline
# \e[38;5;11m is color 11
# \e[0m resets color
```

**Use cases:**
- Git branch display
- Virtual environment indicator
- Time display
- Status indicators

---

## Extension Points

### add_completions

Add TAB completion for commands.

```ruby
def add_completions
  {
    "docker" => %w[ps images pull push run exec logs],
    "kubectl" => %w[get describe create delete apply],
    "myapp" => %w[start stop restart status]
  }
end
```

**Return:** Hash of `"command" => [subcommands]`

**Notes:**
- Merges with existing `@cmd_completions`
- Works immediately with TAB completion system

### add_commands

Add custom shell commands.

```ruby
def add_commands
  {
    "weather" => lambda do |*args|
      city = args[0] || "oslo"
      system("curl -s wttr.in/#{city}")
    end,
    "myip" => lambda do
      require 'net/http'
      Net::HTTP.get(URI('https://api.ipify.org'))
    end
  }
end
```

**Return:** Hash of `"command" => lambda`

**Notes:**
- Lambdas receive variadic arguments `*args`
- Return value printed if not nil
- Executed before user defuns and regular commands

---

## Complete Plugin Examples

### Example 1: Git Prompt

```ruby
# ~/.rsh/plugins/git_prompt.rb
class GitPromptPlugin
  def initialize(rsh_context)
    @rsh = rsh_context
  end

  def on_prompt
    return "" unless Dir.exist?('.git')

    branch = `git branch --show-current 2>/dev/null`.chomp
    return "" if branch.empty?

    # Yellow color (11)
    " \001\e[38;5;11m\002[#{branch}]\001\e[0m\002"
  end
end
```

**Usage:** Automatically shows git branch in prompt when in git repos

### Example 2: Command Logger

```ruby
# ~/.rsh/plugins/command_logger.rb
class CommandLoggerPlugin
  def initialize(rsh_context)
    @rsh = rsh_context
    @log_file = "#{ENV['HOME']}/.rsh_command.log"
  end

  def on_startup
    File.write(@log_file, "# Log started at #{Time.now}\n", mode: 'a')
  end

  def on_command_after(cmd, exit_code)
    timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    status = exit_code == 0 ? "OK" : "FAIL(#{exit_code})"
    log_entry = "#{timestamp} | #{status.ljust(10)} | #{cmd}\n"

    File.write(@log_file, log_entry, mode: 'a')
  end

  def add_commands
    {
      "show_log" => lambda do |*args|
        lines = args[0]&.to_i || 20
        if File.exist?(@log_file)
          puts File.readlines(@log_file).last(lines).join
        else
          "No command log found"
        end
      end
    }
  end
end
```

**Usage:**
- All commands automatically logged
- `show_log` - Show last 20 log entries
- `show_log 50` - Show last 50 entries

### Example 3: Kubectl Helper

```ruby
# ~/.rsh/plugins/kubectl_completion.rb
class KubectlCompletionPlugin
  def initialize(rsh_context)
    @rsh = rsh_context
  end

  def on_startup
    @kubectl_available = system("command -v kubectl >/dev/null 2>&1")
  end

  def add_completions
    return {} unless @kubectl_available

    {
      "kubectl" => %w[get describe create delete apply edit logs exec],
      "k" => %w[get describe create delete apply edit logs exec]
    }
  end

  def add_commands
    {
      "k" => lambda do |*args|
        system("kubectl #{args.join(' ')}")
        nil  # Don't print return value
      end,
      "kns" => lambda do |*args|
        if args[0]
          system("kubectl config set-context --current --namespace=#{args[0]}")
        else
          current = `kubectl config view --minify --output 'jsonpath={..namespace}'`.chomp
          "Current namespace: #{current.empty? ? 'default' : current}"
        end
      end
    }
  end
end
```

**Usage:**
- `k get pods` - Shorthand for kubectl
- `kns production` - Switch namespace
- `kns` - Show current namespace
- `kubectl <TAB>` - Shows completions

---

## Plugin Management Commands

### List Plugins

```bash
:plugins
# Shows loaded plugins with status
```

### Reload Plugins

```bash
:plugins "reload"
# Reloads all enabled plugins
```

### Disable Plugin

```bash
:plugins "disable", "git_prompt"
# Disables git_prompt plugin immediately
# Persists to .rshrc - stays disabled across restarts
```

### Enable Plugin

```bash
:plugins "enable", "git_prompt"
:plugins "reload"  # Must reload to activate
# Removes from disabled list in .rshrc
```

### Plugin Info

```bash
:plugins "info", "git_prompt"
# Shows:
#   - Class name
#   - File location
#   - Available hooks (✓ = implemented, ✗ = not implemented)
#   - Extension points
```

---

## Best Practices

### 1. Error Handling

Always wrap risky operations:
```ruby
def on_command_before(cmd)
  begin
    # Your logic
  rescue => e
    # Fail silently, don't crash shell
    nil
  end
end
```

### 2. Performance

Keep hooks fast (<50ms):
```ruby
def on_command_before(cmd)
  # Bad: Slow network call
  # response = Net::HTTP.get(URI('slow-api.com'))

  # Good: Quick local check
  cmd.match?(/pattern/)
end
```

### 3. State Management

Use instance variables for state:
```ruby
def initialize(rsh_context)
  @rsh = rsh_context
  @counter = 0
  @cache = {}
end

def on_command_after(cmd, exit_code)
  @counter += 1
  @cache[cmd] = exit_code
end
```

### 4. Conditional Activation

Only activate when needed:
```ruby
def on_startup
  @active = File.exist?('.myproject')
end

def on_prompt
  return "" unless @active
  " [MyProject]"
end
```

### 5. Return Values

Be explicit:
```ruby
def on_command_before(cmd)
  return false if should_block?(cmd)  # Block
  return new_cmd if should_modify?(cmd)  # Modify
  nil  # Allow unchanged
end
```

---

## Advanced Patterns

### Accessing rsh Internals

```ruby
def on_startup
  # Access history
  recent = @rsh[:history].first(10)

  # Access bookmarks
  bookmarks = @rsh[:bookmarks]

  # Get current directory
  pwd = @rsh[:pwd]

  # Access configuration
  @rsh[:config].call("session_autosave", "300")
end
```

### Multi-hook Plugin

```ruby
class FullFeaturedPlugin
  def initialize(rsh_context)
    @rsh = rsh_context
    @stats = {commands: 0, errors: 0}
  end

  def on_startup
    puts "Plugin starting..."
  end

  def on_command_before(cmd)
    # Validate or modify
    @stats[:commands] += 1
    nil
  end

  def on_command_after(cmd, exit_code)
    @stats[:errors] += 1 if exit_code != 0
  end

  def on_prompt
    " [Cmds: #{@stats[:commands]}]"
  end

  def add_completions
    {"mycmd" => %w[sub1 sub2]}
  end

  def add_commands
    {
      "plugin_stats" => lambda do
        "Commands: #{@stats[:commands]}, Errors: #{@stats[:errors]}"
      end
    }
  end
end
```

---

## Debugging Plugins

### Enable Debug Mode

```bash
RSH_DEBUG=1 rsh
# Shows plugin load messages and errors
```

### Common Issues

**Problem:** Plugin not loading
- Check class name matches file name convention
- Verify syntax: `ruby -c ~/.rsh/plugins/myplugin.rb`
- Check RSH_DEBUG output

**Problem:** Hook not firing
- Use `:plugins "info", "pluginname"` to see which hooks are detected
- Verify method name spelling (on_startup, not onstartup)

**Problem:** Command not working
- Check add_commands returns Hash
- Verify lambda syntax
- Test command directly in Ruby

### Test Plugin Standalone

```bash
ruby -e '
load "~/.rsh/plugins/myplugin.rb"
plugin = MypluginPlugin.new({})
puts plugin.add_commands.inspect
'
```

---

## Security Considerations

### Safe Practices

✓ Validate all user input
✓ Use system() or backticks for shell commands
✓ Never eval() user input directly
✓ Limit file access to user directories
✓ Handle all exceptions

### Dangerous Patterns

✗ `eval(args.join(' '))` - Command injection risk
✗ `File.write('/etc/...', data)` - System file modification
✗ Infinite loops in hooks - Shell hangs
✗ Network calls without timeout - Slow startup

---

## Plugin Ideas

### Productivity
- Project template generator
- Quick note taker
- Task timer
- Pomodoro tracker

### Development
- Test runner shortcuts
- Deploy helpers
- Container management
- API testing tools

### System
- System monitor in prompt
- Disk space warnings
- Process management
- Network diagnostics

### Integration
- Slack/Discord notifications
- GitHub shortcuts
- Cloud provider CLIs
- Database connections

---

## Publishing Plugins

### Share Your Plugin

1. Create gist or repo on GitHub
2. Add README with usage
3. Share in rsh discussions

### Plugin Registry (Future)

Planned for v4.0:
- Central plugin registry
- One-command install: `:plugin install name`
- Auto-updates
- Ratings and reviews

---

## API Compatibility

**Current:** v3.2.0
**Stability:** Beta (API may change in 3.x)
**Stable:** v4.0.0 (locked API)

**Breaking changes will be announced in:**
- CHANGELOG.md
- GitHub releases
- This guide

---

## Getting Help

- **Issues:** https://github.com/isene/rsh/issues
- **Examples:** `~/.rsh/plugins/*.rb` (included plugins)
- **Debug:** Run with `RSH_DEBUG=1`

---

## Example Plugin Templates

### Minimal Plugin

```ruby
class MinimalPlugin
  def initialize(rsh_context)
    @rsh = rsh_context
  end
end
```

### Completion Plugin

```ruby
class CompletionPlugin
  def initialize(rsh_context)
    @rsh = rsh_context
  end

  def add_completions
    {
      "mycommand" => %w[sub1 sub2 sub3]
    }
  end
end
```

### Command Plugin

```ruby
class CommandPlugin
  def initialize(rsh_context)
    @rsh = rsh_context
  end

  def add_commands
    {
      "mycommand" => lambda do |*args|
        "Executed with args: #{args.join(', ')}"
      end
    }
  end
end
```

### Prompt Plugin

```ruby
class PromptPlugin
  def initialize(rsh_context)
    @rsh = rsh_context
  end

  def on_prompt
    time = Time.now.strftime("%H:%M")
    " \001\e[38;5;12m\002[#{time}]\001\e[0m\002"
  end
end
```

### Lifecycle Plugin

```ruby
class LifecyclePlugin
  def initialize(rsh_context)
    @rsh = rsh_context
    @command_count = 0
  end

  def on_startup
    puts "Lifecycle plugin loaded"
  end

  def on_command_before(cmd)
    @command_count += 1
    nil  # Don't modify
  end

  def on_command_after(cmd, exit_code)
    puts "Command ##{@command_count} completed" if ENV['PLUGIN_VERBOSE']
  end

  def on_prompt
    " [#{@command_count}]"
  end
end
```

---

## Happy Plugin Development!

Start simple, test thoroughly, and share your creations!
