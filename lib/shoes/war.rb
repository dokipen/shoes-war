# War! card game.
# 
#  Copyright (C) 2009 Doki Pen <doki_pen@doki-pen.org>
# 
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA

BASE = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
$: << File.join(BASE, 'lib')

require 'cards/war'
require 'shoes/cards'

Shoes.app :width => 785, :height => 750 do
  background "#555"
  @title = "War!"
  @you = War::Player.new "You"
  @her = War::Player.new "Her"

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
    [@play_spot, @opp_spot].each {|s| s.clear}
  end

  def play_trick
    trick = @game.play

    [
      [@play_spot, trick[@you.name][:cards]], 
      [@opp_spot, trick[@her.name][:cards]]
    ].each do |slot, cards|
      slot.clear do
        card_stack :cards => cards, :vertical => true
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
      warstring = "WAR! " * (trick[@you.name][:cards].size / 4)
      caption "#{warstring}Trick Winner: #{trick[:winner]}", :stroke => "#CD9", :margin => 4
      if trick[:game_over]
        if trick[:winner] == @you.name 
          alert("You won!")
        else
          alert("She won :(")
        end
        reset_game
      end
    end
  end

  stack :margin => 10 do
    flow do
      button("New Game") { reset_game }
      button("Rules") do
            alert <<-"RULES" 
1. High card takes the trick
2. Cards are dealt from the play pile.  Won tricks are placed in a second pile called the won pile.  When the play pile is empty, the won pile is shuffled and becomes the play pile.
3. If you a player runs out of cards during a war, without completing the war, they lose the game.
            RULES
      end
      button("Quit") { quit }
    end
    title strong(@title), :align => "center", :stroke => "#DFA", :margin => 0

    stack :width => "100%", :margin => 10 do
      @result = stack :margin_right => gutter

      # Game board
      flow :margin => 10 do
        # Your side
        stack :margin_top => 25, :margin_right => 25, :width => Card::WIDTH+50 do
          caption @you.name, :stroke => "#CD9", :margin => 4
          @c = card :row => :back, :column => :back
          @c.click { play_trick }
          @you_count = stack do
            caption '26 cards', :stroke => "#CD9", :margin => 4
          end
        end

        # Play space
        stack :width => Card::WIDTH*4 do
          flow :align => 'center' do
            @play_spot = stack :margin => 25, :margin_left => 50, :width => Card::WIDTH+75 
            #, :height => Card::HEIGHT*5+50
            @opp_spot = stack :margin => 25, :margin_left => 50, :width => Card::WIDTH+75 #, :height => Card::HEIGHT*5+50
          end
        end

        # Her side
        stack :margin_top => 25, :margin_left => 25, :width => Card::WIDTH+50 do
          caption @her.name, :stroke => "#CD9", :margin => 4
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
    when ' '
      play_trick
    when :enter
      play_trick
    end
  end

  reset_game
end
