unless ARGV[0]
    puts "You need to include a password to test."
    puts "Usage: ruby passwordstrength.rb SecretPassword"
    exit
  end

password = ARGV[0]
word = password.split(//)
letters = Hash.new(0.0)
set_size = 96                 
#62 for alphaNumeric
#26 for only lowercase or only uppercase, 
#10 for only digits

word.each do |i|              #Count how many instances of each element there are within the array
  letters[i] += 1.0
end


## NOT FINISHED