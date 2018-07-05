require_relative 'version'

module Codebreaker
  class Game
    attr_reader :secret_code

    MAX_ATTEMPT = 6
    WIN = 'WIN'.freeze
    LOSE = 'LOSE'.freeze

    def initialize
      @secret_code = ''
      @rand_index = rand(0...3)
    end

    def start
      4.times { @secret_code << rand(1...6).to_s }
    end

    def input_code(input, secret_code)
      result = ''
      input = input.to_s
      return true if input == secret_code
      input.chars.each_with_index do |char, index|
        result[index] = if secret_code.include?(char)
                          if char == secret_code[index]
                            '+'
                          else
                            '-'
                          end
                        else
                          '.'
                        end
      end
      save_result(input, result)
      return false if get_result.count >= MAX_ATTEMPT
      result
    end

    def hint
      hint = ''
      @secret_code.chars.each_with_index do |char, index|
        hint << if index == @rand_index
                  char
                else
                  '.'
                end
      end
      hint
    end

    def save_result(input, result)
      File.open('lib/codebreaker/tmp/result.txt', 'a') do |file|
        file.puts "#{input},#{result}"
      end
    end

    def get_result
      list_result = []
      File.open('lib/codebreaker/tmp/result.txt', 'r') do |file|
        file.each do |x|
          tmp = x.split(',')
          list_result << tmp
        end
      end
      list_result
    end

    def save_statistic(name, result, status)
      File.open('lib/codebreaker/tmp/statistic.txt', 'a') do |file|
        date = Time.new.strftime('%d.%m.%Y %H:%M:%S')
        file.puts "#{name},#{result},#{status},#{date}"
      end
    end

    def get_statistic
      list_statistic = []
      File.open('lib/codebreaker/tmp/statistic.txt', 'r') do |file|
        file.each do |x|
          tmp = x.split(',')
          list_statistic << tmp
        end
      end
      list_statistic
    end
  end
end
