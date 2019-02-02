
COMMAND_REPO_NAME = 'basename `git rev-parse --show-toplevel`'.freeze
COMMAND_REPO_INIT_DATE = 'git log --date=iso8601-strict --reverse |head -3 |grep "Date"'.freeze
COMMAND_LATEST_ACTIVITY_DATE = 'git log --date=iso8601-strict |head -3 |grep "Date"'.freeze
COMMAND_COMMITS_NUMBER = 'git rev-list --count '.freeze
COMMAND_FILES_NUMBER = 'git ls-files | wc -l'.freeze
COMMAND_BRANCHES_NUMBER = 'git branch | wc -l'.freeze
COMMAND_AUTHORS = 'git shortlog -s -n'.freeze
COMMAND_FILES_HOT = 'git log --pretty=format: --name-only | sort | uniq -c | sort -rg | head -'.freeze
