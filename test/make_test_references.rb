SCRIPT = './bin/git-survey'.freeze
REPO = 'test/fixtures/test_repo/Eureka/'.freeze

REFERENCE_DATA = [
  ['--- Test no arguments prints help',
   '',
   'test/test_references/help.txt'],

  ['--- Test help argument',
   '-h',
   'test/test_references/help.txt'],

  ['--- Test invalid argument',
   '-z',
   'test/test_references/invalid_argument.txt'],

  ['--- Test default arguments',
   "-t now #{REPO}",
   'test/test_references/eureka_master.txt'],

  ['--- Test certain branch',
   "-b new_branch -t now #{REPO}",
   'test/test_references/eureka_new_branch.txt'],

  ['--- Test 3 hotfiles',
   "-n 3 -t now #{REPO}",
   'test/test_references/eureka_master_3hotfiles.txt'],

  ['--- Test anonymized',
   "-a -t now #{REPO}",
   'test/test_references/eureka_master_anonymized.txt']
].freeze

def generate_one_reference(args, file)
  `#{SCRIPT} #{args} > #{file}`
end

def make_test_references
  puts `pwd`
  REFERENCE_DATA.each do |item|
    generate_one_reference(item[1], item[2])
    puts "Generated file #{item[2]}"
  end
end

def diff_output_to_reference(args, file)
  string = `#{SCRIPT} #{args} | diff #{file} -`
  assert string.empty?
end

def test(title, args, reference_file)
  puts
  puts title
  diff_output_to_reference(args, reference_file)
end
