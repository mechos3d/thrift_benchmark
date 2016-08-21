# vi: ft=c

namespace rb ThriftBenchmark

	service SimpleStringService {

		string get_feature(1:i32 query)

  }
