require 'thin'
require_relative 'topic_generator'
require 'json'

class SimpleAdapter
  def call(env)
    req = Rack::Request.new(env)
    req_body = JSON.parse(req.body.read)

    response_body = TopicGenerator.new.get_feature(req_body['size'])
    [
      200,
      { 'Content-Type' => 'application/json' },
      [ response_body.to_json ]
    ]
  end
end

Thin::Server.start('0.0.0.0', 9090) do
  use Rack::CommonLogger
  map '/' do
    run SimpleAdapter.new
  end
end
