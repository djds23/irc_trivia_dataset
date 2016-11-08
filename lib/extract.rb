require 'nokogiri'
require 'json'

FILEPATH = './raw_html/'
OUT = './out/'

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

  def initialize(raw_text)
    @text = raw_text
  end

  def parsed?
    [question, answer, category].all?
  end

  def text
    @text.strip
  end

  def question
    (text.split(':').last.split('*').first rescue nil)
  end

  def answer
    (text.split('*').last rescue nil)
  end

  def category
    (text.split(':').first rescue nil)
  end

  def to_h
    {
      question: question,
      answer: answer
    }
  end
end

class Dataset
  attr_reader :dataset

  def initialize
    @dataset = {}
  end

  def add_to_category(question)
    questions =
      if dataset.has_key? question.category
        dataset[question.category]
      else
        []
      end
    questions = questions.push(question.to_h)
    dataset[question.category] = questions
  end

  def to_json
    dataset.to_json
  end
end

def main
  dataset = Dataset.new
  errors = []

  FILES.each do |filename|
    raw_text = File.open(FILEPATH + filename).read
    question_nodes = Nokogiri::HTML(raw_text).css('ol').children.children
    question_nodes.each do |question_node|
      question = Question.new(question_node.text)
      if question.parsed?
        dataset.add_to_category(question)
        puts "parsed question for: #{question.category}"
      else
        errors.push(question)
      end
    end
  end

  errors.each do |error|
    puts "FAILED TO PARSE: #{error.text}"
  end

  File.open(OUT + "#{Time.now.to_i}_out.json", 'w') { |file|
    file.write(dataset.to_json)
  }
end

main
