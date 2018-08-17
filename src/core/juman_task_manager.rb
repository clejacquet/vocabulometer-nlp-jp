require_relative 'regex_scanner'
require 'open3'
require 'concurrent'

class JumanTaskManager
  def initialize(thread_count)
    @task_queue = Queue.new

    @threads = (0...thread_count).collect do |id|
      Thread.new do
        Open3.popen2('jumanpp') do |stdin, stdout|
          while (task = @task_queue.pop)
            task.call stdin, stdout
          end
        end
      end
    end
  end

  def add_parse_task(input)
    sub_inputs = input
                     .split(/\r?\n/)
                     .delete_if { |paragraph| paragraph.empty? }

    out = Array.new(sub_inputs.size)
    counter = Concurrent::CountDownLatch.new(sub_inputs.size)

    sub_inputs.each_index do |i|
      @task_queue << proc do |stdin, stdout|

        JumanTokenizer.parse(sub_inputs[i], stdin, stdout) do |output|
          out[i] = output[:processed]
          counter.count_down
        end
      end
    end

    counter.wait

    {
        result: out
    }
  end

  def add_raw_task(input)
    sub_inputs = input.split(/\r?\n/)
    out = Array.new(sub_inputs.size)
    counter = Concurrent::CountDownLatch.new(sub_inputs.size)

    sub_inputs.each_index do |i|
      @task_queue << proc do |stdin, stdout|

        JumanTokenizer.raw(sub_inputs[i], stdin, stdout) do |output|
          out[i] = output[:processed]
          counter.count_down
        end
      end
    end

    counter.wait

    out
  end

  def join_all
    @task_queue.close
    @threads.each {|thread| thread.join}
  end
end