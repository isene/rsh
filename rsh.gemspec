Gem::Specification.new do |s|
  s.name        = 'ruby-shell'
  s.version     = '3.4.3'
  s.licenses    = ['Unlicense']
  s.summary     = "rsh - Ruby SHell"
  s.description = "A shell written in Ruby with extensive tab completions, aliases/nicks, history, syntax highlighting, theming, auto-cd, auto-opening files and more. UPDATE v3.4.0: COMPLETION LEARNING - Shell learns which TAB completions you use most and intelligently ranks them higher. Context-aware learning per command. :completion_stats shows patterns. Persistent across sessions. Plus all v3.3 features: quote-less syntax, parametrized nicks, Ctrl-G editing, validation rules, shell scripts!"
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["bin/rsh", "README.md", "PLUGIN_GUIDE.md", ".rshrc"]
  s.executables << 'rsh'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/rsh" }
end
