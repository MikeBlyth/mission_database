module ApplicationHelper

    def code_with_description
      s = self.code.to_s + ' ' + self.description
      return s
    end

    def opposite_sex(s)
      return :male if s == :female
      return :female if s == :male
      return nil unless s.respond_to? :downcase
      return 'F' if s.downcase[0] == 'm'
      return 'M' if s.downcase[0] == 'f'
    end	

end

require "#{Rails.root}/config/initializers/date_formats.rb"

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
