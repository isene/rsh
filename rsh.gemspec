Gem::Specification.new do |s|
  s.name        = 'ruby-shell'
  s.version     = '3.2.0'
  s.licenses    = ['Unlicense']
  s.summary     = "rsh - Ruby SHell"
  s.description = "A shell written in Ruby with extensive tab completions, aliases/nicks, history, syntax highlighting, theming, auto-cd, auto-opening files and more. UPDATE v3.2.0: PLUGIN SYSTEM - Extensible architecture with lifecycle hooks (on_startup, on_command_before/after, on_prompt), extension points (add_completions, add_commands), plugin management, and 3 example plugins included. Plus colon command theming!"
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["bin/rsh", "README.md", "PLUGIN_GUIDE.md", ".rshrc"]
  s.executables << 'rsh'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/rsh" }
end
