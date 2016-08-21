# include thrift-generated code
$:.push('gen-rb')

require 'rubygems'
require 'thrift'
require 'simple_string_service'
require 'topic_service'
require 'active_support/inflector'
require 'httparty'
require 'json'
require 'ostruct'

module ThriftBenchmark

  class Client
    attr_accessor :transport, :type

    def initialize(type, port = 9090)
      @transport = Thrift::BufferedTransport.new(Thrift::HTTPClientTransport.new("http://localhost:#{port}"))
      @type = type
    end

    def open_connect
      transport.open
    end

    def close_connect
      transport.close
    end

    def get_feature(query)
      client.get_feature(query)
    end

    private

    def client
      @client ||= "ThriftBenchmark::#{ type }Service::Client".constantize.new(protocol)
    end

    def protocol
      @protocol ||= Thrift::CompactProtocol.new(transport)
    end
  end
end

module JsonBenchmark
  class Client

    def initialize(port = 9090)
      @port = port
    end

    def open_connect
      # not needed here
    end

    def close_connect
      # not needed here
    end

    def get_feature(size)
      options = { path: "http://localhost:#{@port}/",
                  body: JSON.generate({ size: size })
                }
      response = make_request(options)
      res = JSON.parse(response.body)
      OpenStruct.new(topics: res['topics'], time_spend: res['time_spend'])
    end

    private

    def make_request(options)
      HTTParty.post(options[:path],
                    { body: options[:body],
                      headers: { 'Content-Type': 'application/json',
                                 'Accept': 'application/json' } }
                   )
    end
  end
end
