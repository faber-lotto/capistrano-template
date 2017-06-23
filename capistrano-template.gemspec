# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/template/version'

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-template'
  spec.version       = Capistrano::Template::VERSION
  spec.authors       = ['Dieter Späth']
  spec.email         = ['d.spaeth@faber.de']
  spec.summary       = %q(Erb-Template rendering and upload for capistrano 3)
  spec.description   = %q(A capistrano 3 plugin that aids in rendering erb templates and
uploads the content to the server if the file does not exists at
the remote host or the content did change)
  spec.homepage      = 'https://github.com/faber-lotto/capistrano-template'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.has_rdoc = 'yard'

  spec.required_ruby_version = '>= 2.0.0'
  spec.add_dependency 'capistrano', '~> 3.0'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'

  spec.add_development_dependency 'rspec', '3.5.0'
  # show nicely how many specs have to be run
  spec.add_development_dependency 'fuubar'
  # extended console
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-remote'
end
