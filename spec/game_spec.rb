require_relative 'spec_helper'

module Codebreaker
  RSpec.describe Game do
    let(:game) { Game.new }

    context '#start' do
      before do
        game.start
      end

      it 'saves secret code' do
        expect(game.instance_variable_get(:@secret_code)).not_to be_empty
      end

      it 'saves 4 numbers secret code' do
        expect(game.instance_variable_get(:@secret_code).size).to eq(4)
      end

      it 'saves secret code with numbers from 1 to 6' do
        expect(game.instance_variable_get(:@secret_code)).to match(/^[1-6]{4}$/)
      end
    end

    context '#input_code' do
      before do
        game.instance_variable_set(:@secret_code, '1234')
        Game::MAX_ATTEMPT = 100
      end
      it 'test method called by input validate' do
        expect(game.input_code('1234', game.secret_code)).to be true
        expect(game.input_code('1235', game.secret_code)).to eq('+++.')
        expect(game.input_code('5555', game.secret_code)).to eq('....')
        expect(game.input_code('1334', game.secret_code)).to eq('+-++')
        expect(game.input_code('4551', game.secret_code)).to eq('-..-')
      end
      it 'test method called by input for hin' do
        game.instance_variable_set(:@rand_index, 2)
        expect(game.hint).to eq('..3.')
      end
    end

    context '#save_result' do
      it 'expected by reading a file' do
        File.open('lib/codebreaker/tmp/result.txt', 'w')
        input = '1235'
        result = '+++.'
        game.save_result(input, result)
        result = File.read('lib/codebreaker/tmp/result.txt')
        expect(result).to eq("1235,+++.\n")
      end
    end

    context '#get_result' do
      it 'return this function' do
        list_result = game.get_result
        expect(list_result).to eq([['1235', "+++.\n"]])
      end
    end
  end
end
