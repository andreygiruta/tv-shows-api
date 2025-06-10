ENV["RAILS_ENV"] ||= "test"

# Start SimpleCov before loading application code
require "simplecov"
SimpleCov.start "rails" do
  add_filter "/bin/"
  add_filter "/db/"
  add_filter "/spec/" # if using RSpec
  add_filter "/test/"

  add_group "Controllers", "app/controllers"
  add_group "Models", "app/models"
  add_group "Services", "app/services"
  add_group "Jobs", "app/jobs"

  minimum_coverage 70
  # Allow some files to have lower coverage (configuration, etc.)
  # minimum_coverage_by_file 60
end

require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Disable parallel testing for better SimpleCov coverage tracking
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
