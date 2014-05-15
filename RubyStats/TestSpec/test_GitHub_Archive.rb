require 'test/unit'
require_relative '../Stack_Queries.rb'
require_relative '../GitHub_Archive.rb'

class Test_GitHub_Archive < Test::Unit::TestCase

  @Stats

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @Stats = RubyStats::GitHub_Archive.new
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    #TODO: add @Stats disconnect code
    #@Stats = nil
  end

  #TODO: flesh out the tests

  def test_averages
    avgs = @Stats.get_averages

    assert_not_nil(avgs)
  end

  def test_language_stats
    language_stats = @Stats.get_language_stats

    assert_not_nil(language_stats)
  end

  def test_ratios
    ratios = @Stats.get_ratios

    assert_not_nil(ratios)
  end

end