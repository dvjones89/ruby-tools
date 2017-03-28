#!/usr/bin/env ruby

require "fileutils"

VIDEO_EXTENSION=".MP4"
IMAGE_EXTENSION=".jpg"
IMAGE_DURATION="5" #seconds
OUTPUT_NAME="final.MP4"
DRY_RUN=false

class VideoMaker
  def self.make
    image_files = find_files_by_extension(IMAGE_EXTENSION)
    convert_images_to_clips(image_files)
    videos = find_files_by_extension(VIDEO_EXTENSION)
    videos.sort_by!{ |video| File.mtime(video)}
    merge_videos(videos) unless DRY_RUN
    add_soundtrack("8861639_Same_Man_Original_Mix.mp3") unless DRY_RUN
    #delete_clips unless DRY_RUN
  end

  private

  def self.find_files_by_extension(extension)
    glob_pattern = File.join(Dir.pwd, "*#{extension}")
    Dir.glob(glob_pattern)
  end

  def self.convert_images_to_clips(images)
    images.each do |image_path|
      clip_name = "temp_" + File.basename(image_path, IMAGE_EXTENSION) + VIDEO_EXTENSION
      clip_path = File.join(Dir.pwd, clip_name)
      command = "ffmpeg -loop 1 -i '#{image_path}' -c:v libx264 -t #{IMAGE_DURATION} -pix_fmt yuv420p '#{clip_path}'"
      Kernel.system(command) unless File.exists?(clip_path)
      FileUtils.touch(clip_path, mtime: File.mtime(image_path))
    end
  end

  def self.merge_videos(videos_to_merge)
    output_path = File.join(Dir.pwd, "merged.MP4")
    files_string = videos_to_merge.inject(""){|string, file_path| string += " -cat '#{file_path}'" }
    command = "MP4Box -force-cat #{files_string} -new '#{output_path}'"
    Kernel.system(command)
  end

  def self.add_soundtrack(audio_path)
    command = "ffmpeg -i merged.MP4 -i #{audio_path} -map 0:0 -map 1:0 -shortest #{OUTPUT_NAME}"
    Kernel.system(command)
  end

  def self.delete_clips
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
