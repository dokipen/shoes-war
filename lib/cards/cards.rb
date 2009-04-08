=begin
Simple cards library for ruby.

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
module PlayingCards
  SUITES = [:diamonds, :clubs, :hearts, :spades]
  VALUES = [:ace, :king, :queen, :jack, :ten, :nine, :eight, :seven, :six, 
    :five, :four, :three, :two]

  class Card
    include Comparable

    attr_reader :suite, :val

    def initialize(suite, val)
      @suite, @val = suite, val
    end

    def to_s
      "#{@val} of #{@suite}"
    end

    def inspect
      to_s
    end

    def <=> o
      r = SUITES.index(suite) <=> SUITES.index(o.suite)
      if r == 0
        VALUES.index(val) <=> VALUES.index(o.val)
      else
        r
      end
    end
  end

  class CardArray < Array
    def shuffle
      (size - 1).downto(0) do |i|
        swap = rand(i + 1)
        self[i], self[swap] = self[swap], self[i]
      end
      self
    end

    def take *cards
      self.concat(cards)
      self.flatten!
      self
    end
  end

  def self.std_deck card_class=Card
    deck = CardArray.new
    SUITES.each do |s|
      VALUES.each do |v|
        deck << card_class.new(s, v)
      end
    end
    deck
  end
end
