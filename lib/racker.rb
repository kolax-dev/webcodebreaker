require 'erb'
require_relative 'codebreaker'

module Codebreaker
  class Racker
    def self.call(env)
      new(env).response.finish
    end

    def initialize(env)
      @request = Rack::Request.new(env)
      @game = Game.new
      @max_attempt = Game::MAX_ATTEMPT
    end

    def response
      case @request.path
      when '/' then Rack::Response.new(render('index.html.erb'))
      when '/start_game'
        @game.start
        @hint = @game.hint
        @current_input = 0
        File.open('lib/codebreaker/tmp/result.txt', 'w')
        File.open('lib/codebreaker/tmp/statistic.txt', 'w') unless File.exist? 'lib/codebreaker/tmp/statistic.txt'
        if @request.post?
          @name = @request.params['name']
          if validate_name(@name)
            Rack::Response.new(render('index.html.erb'))
          else
            Rack::Response.new(render('game.html.erb')) do |res|
              res.set_cookie('secret_code', @game.secret_code)
              res.set_cookie('name', @name)
              res.set_cookie('hint', @hint)
            end
          end
        else
          Rack::Response.new { |res| res.redirect('/') }
        end
      when '/processing'
        @name = @request.cookies['name']
        @secret_code = @request.cookies['secret_code']
        @hint = @request.cookies['hint']
        @input = @request.params['input']
        if validate_input(@input)
          @list_result = @game.get_result
          @current_input = @list_result.count
          Rack::Response.new(render('game.html.erb'))
        else
          @result = @game.input_code(@input, @secret_code)
          @list_result = @game.get_result
          @current_input = @list_result.count
          if @result == true
            @messages = 'Congratulations! You win !'
            @status = Game::WIN
            @game.save_statistic(@name, @current_input, @status)
            Rack::Response.new(render('game.html.erb')) do |res|
              res.delete_cookie('name')
              res.delete_cookie('secret_code')
            end
          elsif @result == false
            @messages = 'You loose :('
            @status = Game::LOSE
            @game.save_statistic(@name, @current_input, @status)
            Rack::Response.new(render('game.html.erb')) do |res|
              res.delete_cookie('name')
              res.delete_cookie('secret_code')
            end
          else
            Rack::Response.new(render('game.html.erb'))
          end
          end
      when '/statistic'
        @list_statistic = @game.get_statistic
        Rack::Response.new(render('statistic.html.erb'))
      else Rack::Response.new('Not Found', 404)
      end
    end

    private

    def render(template)
      path = File.expand_path("../views/#{template}", __FILE__)
      ERB.new(File.read(path)).result(binding)
    end

    def validate_name(name)
      @error = false
      @error = 'Name must be between 3 and 32 characters!' if name.size < 3 || name.size > 32
      @error
    end

    def validate_input(input)
      @error = false
      @error = 'Code must contain 4 numbers from 1 to 6' unless input =~ /^[1-6]{4}$/
      @error
    end
  end
end
