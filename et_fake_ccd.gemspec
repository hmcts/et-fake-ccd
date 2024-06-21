
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "et_fake_ccd/version"

Gem::Specification.new do |spec|
  spec.name          = "et_fake_ccd"
  spec.version       = EtFakeCcd::VERSION
  spec.authors       = ["Gary Taylor"]
  spec.email         = ["gary.taylor@hmcts.net"]

  spec.summary       = %q{Fake CCD server for employment tribunals}
  spec.description   = %q{Fake CCD server for employment tribunals}
  spec.homepage      = "https://github.com/hmcts/et-fake-ccd"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'roda', '~> 3.21'
  spec.add_dependency 'roda-enhanced_logger', '~> 0.5.0'

  spec.add_dependency 'thor', '~> 1.0'
  spec.add_dependency 'activemodel', '~> 7.0'
  spec.add_dependency 'rotp', '~> 6.2'
  spec.add_dependency 'tilt', '~> 2.0', '>= 2.0.9'
  spec.add_dependency 'puma', '~> 6.4'
  spec.add_dependency 'json-schema', '~> 4.1.1'

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
end
