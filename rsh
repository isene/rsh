#!/usr/bin/env ruby
# encoding: utf-8
#
# SCRIPT INFO 
# Name:       rsh - Ruby SHell
# Language:   Pure Ruby, best viewed in VIM
# Author:     Geir Isene <g@isene.com>
# Web_site:   http://isene.com/
# Github:     https://github.com/isene/rsh
# License:    I release all copyright claims. This code is in the public domain.
#             Permission is granted to use, copy modify, distribute, and sell
#             this software for any purpose. I make no guarantee about the
#             suitability of this software for any purpose and I am not liable
#             for any damages resulting from its use. Further, I am under no
#             obligation to maintain or extend this software. It is provided 
#             on an 'as is' basis without any expressed or implied warranty.
@version    = "0.14"

# MODULES, CLASSES AND EXTENSIONS
class String # Add coloring to strings (with escaping for Readline)
  def c(code);  color(self, "\001\e[38;5;#{code}m\002"); end
  def b;        color(self, "\001\e[1m\002"); end
  def i;        color(self, "\001\e[3m\002"); end
  def u;        color(self, "\001\e[4m\002"); end
  def l;        color(self, "\001\e[5m\002"); end
  def color(text, color_code)  "#{color_code}#{text}\001\e[0m\002" end
end
module Cursor # Terminal cursor movement ANSI codes (thanks to https://github.com/piotrmurach/tty-cursor/tree/master)
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

# INITIALIZATION
begin # Requires
  require 'etc'
  require 'io/console'
  require 'io/wait'
end
begin # Initialization
  # Theming
  @c_prompt    = 196                      # Color for basic prompt
  @c_cmd       = 48                       # Color for valid command
  @c_nick      = 51                       # Color for matching nick
  @c_gnick     = 87                       # Color for matching gnick
  @c_path      = 208                      # Color for valid path
  @c_switch    = 148                      # Color for switches/options
  @c_tabselect = 207                      # Color for selected tabcompleted item
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
  @histsize    = 100                      # Max history if not set in .rshrc
  @hloaded     = false                    # Variable to determine if history is loaded
  # Use run-mailcap instead of xgd-open? Set = true in .rshrc if iyou want run-mailcap
  @runmailcap  = false
  # Variable initializations
  @dirs        = ["."]*10
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
    present that in "toned down" letters - press the arrow right key to accept the suggestion.
  * History with editing, search
  * Config file (.rshrc) updates on exit (with Ctrl-d) or not (with Ctrl-c)
  * Set of simple rsh specific commands like nick, nick?, history and rmhistory
  * rsh specific commands and full set of Ruby commands available via :<command>
  * All colors are themeable in .rshrc (see github link for possibilities)
  
  Special functions/integrations:
  * Use `r` to launch rtfm (https://github.com/isene/RTFM) - if you have it installed
  * Use `f` to launch fzf (https://github.com/junegunn/fzf) - if you have it installed
  * Use `=` followed by xrpn commands separated by commas (https://github.com/isene/xrpn)
  * Use `:` followed by a Ruby expression to access the whole world of Ruby
  Special commands:
  * `:nick 'll = ls -l'` to make a command alias (ll) point to a command (ls -l)
  * `:gnick 'h = /home/me'` to make a general alias (h) point to something (/home/me)
  * `:nick?` will list all command nicks and general nicks (you can edit your nicks in .rshrc)
  * `:history` will list the command history, while `:rmhistory` will delete the history
  * `:help` will display this help text
  
HELP

# GENERIC FUNCTIONS
def firstrun
  puts @help
  puts "Since there is no rsh configuration file (.rshrc), I will help you set it up to suit your needs.\n\n"
  puts "The prompt you see now is the very basic rsh prompt:"
  print "#{@prompt} (press ENTER)"
  STDIN.gets
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
  c = STDIN.getch
  case c
  when "\e"    # ANSI escape sequences
    case STDIN.getc
    when '['   # CSI
      case STDIN.getc
      when 'A' then chr = "UP"
      when 'B' then chr = "DOWN"
      when 'C' then chr = "RIGHT"
      when 'D' then chr = "LEFT"
      when 'Z' then chr = "S-TAB"
      when '2' then chr = "INS"    ; chr = "C-INS"    if STDIN.getc == "^"
      when '3' then chr = "DEL"    ; chr = "C-DEL"    if STDIN.getc == "^"
      when '5' then chr = "PgUP"   ; chr = "C-PgUP"   if STDIN.getc == "^"
      when '6' then chr = "PgDOWN" ; chr = "C-PgDOWN" if STDIN.getc == "^"
      when '7' then chr = "HOME"   ; chr = "C-HOME"   if STDIN.getc == "^"
      when '8' then chr = "END"    ; chr = "C-END"    if STDIN.getc == "^"
      end
    when 'O'   # Set Ctrl+ArrowKey equal to ArrowKey; May be used for other purposes in the future
      case STDIN.getc
      when 'a' then chr = "C-UP"
      when 'b' then chr = "C-DOWN"
      when 'c' then chr = "C-RIGHT"
      when 'd' then chr = "C-LEFT"
      end
    end
  when "", "" then chr = "BACK"
  when "" then chr = "C-C"
  when "" then chr = "C-D"
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
  end
  return chr
end
def getstr # A custom Readline-like function
  @stk  = 0
  @pos  = 0
  chr   = ""
  @history.insert(0, "")
  while chr != "ENTER" # Keep going with readline until user presses ENTER
    @ci   = nil
    right = false
    @c.clear_line
    print @prompt
    row, @pos0 = @c.pos
    print cmd_check(@history[0])
    @ci  = @history[1..].find_index {|e| e =~ /^#{Regexp.escape(@history[0])}/}
    @ci += 1 unless @ci == nil
    if @history[0].length > 2 and @ci
      print @history[@ci][@history[0].length..].to_s.c(@c_stamp)
      right = true
    end
    @c.col(@pos0 + @pos)
    chr = getchr
    case chr
    when 'C-G'
      @history[0] = "" 
      return
    when 'C-C'   # Ctrl-C exits gracefully but without updating .rshrc
      print "\n"
      exit
    when 'C-D'   # Ctrl-D exits after updating .rshrc
      rshrc
      exit
    when 'C-L'   # Clear screen and set position to top of the screen
      @c.row(1)
      @c.clear_screen_down
    when 'UP'    # Go up in history
      unless @stk >= @history.length - 1
        @stk += 1 
        @history[0] = @history[@stk].dup
        @pos = @history[0].length
      end
    when 'DOWN'  # Go down in history
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
    when 'RIGHT' # Move right on the readline
      if right 
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
    when 'BACK'  # Delete one character to the left
      unless @pos <= 0
        @pos -= 1
        @history[0][@pos] = ""
      end
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
    when 'C-K'   # Kill/delete that entry in the history
      @history.delete_at(@stk)
      @stk -= 1
      @history[0] = @history[@stk].dup
      @pos = @history[0].length
    when 'LDEL'  # Delete readline (Ctrl-U)
      @history[0] = ""
      @pos = 0
    when 'TAB'   # Tab completion of dirs and files
      @tabsearch =~ /^-/ ? tabbing("switch") : tabbing("all")
    when 'S-TAB'
      tabbing("hist")
    when /^.$/
      @history[0].insert(@pos,chr)
      @pos += 1
    end
    while STDIN.ready?
      chr = STDIN.getc
      @history[0].insert(@pos,chr)
      @pos += 1
    end
  end
end
def tabbing(type)
  @tabstr    = @history[@stk][0...@pos]
  @tabend    = @history[@stk][@pos..]
  elements   = @tabstr.split(" ")
  if @tabstr.match(" $")
    elements.append("")
    @tabsearch = ""
  else
    @tabsearch = elements.last.to_s
    @tabstr = @tabstr[0...-@tabsearch.length]
  end
  i = elements.length - 1
  if @tabsearch =~ /^-/
    until i == 0
      i -= 1
      if elements[i] !~ /^-/
        tab_switch(elements[i])
        break
      end
    end
  elsif type == 'all'
    tab_all(@tabsearch)
  elsif type == 'hist'
    tab_hist(@tabsearch)
  end
  @history[@stk] = @tabstr.to_s + @tabsearch.to_s + @tabend.to_s
end
def tab_all(str) # TAB completion for Dirs/files, nicks and commands
  exe = []
  @path.each do |p|
    Dir.glob(p).each do |c| 
      exe.append(File.basename(c)) if File.executable?(c) and not Dir.exist?(c)
    end
  end
  exe.prepend(*@nick.keys)
  exe.prepend(*@gnick.keys)
  compl      = exe.select {|s| s =~ Regexp.new("^" + str)}
  fdir       = str
  fdir      += "/" if Dir.exist?(fdir)
  fdir      += "*"
  compl.prepend(*Dir.glob(fdir))
  match      = tabselect(compl) unless compl.empty?
  @tabsearch = match if match
  @pos       = @tabstr.length + @tabsearch.length if match
end
def tab_switch(str) # TAB completion for command switches (TAB after "-")
  begin
    hlp = `#{str} --help`
    hlp = hlp.split("\n").grep(/^\s*-{1,2}[^-]/)
    hlp = hlp.map {|h| h.sub(/^\s*/, '')}
    switch = tabselect(hlp)
    switch = switch.sub(/ .*/, '').sub(/,/, '')
    @tabsearch = switch if switch
    @pos = @tabstr.length + @tabsearch.length
  rescue
  end
end
def tab_hist(str)
  sel  = @history.select {|el| el =~ /#{str}/}
  sel.delete("")
  hist = tabselect(sel, true)
  @tabsearch = hist if hist
  @pos       = @tabstr.length + @tabsearch.length if hist
end
def tabselect(ary, hist=false) # Let user select from the incoming array
  ary.uniq!
  @c_row, @c_col = @c.pos
  chr = ""
  i = 0
  while chr != "ENTER"
    @c.clear_screen_down
    ary.length - i < 5 ? l = ary.length - i : l = 5
    l.times do |x|
      tl = @tabsearch.length
      if x == 0
        @c.clear_line
        tabchoice = ary[i].sub(/(.*?)[ ,].*/, '\1')
        tabline   = "#{@prompt}#{cmd_check(@tabstr)}#{tabchoice.c(@c_tabselect)}#{@tabend}"
        print tabline # Full command line
        @c_col = @pos0 + @tabstr.length + tabchoice.length
        nextline
        print " " + ary[i].sub(/(.*?)#{@tabsearch}(.*)/, '\1'.c(@c_tabselect) + @tabsearch + '\2'.c(@c_tabselect))
      else
        begin
          print " " + ary[i+x].sub(/(.*?)#{@tabsearch}(.*)/, '\1'.c(@c_taboption) + @tabsearch + '\2'.c(@c_taboption))
        rescue
        end
      end
      nextline
    end
    @c.row(@c_row)
    @c.col(@c_col)
    chr = getchr
    case chr
    when 'C-G', 'C-C'
      @c.clear_screen_down
      return @tabsearch
    when 'DOWN'
      i += 1 unless i > ary.length - 2
    when 'UP'
      i -= 1 unless i == 0
    when 'TAB'
      chr = "ENTER"
    when 'BACK'
      if @tabsearch == ''
        @c.clear_screen_down
        return ""
      end
      @tabsearch.chop!
      hist ? tab_hist(@tabsearch) : tab_all(@tabsearch)
      return @tabsearch
    when /^[[:print:]]$/
      @tabsearch += chr
      hist ? tab_hist(@tabsearch) : tab_all(@tabsearch)
      return @tabsearch
    end
  end
  @c.clear_screen_down
  @c.row(@c_row)
  @c.col(@c_col)
  return ary[i]
end
def nextline # Handle going to the next line in the terminal
  row, col = @c.pos
  if row == @maxrow
    @c.scroll_down
    @c_row -= 1
  end
  @c.next_line
end
def hist_clean # Clean up @history
  @history.uniq!
  @history.compact!
  @history.delete("")
end
def cmd_check(str) # Check if each element on the readline matches commands, nicks, paths; color them
  str.gsub(/\S+/) do |el|
    if @nick.include?(el)
      el.c(@c_nick)
    elsif @gnick.include?(el)
      el.c(@c_gnick)
    elsif File.exist?(el.sub(/^~/, "/home/#{@user}"))
      el.c(@c_path)
    elsif system "which #{el}", %i[out err] => File::NULL
      el.c(@c_cmd)
    elsif el =~ /^-/
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
  puts ".rshrc updated"
end

# RSH FUNCTIONS
def help
  puts @help
end
def history # Show history
  puts "History:"
  puts @history
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
  @nick.each {|key, value| puts "  #{key} = #{value}"}
  puts "  General nicks:".c(@c_gnick)
  @gnick.each {|key, value| puts "  #{key} = #{value}"}
end
def dirs
  puts "Past direactories:"
  @dirs.each_with_index do |e,i|
    puts "#{i}: #{e}"
  end
end

# INITIAL SETUP
begin # Load .rshrc and populate @history
  trap "SIGINT" do print "\n"; exit end
  firstrun unless File.exist?(Dir.home+'/.rshrc') # Initial loading - to get history
  load(Dir.home+'/.rshrc') 
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
    getstr # Main work is here
    @cmd = @history[0]
    @dirs.unshift(Dir.pwd)
    @dirs.pop
    hist_clean # Clean up the history
    @cmd = "ls" if @cmd == "" # Default to ls when no command is given
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
    @cmd = "echo \"#{@cmd[1...]},prx,off\" | xrpn" if @cmd =~ /^\=/ # Integration with xrpn (https://github.com/isene/xrpn)
    if @cmd.match(/^\s*:/) # Ruby commands are prefixed with ":"
      begin
        eval(@cmd[1..-1])
      #rescue StandardError => err
      rescue Exception => err
        puts "\n#{err}"
      end
    elsif @cmd == '#'
      dirs
    else # Execute command
      ca = @nick.transform_keys {|k| /((^\K\s*\K)|(\|\K\s*\K))\b(?<!-)#{Regexp.escape k}\b/}
      @cmd = @cmd.gsub(Regexp.union(ca.keys), @nick)
      ga = @gnick.transform_keys {|k| /\b#{Regexp.escape k}\b/}
      @cmd = @cmd.gsub(Regexp.union(ga.keys), @gnick)
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
          res = `#{@cmd}`.chomp
          Dir.chdir(File.dirname(res))
        else
          if File.exist?(@cmd)
            if File.read(@cmd).force_encoding("UTF-8").valid_encoding?
              system("#{ENV['EDITOR']} #{@cmd}") # Try open with user's editor
            else
              if @runmailcap
                Thread.new { system("run-mailcap #{@cmd} 2>/dev/null") }
              else
                Thread.new { system("xdg-open #{@cmd} 2>/dev/null") }
              end
            end
          elsif system(@cmd) # Try execute the command
          else puts "No such command: #{@cmd}"
          end
        end
      end
    end
  rescue StandardError => err # Throw error nicely
    puts "\n#{err}"
  end
end

# vim: set sw=2 sts=2 et fdm=syntax fdn=2 fcs=fold\:\ :
