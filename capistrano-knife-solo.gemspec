# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-knife-solo'
  spec.version       = '0.0.1'
  spec.authors       = 'Robert Coleman'
  spec.email         = 'github@robert.net.nz'
  spec.summary       = %q{Use knife solo with Capistrano.}
  spec.description   = %q{Use knife solo with Capistrano.}
  spec.homepage      = 'https://github.com/rjocoleman/capistrano-knife-solo'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry'

  spec.add_dependency 'capistrano', '~> 3.1.0'
  spec.add_dependency 'knife-solo', '~> 0.4'
end
