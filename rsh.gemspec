Gem::Specification.new do |s|
  s.name        = 'ruby-shell'
  s.version     = '2.11.0'
  s.licenses    = ['Unlicense']
  s.summary     = "rsh - Ruby SHell"
  s.description = "A shell written in Ruby with extensive tab completions, aliases/nicks, history, syntax highlighting, theming, auto-cd, auto-opening files and more. UPDATE v2.11.0: Enhanced TAB completion with smart context-aware completion, frequency-based scoring, fuzzy matching, configurable options, and improved performance. v2.10.0: Auto-healing for corrupted .rshrc files and robust error handling. v2.9.0: AI integration! Use @ for AI text responses and @@ for AI command suggestions."
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["bin/rsh", "README.md", ".rshrc"]
  s.executables << 'rsh'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/rsh" }
end
