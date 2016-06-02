Conquer.bar do
  every(5.seconds) { Time.now }
  separator
  every(8.seconds) { %w(Hello World).sample }
  separator
  scroll do
    block { `mpc -w current`.chomp }
  end
end
