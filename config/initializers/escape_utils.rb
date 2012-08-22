# I think this is a temp fix. See http://crimpycode.brennonbortz.com/?p=42
module Rack
  module Utils
    def escape(s)
      EscapeUtils.escape_url(s)
    end
  end
end
