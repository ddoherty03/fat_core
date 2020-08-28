# frozen_string_literal: true

require 'fat_core/numeric'

module Kernel
  # Run the given block and report the time it took to execute in
  # hour-minute-second form.
  #
  # @example
  #   result = time_it 'Fibbonacci' do
  #     Fibbonacci.fib(30)
  #   end
  #   puts "For 30 its #{result}"
  #   => "Ran Fibonacci in 30:23"
  #
  # @param name [String, #to_s] an optional name to use for block in timing
  #   message.
  # @return [Object] whatever the block returns
  def time_it(name = 'block', &block)
    start = Time.now
    result = yield block
    run_time = Time.now - start
    puts "Ran #{name} in #{run_time.secs_to_hms}"
    result
  end
end
