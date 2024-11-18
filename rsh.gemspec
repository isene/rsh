Gem::Specification.new do |s|
  s.name        = 'ruby-shell'
  s.version     = '2.6.2'
  s.licenses    = ['Unlicense']
  s.summary     = "rsh - Ruby SHell"
  s.description = "A shell written in Ruby with extensive tab completions, aliases/nicks, history, syntax highlighting, theming, auto-cd, auto-opening files and more. In continual development. New in 2.0: Full rewrite of tab completion engine. Lots of other bug fixes. 2.6: Handling line longer than terminal width. 2.6.2: Fixed issue with tabbing at bottom of screen."
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["bin/rsh", "README.md", ".rshrc"]
  s.executables << 'rsh'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/rsh" }
end
