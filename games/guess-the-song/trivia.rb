# this program grabs data from opentriviadb and formats
# it to work in this game. Just pass the query string as the first arg.
# https://opentdb.com/api_config.php

require 'open-uri'
require 'json'

data = JSON.parse(URI.open("https://opentdb.com/api.php?#{ARGV[0]}").read)
results = data['results'].map do |q|
  choices = q['incorrect_answers'] + [q['correct_answer']]
  choices.shuffle!
  answer_index = choices.index(q['correct_answer'])
  {
    prompt: q['question'],
    options: choices,
    answerIndex: answer_index
  }
end

puts JSON.pretty_generate(results)

