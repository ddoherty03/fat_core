module Kernel
  def time_it(message = '', &block)
    start = Time.now
    yield block
    run_time = Time.now - start
    puts "Ran #{message} in #{run_time.secs_to_hms}"
  end
end
