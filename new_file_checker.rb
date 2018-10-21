#!/usr/bin/env ruby

# Checks a specific directory for the presence of a file with a created_at timestamp within a supplied number of seconds
class NewFileChecker
  # PUBLIC METHOD
  # Identifies the maximum created_at timestamp for contents of a specified directory.
  # If the maximum created_at is within allowed bounds, exits with code 0 (OK)
  # If the maximum created_at is too old (beyond age_limit) then exits with code 1 (error).
  #
  # Returns exit code, 0 = OK, 1 = error
  def self.check(check_directory, age_limit)
    creation_dates = Dir.entries(check_directory).map do |entry|
      next if [".",".."].include?(entry) # we're not interested in the navigation symbolic links
      absolute_path = File.join(check_directory, entry)
      File.ctime(absolute_path)
    end.compact

    max_creation_date = creation_dates.max
    if max_creation_date.nil?
      puts "FAIL: Directory appears to be empty."
      exit(1)
    end

    seconds_since_creation = (Time.now - max_creation_date).to_i
    if seconds_since_creation < age_limit
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
  if ARGV.length == 2
    NewFileChecker.check(ARGV[0], ARGV[1].to_i)
  else
    raise "Please supply check_directory and age_limit arguments"
  end
end
