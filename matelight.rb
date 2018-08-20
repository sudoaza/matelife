require 'nmatrix'
require 'socket'

class Matelight
  attr_accessor :dims, :config, :screen

  def initialize(config = {})
    @config = config
    @socket = UDPSocket.new
    @dims   = [16,40,3]
    @next   = NMatrix.zeros(dims, :dtype => :byte, :scale => 255)
    @screen = init
  end

  def server
    config[:server] || "matelight.rocks"
  end

  def debug?
    !!config[:debug]
  end

  def framerate
    config[:framerate] || 2
  end

  def init
    NMatrix.random(dims, :dtype => :byte, :scale => 255)
  end

  def stream
    _stream = ''
    @screen.each do |e|
      _stream += e.to_s(2).rjust(8,'0')
    end
    _stream += '0' * 8 * 4
  end

  def as_bytestream
    stream.pack('B*')
  end

  def transmit
    puts "Transmiting..."
    puts stream, as_bytestream if debug?
    @socket.send as_bytestream, 0, server, 1337
  end

  def xsize
    @screen.shape[1]
  end

  def ysize
    @screen.shape[0]
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
    @screen = @next
    transmit
  end

  def tick_value(x,y,chan)
    puts 'override me'
  end

  def run
    while true do
      tick
      # dos much?
      sleep 1.0 / framerate
    end
  end

  def neighbors(x,y,chan)
    # closed universe
    left = (x==0) ? xsize-1 : x-1
    right = (x==xsize-1) ? 0 : x+1
    down = (y==0) ? ysize-1 : y-1
    up = (y==ysize-1) ? 0 : y+1

    [screen[up,left,chan], screen[up,x,chan], screen[up,right,chan],
    screen[y,left,chan], screen[y,right,chan],
    screen[down,left,chan], screen[down,x,chan], screen[down,right,chan]]
  end
end
