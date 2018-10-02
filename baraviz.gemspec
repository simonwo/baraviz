lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'baraviz/version'

Gem::Specification.new do |spec|
  spec.name          = 'baraviz'
  spec.version       = Baraviz::VERSION
  spec.authors       = ['Simon Worthington']
  spec.email         = ['simon@simonwo.net']

  spec.summary       = %q{Generates Graphviz diagrams of user journeys automatically during testing.}
  spec.homepage      = 'https://github.com/simonwo/baraviz'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'capybara', '>= 0.3.5'
  spec.add_dependency 'rgl', '>= 0.4'
  spec.add_dependency 'capybara-screenshot', '>= 1.0'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
end
