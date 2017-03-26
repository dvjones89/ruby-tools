#!/usr/bin/env ruby

VIDEO_EXTENSION=".MP4"
OUTPUT_NAME = "merged.MP4"
DRY_RUN = false

class VideoMerger
  def merge
    files = find_files_to_merge
    input_list = create_input_list(files)
    do_merge(input_list) unless DRY_RUN
    do_cleanup(input_list) unless DRY_RUN
  end

  private
  def create_input_list(files)
    list_path = File.join(Dir.pwd, "input.list")
    File.open(list_path, "w") do |list|
      files.each do |file|
        list.puts("file '#{file}'")
      end
    end
    list_path
  end

  def find_files_to_merge
    glob_pattern = File.join(Dir.pwd, "*#{VIDEO_EXTENSION}")
    files = Dir.glob(glob_pattern)
    files.sort_by{|file| File.mtime(file)}
  end

  def do_merge(input_list)
    output_path = File.join(Dir.pwd, OUTPUT_NAME)
    command = "ffmpeg -safe 0 -f concat -i '#{input_list}' -c copy '#{output_path}'"
    Kernel.system(command)
  end

  def do_cleanup(input_list)
    File.delete(input_list)
  end
end

# Entrypoint
if __FILE__ == $0
  if ENV['STY'] # if running in a screen session
    VideoMerger.new.merge
  else
    puts "It is recommended that you run this script within a screen session."
  end
end
