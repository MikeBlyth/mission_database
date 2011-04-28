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

    def make_sorted_rows
      rows = @table_rows.to_a # => [["cat", {"Total"=>3, "m"=>2, "f"=>1}], ["dog", {"Total"=>4, "m"=>1, "f"=>3}], ["Totals", {"Total"=>7, "m"=>3, "f"=>4}]] 
      rows.sort! {|x,y| y[1]['Total'] <=> x[1]['Total']}  # sort by total frequency, putting highest freq rows first
      totals_row = rows.shift  # removes totals row from front of array ...
      rows.push(totals_row)  # ... and pushes it onto the end 
      # Now figure out the column order based on highest frequencies first
      # totals_row is like ["Totals", {"Total"=>7, "m"=>3, "f"=>4}]  
      col_heads = totals_row[1].to_a.sort {|x,y| y[1] <=> x[1]}.map{|x| x[0]}  # => ["Total", "f", "m"] (column labels in desc order)
      col_heads.rotate!  # Push Total to end of array so now like ['f', 'm', 'Total']
      col_heads.unshift('')  # Prepend blank column, where row labels will go on subsequent rows ... ['', 'f', 'm', 'Total']
      # Now col_heads is the column names (labels) in descending order of freq, with Total at the end
      # Build the table row by row
      output = [col_heads]
      rows.each do |r|
        cell_values = col_heads[1..-1].map {|c| r[1][c] } # for each column except first, which is blank, return count. For example,
                                            # col_head[1] is 'f', so in 'dogs' row where r[1] is {"Total"=>4, "m"=>1, "f"=>3},
                                            # the value will be 3 ("f"=>3)
        output << [r[0]] + cell_values  # where r[0] is the row label
      end
      @sorted_rows = output
      # @sorted_rows is now like: [["", "f", "m", "Total"], ["dog", 3, 1, 4], ["cat", 1, 2, 3], ["Totals", 4, 3, 7]] 
      return output                                                    
    end # sorted rows

    def to_s
      make_sorted_rows unless @sorted_rows
      output = @title + "\n\t\t#{@columns_label}\n"
      @sorted_rows.each {|r| output << r.join("\t") + "\n"}
      return output
    end
      
      
    private

    def init_main(data, options)
      @data = data
      @sorted_rows = nil
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


  
