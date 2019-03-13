lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metamachine/version'

Gem::Specification.new do |spec|
  spec.name          = 'metamachine'
  spec.version       = Metamachine::VERSION
  spec.authors       = ['Anton Lee']
  spec.email         = ['antoshalee@gmail.com']

  spec.summary       = 'Metamachine: state machine which does not change a state'
  spec.homepage      = 'https://github.com/antoshalee/metamachine'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency "concurrent-ruby"
  spec.add_runtime_dependency "def_initialize"

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end