class GamesController < ApplicationController
  require 'open-uri'
  require 'json'
  @grid = []
  def generate_grid
    grid = []
    characters = ('A'..'Z').to_a.shuffle
    10.times do
      grid << characters[rand(0..10)]
    end
    grid
  end

  def check(attempt, grid, start_time, end_time)
    word = JSON.parse(URI.open("https://wagon-dictionary.herokuapp.com/#{attempt}").read)
    no_letter = false
    overused = false

    if word['found']
      word['word'].chars.each do |letter|
        no_letter = true unless grid.include?(letter.upcase)
      end
      grid.each do |letter|
        overused = true if (word['word'].upcase.chars.count letter.upcase) > (grid.count letter.upcase)
      end
      if no_letter || overused == true
        message = 'Sorry, some of the letters you used are not in the grid!'
        score = 0
      else
        score = (((word['length']) * 2) + ((start_time - end_time).to_f * 0.2))
        message = 'The word you have entered exists! Well done!'
      end
    else
      message = 'The word you have entered is not an english word. Better luck next time!'
      score = 0
    end
    {
      score: score,
      message: message,
      time: (end_time - start_time).to_i
    }
  end

  def home
    session[:total] = 0
  end

  def new
    session[:grid] = generate_grid
    session[:total] = 0 if !session[:total]
  end

  def score
    attempt = params[:word]
    start_time = Time.now
    end_time = Time.now
    @info = check(attempt, session[:grid], start_time, end_time)
    session[:total] += @info[:score]
  end
end
