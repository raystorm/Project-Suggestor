require 'test/unit'
require 'serel'
require_relative '../Stack_Queries.rb'
require_relative '../GitHub_Archive.rb'

class Test_Stack_Queries < Test::Unit::TestCase

  @Stack

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @Stack = RubyStats::Stack_Queries.new
    @Stack.config
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end


  def test_check_tag_valid
    language = @Stack.check_tag('C')
    assert_not_nil(language)
    assert_equal('C', language[0].name)
  end

  def test_check_tag_invalid
    language = @Stack.check_tag('ZZZzziuagtqwerfkjqwelhyrpoi') #hopefully never a language
    #assert_nil(language)
    assert_equal(0, language.length)
  end

  def test_get_questions_count
    result = @Stack.get_questions_count('Java')
    assert_not_nil(result)
  end

end