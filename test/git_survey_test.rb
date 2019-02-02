require 'test_helper'

SCRIPT = './bin/git-survey'.freeze

# switch this on to create reference files.
GENERATE_REFERENCES = false

def generate_reference_if_needed(args, file)
  `#{SCRIPT} #{args} > #{file}` if GENERATE_REFERENCES
end

def diff_output_to_reference(args, file)
  string = `#{SCRIPT} #{args} | diff #{file} -`
  assert string.empty?
end

def test(title, args, reference_file)
  puts
  puts title
  generate_reference_if_needed(args, reference_file)
  diff_output_to_reference(args, reference_file)
end

def make_references
     puts 'make references'
end

class GitSurveyTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::GitSurvey::VERSION
  end

  def test_diffs_to_reference
    puts '------- Tests ----------'

    test('--- Test no arguments prints help',
         '',
         'test/test_references/help.txt')

    test('--- Test help argument',
         '-h',
         'test/test_references/help.txt')

    test('--- Test invalid argument',
         '-z',
         'test/test_references/invalid_argument.txt')

    test('--- Test default arguments',
         '-t now ../fixtures/test_repo/Eureka/',
         'test/test_references/eureka_master.txt')

    test('--- Test certain branch',
         '-b new_branch -t now ../fixtures/test_repo/Eureka/',
         'test/test_references/eureka_new_branch.txt')

    test('--- Test no arguments prints help',
         '-n 3 -t now ../fixtures/test_repo/Eureka/',
         'test/test_references/eureka_master_3hotfiles.txt')

    test('--- Test no arguments prints help',
         '-a -t now ../fixtures/test_repo/Eureka/',
         'test/test_references/eureka_master_anonymized.txt')
  end
end
