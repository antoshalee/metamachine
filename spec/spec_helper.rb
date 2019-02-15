require 'metamachine'

%w[
  /models/*.rb
  /support/**/*.rb
].each do |path|
  Dir[File.dirname(__FILE__) + path].each { |f| require f }
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.example_status_persistence_file_path = '.rspec_status'
  config.order = :random
  config.disable_monkey_patching!
end

