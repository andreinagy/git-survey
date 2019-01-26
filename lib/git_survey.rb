require 'time'
require 'json'
require 'digest'

require 'git_survey/version'
require 'git_survey/arguments_parser.rb'

module GitSurvey

# Private helpers
def self._run_shell_command(directory, cmd)
  result = `cd #{directory}; #{cmd}`
  result
end

def self._date_at_the_end_of(string)
  string.split(' ').last
end

def self._anonymized(anonymize, string)
  if anonymize
    Digest::MD5.hexdigest(string)[0...10]
  else
    string
  end
end

def self._key_value_hash(anonymized, directory, command, split_char)
  list = _run_shell_command(directory, command)
         .split("\n")

  result = {}
  list.each do |line|
    parts = line.split(split_char)
    key = parts.last
    value = parts.first

    key = key == value ? 'empty' : _anonymized(anonymized, key)

    result[key] = value.to_i
  end
  result
end

# basename `git rev-parse --show-toplevel`
def self.repo_name(anonimize, directory)
  name = _run_shell_command(directory, 'basename `git rev-parse --show-toplevel`').strip
  _anonymized(anonimize, name)
end

# git log --date=iso8601-strict --reverse |head -3 |grep "Date"
def self.init_date(directory)
  command = 'git log --date=iso8601-strict --reverse |head -3 |grep "Date"'
  string = _run_shell_command(directory, command)
  Time.iso8601(_date_at_the_end_of(string))
end

# git log --date=iso8601-strict |head -3 |grep "Date"
def self.latest_activity_date(directory)
  command = 'git log --date=iso8601-strict |head -3 |grep "Date"'
  string = _run_shell_command(directory, command)
  Time.iso8601(_date_at_the_end_of(string))
end

def self.activity_interval(directory)
  earliest = init_date(directory).to_f
  latest = latest_activity_date(directory).to_f

  diff = latest - earliest
  (diff / (365 * 24 * 60 * 60)).round(2)
end

# git rev-list --count <revision>
def self.number_of_commits(directory, branch)
  _run_shell_command(directory, 'git rev-list --count ' + branch).to_i
end

#  git ls-files | wc -l
def self.number_of_files(directory)
  _run_shell_command(directory, 'git ls-files | wc -l').to_i
end

# git branch | wc -l
def self.number_of_branches(directory)
  _run_shell_command(directory, 'git branch | wc -l').to_i
end

# git shortlog -s -n
def self.authors(anonymized, directory)
  _key_value_hash(anonymized, directory, 'git shortlog -s -n', "\t")
end

# git log --pretty=format: --name-only | sort | uniq -c | sort -rg | head -10
def self.hot_files(anonymized, directory, number)
  command = "git log --pretty=format: --name-only | sort | uniq -c | sort -rg | head -#{number}"
  _key_value_hash(anonymized, directory, command, ' ')
end

# Main

def self.main(argv)
  options = Parser.parse(ARGV)

  # Google JSON Style Guide (camel case for keys)
# https://google.github.io/styleguide/jsoncstyleguide.xml

result = {
  'surveyData' => {
    'date' => options.scan_date,
    'anonymized' => options.anonymize,
    'branch' => options.git_branch
  },
  'repo' => {
    'name' => repo_name(options.anonymize, options.input_directory),
    'dateOfInit' => init_date(options.input_directory),
    'dateOfLatestActivity' => latest_activity_date(options.input_directory),
    'yearsWorkedOn' => activity_interval(options.input_directory),
    'numberOfFiles' => number_of_files(options.input_directory),
    'numberOfCommits' => number_of_commits(options.input_directory,
                                           options.git_branch),
    'numberOfBranches' => number_of_branches(options.input_directory)
  },
  'hotFiles' => hot_files(options.anonymize, options.input_directory, options.number_of_hotfiles),
  'authors' => authors(options.anonymize, options.input_directory)
}

puts JSON.pretty_generate(result)

exit 0
end

end
