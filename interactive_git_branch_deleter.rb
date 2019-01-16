#!/usr/bin/env ruby

# Simple helper class to iterate over the git branches in your working directory and offer to delete them.
class InteractiveGitBranchDeleter
  require 'open3'

  def self.perform
    stdout, stderr, status = Open3.capture3("git branch")
    branches = stdout.split

    branches.each do |branch|
      print "\n Delete \e[31m#{branch}?\e[0m (y/n) "
      response = gets.chomp.strip.downcase

      if response == 'y'
        command = "git branch -d #{branch}"
        stdout, stderr, status = Open3.capture3(command)
      end
    end
  end
end

# Entrypoint
if __FILE__ == $0
  InteractiveGitBranchDeleter.perform
end
