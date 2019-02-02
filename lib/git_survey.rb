require 'time'
require 'json'
require 'digest'

require 'git_survey/version'
require 'git_survey/arguments_parser.rb'
require 'git_survey/shell_adapter.rb'

EXECUTABLE_NAME = 'git-survey'.freeze

# Generates a report on a git project's history
module GitSurvey
  def self.executable_hash(options)
    {
      'date' => options.scan_date,
      'anonymized' => options.anonymize,
      'branch' => options.git_branch,
      'hotFiles' => options.number_of_hotfiles
    }
  end
  private_class_method :executable_hash

  def self.repo_hash(options)
    {
      'name' => ShellAdapter.repo_name(options.anonymize, options.input_directory),
      'dateOfInit' => ShellAdapter.init_date(options.input_directory),
      'dateOfLastCommit' => ShellAdapter.latest_activity_date(options.input_directory),
      'yearsWorkedOn' => ShellAdapter.activity_interval(options.input_directory),
      'numberOfFiles' => ShellAdapter.number_of_files(options.input_directory),
      'numberOfCommits' => ShellAdapter.number_of_commits(options.input_directory,
                                                          options.git_branch),
      'numberOfBranches' => ShellAdapter.number_of_branches(options.input_directory)
    }
  end
  private_class_method :repo_hash

  def self.main(_argv)
    options = Parser.parse(ARGV)

    # Google JSON Style Guide (camel case for keys)
    # https://google.github.io/styleguide/jsoncstyleguide.xml

    result = {
      EXECUTABLE_NAME => executable_hash(options),
      'repo' => repo_hash(options),
      'hotFiles' => ShellAdapter.hot_files(options.anonymize,
                                           options.input_directory,
                                           options.number_of_hotfiles),
      'authors' => ShellAdapter.authors(options.anonymize,
                                        options.input_directory)
    }

    puts JSON.pretty_generate(result)

    exit 0
  end
end
