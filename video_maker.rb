#!/usr/bin/env ruby

require "fileutils"

VIDEO_EXTENSION=".MP4"
IMAGE_EXTENSION=".jpg"
OUTPUT_NAME = "final.MP4"
DRY_RUN = false

class VideoMaker
  def self.make
    #image_files = find_files_by_extension(IMAGE_EXTENSION)
    #convert_images_to_clips(image_files)
    videos = find_files_by_extension(VIDEO_EXTENSION)
    input_list = create_input_list(videos)
    do_merge(input_list) unless DRY_RUN
    #do_cleanup(input_list) unless DRY_RUN
  end

  private
  def self.create_input_list(videos)
    videos.sort_by!{ |video| File.mtime(video)}
    list_path = File.join(Dir.pwd, "input.list")
    File.open(list_path, "w") do |list|
      videos.each do |video_path|
        list.puts("file '#{video_path}'")
      end
    end
    list_path
  end

  def self.find_files_by_extension(extension)
    glob_pattern = File.join(Dir.pwd, "*#{extension}")
    Dir.glob(glob_pattern)
  end

  def self.convert_images_to_clips(images)
    images.each do |image_path|
      clip_name = "temp_" + File.basename(image_path, IMAGE_EXTENSION) + ".MP4"
      clip_path = File.join(Dir.pwd, clip_name)
      command = "ffmpeg -loop 1 -i '#{image_path}' -c:v libx264 -t 5 -pix_fmt yuv420p '#{clip_path}'"
      Kernel.system(command) unless File.exists?(clip_path)
      FileUtils.touch(clip_path, mtime: File.mtime(image_path))
    end
  end

  def self.do_merge(input_list)
    output_path = File.join(Dir.pwd, OUTPUT_NAME)
    command = "ffmpeg -safe 0 -f concat -i '#{input_list}' '#{output_path}'"
    Kernel.system(command)
  end

  def self.do_cleanup(input_list)
    # delete the input_list now that's it's no longer needed by ffmpeg
    File.delete(input_list)

    # delete temporary files created when converting images to clips
    glob_pattern = File.join(Dir.pwd, "temp_*")
    Dir.glob(glob_pattern).each{|temp_path| File.delete(temp_path)}
  end
end

# Entrypoint
if __FILE__ == $0
  if ENV['STY'] # if running in a screen session
    VideoMaker.make
  else
    puts "It is recommended that you run this script within a screen session."
  end
end
