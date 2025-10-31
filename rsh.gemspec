Gem::Specification.new do |s|
  s.name        = 'ruby-shell'
  s.version     = '3.6.0'
  s.licenses    = ['Unlicense']
  s.summary     = "rsh - Ruby SHell"
  s.description = "A shell written in Ruby with extensive tab completions, aliases/nicks, history, syntax highlighting, theming, auto-cd, auto-opening files and more. UPDATE v3.6.0: MULTI-LINE PROMPT SUPPORT - Complete readline refactor with rcurses-inspired ANSI handling. Define prompts with newlines! Plus nick/history export, 9 new completions, validation templates, startup tips, and critical performance fixes for huge PATHs!"
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["bin/rsh", "README.md", "PLUGIN_GUIDE.md", ".rshrc"]
  s.executables << 'rsh'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/rsh" }
end
