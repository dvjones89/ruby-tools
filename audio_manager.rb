#!/usr/bin/env ruby
require 'tty-prompt'
require 'fileutils'

# Simple helper class to grab an MP3 from YouTube and tag it with the artist and track name
# Requires yt-dl and id3lib to be installed
class AudioManager

  # PUBLIC
  # Takes a YouTube URL, rips the MP3 and writes user-supplied ID3 tags
  def self.rip_and_tag(youtube_url)
    extract_audio_cmd = "youtube-dl --extract-audio --audio-format mp3 --no-playlist #{youtube_url}"
    system(extract_audio_cmd)

    prompt = TTY::Prompt.new
    artist = prompt.ask("Artist: ")
    track_name = prompt.ask("Track name:")
    original_filename = Dir.glob("*.mp3").first
    tag_mp3_cmd = "id3tag --artist='#{artist}' --song='#{track_name}' '#{original_filename}'"
    system(tag_mp3_cmd)

    new_filename = "#{artist} - #{track_name}.mp3"
    File.rename(original_filename, new_filename)
    destination_folder = prompt.select("Choose destination", ["Remixes", "Radio Edits"])
    destination_path = File.join("~/Music/DJ Tracks", destination_folder)
    FileUtils.mv(new_filename, File.expand_path(destination_path))
   end
 end

# Entrypoint
# audio_manager.rb https://www.youtube.com/watch?v=pAfKduntW28
if __FILE__ == $0
  youtube_url = ARGV[0]
  AudioManager.rip_and_tag(youtube_url)
end
