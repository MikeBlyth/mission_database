module Utilities
  def string_dump(s)
    begin
      puts s
    rescue
      puts "*** ERROR #{$!} on trying to print string"
    end
    puts "#{s.bytes.to_a}, #{s.encoding}"
  end

end