=begin
War card game library in Ruby.

  Copyright (C) 2009  doki_pen@doki-pen.org

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
=end
require 'cards'
module War
  include PlayingCards 

  class WarCard < Card
    include Comparable

    VALS = {
      :two => 0,
      :three => 1,
      :four => 2,
      :five => 3,
      :six => 4,
      :seven => 5,
      :eight => 6,
      :nine => 7,
      :ten => 8,
      :jack => 9,
      :queen => 10,
      :king => 11,
      :ace => 12 
    }

    def <=> ocard
      VALS[val] <=> VALS[ocard.val]
    end
  end

  class Player
    attr_reader :name

    def initialize name
      @play = PlayingCards::CardArray.new
      @captured = PlayingCards::CardArray.new
      @name = name
    end

    def play
      if @play.empty?
        if @captured.empty?
          raise 'out of cards, but asked to play'
        end
        @play = @captured.shuffle
        @captured = PlayingCards::CardArray.new
      end
      @play.shift
    end

    def empty?
      count == 0
    end

    def count
      @play.size + @captured.size
    end

    def take *cards
      @captured.take(cards)
    end

    def war! val; end
  end

  class HumanPlayer < Player
    attr_accessor :input, :output

    def initialize name, output, input
      @name = name
      @play = PlayingCards::CardArray.new
      @captured = PlayingCards::CardArray.new
      @input = input
      @output = output
      @warcards = 0
    end

    def play
      if @play.empty?
        if @captured.empty?
          raise 'out of cards, but asked to play'
        end
        @play = @captured.shuffle
        @captured = PlayingCards::CardArray.new
      end
      if @warcards > 0
        sleep 1
        output.print '.'
        if @warcards == 1
          output.puts
        end
        output.flush
        @warcards -= 1
      else
        output.print 'Press enter to play a card'
        input.gets
      end
      @play.shift
    end

    def war! val
      output.puts "WAR of #{val}s!"
      @warcards = 3
    end
  end

  class Game
    attr_reader :player1, :player2

    def initialize player1 = nil, player2 = nil
      @player1 = player1 || Player.new('Computer Player 1')
      @player2 = player2 || Player.new('Computer Player 2')
      @players = {
        @player1.name => @player1,
        @player2.name => @player2
      }
      d = PlayingCards.std_deck(WarCard).shuffle
      @player1.take d[0..25]
      @player2.take d[26..-1]
    end

    def _check_end_game round
      if @player1.empty? and @player2.empty?
        round[:game_over] = true
        round[:winner] = nil
      elsif @player1.empty?
        round[:game_over] = true
        round[:winner] = @player2.name
      elsif @player2.empty?
        round[:game_over] = true
        round[:winner] = @player1.name
      end
    end

    def _play_card win_cards, round
      p1 = @player1.play
      round[@player1.name][:cards] << p1
      p2 = @player2.play
      round[@player2.name][:cards] << p2
      win_cards.concat([p1, p2])
      return p1, p2
    end

    # parameters are for recursion in case of WAR
    def play win_cards=[], round=nil
      round ||= { 
        :game_over => false, 
        @player1.name => { :cards => [] }, 
        @player2.name => { :cards => [] }
      }
      p1, p2 = _play_card win_cards, round
      case p1 <=> p2
      when 1
        round[:winner] = @player1.name
        @player1.take win_cards
      when -1
        round[:winner] = @player2.name
        @player2.take win_cards
      else
        # send notifications
        @player1.war! p1.val
        @player2.war! p2.val
        3.times do 
          if @player1.empty? or @player2.empty?
            _check_end_game round
            @players[round[:winner]].take(win_cards) if @players[round[:winner]]
            break
          end
          _play_card win_cards, round
        end
        # recurse
        _check_end_game round
        play(win_cards, round) unless round[:game_over]
      end

      _check_end_game(round)

      round[@player1.name][:score] = @player1.count
      round[@player2.name][:score] = @player2.count
      
      round
    end

    def simulate
      game_over = false
      rounds = []
      until game_over
        r = play
        game_over = r[:game_over]
        rounds << r
      end
      rounds
    end
  end
end

