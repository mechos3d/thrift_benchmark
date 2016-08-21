# vi: ft=c

namespace rb ThriftBenchmark

struct Widget {
  1:i32 id,             // 1-10000
  2:string type,        // 6 random  ascii
  3:string data,        // 1000 utf-8 cyrillic
  4:i32 created_at,     // unix seconds
  5:i32 updated_at,
  6:i32 position        // 1-100
}
