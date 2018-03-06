$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'simplecov'
require 'simplecov-rcov'
require 'codeclimate-test-reporter'

SimpleCov.start do
  formatter SimpleCov::Formatter::MultiFormatter.new([
                                                         SimpleCov::Formatter::HTMLFormatter,
                                                         SimpleCov::Formatter::RcovFormatter,
                                                         CodeClimate::TestReporter::Formatter])
  add_group('LocalePack', 'lib/locale_pack')
  add_group('Rake Tasks', 'lib/tasks')
  add_group('Specs', 'spec')
end

require 'factory_bot'
require 'rspec'
require 'yaml'

require 'locale_pack'
Dir["spec/support/**/*.rb"].each { |f| require File.expand_path(f) }

# Dir["spec/support/**/*.rb"].each { |f| require f }

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
# Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.before(:suite) do
    FactoryBot.find_definitions
    LocalePack.configure do |config|
      config.config_path = File.expand_path('spec/fixtures/locale_packs')
      config.locale_path = File.expand_path('spec/fixtures/locales')
      config.output_path = File.expand_path('spec/fixtures/public')
    end
  end

  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
