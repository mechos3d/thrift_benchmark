module ThriftBenchmark
  class SimpleStringServiceHandler

    def initialize(options = {})
      @encoding = options[:encoding]
      @random_string = File.open("res/#{ @encoding }", 'r').read
    end

    def get_feature(query)
      time_start = (Time.now.to_f * 1000).to_i

      result = read_random_fragment(query)

      time_spend =  "server_side_ms: #{ (Time.now.to_f * 1000).to_i - time_start }"
      puts time_spend
      result += time_spend
    end

    private

    # works ok only for sizes < 2427039 chars
    def read_random_fragment(size)
      start = rand(@random_string.size/2)
      result = @random_string[start, size]
      if @encoding == 'ascii'
        result.force_encoding(Encoding::ASCII_8BIT)
      else
        result.force_encoding(Encoding::UTF_8)
      end
    end
  end # SimpleStringServiceHandler end
end # ThriftBenchmark module end
