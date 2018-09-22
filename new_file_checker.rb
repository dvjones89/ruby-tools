#!/usr/bin/env ruby

# Checks a specific directory for the presence of a file with a created_at timestamp newer than CHECK_LIMIT
class NewFileChecker
  # The directory to be checked for the presence of new file(s)
  CHECK_DIRECTORY="/home/pi/backup"
  # The maximum accepted time since last file creation. Exceeding this limit results in a check failure.
  CHECK_LIMIT=86400 #seconds (24 hours)

  # PUBLIC METHOD
  # Identifies the maximum created_at timestamp for contents of a specified directory.
  # If the maximum created_at is within allowed bounds, exits with code 0 (OK)
  # If the maximum created_at is too old (beyond CHECK_LIMIT) then exits with code 1 (error).
  #
  # Returns exit code, 0 = OK, 1 = error
  def self.check
    creation_dates = Dir.entries(CHECK_DIRECTORY).map do |entry|
      next if [".",".."].include?(entry) # we're not interested in the navigation symbolic links
      absolute_path = File.join(CHECK_DIRECTORY, entry)
      File.ctime(absolute_path)
    end.compact

    exit(1) if max_creation_date.nil?
    max_creation_date = creation_dates.max
    seconds_since_creation = (Time.now - max_creation_date).to_i

    if seconds_since_creation < CHECK_LIMIT
      puts "PASS: Latest file created #{max_creation_date}"
      exit(0)
    else
      puts "FAIL: Latest file created #{max_creation_date}"
      exit(1)
    end
  end
end

# Entrypoint
if __FILE__ == $0
  NewFileChecker.check
end
