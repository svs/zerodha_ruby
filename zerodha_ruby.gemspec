lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "zerodha_ruby/version"

Gem::Specification.new do |spec|
  spec.name          = "zerodha_ruby"
  spec.version       = Zerodha::VERSION
  spec.authors       = ["Siddharth Sharma"]
  spec.email         = ["siddharth.sharma@peopleinteractive.in"]

  spec.summary       = %q{Ruby gem for Zerodha}
  spec.homepage      = "https://github.com/svs/zerodha-ruby"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = "https://github.com/svs/zerodha-ruby"
  spec.metadata["source_code_uri"] = "https://github.com/svs/zerodha-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/svs/zerodha-ruby"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "pry-byebug"

  spec.add_dependency "httparty"
  spec.add_dependency "redis"
end
