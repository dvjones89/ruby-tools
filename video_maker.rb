#!/usr/bin/env ruby

require "fileutils"

# Process all images and videos into a chronological video, ideal for documenting a day trip or holiday.
class VideoMaker
  VIDEO_EXTENSION=".MP4"
  IMAGE_EXTENSION=".jpg"
  IMAGE_DURATION="5" #seconds
  OUTPUT_NAME="final.MP4"

  # PUBLIC
  # Converts images to clips, merges clips into a master video, applies soundtrack and cleans up.
  def self.make
    image_files = find_files_by_extension(IMAGE_EXTENSION)
    convert_images_to_clips(image_files)
    videos = find_files_by_extension(VIDEO_EXTENSION)
    videos.sort_by!{ |video| File.mtime(video)}
    video_path = merge_videos(videos)
    audio_path = find_files_by_extension(".mp3")[0]
    add_soundtrack(video_path, audio_path)
    delete_temp_files
  end

  private

  # Finds all files of a particular extension in the current working directory
  # extension - the string file extension you're interested in, for example, '.MP4'
  #
  # returns string array - filepaths matching the specific extension
  def self.find_files_by_extension(extension)
    glob_pattern = File.join(Dir.pwd, "*#{extension}")
    Dir.glob(glob_pattern)
  end

  # Converts images into video clips
  # images - array of strings where each string is the path to an image file.
  #
  # returns string array - filepaths to resultant video clips
  def self.convert_images_to_clips(images)
    images.inject([]) do |clip_array, image_path|
      clip_name = "temp_" + File.basename(image_path, IMAGE_EXTENSION) + VIDEO_EXTENSION
      clip_path = File.join(Dir.pwd, clip_name)
      command = "ffmpeg -loop 1 -i '#{image_path}' -c:v libx264 -t #{IMAGE_DURATION} -pix_fmt yuv420p '#{clip_path}'"
      Kernel.system(command) unless File.exists?(clip_path)
      # Set the clip modified_at timestamp to match that of the source image, retaining chronological order.
      FileUtils.touch(clip_path, mtime: File.mtime(image_path))
      clip_array << clip_path
    end
  end

  # Merges multiple videos into a single file
  # videos_to_merge (string array) - File paths of videos to be merged
  #
  # returns string - the filepath to the resultant video file
  def self.merge_videos(videos_to_merge)
    output_path = File.join(Dir.pwd, "temp_merged.MP4")
    files_string = videos_to_merge.inject(""){|string, file_path| string += " -cat '#{file_path}'" }
    command = "MP4Box -force-cat #{files_string} -new '#{output_path}'"
    Kernel.system(command)
    output_path
  end

  # Adds an audio soundtrack to a video file
  # video_path (string) - path to video file
  # audio_path (string) - path to audio file
  #
  # returns string - the absolute path to the resultant video file
  def self.add_soundtrack(video_path, audio_path)
    command = "ffmpeg -i '#{video_path}'' -i '#{audio_path}'' -map 0:0 -map 1:0 -shortest '#{OUTPUT_NAME}'"
    Kernel.system(command)
    File.join(Dir.pwd, OUTPUT_NAME)
  end

  # Deletes temporary files that have been created in earlier steps
  #
  # return nothing of interest.
  def self.delete_temp_files()
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
