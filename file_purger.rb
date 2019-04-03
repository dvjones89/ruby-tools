#!/usr/bin/env ruby

# Searches a given directory for files of a given extension and purges (deletes) them if they're old than x days.
class FilePurger
  def self.purge(purge_directory, purge_extension, purge_age, purge_log)
    files_to_purge = find_files_to_purge(purge_directory, purge_extension, purge_age)
    files_to_purge.each { |filepath| perform_logged_purge(filepath, purge_log)}
  end

  private
  def self.find_files_to_purge(purge_directory, purge_extension, purge_age)
    glob_pattern = File.join(purge_directory, "*" + purge_extension)
    Dir.glob(glob_pattern).select{|path| File.mtime(path) < (Time.now - (60 * 60 *24 * purge_age))}
  end

  def self.perform_logged_purge(filepath, purge_log)
    timestamp = Time.now.strftime("%d/%m/%Y %H:%M")
    log_msg = "#{timestamp}: Deleting #{filepath}"
    File.open(purge_log, "a") { |f| f.puts log_msg }

    # export PURGE_DRY_RUN=true
    File.delete(filepath) unless ENV['PURGE_DRY_RUN']
  end
end

# Entrypoint
if __FILE__ == $0
  if ARGV.length == 4
    FilePurger.purge(ARGV[0],ARGV[1], ARGV[2].to_i, ARGV[3])
  else
    raise "Usage: file_purger.rb purge_directory purge_extension purge_age purge_log"
  end
end
