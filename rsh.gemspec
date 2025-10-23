Gem::Specification.new do |s|
  s.name        = 'ruby-shell'
  s.version     = '3.3.0'
  s.licenses    = ['Unlicense']
  s.summary     = "rsh - Ruby SHell"
  s.description = "A shell written in Ruby with extensive tab completions, aliases/nicks, history, syntax highlighting, theming, auto-cd, auto-opening files and more. UPDATE v3.3.0: QUOTE-LESS SYNTAX - No quotes needed! Parametrized nicks with {{placeholders}} - :nick gp=git push {{branch}}, use: gp branch=main. Ctrl-G multi-line editing in $EDITOR. Custom validation rules. Full bash shell script support. Simpler, cleaner, more powerful!"
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["bin/rsh", "README.md", "PLUGIN_GUIDE.md", ".rshrc"]
  s.executables << 'rsh'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/rsh" }
end
