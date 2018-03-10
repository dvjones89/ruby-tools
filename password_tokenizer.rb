#!/usr/bin/env ruby

# Simple helper class to select specific tokens from a longer, pseudorandom password.
class PasswordTokenizer

  # PUBLIC
  # Takes a password and unlimited number of indexes, returning the tokens from each index
  # tokenize("mypassword", 1, 2, 3) => m y p
  def self.tokenize(password, *indexes)
    indexes.each do |index|
      puts "#{index}: #{password[index - 1]}"
    end;nil
  end
end
