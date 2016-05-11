# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'udrs/version'

Gem::Specification.new do |spec|
  spec.name          = 'udrs'
  spec.version       = Udrs::VERSION
  spec.authors       = ['Michon van Dooren']
  spec.email         = ['michon1992@gmail.com']

  spec.summary       = %q{Simple templates to generate documents in various formats.}
  spec.homepage      = 'https://github.com/MaienM/UDRS'
  spec.license       = 'MIT'

  spec.files         = Dir.glob('lib/**/**/*') + %w(udrs.gemspec LICENSE.txt README.md)
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'attribute_predicates', '~> 0.2'
  spec.add_dependency 'barby', '~> 0.6'
  spec.add_dependency 'facets', '~> 3'
  spec.add_dependency 'prawn', '~> 2'
  spec.add_dependency 'prawn-table', '~> 0.2'
  spec.add_dependency 'rqrcode', '~> 0.9'
  spec.add_runtime_dependency 'rails', '~> 4'
  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
end
