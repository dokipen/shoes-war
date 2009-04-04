=begin
War! card game.

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
require 'war'
BASE = File.expand_path(File.join(File.dirname(__FILE__), '..')
$: << File.join(BASE, '..')

class Card < Widget
  XY_RATIO = 0.6872
  HEIGHT = 100
  WIDTH = (HEIGHT * XY_RATIO).to_i
  # if you define width, do this
  # HEIGHT = (WIDTH / XY_RATIO).to_i
  CARD_IMG = File.join(BASE, "static/cards.png")
  ROW_COUNT = 5
  COLUMN_COUNT = 13

  ROWS = Hash.new {|_,_|0}.merge({
    :clubs    =>  0,
    :diamonds => -1,
    :hearts   => -2,
    :spades   => -3,
    :other    => -4,
    :back     => -4,
    :joker    => -4,
    :blank    => -5,
  })

  COLUMNS = Hash.new {|_,k| (k.kind_of?Numeric) ? -(k-1) : 0}.merge({
    :joker0 =>   0,
    :joker1 => - 1,
    :back   => - 2,
    :ace    =>   0,
    :two    => - 1,
    :duce   => - 2,
    :three  => - 2,
    :four   => - 3,
    :five   => - 4,
    :six    => - 5,
    :seven  => - 6,
    :eight  => - 7,
    :nine   => - 8,
    :ten    => - 9,
    :jack   => -10,
    :queen  => -11,
    :king   => -12,
    :blank  => -13,
  })

  def initialize opts
    style :width => WIDTH, :height => HEIGHT
    @up = opts[:up] || true
    @row = ROWS[opts[:row]]
    @column = COLUMNS[opts[:column]]
    stack :width => WIDTH, :height => HEIGHT do
      @img = image CARD_IMG,
        :height => HEIGHT*ROW_COUNT, 
        :width => WIDTH*COLUMN_COUNT,
        :left => @column*WIDTH,
        :top => @row*HEIGHT
    end
  end

  def flip
    if @up
      @up = false
      @img.style(
        :left => COLUMNS[:back]*WIDTH,
        :top => ROWS[:other]*HEIGHT
      )
    else
      @up = true
      @img.style(
        :left => @column*WIDTH,
        :top => @row*HEIGHT
      )
    end
  end
end

Shoes.app do
  background "#555"
  @title = "War!"

  def reset_game
    @you = War::Player.new "You"
    @her = War::Player.new "Her"
    @game = War::Game.new @you, @her
    @you_count.clear do
      caption "#{@you.count} cards", :stroke => "#CD9", :margin => 4
    end
    @her_count.clear do
      caption "#{@her.count} cards", :stroke => "#CD9", :margin => 4
    end
    @result.clear do
      background "#333", :curve => 4
      caption 'Let\'s play some War!', :stroke => "#CD9", :margin => 4
    end
  end

  def play_trick
    trick = @game.play

    [
      [@play_spot, trick["You"][:cards]], 
      [@opp_spot, trick["Her"][:cards]]
    ].each do |slot, cards|
      slot.clear do
        cards.each do |c|
          card :row => c.suite, :column => c.val 
        end
      end
    end

    [
      [@you_count, @you],
      [@her_count, @her]
    ].each do |slot, player|
      slot.clear do
        caption "#{player.count} cards", :stroke => "#CD9", :margin => 4
      end
    end

    @result.clear do
      background '#333', :curve => 4
      warstring = "WAR! " * (trick["You"][:cards].size / 4)
      caption "#{warstring}Trick Winner: #{trick[:winner]}", :stroke => "#CD9", :margin => 4
      if trick[:game_over]
        if trick[:winner] == "You"
          alert("You won!")
        else
          alert("She won :(")
        end
        reset_game
      end
    end
  end

  stack :margin => 10 do
    title strong(@title), :align => "center", :stroke => "#DFA", :margin => 0

    stack :width => "100%", :margin => 10 do
      @result = stack :margin_right => gutter

      # Game board
      flow :margin => 10 do
        # Your side
        stack :margin_top => 25, :margin_right => 25, :width => Card::WIDTH+50 do
          caption "You", :align => 'left'
          card :row => :back, :column => :back
          @you_count = stack do
            caption '26 cards', :stroke => "#CD9", :margin => 4
          end
          button("Play") { play_trick }
          para
          button("New Game") { reset_game }
          button("Quit") { quit }
          button("Rules") do
            alert <<-"RULES" 
1. High card takes the trick
2. Cards are dealt from the play pile.  Won tricks are placed in a second pile called the won pile.  When the play pile is empty, the won pile is shuffled and becomes the play pile.
3. If you a player runs out of cards during a war, without completing the war, they lose the game.
            RULES
          end
        end

        # Play space
        stack :width => Card::WIDTH*5-20 do
          flow :align => 'center' do
            @play_spot = stack :margin => 25, :margin_left => 50, :width => Card::WIDTH+75 #, :height => Card::HEIGHT*5+50
            @opp_spot = stack :margin => 25, :margin_left => 50, :width => Card::WIDTH+75 #, :height => Card::HEIGHT*5+50
          end
        end

        # Her side
        stack :margin_top => 25, :margin_left => 25, :width => Card::WIDTH+50 do
          caption "Her", :align => 'left'
          card :row => :back, :column => :back
          @her_count = stack do
            caption '26 cards', :stroke => "#CD9", :margin => 4
          end
        end
      end
    end
  end

  keypress do |k|
    case k
    when 'q'
      quit
    end
  end

  reset_game
end
