require 'optparse'

# https://docs.ruby-lang.org/en/2.1.0/OptionParser.html
Options = Struct.new(:anonymize,
                     :git_branch,
                     :input_directory,
                     :number_of_hotfiles,
                     :scan_date)
# Parses command line arguments
class Parser
  def self.parse(argv)
    # If no arguments supplied, print help
    argv << '-h' if argv.empty?

    result = Options.new
    result.anonymize = false
    result.git_branch = 'master'
    result.number_of_hotfiles = 10
    result.scan_date = Time.now.iso8601(3)

    options_parser = OptionParser.new do |o|
      o.banner = 'Usage: git-survey.rb [options] [input directory]'

      o.on('-a',
           '--anonymize',
           "Anonymizes the output (#{result.anonymize})") do |v|
        result.anonymize = v
      end

      o.on('-bBRANCH',
           '--branch=BRANCH',
           "Git branch (#{result.git_branch})") do |v|
        result.git_branch = v
      end

      o.on('-nNUMBER',
           '--number=NUMBER',
           "Number of hot files to display (#{result.number_of_hotfiles})") do |v|
        result.number_of_hotfiles = v
      end

      o.on('-tTODAY',
           '--today=TODAY',
           "Today's date for testing purposes (string)") do |v|
        result.scan_date = v
      end

      o.on('-h',
           '--help',
           'Prints this help') do
        puts options_parser
        exit 0
      end
    end

    begin
      options_parser.parse!(argv)
    rescue StandardError => exception
      puts exception
      puts options_parser
      exit 1
    end

    result.input_directory = argv.pop
    if result.input_directory.nil? || !Dir.exist?(result.input_directory)
      puts 'Can\'t find directory ' + result.input_directory
      Parser.parse %w[--help]
      exit 0
    end

    result
  end
end
