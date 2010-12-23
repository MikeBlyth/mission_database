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
include ActionView::Helpers::FormOptionsHelper
# TODO: May be best to replace this with the Rails method that does the same thing.
# http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-option_groups_from_collection_for_select
def options_for_select_with_grouping(option_list, grouping_column, selected, value_column=:id, label_column=:description)
  options = []
  groups = option_list.group_by{|opt| opt[grouping_column]}.sort_by { |k,v| k}
  groups.each do |group|
    group_label = group[0]
    options << "<optgroup label='#{group_label}'>"
    group_options = group[1].sort_by {|opt| opt[label_column]}
    group_options.each do |option|
      
      if option[value_column] == selected
        options <<  "<option value='#{option[value_column]}' selected='selected'>#{option[label_column]}<\/option>"
      else
        options <<  "<option value='#{option[value_column]}'>#{option[label_column]}<\/option>"
      end
    end
  end
  options
end

def location_selection_list (selected=-1)
cities = City.where(1).order('name')
return option_groups_from_collection_for_select(cities, :locations_sorted, :name, :id, :description, selected)
  selections =  Location.select("id, city_id, description")
  hashed_locations = []
  selections.each do | selection |
    hashed_locations << {:id => selection.id, :city=>selection.city.name, :description => selection.description}
  end
  options_for_select_with_grouping(hashed_locations, :city, selected)
  
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

end

