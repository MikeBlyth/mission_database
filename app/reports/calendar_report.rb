require 'reports_helper'

# Prawn document to generate PDF calendar for a given month
class CalendarReport < Prawn::Document
    include ReportsHelper

    DEFAULT_MARGIN = 36
    DAYS_PER_WEEK = 7
    CELL_PADDING = 2
    
    # For any date, find where it goes (zero-based row & column) in a one-month calendar of that month
    def date_to_row_col(date)
      first_dow = Date.new(date.year,date.month,1).wday     # Sunday = 0
       [(date.day+first_dow-1)/7, (date.day+first_dow-1) % 7] 
    end 

    # For a day _this_ month find where it goes (zero-based row & column) 
    def day_to_row_col(day)
      [(day+@first_wday-1)/7, (day+@first_wday-1) % 7]
    end
    
    # Translate row and column to an x,y position representing top-left corner of box
    # Arguments: row_col is an array of the row and column number. row_col[0] is row number, row_col[1] is column.
    # Returns: array of x and y points, where 0,0 is the BOTTOM-left corner of calendar 
    # note that with row-column the vertical component (row) is first, while the return value xy has x first
    def row_col_to_xy(row_col) 
      [ row_col[1]*@cell_width, (@row_count-row_col[0])*@cell_height]  # oh, that was easy!
    end
    
    def day_to_xy(day)
      row_col_to_xy(day_to_row_col(day))
    end

    # Generate a bounding_box to fit in the cell for the given day. in_day is an alias.
    # Used just like a bounding_box, for example
    # * in_box_for_day(25) {text "Christmas", :align=>:center, :valign=>:center}
    # * in_day(24) {text "Christmas eve"} 
    def in_box_for_day(day)
      box_corner = day_to_xy(day)
      box_corner[0] = box_corner[0]+CELL_PADDING
      box_corner[1] = box_corner[1]-CELL_PADDING
      box_width = @cell_width-2*CELL_PADDING
      box_height = @cell_height - 2*CELL_PADDING
      bounding_box(box_corner, :width=>box_width, :height=>box_height) do
        yield
      end
    end
    # 
    alias in_day in_box_for_day    

    def draw_horizontal_lines
      move_cursor_to(@top_edge)
      # Top line goes from first day to right margin
      horizontal_line @first_wday*@cell_width, (DAYS_PER_WEEK)*@cell_width
      # These lines go across whole width of calendar
      (1..@row_count-1).each do |r|
        move_down @cell_height
        horizontal_line 0, 7 * @cell_width
      end
      # Bottom line goes from left margin to last day + its cell width
      move_down @cell_height
      horizontal_line 0, @cell_width*(1+@last_wday)
      # this leaves us at the bottom line of the calendar
      stroke
    end

    def draw_vertical_lines
      (0..DAYS_PER_WEEK).each do |d|
        # top position for line
        if d < @first_wday
          top_y = @top_edge-@cell_height
        else
          top_y = @top_edge
        end
        # bottom position for line
        if d < @last_wday + 2
          bottom_y = 0
        else
          bottom_y = @cell_height
        end
        vertical_line top_y, bottom_y, :at => d*@cell_width
      end  
      stroke
    end  

    def to_pdf(month, year, params={})
      # First, the calculations
      # Consider calendar as having 7 columns (0..6) and row_count rows (0..row_count)
      # First, find where the first of the month will go. Row 0, column first_dow
      @month = month
      @year = year
      @first = Date.new(year,month,1)
      @last = @first.end_of_month
      @first_wday = @first.wday
      @last_wday = @last.wday
      @row_count = date_to_row_col(@last)[0] + 1  # zero based, so count is one more than last row
      @margins = params[:margins] || DEFAULT_MARGIN
      @calendar_height = bounds.height-2*@margins   # subtract margins equally on top and bottom,
 puts "Initial @calendar_height=#@calendar_height, bounds = #{bounds}"
      @calendar_width = bounds.width-2*@margins     # ... and both sides
      @cell_height = @calendar_height/@row_count
  puts "cell_height = #@cell_height"
      @cell_width = @calendar_width/DAYS_PER_WEEK 
      # Redefine width and height now to eliminate any rounding issues.
      @calendar_width = @right_edge = DAYS_PER_WEEK * @cell_width
      @calendar_height = @top_edge = @row_count*@cell_height  # remember that 0 is bottom, and y increases as we move up on page
      # Start Drawing
      move_down 10
      text Date::MONTHNAMES[month] + " #{year}", :size=>24, :align=>:center
      stroke_bounds    
      bounding_box([margins,@calendar_height+margins], :width=>@calendar_width, :height=>@calendar_height) do
      # Now, within bounding_box, everything is relative to calendar itself, not the page or page margins!
#        circle_at [0,@calendar_height], :radius=>5
#        circle_at [0,0], :radius=>5
        draw_horizontal_lines
        draw_vertical_lines
        # Number the boxes
        (1..@last.day).each do |d|
          in_box_for_day(d) {text d.to_s, :size=>10, :align=>:left}  
        end
        in_box_for_day(25) {text "Thanksgiving", :size=>12, :valign=>:center, :align=>:center}
      end
      render
    end
end
