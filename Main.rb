require("colorize") #External library for printing to console in color.
require("fox16") #GUI library, intended to provide very efficent, cross-platform, and easy to use UI.
include Fox
$position = 0
$magnitude = 0
$noise = 15
data = ""
$rate = 44100
$waveLengthMult = 1
$continue = false
$SquarePulseWidth = 110
$offset = 0

def sineWave(data, noise)
    $position = $offset
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
    $position = $offset
  ($rate).times {
    $position += $waveLengthMult
    if ($position % (240) < $SquarePulseWidth)
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
    $position = $offset
  ($rate).times {
    $position += $waveLengthMult
    $magnitude = (Math.tan(($position + Random.rand(0..noise)) * 0.02 + 1) + 1) * 127
    $magnitude = ($magnitude.round) % 255 #Turn the magnitude into an int so it can be saved as a char, and ensure it's between 0 and 255 without adding too much distortion
    displayMagnitude($magnitude)
    data += $magnitude.chr()
  }
  data
end

def pwmSquareWave(data, otherWave)
    $position = $offset
  sPos = 0
  ($rate).times {
    $position += $waveLengthMult
    if ($position % (240) < otherWave[sPos].ord * 0.9)
      $magnitude = 255
    else
      $magnitude = 0
    end
    displayMagnitude $magnitude
    data += $magnitude.chr()
    sPos += 1
  }
  data
end

def fmSineWave(data, otherwave)
    $position = $offset
    otherWavePositon = 0
    ($rate).times {
    $position += otherwave[otherWavePositon].ord * 0.01 * $waveLengthMult
    otherWavePositon += 1
    $magnitude = (Math.sin(($position + Random.rand(0..$noise)) * 0.02 + 1) + 1) * 127 #Run-on sentance but in code. Figures out the current magnitude from the position, noise, and a pile of constants.
    $magnitude = $magnitude.round #Turn the magnitude into an int so it can be saved as a char
    displayMagnitude $magnitude
    data += $magnitude.chr()
  }
  data
end

def volumeAdjust(data, volume)
  i = 0
  data.length.times{
    data[i] = ((data[i].ord * volume) % 255).to_i.chr
    displayMagnitude data[i].ord
    i += 1
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
  sounds = []
  continue = false
  #Set up GUI =======================================================================================================
  Thread.new {
    application = FXApp.new("Sound Generator", "Henry")
    mainWindow = FXMainWindow.new(application, "Waveform Settings")

    universalSettings = FXGroupBox.new(mainWindow, "Universal Settings", opts = GROUPBOX_NORMAL)
    FXLabel.new(universalSettings, "Wavelength Multiplier: float, 0-infinite")           #Wavelength
    waveLengthEntry = FXTextField.new(universalSettings, 15); waveLengthEntry.text = "1"
    FXLabel.new(universalSettings, "Noise: float, 0-infinite")                           #Noise
    noiseEntry = FXTextField.new(universalSettings, 15); noiseEntry.text = "15"
    FXLabel.new(mainWindow, "Pulse width, int,  0-220")                                   #Pulse Width
    pulseWidthEntry = FXTextField.new(mainWindow, 15); pulseWidthEntry.text = "110"
    FXLabel.new(mainWindow,"Offset, float, 0-infinite")
    offsetEntry = FXTextField.new(mainWindow, 15); offsetEntry.text = "0"               #Offset

    printButton = FXButton.new(mainWindow, "Print waves", nil, application)
    printButton.connect(SEL_COMMAND) do
      outerIteration = 0
      sounds.each() { |n|
        iteration = 0
        print "\n#{outerIteration}:"
        160.times {
          displayMagnitude(n[iteration].ord)

          iteration += 1
        }
        outerIteration += 1
      }
    end

    enterButton = FXButton.new(mainWindow, "Enter", nil, application)
    enterButton.connect(SEL_COMMAND) do
      puts "Applied Settings!"
      $waveLengthMult = waveLengthEntry.text.chomp.to_f
      $noise = noiseEntry.text.chomp.to_f
      $SquarePulseWidth = pulseWidthEntry.text.chomp.to_f
      $offset = offsetEntry.text.chomp.to_f
    end
    application.create()
    mainWindow.show(PLACEMENT_SCREEN)
    application.run()
    application.destroy
  }
   #Main loop ==================================================================================================================
  while continue == false
    puts "What do you want to generate?\n
0: Sine wave
1: Square Wave
2: Tan wave
3: Pulse Width Modulation
4: Delete a wave
5: Adjust volume of a wave
6: FM Synthesis"
    ui = gets().chomp

    if ui == "0" #Sine wave
      # puts "What tone multiplier do you want?"
      # $waveLengthMult = gets.to_f()
      # puts "How much noise do you want?"
      # data = sineWave("", gets.to_i())
      data = sineWave("", $noise)
      sounds << data
      puts "Generated a sine wave"
    elsif ui == "1" #Square wave
      # puts "What tone multiplier do you want?"
      # $waveLengthMult = gets.to_f()
      # puts "How much noise do you want?"
      data = squareWave("", $noise)
      sounds << data
      puts "Generated a square wave"
    elsif ui == "2" #Tan wave
      data = tanWave("", $noise)
      sounds << data
      puts "Generated a tan wave"
    elsif ui == "3" #PWM
      puts "Which wave to you want to use?"
      ui = gets.chomp.to_i
      data = pwmSquareWave("", sounds[ui])
      sounds << data
      puts "Created PWM from #{ui}!"
    elsif ui == "4" #Delete wave
      puts "Which wave do you want to delete?"
      sounds.delete_at(gets.chomp.to_i)
    elsif ui == "5"  #Volume
      puts "Which wave to you want to adjust?"
      ui = gets.chomp.to_i()
      puts "what volume do you want?"
      vol = gets.chomp.to_f()
      data = sounds[ui]
      sounds[ui] = volumeAdjust(data, vol)
    elsif ui == "6" #FM Synthesis
      puts "Which wave to you want to use?"
      ui = gets.chomp.to_i
      data = fmSineWave("", sounds[ui])
      sounds << data
      puts "Created FM Syntesis from #{ui}!"
    end

    puts "1: Combine all sounds and save
2: Add or remove sound
3: Save a specific sound"
    ui = gets().chomp
    if (ui == "1") #Combine all sounds and save
      data = combineSounds(sounds)
      puts "Import as unsigned 8-bit PCM"
      File.write("Sample", data)
      exit
    elsif (ui == "3")
      puts "What sound do you want to save?"
      data = sounds[gets.chomp.to_i]
      puts "Import as unsigned 8-bit PCM"
      File.write("Sample", data)
    end
  end
end
