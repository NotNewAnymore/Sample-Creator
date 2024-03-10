require("colorize")
$position = 0
$magnitude = 0
data = ""
$rate = 44100
$waveLengthMult = 1

def sineWave(data, noise)
  ($rate).times {
    $position += $waveLengthMult
    $magnitude = (Math.sin(($position + Random.rand(0..noise)) * 0.02 + 1) + 1) * 127
    $magnitude = $magnitude.round
    displayMagnitude $magnitude
    data += $magnitude.chr()
  }
  data
end

def squareWave(data, noise)
  ($rate).times {
    $position += $waveLengthMult
    #$magnitude = Math.sin(($position + Random.rand(0..noise))).round()
    #$magnitude = ($magnitude + 1) * 127.round
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
    $magnitude = ($magnitude.round) % 255
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
def combineSounds (input)

end

if __FILE__ == $0
  continue = false
  sounds = []
  while continue == false
    puts "What do you want to generate?\n
0: Sine wave\n
1: Square Wave\n
2: Tan wave"
    ui = gets().chomp
    if ui == "0"  #Sine wave
      puts "What tone multiplier do you want?"
      $waveLengthMult = gets.to_f()
      puts "How much noise do you want?"
      data = sineWave(data, gets.to_i())
      puts "Generated a sine wave"
    elsif ui == "1" #Square wave
      puts "What tone multiplier do you want?"
      $waveLengthMult = gets.to_f()
      puts "How much noise do you want?"
      data = squareWave(data, gets.to_i())
      puts "Generated a square wave"
    elsif ui == "2" #Tan wave
      puts "What tone multiplier do you want?"
      $waveLengthMult = gets.to_f()
      puts "How much noise do you want?"
      data = tanWave(data, gets.to_i())
      puts "Generated a tan wave"
    end
    sounds << data
    puts "1: Combine sounds \n2: Add another sound"
    if (gets().chomp == "1")
      continue = true
    end
  end

  puts "Import as unsigned 8-bit PCM"
  File.write("Sample", data)
end
