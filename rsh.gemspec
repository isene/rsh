Gem::Specification.new do |s|
  s.name        = 'ruby-shell'
  s.version     = '3.4.5'
  s.licenses    = ['Unlicense']
  s.summary     = "rsh - Ruby SHell"
  s.description = "A shell written in Ruby with extensive tab completions, aliases/nicks, history, syntax highlighting, theming, auto-cd, auto-opening files and more. UPDATE v3.4.5: FULL LS_COLORS COMPLIANCE - Prompt and command line now use LS_COLORS with pattern-based directory coloring. Configure @dir_colors like RTFM's @topmatch for visual project distinction. Plus v3.4.0: Completion learning, context-aware ranking, persistent patterns across sessions!"
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["bin/rsh", "README.md", "PLUGIN_GUIDE.md", ".rshrc"]
  s.executables << 'rsh'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/rsh" }
end
