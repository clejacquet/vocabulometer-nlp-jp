require_relative 'core/juman_task_manager'
require_relative 'core/juman_tokenizer'
require_relative 'web/www'

JumanTokenizer.init

THREAD_COUNT = 8

WebApplication.load_manager(JumanTaskManager.new(THREAD_COUNT))
WebApplication.run!

Kernel.at_exit do
  WebApplication.finalize
end