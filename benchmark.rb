require 'benchmark'
require_relative 'client'
require 'elasticsearch/persistence/model'
require 'slop'
require 'ostruct'

OPTS = Slop.parse do |o|
  o.bool '-nl', '--nolog', 'Disable logging', default: false
  o.integer '-n', '--number', 'Number of iterations', default: 10
  o.bool '-rm', '--remove', 'Recreate indexes', default: false
  o.string '-t', '--type', 'Test type', default: 'ascii'
  o.bool '-us', '--unstable', 'Unstable connection - recreate everytime', default: false
end.freeze
# available types are: ascii, utf, topic, json

unless OPTS.nolog?
  class Log
    include Elasticsearch::Persistence::Model
    attribute :kind, String, type: 'string', mapping: { index: 'not_analyzed' }
    attribute :message_size, Integer, default: 0, mapping: { type: 'integer' }
    attribute :time_spend, Integer, default: 0, mapping: { type: 'integer' }
  end
  Log.gateway.client.indices.delete index: Log.index_name if OPTS.remove?
end

module Interactions
  private

  def perform_stable(stub:, size:, kind:)
    stub.open_connect
    50.times do |j|
      result = 0
      measure = Benchmark.measure do
        result = stub.get_feature(size)
      end
      time_spend = calculate(measure, result)
      puts time_spend

      kind_str = "#{kind}_stable_connection"
      Log.create(message_size: size, time_spend: time_spend, kind: kind_str) unless OPTS[:nolog]
    end
    stub.close_connect
  end

  def perform_recreating(stub:, size:, kind:)
    50.times do |j|
      result = 0
      measure = Benchmark.measure do
        stub.open_connect
        result = stub.get_feature(size)
        stub.close_connect
      end
      time_spend = calculate(measure, result)
      puts time_spend

      kind_str = "#{kind}_recreating_connection"
      Log.create(message_size: size, time_spend: time_spend, kind: kind_str) unless OPTS[:nolog]
    end
  end

  def calculate(measure, result) # HACK because of topic_service returning time-spend on server
    time = (measure.real * 1000).to_i
    return time if result.is_a? String
    time - result.time_spend
  end
end

class ConnectionTest
  include ::Interactions

  def initialize(unstable = false)
    @unstable = unstable
  end

  def perform(n, type, stable = true)
    case type
    when 'ascii'
      simple_string_test(n, encoding: 'ascii')
    when 'utf'
      simple_string_test(n, encoding: 'utf')
    when 'topic'
      topic_test(n)
    when 'json'
      json_test(n)
    end
  end

  private

  def simple_string_test(n, options = {})
    kind = "string_#{ options[:encoding] }"
    stub = ThriftBenchmark::Client.new('SimpleString')

    n.times do |i|
      size =
        if options[:encoding] == 'ascii'
          i*10000 #(i * 2 + 1) ** 3
        else
          (i * 2 + 1) ** 2
        end
      p "Starting iteration for #{kind}, length (chars): #{size}"
      if @unstable
        perform_recreating(stub: stub, size: size, kind: kind)
      else
        perform_stable(stub: stub, size: size, kind: kind)
      end
    end
  end

  def topic_test(n)
   kind = 'topic'
   puts "Commencing #{kind}_"

   stub = ThriftBenchmark::Client.new('Topic')
   n.times do |i|
     next if i == 0
     size = i * 2 + 1
     p "Starting iteration for topic, quantity: #{ size }"
     perform_stable(stub: stub, size: size, kind: kind)
   end

  end

  def json_test(n)
    kind = 'json'
    puts "Commencing #{kind}_"

    stub = JsonBenchmark::Client.new
    n.times do |i|
     next if i == 0
     size = i * 2 + 1
     p "Starting iteration for json_topic, quantity: #{ size }"
     perform_stable(stub: stub, size: size, kind: kind)
   end

  end

end # ConnectionTest end

ConnectionTest.new(OPTS[:unstable]).perform(OPTS[:number], OPTS[:type])
