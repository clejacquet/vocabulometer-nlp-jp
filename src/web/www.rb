require 'sinatra/base'


class WebApplication < Sinatra::Base
  def self.load_manager(task_manager)
    ObjectSpace.define_finalizer(self, self.method(:finalize))

    @manager = task_manager
  end

  def self.finalize
    puts 'Joining all threads'
    @manager.join_all
  end

  def self.manager
    @manager
  end

  set :bind, '0.0.0.0'
  set :port, ENV['PORT'] || 2345
  set :root, File.join(File.dirname(__FILE__), '../')

  get '/' do
    erb :index
  end

  post '/' do
    request.body.rewind
    data = JSON.parse(request.body.read)

    texts = data['texts']

    if texts === nil
      status 400

      headers 'Content-Type' => 'application/json'
      body ({error: 'Incorrect input'}).to_json
    else
      result = texts.map do |text|
        WebApplication.manager.add_parse_task(text)
      end

      status 200
      headers 'Content-Type' => 'application/json'
      body ({ texts: result }).to_json
    end
  end

  post '/raw' do
    request.body.rewind
    data = JSON.parse(request.body.read)

    texts = data['texts']

    if texts === nil
      status 400

      headers 'Content-Type' => 'application/json'
      body ({error: 'Incorrect input'}).to_json
    else
      result = texts.map do |text|
        WebApplication.manager.add_raw_task(text)
      end

      status 200
      headers 'Content-Type' => 'application/json'
      body ({ texts: result }).to_json
    end
  end
end