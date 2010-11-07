# require 'prawn_extend'
require 'reports_helper'
class MultiColumnTest < Prawn::Document
include ReportsHelper


  def to_pdf()
      page_header(:title=>"Multi-column test")
      p_break = " \n\n"
      lorem = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.#{p_break}Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.#{p_break}Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."    

      #calculate column parameters
      options = {:columns=>3, :top_margin=>40, :bottom_margin=>150, :size=>8, :align=>:justify}
      flow_in_columns(lorem*20, options)
      render
  end

end