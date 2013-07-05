xs = File.readlines ARGV.shift
xs = xs.map(&:chomp).map {|l| l.split(/\s/, 2)[0] }
p xs.grep(/^#{ARGV.shift}/)
