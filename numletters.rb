# check the input param
raise 'Must specify input file' unless ARGV.first
file = ARGV.first
raise 'File doesnt exist' unless File.exists? file

# get all input as a single string
input = File.readlines(file).join ' '
# remove puncuation, and split in to an array of words
words = input.gsub(/[^a-z0-9\s]/i, '').split(' ')

# start iterating through each word and store the one with the most amount
# of repeated letters
answer = nil
letter_count = -1
words.each do |word|
  # skip word if it's <= our letter count
  # since it would be impossible to be the answer
  next if word.size <= letter_count

  letters = {}
  # iterate through each character
  word.downcase.split(//).each do |letter|
    letters[letter] ||= 0
    letters[letter] += 1
    if letters[letter] > letter_count
      answer = word
      letter_count = letters[letter]
    end
  end
end

puts answer
