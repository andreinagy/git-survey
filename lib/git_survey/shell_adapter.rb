require_relative 'helpers'

COMMAND_REPO_NAME = 'basename `git rev-parse --show-toplevel`'.freeze
COMMAND_REPO_INIT_DATE = 'git log --date=iso8601-strict --reverse |head -3 ' +
                         '|grep "Date"'.freeze
COMMAND_LATEST_ACTIVITY_DATE = 'git log --date=iso8601-strict |head -3 ' +
                               '|grep "Date"'.freeze
COMMAND_COMMITS_NUMBER = 'git rev-list --count '.freeze
COMMAND_FILES_NUMBER = 'git ls-files | wc -l'.freeze
COMMAND_BRANCHES_NUMBER = 'git branch | wc -l'.freeze
COMMAND_AUTHORS = 'git shortlog -s -n'.freeze
COMMAND_FILES_HOT = 'git log --pretty=format: --name-only | sort | uniq -c | ' +
                    'sort -rg | head -'.freeze

# Adapter which handles shell access.
class ShellAdapter
  def self.run_shell_command(directory, cmd)
    result = `cd #{directory}; #{cmd}`
    result
  end
  private_class_method :run_shell_command

  def self.date_at_the_end_of_line(string)
    string.split(' ').last
  end
  private_class_method :date_at_the_end_of_line

  def self.hash_from_line_with_delimiter(anonymized,
                                         directory,
                                         command,
                                         delimiter)

    list = run_shell_command(directory, command)
           .split("\n")
    empty = 'empty' # git outputs empty lines too, they should be removed.

    result = {}
    list.each do |line|
      parts = line.split(delimiter)
      value = parts.first
      key = parts.last == value ? empty : Helpers.anonymized(anonymized, parts.last)

      result[key] = value.to_i
    end
    result.reject { |key, _value| key.to_s.match(empty) }
  end
  private_class_method :hash_from_line_with_delimiter

  # basename `git rev-parse --show-toplevel`
  def self.repo_name(anonimize, directory)
    name = run_shell_command(directory, COMMAND_REPO_NAME).strip
    Helpers.anonymized(anonimize, name)
  end

  # git log --date=iso8601-strict --reverse |head -3 |grep "Date"
  def self.init_date(directory)
    string = run_shell_command(directory, COMMAND_REPO_INIT_DATE)
    Time.iso8601(date_at_the_end_of_line(string))
  end

  # git log --date=iso8601-strict |head -3 |grep "Date"
  def self.latest_activity_date(directory)
    string = run_shell_command(directory, COMMAND_LATEST_ACTIVITY_DATE)
    Time.iso8601(date_at_the_end_of_line(string))
  end

  def self.activity_interval(directory)
    earliest = init_date(directory).to_f
    latest = latest_activity_date(directory).to_f

    diff = latest - earliest
    (diff / (365 * 24 * 60 * 60)).round(2)
  end

  # git rev-list --count <revision>
  def self.number_of_commits(directory, branch)
    run_shell_command(directory, COMMAND_COMMITS_NUMBER + branch).to_i
  end

  #  git ls-files | wc -l
  def self.number_of_files(directory)
    run_shell_command(directory, COMMAND_FILES_NUMBER).to_i
  end

  # git branch | wc -l
  def self.number_of_branches(directory)
    run_shell_command(directory, COMMAND_BRANCHES_NUMBER).to_i
  end

  # git shortlog -s -n
  def self.authors(anonymized, directory)
    hash_from_line_with_delimiter(anonymized, directory, COMMAND_AUTHORS, "\t")
  end

  # git log --pretty=format: --name-only | sort | uniq -c | sort -rg | head -10
  def self.hot_files(anonymized, directory, number)
    number_with_empty_lines = number.to_i + 1
    command = COMMAND_FILES_HOT + number_with_empty_lines.to_s
    hash_from_line_with_delimiter(anonymized, directory, command, ' ')
  end
end
