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

  attr_reader :question_id

  def initialize(raw_text, question_id)
    @text = raw_text
    @question_id = question_id
  end

  def parsed?
    [question, answer, category].all?
  end

  def text
    @text.strip
  end

  def question
    question_start = category.length + 1
    question_end = (text =~ /\*(.*)/) - 1
    stripped_question = text[question_start..question_end].strip
    unless stripped_question.empty?
      stripped_question
    end
  rescue
    nil
  end

  def answer
    stripped_answer = /\*(.*)/.match(text).to_s[1..-1].strip
    unless stripped_answer.empty?
      stripped_answer
    end
  rescue
    nil
  end

  def category
    stripped_category = /.+?(?=: )/.match(text).to_s.strip
    unless stripped_category.empty?
      stripped_category
    end
  rescue
    nil
  end

  def to_h
    {
      id: question_id,
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

  current_id = 1
  FILES.each do |filename|
    raw_text = File.open(FILEPATH + filename).read
    question_nodes = Nokogiri::HTML(raw_text).css('ol').children.children
    question_nodes.each do |question_node|
      question = Question.new(question_node.text, current_id)
      if question.parsed?
        dataset.add_to_category(question)
        puts "parsed question for: #{question.category}"
        current_id += 1
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
