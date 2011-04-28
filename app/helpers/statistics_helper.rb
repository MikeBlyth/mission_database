module StatisticsHelper

  def method_or_key(object, key)
    if object.respond_to? key 
      return object.send(key)
    elsif object.is_a? Hash
      return object[key] || object[key.to_s] || object[key.to_sym]
    else
      return nil
    end
  end

  class CrossTab < Object
    attr_accessor :title, :columns_label, :rows_label, :table_rows
    
    def initialize(data,options)
      return nil if data.empty?
      init_main(data, options)
      init_rows
      init_columns

      row_cells = {'Total'=>0}
      @col_values.each {|c| row_cells[c] = 0}   # Make a 'starter row' like 'Total'=>0, 'Male'=>0, 'Female'=>0
      @row_values.each {|r| @table_rows[r] = row_cells.dup}  # e.g. "career" => {'Total'=>0, 'Male'=>0, 'Female'=>0}
      data.each do |x|   # Increment the right table cell for each element of the data
        @table_rows[method_or_key(x, @row).to_s][method_or_key(x, @col).to_s] += 1
      end

      column_totals = {'Total' => 0}
      @col_values.each do |col|
        column_totals[col] = 0
        @table_rows.each do |label, cells|
          column_totals[col] += cells[col]
        end
      end
      column_totals['Total']= column_totals.inject(0) {|sum, cell| sum + cell[1]}

      # Get row totals -- it just works
      @table_rows.each do |label, cells|
        cells['Total'] = cells.inject(0) {|sum, cell| sum + cell[1]}
      end
      @table_rows['Totals'] = column_totals # Do this AFTER calculating column totals, to avoid double counting
    end  # initialize

    private

    def init_main(data, options)
      @data = data
      @options = options
      @title = options[:title] || "#{options[:rows]} x #{options[:columns]}"
      @table_rows = {}   
    end

    def init_rows
      @row = @options[:rows]
      @rows_label = @options[:rows_label] || @row.to_s
      @row_values = @data.map {|x| method_or_key(x, @row).to_s}.uniq
    end
    
    def init_columns
      @col = @options[:columns]
      @columns_label = @options[:columns_label] || @col.to_s
      @col_values = @data.map {|x| method_or_key(x, @col).to_s}.uniq
    end

  end # Class CrossTab

  class Freq < CrossTab

    def initialize(data,options)
      return nil if data.empty?
      init_main(data, options)
      init_rows
      @row_values.each {|r| @table_rows[r] = 0}   
      data.each do |x|
        @table_rows[method_or_key(x, @row).to_s] += 1
      end
      @table_rows['Total'] = @table_rows.inject(0) {|sum, cell| sum + cell[1]}
    end # initialize

  end  # Class Freq

end  # Module


  
