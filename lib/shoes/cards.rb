# Shoes card widgets.
#
# Copyright (C) 2009 Doki Pen <doki_pen@doki-pen.org>
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

class Card < Shoes::Widget
  XY_RATIO = 0.6872
  HEIGHT = 150
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

class CardStack < Shoes::Widget
  HORIZ_OFFSET_RATIO = 0.15
  VERT_OFFSET_RATIO = 0.25

  def initialize opts
    @x_offset = opts[:horizontal] ? Card::WIDTH*HORIZ_OFFSET_RATIO : 0
    @y_offset = opts[:vertical] ? Card::HEIGHT*VERT_OFFSET_RATIO : 0
    @cards = opts[:cards]
    @cards.each_with_index do |card, i|
      card(:row => card.suite, :column => card.val).move(*offset(i))
    end
  end

  def offset position
    [(position*@x_offset).to_i,(position*@y_offset).to_i]
  end

  def add_card card
    @cards << card
    @cards.each_with_index do |card, i|
      card(:row => card.suite, :column => card.val, :x => x, :y => y).
        move((i*@x_offset).to_i,(i*@y_offset).to_i)
    end
  end
end

