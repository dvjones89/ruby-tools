#!/usr/bin/env ruby

# Simple helper class to select specific tokens from a longer, pseudorandom password.
class PasswordTokenizer

  # PUBLIC
  # Takes a password and array of indexes, returning the tokens from each index
  # tokenize("mypassword", [1, 2, 3]) => m y p
  def self.tokenize(password, indexes)
    indexes.each do |index|
      puts "#{index}: #{password[index - 1]}"
    end;nil
  end
end

# Entrypoint
# password_tokenizer.rb "mypassword", 1,2,3 => m y p
if __FILE__ == $0
  password, indexes = ARGV
  PasswordTokenizer.tokenize(password, indexes.split(",").map(&:to_i))
end
