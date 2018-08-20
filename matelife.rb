require './matelight.rb'

class Matelife < Matelight
  def tick
    @screen = init if @screen.inject(:+) < 4*255
    super
  end

  def tick_value(x,y,chan)
    sum = neighbors(x,y,chan).sum / 255

    # if alive
    if screen[y,x,chan] > 0
      if sum > 1 and sum < 4
        @next[y,x,chan] = 255
      else
        @next[y,x,chan] = 0
      end

    # if dead
    else
      if sum > 2 and sum < 4
        @next[y,x,chan] = 255
      else
        @next[y,x,chan] = 0
      end
    end
    puts @next[y,x,chan] if debug?
  end

  def init
    NMatrix.random(dims, :dtype => :byte, :scale => 90)
  end
end

class MatelifeMono < Matelife
  def tick_value(x,y,chan)
    return if chan > 0
    super
  end
 end

class Mateblack < Matelight
  def tick_value(x,y,chan)
    @next[y,x,chan] = 0
  end
end

class Matelines < Matelight
  def tick_value(x,y,c)
    @next[y,x,c] = (y % 2 == 0) ? 255 : 0
  end
end

m = Matelife.new(server: 'localhost', framerate: 30)
m.run
