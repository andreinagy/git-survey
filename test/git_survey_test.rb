require 'test_helper'
require_relative 'make_test_references'

SCRIPT = './bin/git-survey'.freeze

def assert_output_equal(args, file)
  string = `#{SCRIPT} #{args} | diff #{file} -`

  # check that there is no difference
  assert string.empty?
end

class GitSurveyTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::GitSurvey::VERSION
  end

  def test_diffs_to_reference
    REFERENCE_DATA.each do |item|
      puts item[0]
      assert_output_equal(item[1], item[2])
    end
  end
end
