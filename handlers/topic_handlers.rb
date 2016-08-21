module ThriftBenchmark
  class TopicServiceHandler

    def initialize(options = {})
      @random_ascii_string_file = File.open("res/ascii", 'r').read.slice(0,1000)
      @random_utf_string_file = File.open("res/utf_small", 'r').read.slice(0,5000)
    end

    def get_feature(size)
      time_start = (Time.now.to_f * 1000).to_i
      topics = generate_topics(size)

      time_spend =  (Time.now.to_f * 1000).to_i - time_start
      puts "server-side time: #{ time_spend }"
      QueryResult.new(topics: topics, time_spend: time_spend)
    end

    private

    def generate_topics(size)
      size.times.map{ generate_topic }
    end

    def generate_topic
      Topic.new(generate_attributes)
    end

    def generate_attributes
      {
        alternative_headline: generate_string(200),
        announce: generate_string(400),
        content_type: generate_ascii_string,
        dispatched_at: unix_seconds,
        headline: generate_string(200),
        id: rand(10_000),
        is_visible: true,
        partner_related: false,
        preview_token: generate_ascii_string,
        published_at: unix_seconds,
        widgets: generate_widgets(3)
      }
    end

    def generate_string(size)
      full_string = @random_utf_string_file
      start = rand(full_string.size - size - 1)
      full_string[start, size]
    end

    def generate_ascii_string
      num = 12
      full_string = @random_ascii_string_file
      start = rand(full_string.size - num - 1)
      full_string[start, num]
    end

    def unix_seconds
      @time ||= Time.now.to_i
    end

    def generate_widgets(num)
      num.times.map do
        Widget.new(generate_widget_attributes)
      end
    end

    def generate_widget_attributes
      { id: rand(10_000),
        type: generate_ascii_string,
        data: generate_string(1000),
        created_at: unix_seconds,
        updated_at: unix_seconds,
        position: rand(100)
      }
    end

  end # TopicServiceHandler end
end # ThriftBenchmark module end
