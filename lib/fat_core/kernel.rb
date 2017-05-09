require 'fat_core/numeric'

module Kernel
  def time_it(name = 'block', &block)
    start = Time.now
    result = yield block
    run_time = Time.now - start
    puts "Ran #{name} in #{run_time.secs_to_hms}"
    result
  end
end
