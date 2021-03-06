# encoding: utf-8

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'rubocop'
require 'rubocop/cli'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

module ExitCodeMatchers
  RSpec::Matchers.define :exit_with_code do |code|
    actual = nil
    match do |block|
      begin
        block.call
      rescue SystemExit => e
        actual = e.status
      end
      actual and actual == code
    end
    failure_message_for_should do |block|
      "expected block to call exit(#{code}) but exit" +
        (actual.nil? ? ' not called' : "(#{actual}) was called")
    end
    failure_message_for_should_not do |block|
      "expected block not to call exit(#{code})"
    end
    description do
      "expect block to call exit(#{code})"
    end
  end
end

RSpec.configure do |config|
  config.filter_run_excluding ruby: ->(v) { !RUBY_VERSION.start_with?(v.to_s) }

  config.expect_with :rspec do |c|
    c.syntax = :expect # disables `should`
  end

  config.include(ExitCodeMatchers)
end

def inspect_source(cop, file, source)
  tokens, sexp, correlations = Rubocop::CLI.rip_source(source)
  cop.correlations = correlations
  cop.inspect(file, source, tokens, sexp)
end
