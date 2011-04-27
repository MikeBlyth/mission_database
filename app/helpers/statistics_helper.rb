# This helper is to be included in a controller to user authentication

module StatisticsHelper

def ctab(h, row=:a, col=:s)
  row_values = h.map {|x| x[row]}.uniq
  col_values = h.map {|x| x[col]}.uniq

  table_rows = {}   
  row_cells = {'Total'=>0}
  col_values.each {|c| row_cells[c] = 0} 
  row_values.each {|r| table_rows[r] = row_cells.dup}   
  h.each do |x|
    table_rows[x[row]][x[col]] += 1
  end

  column_totals = {'Total' => 0}
  col_values.each do |col|
    column_totals[col] = 0
    table_rows.each do |label, cells|
      column_totals[col] += cells[col]
    end
    puts "column_totals = #{column_totals}"
  end
  column_totals['Total']= column_totals.inject(0) {|sum, cell| sum + cell[1]}
  # Get row totals -- it just works
  table_rows.each do |label, cells|
    cells['Total'] = cells.inject(0) {|sum, cell| sum + cell[1]}
  end
  table_rows['Totals'] = column_totals
  return table_rows
end  

  private
end  
  
