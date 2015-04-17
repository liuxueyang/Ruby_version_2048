#!/usr/bin/ruby 

require "io/console"
require "time"

mar = Array.new(16, 0) # sheet value array
$score = 0
$target = 2048
$pieces = 0

$colo = Hash.new
$colo[2] = 30
$colo[4] = 31
$colo[8] = 32
$colo[16] = 33
$colo[32] = 34
$colo[64] = 35
$colo[128] = 36
$colo[256] = 37
$colo[512] = 42
$colo[1024] = 45
$colo[2048] = 41

def operate(mar, ran, gap)
  mark = false
  ran.each { |index| 
    ar = index.step(index + 3 * gap, gap).collect { |ind| ind}
    tm_ar = ar.collect{|ie| mar[ie]}
    pre_tm_ar = tm_ar.clone
    tm_ar.delete_if{|item| item == 0}
    (0..(tm_ar.size-1)).each {|ie|
      if tm_ar[ie] == tm_ar[ie+1]
        tm_ar[ie] *= 2
        $score += tm_ar[ie]
        tm_ar[ie+1] = 0
      end 
    }
    tm_ar.delete_if{|item| item == 0}
    (4-tm_ar.size).times {
      tm_ar << 0
    }
    tm_ar.size.times {|item|
      mar[ar[item]] = tm_ar[item]
    }
    mark = true if tm_ar != pre_tm_ar
  }
  mark
end

def myloop(mar, a_pos, gap) 
  a_pos.each{|item|
    3.times {|i|
      if mar[item+i*gap] == mar[item+i*gap+gap]
        return true
      end 
    }
  }
  false
end

def judge_lose_full(mar) 
  ro = [0, 4, 8, 12]
  col = [0, 1, 2, 3]
  !myloop(mar, ro, 1) && !myloop(mar, col, 4)
end

def lose?(mar) 
  cnt = mar.count(0)
  return cnt == 0 ? judge_lose_full(mar) : false
end

def win?(mar) 
  max_value = mar.sort[-1]
  return max_value == 2048 ? true : false
end

def genera_num(mar) 
  r_pos = Random.new # get pos random seed
  ran = [2, 4] # generate random new value
  pos = r_pos.rand(16)
  while mar[pos] != 0 
    r_pos = Random.new
    pos = r_pos.rand(16)
  end

  r_val = Random.new 
  val = r_val.rand(2)
  mar[pos] = ran[val]

end

def move?(mar, ba_r) 
  val = ba_r.collect{|i| mar[i]}
  val.count(0) > 0 ? true : false
end

def add(mar, direc)
  mark = false;
  case 
  when direc == "j" || direc == "\e[B"
    mark = (operate(mar, Array(12..15), -4) || move?(mar, Array(12..15))) #j
  when direc == "k" || direc == "\e[A"
    mark = (operate(mar, Array(0..3), 4) || move?(mar, Array(0..3))) #k
  when direc == "h" || direc == "\e[D"
    mark = (operate(mar, [0, 4, 8, 12], 1) || move?(mar, [0, 4, 8, 12])) #h
  when direc == "l" || direc == "\e[C"
    mark = (operate(mar, [3, 7, 11, 15], -1) || move?(mar, [3, 7 ,11, 15])) #l
  end
  if mark 
    genera_num(mar)
    $pieces += 1
  end
end

# print sheet
def sheet(mar) 
  printf("%s\n", "I am a vimer. So you can use vim-keybindings -.-")
  printf("%s\n", "You can also use direction keys...")
  puts "Press 'q' or 'ESC' to quit."
  
  printf("\nRuby 2048 (https://github.com/liuxueyang/Ruby_version_2048)\n")
  print Time.now.rfc2822
  printf("\n\n    target = %-4d pieces = %-4d score = %-4d\n", $target, $pieces, $score)
  printf("\n%s%s\n", " " * 5, "~" * 35)
  printf("%s%s\n\n", " " * 5, "~" * 35)


  printf("%s%s%s\n%s", " " * 8 + "/", ("-" * 6 + "+") * 3,
        "-" * 6 + "\\", " " * 8)
  16.times { |i|
    if mar[i] != 0
      printf("|\033[%dm%5d \033[0m", $colo[mar[i]], mar[i])
    else 
      printf("|%5s ", " ")
    end 
    if (i+1) % 4 == 0 
      printf("|\n") 
      if (i+1) != 16
        printf("%s%s%s\n%s", " " * 8 + "|", ("-" * 6 + "+") * 3,
              "-" * 6 + "|", " " * 8)
      else 
        printf("%s%s%s\n%s", " " * 8 + "\\", ("-" * 6 + "+") * 3,
              "-" * 6 + "/", " " * 8)
      end 
    end 
  }
  printf("\n%s%s\n", " " * 5, "~" * 35)
  printf("%s%s\n\n", " " * 5, "~" * 35)
end

def read_char 
  STDIN.echo = false 
  STDIN.raw!

  input = STDIN.getc.chr 
  if input == "\e" 
    input << STDIN.read_nonblock(3) rescue nil
    input << STDIN.read_nonblock(2) rescue nil
  end 
ensure 
  STDIN.echo = true
  STDIN.cooked!
  return input
end


$start = Time.now
genera_num(mar)
$pieces += 1
system "clear"
while true
  sheet(mar)
  direc = read_char
  if direc == "q" || direc == "\e" || direc == "\u0003"
    printf("Your score: %d\n", $score)
    printf("This game lasted %02d:%02d:%02d.\n\n", $hours, $minutes, $seconds)
    break 
  end
  add(mar, direc)

  system "clear"
  sheet(mar)

  $end = Time.now
  $time_gap = $end - $start 
  $seconds = $time_gap % 60
  $minutes = (($time_gap - $seconds) % 3600) / 60
  $hours = $time_gap / 3600
  if win?(mar) 
    puts "Congratulations! You Win!"
    printf("This game lasted %02d:%02d:%02d.\n\n", $hours, $minutes, $seconds)
    break
  end

  if lose?(mar) 
    printf("Your score: %d\n", $score)
    printf("This game lasted %02d:%02d:%02d.\n\n", $hours, $minutes, $seconds)
    puts "You have lost, better luck next time T^T...\n\n"
    break
  end
  system "clear"
end 

