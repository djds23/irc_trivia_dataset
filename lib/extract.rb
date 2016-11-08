require 'nokogiri'
require 'json'

FILES = [
 "Trivia_Animals.html",
 "Trivia_Food.html",
 "Trivia_History.html",
 "Trivia_Movies.html",
 "Trivia_Religion_Mythology.html",
 "Trivia_TV.html",
 "Trivia_anime.html",
 "Trivia_Computer.html",
 "Trivia_Geography.html",
 "Trivia_Misc.html",
 "Trivia_Music.html",
 "Trivia_Sport.html",
 "Trivia_Video_Games.html",
 "Trivia_science.html"
]

class Question
  attr_reader :text
  def initialize(raw_text)
    @text = raw_text.strip
  end

  def question
    text.split(':').last.split('*').first
  end

  def answer
    text.split('*').last
  end

  def category
    text.split(':').first
  end

  def to_json
    {
      question: question,
      answer: answer
    }.to_json
  end
end


task :get_open_questions  => :environment  do |t, args|
  FILES.each do |filename|
    raw_text = File.open(FILEPATH + filename).read
    question_nodes = Nokogiri::HTML(raw_text).css('ol').children.children
    question_nodes.each do |question|
      clue = text_to_clue(question.text)
      puts clue.answer
    end
  end
end

