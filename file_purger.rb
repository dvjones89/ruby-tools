#!/usr/bin/env ruby

class FilePurger
  PURGE_DIRECTORY="/home/pi/backup_directory"
  PURGE_EXTENSION=".tar.bz2"
  MAX_DAYS_BEFORE_PURGE=7
  LOG_FILE="/home/pi/file_purger.log"
  DRY_RUN=false
  
  def self.purge
    files_to_purge = find_files_to_purge(MAX_DAYS_BEFORE_PURGE)
    files_to_purge.each { |filepath| perform_logged_purge(filepath)}
  end

  private
  def self.find_files_to_purge(max_days_before_purge)
    glob_pattern = File.join(PURGE_DIRECTORY, "*" + PURGE_EXTENSION)
    Dir.glob(glob_pattern).select{|path| File.mtime(path) < (Time.now - (60 * 60 *24 * max_days_before_purge))}
  end

  def self.perform_logged_purge(filepath)
    timestamp = Time.now.strftime("%d/%m/%Y %H:%M")
    log_msg = "#{timestamp}: Deleting #{filepath}"
    File.open(LOG_FILE, "a") { |f| f.puts log_msg }
    File.delete(filepath) unless DRY_RUN
  end
end

# Entrypoint
if __FILE__ == $0
  FilePurger.purge
end
