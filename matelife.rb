require 'nmatrix'
require 'socket'

class Matelight
  def initialize
    @screen = NMatrix.random([40,16,3], :dtype => :byte, :scale => 255)
    @next = NMatrix.zeros([40,16,3], :dtype => :byte, :scale => 255)
    @socket = UDPSocket.new
  end

  def as_bytestream
    stream = ''
    @screen.each do |e|
      stream += e.to_s(2).rjust(8,'0')
    end
    stream += '0000'
    stream.pack('B*')
  end

  def transmit
    puts "Transmiting..."
    @socket.send as_bytestream, 0, "matelight.rocks", 1337
  end

  def xsize
    @screen.shape[0]
  end

  def ysize
    @screen.shape[1]
  end

  def channels
    @screen.shape[2]
  end

  def tick
    xsize.times do |x|
      ysize.times do |y|
        channels.times do |chan|
          tick_value(x,y,chan)
        end
      end
    end
    transmit
  end

  def tick_value(x,y,chan)
    puts 'override me'
  end

  def screen
    @screen
  end

  def run
    while true do
      tick
      #sleep 0.5
    end
  end

  def neighbors(x,y,chan)
    x1 = (x==0) ? xsize-1 : x-1
    x3 = (x==xsize-1) ? 0 : x+1
    y1 = (y==0) ? ysize-1 : y-1
    y3 = (y==ysize-1) ? 0 : y+1

    [screen[x1,y1,chan], screen[x,y1,chan], screen[x3,y1,chan],
    screen[x,y1,chan], screen[x,y3,chan],
    screen[x1,y3,chan], screen[x,y3,chan], screen[x3,y3,chan]]
  end
end

class Matelife < Matelight
  def tick_value(x,y,chan)
    sum = neighbors(x,y,chan).sum / 255
    if screen[x,y,chan] > 0
      if sum > 1 and sum < 4
        @next[x,y,chan] = 255
      else
        @next[x,y,chan] = 0
      end
    else
      if sum > 2 and sum < 4
        @next[x,y,chan] = 255
      else
        @next[x,y,chan] = 0
      end
    end
  end
end

m = Matelife.new
m.run
