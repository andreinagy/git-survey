SCRIPT = './bin/git-survey'.freeze

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
   '-t now ../fixtures/test_repo/Eureka/',
   'test/test_references/eureka_master.txt'],

  ['--- Test certain branch',
   '-b new_branch -t now ../fixtures/test_repo/Eureka/',
   'test/test_references/eureka_new_branch.txt'],

  ['--- Test no arguments prints help',
   '-n 3 -t now ../fixtures/test_repo/Eureka/',
   'test/test_references/eureka_master_3hotfiles.txt'],

  ['--- Test no arguments prints help',
   '-a -t now ../fixtures/test_repo/Eureka/',
   'test/test_references/eureka_master_anonymized.txt']
].freeze

def generate_one_reference(args, file)
  `#{SCRIPT} #{args} > #{file}`
end

def generate_references
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
  #   generate_one_reference(args, reference_file)
  diff_output_to_reference(args, reference_file)
end