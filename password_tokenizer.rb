#!/usr/bin/env ruby

# Simple helper class to select specific tokens from a longer, pseudorandom password.
class PasswordTokenizer

  # PUBLIC
  # Takes a password and array of indexes, returning the tokens from each index
  # tokenize('mypassword', [1, 2, 3]) => m y p
  # You can also pass index "l" for "last" and"p" for "penultimate"
  def self.tokenize(password, indexes)

    indexes.each do |index|
      if index.downcase == "l"
        index = password.length
      elsif index.downcase == "p"
        index = password.length - 1
      end

       # Remember that string characters are indexed from zero, therefore we subject one from index
       index = index.to_i - 1
       puts "#{index}: #{password[index]}"
     end;nil
   end
 end

# Entrypoint
# password_tokenizer.rb 'mypassword', 1,2,3 => m y p
if __FILE__ == $0
  password, indexes = ARGV
  PasswordTokenizer.tokenize(password, indexes.split(","))
end
