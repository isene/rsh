#!/usr/bin/env ruby
# encoding: utf-8
#
# SCRIPT INFO 
# Name:       rsh - Ruby SHell
# Language:   Pure Ruby, best viewed in VIM
# Author:     Geir Isene <g@isene.com>
# Web_site:   http://isene.com/
# Github:     https://github.com/isene/rsh
# License:    Public domain
@version    = "2.1"

# MODULES, CLASSES AND EXTENSIONS
class String # Add coloring to strings (with escaping for Readline)
  def c(code);  color(self, "\001\e[38;5;#{code}m\002"); end  # Color code
  def b;        color(self, "\001\e[1m\002"); end             # Bold
  def i;        color(self, "\001\e[3m\002"); end             # Italic
  def u;        color(self, "\001\e[4m\002"); end             # Underline
  def l;        color(self, "\001\e[5m\002"); end             # Blink
  def r;        color(self, "\001\e[7m\002"); end             # Reverse
  def color(text, color_code)  "#{color_code}#{text}\001\e[0m\002" end
end
module Cursor # Terminal cursor movement ANSI codes (thanks to https://github.com/piotrmurach/tty-cursor)
  module_function
  ESC = "\e".freeze
  CSI = "\e[".freeze
  def save # Save current position
    print(Gem.win_platform? ? CSI + 's' : ESC + '7')
  end
  def restore # Restore cursor position
    print(Gem.win_platform? ? CSI + 'u' : ESC + '8')
  end
  def pos # Query cursor current position
    res = ''
    $stdin.raw do |stdin|
      $stdout << CSI + '6n' # Tha actual ANSI get-position
      $stdout.flush
      while (c = stdin.getc) != 'R'
        res << c if c
      end
    end
    m = res.match /(?<row>\d+);(?<col>\d+)/
    return m[:row].to_i, m[:col].to_i
  end
  def up(n = nil) # Move cursor up by n
    print(CSI + "#{(n || 1)}A")
  end
  def down(n = nil) # Move the cursor down by n
    print(CSI + "#{(n || 1)}B")
  end
  def left(n = nil) # Move the cursor backward by n
    print(CSI + "#{n || 1}D")
  end
  def right(n = nil) # Move the cursor forward by n
    print(CSI + "#{n || 1}C")
  end
  def col(n = nil) # Cursor moves to nth position horizontally in the current line
    print(CSI + "#{n || 1}G")
  end
  def row(n = nil) # Cursor moves to the nth position vertically in the current column
    print(CSI + "#{n || 1}d")
  end
  def next_line # Move cursor down to beginning of next line
    print(CSI + 'E' + CSI + "1G")
  end
  def prev_line # Move cursor up to beginning of previous line
    print(CSI + 'A' +  CSI + "1G")
  end
  def clear_char(n = nil) # Erase n characters from the current cursor position
    print(CSI + "#{n}X")
  end
  def clear_line # Erase the entire current line and return to beginning of the line
    print(CSI + '2K' +  CSI + "1G")
  end
  def clear_line_before # Erase from the beginning of the line up to and including the current cursor position.
    print(CSI + '1K')
  end
  def clear_line_after # Erase from the current position (inclusive) to the end of the line
    print(CSI + '0K')
  end
  def scroll_up # Scroll display up one line
    print(ESC + 'M')
  end
  def scroll_down # Scroll display down one line
    print(ESC + 'D')
  end
  def clear_screen_down
    print(CSI + 'J')
  end
end
def stdin_clear
  begin
    $stdin.getc while $stdin.ready?
  rescue
  end
end

# INITIALIZATION
begin # Requires
  require 'etc'
  require 'io/console'
  require 'io/wait'
end
begin # Initialization
  # Theming
  @c_prompt    = 10                       # Color for basic prompt
  @c_cmd       = 2                        # Color for valid command
  @c_nick      = 6                        # Color for matching nick
  @c_gnick     = 14                       # Color for matching gnick
  @c_path      = 3                        # Color for valid path
  @c_switch    = 6                        # Color for switches/options
  @c_tabselect = 5                        # Color for selected tabcompleted item
  @c_taboption = 244                      # Color for unselected tabcompleted item
  @c_stamp     = 244                      # Color for time stamp/command
  # Prompt
  @prompt      = "rsh > ".c(@c_prompt).b  # Very basic prompt if not defined in .rshrc
  # Hash & array initializations
  @nick        = {}                       # Initiate alias/nick hash
  @gnick       = {}                       # Initiate generic/global alias/nick hash
  @history     = []                       # Initiate history array
  # Paths
  @user = Etc.getpwuid(Process.euid).name # For use in @prompt
  @path        = ["/bin", 
                  "/usr/bin", 
                  "/home/#{@user}/bin"]   # Basic paths for executables if not set in .rshrc
  # History
  @histsize    = 200                      # Max history if not set in .rshrc
  @hloaded     = false                    # Variable to determine if history is loaded
  # Use run-mailcap instead of xgd-open? Set "= true" in .rshrc if you want run-mailcap
  @runmailcap  = false
  # Variable initializations
  @dirs        = ["."]*10
  def pre_cmd; end                        # User-defined function to be run BEFORE command execution
  def post_cmd; end                       # User-defined function to be run AFTER  command execution
end

# HELP TEXT
@help = <<~HELP

  Hello #{@user}, welcome to rsh - the Ruby SHell. 
  
  rsh does not attempt to compete with the grand old shells like bash and zsh. 
  It serves the specific needs and wants of its author. If you like it, then feel free 
  to ask for more or different features here: https://github.com/isene/rsh. Features:

  * Aliases (called nicks in rsh) - both for commands and general nicks
  * Syntax highlighting, matching nicks, system commands and valid dirs/files
  * Tab completions for nicks, system commands, command switches and dirs/files
  * Tab completion presents matches in a list to pick from
  * When you start to write a command, rsh will suggest the first match in the history and
    present that in "toned down" letters - press the arrow right key to accept the suggestion
  * Writing a partial command and pressing `UP` will search history for matches.
    Go down/up in the list and press `TAB` or `ENTER` to accept, `Ctrl-g` or `Ctrl-c` to discard
  * History with editing, search and repeat a history command (with `!`)
  * Config file (.rshrc) updates on exit (with Ctrl-d) or not (with Ctrl-e)
  * Set of simple rsh specific commands like nick, nick?, history and rmhistory
  * rsh specific commands and full set of Ruby commands available via :<command>
  * All colors are themeable in .rshrc (see github link for possibilities)
  * Copy current command line to primary selection (paste w/middle button) with `Ctrl-y`

  Special functions/integrations:
  * Use `r` to launch rtfm (https://github.com/isene/RTFM) - if you have it installed
  * Use `f` to launch fzf (https://github.com/junegunn/fzf) - if you have it installed
  * Use `=` followed by xrpn commands separated by commas or double-spaces (https://github.com/isene/xrpn)
  * Use `:` followed by a Ruby expression to access the whole world of Ruby

  Special commands:
  * `:nick 'll = ls -l'` to make a command alias (ll) point to a command (ls -l)
  * `:gnick 'h = /home/me'` to make a general alias (h) point to something (/home/me)
  * `:nick?` will list all command nicks and general nicks (you can edit your nicks in .rshrc)
  * `:history` will list the command history, while `:rmhistory` will delete the history
  * `:version` Shows the rsh version number and the last published gem file version
  * `:help` will display this help text
  
HELP

# GENERIC FUNCTIONS
def firstrun
  puts @help
  puts "Since there is no rsh configuration file (.rshrc), I will help you set it up to suit your needs.\n\n"
  puts "The prompt you see now is the very basic rsh prompt:"
  print "#{@prompt} (press ENTER)"
  $stdin.gets
  puts "\nI will now change the prompt into something more useful."
  puts "Feel free to amend the prompt in your .rshrc.\n\n"
  rc = <<~RSHRC
  # PROMPT
  # The numbers in parenthesis are 256 color codes (the '.c()' is a String extention
  # to color text in the terminal. Add '.b' for bold and '.i' for italics.
  @prompt = "\#{@user}@\#{@node}".c(46) + ":".c(255) + " \#{Dir.pwd}/".c(196) + " ".c(7)

  # THEME
  @c_prompt    = 196  # Color for basic prompt
  @c_cmd       = 48   # Color for valid command
  @c_nick      = 51   # Color for matching nick
  @c_gnick     = 87   # Color for matching gnick
  @c_path      = 208  # Color for valid path
  @c_switch    = 148  # Color for switches/options
  @c_tabselect = 207  # Color for selected tabcompleted item
  @c_taboption = 244  # Color for unselected tabcompleted item
  @c_stamp     = 244  # Color for time stamp/command

  @nick = {"ls"=>"ls --color -F"}
RSHRC
  File.write(Dir.home+'/.rshrc', rc)
end
def getchr # Process key presses
  c = $stdin.getch
  case c
  when "\e"    # ANSI escape sequences (with only ESC, it should stop right here)
    return "ESC" if $stdin.ready? == nil
    case $stdin.getc
    when '['   # CSI
      case $stdin.getc  # Will get (or ASK) for more (remaining part of special character)
      when 'A' then chr = "UP"
      when 'B' then chr = "DOWN"
      when 'C' then chr = "RIGHT"
      when 'D' then chr = "LEFT"
      when 'Z' then chr = "S-TAB"
      when '2' then chr = "INS"    ; chr = "C-INS"    if $stdin.getc == "^"
      when '3' then chr = "DEL"    ; chr = "C-DEL"    if $stdin.getc == "^"
      when '5' then chr = "PgUP"   ; chr = "C-PgUP"   if $stdin.getc == "^"
      when '6' then chr = "PgDOWN" ; chr = "C-PgDOWN" if $stdin.getc == "^"
      when '7' then chr = "HOME"   ; chr = "C-HOME"   if $stdin.getc == "^"
      when '8' then chr = "END"    ; chr = "C-END"    if $stdin.getc == "^"
      else chr = ""
      end
    when 'O'   # Set Ctrl+ArrowKey equal to ArrowKey; May be used for other purposes in the future
      case $stdin.getc
      when 'a' then chr = "C-UP"
      when 'b' then chr = "C-DOWN"
      when 'c' then chr = "C-RIGHT"
      when 'd' then chr = "C-LEFT"
      else chr = ""
      end
    end
  when "", "" then chr = "BACK"
  when "" then chr = "C-C"
  when "" then chr = "C-D"
  when "" then chr = "C-E"
  when "" then chr = "C-G"
  when "" then chr = "C-K"
  when "" then chr = "C-L"
  when "" then chr = "C-N"
  when "" then chr = "C-O"
  when "" then chr = "C-P"
  when "" then chr = "C-T"
  when "" then chr = "C-Y"
  when "" then chr = "WBACK"
  when "" then chr = "LDEL"
  when "\r" then chr = "ENTER"
  when "\t" then chr = "TAB"
  when /[[:print:]]/  then chr = c
  else chr = ""
  end
  stdin_clear
  return chr
end
def getstr # A custom Readline-like function
  @stk  = 0
  @pos  = 0
  chr   = ""
  @history.unshift("")
  while chr != "ENTER" # Keep going with readline until user presses ENTER
    @ci   = nil
    lift  = false
    right = false
    @c.clear_line
    print @prompt
    row, @pos0 = @c.pos
    #@history[0] = "" if @history[0].nil?
    print cmd_check(@history[0])
    @ci  = @history[1..].find_index {|e| e =~ /^#{Regexp.escape(@history[0].to_s)}./}
    unless @ci == nil
      @ci += 1
      @ciprompt = @history[@ci][@history[0].to_s.length..].to_s
    end
    if @history[0].to_s.length > 1 and @ci
      print @ciprompt.c(@c_stamp)
      right = true
    end
    @c.col(@pos0 + @pos)
    chr = getchr
    case chr
    when 'C-G', 'C-C'
      @history[0] = "" 
      @pos = 0
    when 'C-E'   # Ctrl-C exits gracefully but without updating .rshrc
      print "\n"
      exit
    when 'C-D'   # Ctrl-D exits after updating .rshrc
      rshrc
      exit
    when 'C-L'   # Clear screen and set position to top of the screen
      @c.row(1)
      @c.clear_screen_down
    when 'UP'    # Go up in history
      if @stk == 0 and @history[0].length > 0
        @tabsearch = @history[0]
        tab("hist")
      else
        if lift
          @history.unshift("")
          @history[0] = @history[@stk].dup
          @stk += 1 
        end
        unless @stk >= @history.length - 1
          @stk += 1 
          @history[0] = @history[@stk].dup
          @history[0] = "" unless @history[0]
          @pos = @history[0].length
        end
        lift = false
      end
    when 'DOWN'  # Go down in history
      if lift
        @history.unshift("")
        @history[0] = @history[@stk].dup
        @stk += 1 
      end
      if @stk == 0
        @history[0] = ""
        @pos = 0
      elsif @stk == 1
        @stk -= 1 
        @history[0] = ""
        @pos = 0
      else
        @stk -= 1 
        @history[0] = @history[@stk].dup
        @pos = @history[0].length
      end
      lift = false
    when 'RIGHT' # Move right on the readline
      if right 
        if lift
          @history.unshift("")
          @history[0] = @history[@stk].dup
          @stk += 1 
        end
        @history[0] = @history[@ci].dup
        @pos = @history[0].length
      end
      @pos += 1 unless @pos >= @history[0].length
    when 'LEFT'  # Move left on the readline
      @pos -= 1 unless @pos <= 0
    when 'HOME'  # Go to beginning of the readline
      @pos = 0
    when 'END'   # Go to the end of the readline
      @pos = @history[0].length
    when 'DEL'   # Delete one character
      @history[0][@pos] = ""
      lift = true
    when 'BACK'  # Delete one character to the left
      unless @pos <= 0
        @pos -= 1
        @history[0][@pos] = ""
      end
      lift = true
    when 'WBACK' # Delete one word to the left (Ctrl-W)
      unless @pos == @pos0
        until @history[0][@pos - 1] == " " or @pos == 0
          @pos -= 1
          @history[0][@pos] = ""
        end
        if @history[0][@pos - 1] == " "
          @pos -= 1
          @history[0][@pos] = ""
        end
      end
      lift = true
    when 'C-Y'   # Copy command line to primary selection
      system("echo -n '#{@history[0]}' | xclip")
      puts "\n#{Time.now.strftime("%H:%M:%S")}: Copied to primary selection (paste with middle buttoni)".c(@c_stamp)
    when 'C-K'   # Kill/delete that entry in the history
      @history.delete_at(@stk)
      @stk -= 1
      if @stk == 0
        @history[0] = "" 
        @pos = 0
      else
        @history[0] = @history[@stk].dup
        @history[0] = "" unless @history[0]
        @pos = @history[0].length
      end
    when 'LDEL'  # Delete readline (Ctrl-U)
      @history[0] = ""
      @pos = 0
      lift = true
    when 'TAB'   # Tab completion of dirs and files
      @ci = nil
      #@tabsearch =~ /^-/ ? tabbing("switch") : tabbing("all")
      tab("all")
      lift = true
    when 'S-TAB'
      @ci = nil
      tabbing("hist")
      lift = true
    when /^.$/
      @history[0].insert(@pos,chr)
      @pos += 1
      lift = true
    end
    while $stdin.ready?
      chr = $stdin.getc
      @history[0].insert(@pos,chr)
      @pos += 1
    end
  end
  @c.col(@pos0 + @history[0].length)
  @c.clear_screen_down
end

def tab(type)
  i = 0
  chr = ""
  @tabarray = []
  @pretab = @history[0][0...@pos].to_s        # Extract the current line up to cursor
  @postab = @history[0][@pos..].to_s          # Extract the current line from cursor to end
  @c_row, @c_col = @c.pos                     # Get cursor position
  @tabstr = @pretab.split(/[|, ]/).last.to_s  # Get the sustring that is being tab completed
  @tabstr = "" if @pretab[-1] =~ /[ |]/
  @pretab = @pretab.delete_suffix(@tabstr)
  type = "switch" if @tabstr[0] == "-"
  while chr != "ENTER"
    case type
    when "hist"         # Handle history completions ('UP' key)
      @tabarray = @history.select {|el| el =~ /#{@tabstr}/} # Select history items matching @tabstr
      @tabarray.shift   # Take away @history[0]
      return if @tabarray.empty?
    when "switch"
      cmdswitch = @pretab.split(/[|, ]/).last.to_s
      hlp = `#{cmdswitch} --help 2>/dev/null`
      hlp = hlp.split("\n").grep(/^\s*-{1,2}[^-]/)
      hlp = hlp.map{|h| h.sub(/^\s*/, '').sub(/^--/, '    --')}
      hlp = hlp.reject{|h| /-</ =~ h}
      @tabarray = hlp
    when "all"          # Handle all other tab completions
      exe = []
      @path.each do |p| # Add all executables in @path
        Dir.glob(p).each do |c|
          exe.append(File.basename(c)) if File.executable?(c) and not Dir.exist?(c)
        end
      end
      exe.sort!
      exe.prepend(*@nick.keys)        # Add nicks
      exe.prepend(*@gnick.keys)       # Add gnicks
      compl      = exe.select {|s| s =~ Regexp.new(@tabstr)} # Select only that which matches so far
      fdir       = @tabstr + "*"
      compl.prepend(*Dir.glob(fdir)).map! do |e| 
        if e =~ /(?<!\\) / 
          e = e.sub(/(.*\/|^)(.*)/, '\1\'\2\'') unless  e =~ /'/
        end
        Dir.exist?(e) ? e + "/" : e   # Add matching dirs
      end
      @tabarray = compl               # Finally put it into @tabarray
    end
    return if @tabarray.empty?
    @tabarray.delete("")                                      # Don't remember why
    @c.clear_screen_down                                      # Here we go
    @tabarray.length.to_i - i < 5 ? l = @tabarray.length.to_i - i : l = 5 # Max 5 rows of completion items
    l.times do |x|                                            # Iterate through
      if x == 0                                               # First item goes onto the commandline
        @c.clear_line                                         # Clear the line
        tabchoice = @tabarray[i]                              # Select the item from the @tabarray
        tabchoice = tabchoice.sub(/\s*(-.*?)[,\s].*/, '\1') if type == "switch"
        @newhist0 = @pretab + tabchoice + @postab             # Remember now the new value to be given to @history[0]
        line1     = cmd_check(@pretab).to_s                   # Syntax highlight before @tabstr
        line2     = cmd_check(@postab).to_s                   # Syntax highlight after  @tabstr
        # Color and underline the current tabchoice on the commandline:
        tabline   = tabchoice.sub(/(.*)#{@tabstr}(.*)/, '\1'.c(@c_tabselect) + @tabstr.u.c(@c_tabselect) + '\2'.c(@c_tabselect))
        print @prompt + line1 + tabline + line2               # Print the commandline
        @pos   = @pretab.length.to_i + tabchoice.length.to_i  # Set the position on that commandline
        @c_col = @pos0 + @pos                                 # The cursor position must include the prompt as well
        @c.col(@c_col)                                        # Set the cursor position
        nextline                                              # Then start showing the completion items
        tabline  = @tabarray[i]                               # Get the next matching tabline
        # Can't nest ANSI codes, they must each complete/conclude or they will mess eachother up
        tabline1 = tabline.sub(/(.*?)#{@tabstr}.*/, '\1').c(@c_tabselect) # Color the part before the @tabstr
        tabline2 = tabline.sub(/.*?#{@tabstr}(.*)/, '\1').c(@c_tabselect) # Color the part after the @tabstr
        print " " + tabline1 + @tabstr.c(@c_tabselect).u + tabline2       # Color & underline @tabstr
      else
        begin
          tabline = @tabarray[i+x]    # Next tabline, and next, etc (usually 4 times here)
          tabline1 = tabline.sub(/(.*?)#{@tabstr}.*/, '\1').c(@c_taboption) # Color before @tabstr
          tabline2 = tabline.sub(/.*?#{@tabstr}(.*)/, '\1').c(@c_taboption) # Color after @tabstr
          print " " + tabline1 + @tabstr.c(@c_taboption).u + tabline2       # Print the whole line
        rescue
        end
      end
      nextline      # To not run off screen
    end
    @c.row(@c_row)  # Set cursor row to commandline
    @c.col(@c_col)  # Set cursor col on commandline 
    chr = getchr    # Now get user input
    case chr        # Treat the keypress
    when 'C-G', 'C-C', 'ESC'
      tabend; return
    when 'DOWN'
      i += 1 unless i > @tabarray.length.to_i - 2
    when 'UP'
      i -= 1 unless i == 0
    when 'TAB', 'RIGHT'  # Effectively the same as ENTER 
      chr = "ENTER"
    when 'BACK', 'LEFT'  # Delete one character to the left
      if @tabstr == ""
        @history[0] = @pretab + @postab
        tabend
        return 
      end
      @tabstr.chop!
    when 'WBACK' # Delete one word to the left (Ctrl-W)
      if @tabstr == ""
        @history[0] = @pretab + @postab
        tabend
        return 
      end
      @tabstr.sub!(/#{@tabstr.split(/[|, ]/).last}.*/, '')
    when ' '
      @tabstr += " "
      chr = "ENTER"
    when /^[[:print:]]$/
      @tabstr += chr
      i = 0
    end
  end
  @c.clear_screen_down
  @c.row(@c_row)
  @c.col(@c_col)
  @history[0] = @newhist0
end
def nextline # Handle going to the next line in the terminal
  row, col = @c.pos
  if row == @maxrow
    @c.scroll_down
    @c_row -= 1
  end
  @c.next_line
end
def tabend
  @c.clear_screen_down
  @pos = @history[0].length
  @c_col = @pos0 + @pos
  @c.col(@c_col)
end
def hist_clean # Clean up @history
  @history.uniq!
  @history.compact!
  @history.delete("")
end
def cmd_check(str) # Check if each element on the readline matches commands, nicks, paths; color them
  return if str.nil?
  str.gsub(/(?:\S'[^']*'|[^ '])+/) do |el|
    if @nick.include?(el)
      el.c(@c_nick)
    elsif el == "r" or el == "f"
      el.c(@c_nick)
    elsif @gnick.include?(el)
      el.c(@c_gnick)
    elsif File.exist?(el.gsub("'", ""))
      el.c(@c_path)
    elsif system "which #{el}", %i[out err] => File::NULL
      el.c(@c_cmd)
    elsif el == "cd"
      el.c(@c_cmd)
    elsif el[0] == "-"
      el.c(@c_switch)
    else
      el
    end
  end
end
def rshrc # Write updates to .rshrc
  hist_clean
  if File.exist?(Dir.home+'/.rshrc')
    conf = File.read(Dir.home+'/.rshrc')
  else
    conf = ""
  end
  conf.sub!(/^@nick.*\n/, "") 
  conf += "@nick = #{@nick}\n"
  conf.sub!(/^@gnick.*\n/, "") 
  conf += "@gnick = #{@gnick}\n"
  conf.sub!(/^@history.*\n/, "") 
  conf += "@history = #{@history.last(@histsize)}\n"
  File.write(Dir.home+'/.rshrc', conf)
  puts "\n.rshrc updated"
end

# RSH FUNCTIONS
def help
  puts @help
end
def version
  puts "rsh version = #{@version} (latest RubyGems version is #{Gem.latest_version_for("ruby-shell").version} - https://github.com/isene/rsh)"
end
def history # Show most recent history (up to 50 entries)
  puts "History:"
  @history.each_with_index {|h,i| puts i.to_s + "; " + h if i < 50}
end
def rmhistory # Delete history
  @history = []
  puts "History deleted."
end
def nick(nick_str)  # Define a new nick like this: `:nick "ls = ls --color"`
  if nick_str.match(/^\s*-/)
    source = nick_str.sub(/^\s*-/, '')
    @nick.delete(source)
  else
    source = nick_str.sub(/ =.*/, '')
    target = nick_str.sub(/.*= /, '')
    @nick[source] = target
  end
  rshrc
end
def gnick(nick_str) # Define a generic/global nick to match not only commands (format like nick)
  if nick_str.match(/^\s*-/)
    source = nick_str.sub(/^\s*-/, '')
    @gnick.delete(source)
  else
    source = nick_str.sub(/ =.*/, '')
    target = nick_str.sub(/.*= /, '')
    @gnick[source] = target
  end
  rshrc
end
def nick? # Show nicks
  puts "  Command nicks:".c(@c_nick)
  @nick.sort.each {|key, value| puts "  #{key} = #{value}"}
  puts "  General nicks:".c(@c_gnick)
  @gnick.sort.each {|key, value| puts "  #{key} = #{value}"}
end
def dirs
  puts "Past direactories:"
  @dirs.each_with_index do |e,i|
    puts "#{i}: #{e}"
  end
end

# INITIAL SETUP
begin # Load .rshrc and populate @history
  trap "SIGINT" do end
  firstrun unless File.exist?(Dir.home+'/.rshrc') # Initial loading - to get history
  load(Dir.home+'/.rshrc') 
  ENV["SHELL"] = __FILE__
  ENV["TERM"]  = "rxvt-unicode-256color"
  ENV["PATH"]  ? ENV["PATH"] += ":" : ENV["PATH"] = ""
  ENV["PATH"] += "/home/#{@user}/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  if @lscolors and File.exist?(@lscolors)
    ls = File.read(@lscolors) 
    ls.sub!(/export.*/, '')
    ls.sub!(/^LS_COLORS=/, 'ENV["LS_COLORS"]=')
    eval(ls)
  end
  @c = Cursor               # Initiate @c as Cursor
  @c.save                   # Get max row & col
  @c.row(8000)
  @c.col(8000)
  @maxrow, @maxcol = @c.pos
  @c.restore                # Max row & col gotten, cursor restored
  hist_clean                # Remove duplicates, etc
  @path.map! {|p| p + "/*"} # Set proper format for path search
end

# MAIN PART
loop do 
  begin
    @user = Etc.getpwuid(Process.euid).name # For use in @prompt
    @node = Etc.uname[:nodename]            # For use in @prompt
    h = @history; load(Dir.home+'/.rshrc') if File.exist?(Dir.home+'/.rshrc'); @history = h # reload prompt but not history
    @prompt.gsub!(/#{Dir.home}/, '~') # Simplify path in prompt
    system("printf \"\033]0;rsh: #{Dir.pwd}\007\"")   # Set Window title to path 
    @history[0] = "" unless @history[0]
    getstr # Main work is here
    @cmd = @history[0]
    @dirs.unshift(Dir.pwd)
    @dirs.pop
    hist_clean # Clean up the history
    @cmd = "ls" if @cmd == "" # Default to ls when no command is given
    if @cmd.match(/^!\d+/)
      hi = @history[@cmd.sub(/^!(\d+)$/, '\1').to_i+1] 
      @cmd = hi if hi
    end
    print "\n"; @c.clear_screen_down
    if @cmd == "r" # Integration with rtfm (https://github.com/isene/RTFM)
      t  = Time.now
      t0 = t.nsec.to_s
      tf = "/tmp/.rshpwd" + t0
      File.write(tf, Dir.pwd)
      system("rtfm #{tf}")
      Dir.chdir(File.read(tf))
      File.delete(tf)
      system("git status .") if Dir.exist?(".git")
      next
    end
    if @cmd =~ /^\=/ # Integration with xrpn (https://github.com/isene/xrpn)
      @cmd.gsub!("  ", ",")
      @cmd = "echo \"#{@cmd[1...]},prx,off\" | xrpn" 
    end
    if @cmd.match(/^\s*:/) # Ruby commands are prefixed with ":"
      begin
        eval(@cmd[1..-1])
      #rescue StandardError => err
      rescue Exception => err
        puts "\n#{err}"
      end
    elsif @cmd == '#' # List previous directories
      dirs
    else # Execute command
      ca = @nick.transform_keys {|k| /((^\K\s*\K)|(\|\K\s*\K))\b(?<!-)#{Regexp.escape k}\b/}
      @cmd = @cmd.gsub(Regexp.union(ca.keys), @nick)
      ga = @gnick.transform_keys {|k| /\b(?<!-)#{Regexp.escape k}\b/}
      @cmd = @cmd.gsub(Regexp.union(ga.keys), @gnick)
      @cmd = "~" if @cmd == "cd"
      @cmd.sub!(/^cd (\S*).*/, '\1')
      @cmd = Dir.home if @cmd == "~"
      @cmd = @dirs[1] if @cmd == "-"
      @cmd = @dirs[@cmd.to_i] if @cmd =~ /^\d$/
      dir  = @cmd.strip.sub(/~/, Dir.home)
      if Dir.exist?(dir)
        Dir.chdir(dir) 
        system("git status .") if Dir.exist?(".git")
      else
        puts "#{Time.now.strftime("%H:%M:%S")}: #{@cmd}".c(@c_stamp)
        if @cmd == "f" # fzf integration (https://github.com/junegunn/fzf)
          res = `fzf`.chomp
          Dir.chdir(File.dirname(res))
        elsif File.exist?(@cmd) and not File.executable?(@cmd)
          if File.read(@cmd).force_encoding("UTF-8").valid_encoding?
            system("#{ENV['EDITOR']} #{@cmd}") # Try open with user's editor
          else
            if @runmailcap
              Thread.new { system("run-mailcap #{@cmd} 2>/dev/null") }
            else
              Thread.new { system("xdg-open #{@cmd} 2>/dev/null") }
            end
          end
        else 
          begin
            pre_cmd
            puts " Not executed: #{@cmd}" unless system (@cmd) # Try execute the command
            post_cmd
          rescue StandardError => err
            puts "\n#{err}"
          end
        end
      end
    end
  rescue StandardError => err # Throw error nicely
    puts "\n#{err}"
  end
end

# vim: set sw=2 sts=2 et fdm=syntax fdn=2 fcs=fold\:\ :
