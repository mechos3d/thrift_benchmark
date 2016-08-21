$:.push('gen-rb')

require 'thrift'
require 'slop'
require 'active_support/inflector'

require 'simple_string_service'
require 'topic_service'
require_relative 'thrift_thin_server'
require_relative 'handlers/string_handlers'
require_relative 'handlers/topic_handlers'

OPTS = Slop.parse do |o|
  o.string '-t', '--type', 'Server type', default: 'ascii'
end.freeze # available types: ascii, utf, topic

module ThriftBenchmark
  class Server

    def initialize(type, options = {})
      @type = type
      handler = handler_type.new(options)
      @processor = processor_type.new(handler)
    end

    def start_instance
      port = 9090
      server = Thrift::ThinHTTPServer.new(@processor, port: port, protocol_factory: Thrift::CompactProtocolFactory.new )
      puts "Starting the Thrift Thin Server..."
      server.serve
      puts "done."
    end

    def self.start(type)
      server = case type
      when 'ascii'
        ThriftBenchmark::Server.new('SimpleString', encoding: 'ascii')
      when 'utf'
        ThriftBenchmark::Server.new('SimpleString', encoding: 'utf')
      when 'topic'
        ThriftBenchmark::Server.new('Topic')
      end
      server.start_instance
    end

    private

    def handler_type
      "ThriftBenchmark::#{ @type }ServiceHandler".constantize
    end

    def processor_type
      "ThriftBenchmark::#{ @type }Service::Processor".constantize
    end
  end # Server end
end # ThriftBenchmark module end

ThriftBenchmark::Server.start(OPTS[:type])
