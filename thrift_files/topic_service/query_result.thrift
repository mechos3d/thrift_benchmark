namespace rb ThriftBenchmark

include "topic.thrift"

service TopicService {
  QueryResult get_feature(1:i32 size)
}

struct QueryResult {
  1:list<topic.Topic> topics,
  2:i32 time_spend
}
