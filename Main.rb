require("colorize") #External library for printing to console in color.
require("fox16") #GUI library, intended to provide very efficent, cross-platform, and easy to use UI.
include Fox
$position = 0
$magnitude = 0
$noise
data = ""
$rate = 44100
$waveLengthMult = 1

def sineWave(data, noise)
  ($rate).times {
    $position += $waveLengthMult
    $magnitude = (Math.sin(($position + Random.rand(0..noise)) * 0.02 + 1) + 1) * 127 #Run-on sentance but in code. Figures out the current magnitude from the position, noise, and a pile of constants.
    $magnitude = $magnitude.round #Turn the magnitude into an int so it can be saved as a char
    displayMagnitude $magnitude
    data += $magnitude.chr()
  }
  data
end

def squareWave(data, noise)
  ($rate).times {
    $position += $waveLengthMult
    if ($position % (240) < 110)
      $magnitude = 255
    else
      $magnitude = 0
    end
    displayMagnitude $magnitude
    data += $magnitude.chr()
  }
  data
end

def tanWave(data, noise)
  ($rate).times {
    $position += $waveLengthMult
    $magnitude = (Math.tan(($position + Random.rand(0..noise)) * 0.02 + 1) + 1) * 127
    $magnitude = ($magnitude.round) % 255 #Turn the magnitude into an int so it can be saved as a char, and ensure it's between 0 and 255 without adding too much distortion
    displayMagnitude($magnitude)
    data += $magnitude.chr()
  }
  data
end

#Display magnitude of current position.
def displayMagnitude(magnitude)
  m = magnitude
  case m
  when 0..31
    print "░".black
  when 32..63
    print "░".light_red
  when 64..95
    print "▒".yellow
  when 96..127
    print "▒".light_yellow
  when 128..159
    print "▓".green
  when 160..191
    print "▓".light_cyan
  when 192..223
    print "█".light_green
  when 224..255
    print "█".white
  end
end

#Iterate through all arrays in input, add them together, then divide by the number of items in input.
def combineSounds(input)
  datHolder = []
  input.each { |x| #Outer loop, iterates through the sound container
    x.length.times { |i| #Inner loop, iterates through the sound
      if datHolder[i].nil? #If the spot is empty, set it to the value of the current tone
        datHolder[i] = x[i].ord
      else #If the spot is not empty, add the current sound to the previous sound
        datHolder[i] += x[i].ord
      end
    }
  }
  datHolder.length.times { |i| #Divide everything by the number of sounds, to finish averaging it.
    datHolder[i] /= input.count
    datHolder[i] = datHolder[i].chr
  }
  datout = ""
  datHolder.each { |x| #Display sounds in visualizer
    datout += x
    displayMagnitude(x.ord)
  }
  datout              #Return combined sounds
end

if __FILE__ == $0
  application = FXApp.new("Sound Generator", "Henry")
  continue = false
  sounds = []
  while continue == false
    puts "What do you want to generate?\n
0: Sine wave\n
1: Square Wave\n
2: Tan wave"
    ui = gets().chomp
    if ui == "0" #Sine wave
      # puts "What tone multiplier do you want?"
      # $waveLengthMult = gets.to_f()
      # puts "How much noise do you want?"
      # data = sineWave("", gets.to_i())
      main = FXMainWindow.new(application, "Hello")
      FXLabel.new(main, "Wavelength Multiplier: float, 0-infinite")
      waveLengthEntry = FXTextField.new(main, 15)
      enterButton = FXButton.new(main, "Enter", nil, application)
      enterButton.connect(SEL_COMMAND) do
        puts "The button works!"
        $waveLengthMult = waveLengthEntry.text.chomp.to_f
        $noise = 0
      end
      FXButton.new(main, "Continue", nil, application, FXApp::ID_QUIT)
      application.create()
      main.show(PLACEMENT_SCREEN)
      application.run()
      data = sineWave("", 0)
      puts "Generated a sine wave"
    elsif ui == "1" #Square wave
      puts "What tone multiplier do you want?"
      $waveLengthMult = gets.to_f()
      puts "How much noise do you want?"
      data = squareWave("", gets.to_i())
      puts "Generated a square wave"
    elsif ui == "2" #Tan wave
      puts "What tone multiplier do you want?"
      $waveLengthMult = gets.to_f()
      puts "How much noise do you want?"
      data = tanWave("", gets.to_i())
      puts "Generated a tan wave"
    end
    sounds << data
    puts "1: Combine sounds \n2: Add another sound"
    if (gets().chomp == "1")
      continue = true
    end
  end
  data = combineSounds(sounds)
  puts "Import as unsigned 8-bit PCM"
  File.write("Sample", data)
end
