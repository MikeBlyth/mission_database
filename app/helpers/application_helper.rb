module ApplicationHelper

    def code_with_description
      s = self.code.to_s + ' ' + self.description
      return s
    end

    # Given an object (or nil) described by method description_method, return 
    # * nil_value if object is nil or its description is missing or is "unspecified"
    # * description_method otherwise
    # Example:
    #   given m = Member with status=>on_field_status, residence_location=>nil, country=>nil
    #     description_or_blank(m.residence_location) returns nil
    #     description_or_blank(m.residence_location, "Unknown") returns "Unknown"
    #     description_or_blank(m.status) returns "On field"
    #     description_or_blank(m.country, '?', :name) returns '?'
    def description_or_blank(object, nil_value='', description_method=:description)
      nil_value = nil if nil_value == :nil
      return nil_value unless object
      value = object.send description_method || 'unspecified'
      return value.downcase == 'unspecified' ? nil_value : value
    end

    # Tries sending 'key' to object as method, then as hash key (string and symbol)
    #   so a model, a hash, or other object can be accessed the same way
    def method_or_key(object, key)
      if object.respond_to? key 
        return object.send(key)
      elsif object.is_a? Hash
        return object[key] || object[key.to_s] || object[key.to_sym]
      else
        return nil
      end
    end

    def opposite_sex(s)
      return :male if s == :female
      return :female if s == :male
      return nil unless s.respond_to? :downcase
      return 'F' if s.downcase[0] == 'm'
      return 'M' if s.downcase[0] == 'f'
    end	
    
    # Returns true unless x = false.
    # Same as x || x.nil?
    def default_true(x)
      return x != false
    end

    # Join the elements in array a with delimiter (default ", ")
    #   but first trim whitespace from elements and delete blank elements
    # Example
    # smart_join([' a ', '', nil, 3.5, "25\n"]) -> "a, 3.5, 25" 
    def smart_join(a, delim=', ')
      a.collect{|x| (x || '').to_s.strip}.delete_if{|x| x.blank?}.join(delim)
    end
  
    # Just add '_id' to a string or symbol
    def link_id(s)
      return s if s =~ /_id\z/  # no change if it already ends in _id
      val = s.to_s + "_id"
      val = val.to_sym if s.is_a? Symbol
      return val
    end  
    
    # Return the value of an association id, 
    # For example link_value(record, :status) is the same as record.status_id
    # Link can be either the name (:status) or id (:status_id)
    def link_value(record, link)
      return record.send(link_id(link))  # where link_id adds '_id' if not there
    end  

    # This is just for Nigerian phone numbers for now, to keep it really simple
    # It's highly localized -- probably best to make it optional!
    # takes an 11-digit phone number starting in 0, or +234 plus 10 digits, and formats it
    # ToDo: make this optional
    def format_phone(s,options={})
      return s unless s.respond_to? :phone_format
      return s.phone_format(options)
    end

#    # Standardize phone number string to "+2349999999" format
#    def phone_std(s,options={})
#      return s unless s.respond_to? :phone_std
#      return s.phone_format(options)
#    end

  # with incoming body like
  #   COMMAND_1 
  #   command_2 Parameters for this command 
  #   ...
  # make array like [ [command_1, ''], [command_2, 'Parameters for this command']]
  def extract_commands(body)
    commands = body.lines.map do |line| 
      line =~ /\s*(\w+)( .*)?/ 
      [($1 || '').downcase, ($2 || '').strip.chomp]
    end  
 #puts "*** Commands = #{commands}"
    return commands
  end
  

end  # ApplicationHelper module

#******* Anything below this point is not in the module itself *********

require "#{Rails.root}/config/initializers/date_formats.rb"

# Add some methods to nil so we don't always have to make it a special case
class NilClass
  def strip
    nil
  end
end

class String
  def phone_format(options={})
    if Settings.formatting.format_phone_numbers && !self.blank? 
      delim_1 = options[:delim_1] || " "
      delim_2 = options[:delim_2] || " "
      squished = self.ljust(7).gsub(/[^\+0-9]/,'').gsub('+234','0')
      if squished.length == 11 && squished[0]=='0'
        return squished.insert(7,delim_2).insert(4,delim_1)
      end
    end
    return self  # nothing to do
  end

  # Standardize phone number string to "+2349999999" format
  def phone_std(options={})
    return nil if self.blank?
      raw = self
#    raw = (self =~ /\A[0+]/  ? '' : '0') + self  # Add zero if leading plus or zero not present
    return raw.gsub(/\A0/,Settings.contacts.local_country_code).gsub(/-|\.| /,'')
  end

end

# Add to_ordinal method to Fixnums, so we get 1.to_ordinal is 1st and so on
class Fixnum
  def to_ordinal
    if (10...20)===self
      "#{self}th"
    else
      g = %w{ th st nd rd th th th th th th }
      a = self.to_s
      c=a[-1..-1].to_i
      a + g[c]
    end
  end

  # Add methods blank? and empty? and make them false for all Fixnum
  def blank?
    return false
  end

  def empty?
    return false
  end
end # class Fixnum 

module ActiveRecord  
  class Base  

    def update_record_without_timestamping  
      class << self  
        def record_timestamps; false; end  
      end  

      save!  

      class << self  
        def record_timestamps; super ; end  
      end  
    end  

  end  
end

