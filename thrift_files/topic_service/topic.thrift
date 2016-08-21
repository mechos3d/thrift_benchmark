# vi: ft=c

include "widget.thrift"

namespace rb ThriftBenchmark

struct Topic {
  1:string alternative_headline,        // 200 cyrillic
  2:string announce,                    // 400 cyrillic
  3:string content_type,                // 6 ascii
  4:i32 dispatched_at,                  // unix seconds
  5:string headline,                    // 200 cyr
  6:i32 id,                             // 1-1000
  7:bool is_visible,
  8:bool partner_related,
  9:string preview_token,              // 12 ascii
  10:i32 published_at,                  // unix seconds
  11:list<widget.Widget> widgets               // array of 5 widgets
}
