# vi: ft=c

namespace rb ThriftBenchmark

include "query_result.thrift"
include "topic.thrift"

service TopicService {
  query_result.QueryResult get_feature(1:i32 size)
}

// size <= 1000
