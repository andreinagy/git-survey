require 'test_helper'

class GitSurveyTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::GitSurvey::VERSION
  end

  def test_it_does_something_useful
    assert true
  end

  def test_it_does_something_useful_other
    assert ::GitSurvey::VERSION == '0.1.0'
  end

  def test_a_fun_from_the_module
    assert ::GitSurvey.someFunc1 == 3
  end
end
