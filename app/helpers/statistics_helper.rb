module StatisticsHelper

def ctab(h, row=:a, col=nil)
  return nil if h.empty?
  row_values = h.map {|x| method_or_key(x, row).to_s}.uniq
  col_values = h.map {|x| method_or_key(x, col).to_s}.uniq

  table_rows = {}   
  row_cells = {'Total'=>0}
  col_values.each {|c| row_cells[c] = 0} 
  row_values.each {|r| table_rows[r] = row_cells.dup}   
  h.each do |x|
    table_rows[method_or_key(x, row).to_s][method_or_key(x, col).to_s] += 1
  end

  column_totals = {'Total' => 0}
  col_values.each do |col|
    column_totals[col] = 0
    table_rows.each do |label, cells|
      column_totals[col] += cells[col]
    end
  end
  column_totals['Total']= column_totals.inject(0) {|sum, cell| sum + cell[1]}
  # Get row totals -- it just works
  table_rows.each do |label, cells|
    cells['Total'] = cells.inject(0) {|sum, cell| sum + cell[1]}
  end
  table_rows['Totals'] = column_totals
  return table_rows
end  

def method_or_key(object, key)
  if object.respond_to? key 
    return object.send(key)
  elsif object.is_a? Hash
    return object[key] || object[key.to_s] || object[key.to_sym]
  else
    return nil
  end
end

def freq(h, row)
  return nil if h.empty?
  nil_value = 'none'  # This is label shown for nil values. Could be '', "*none*", etc.
  row_values = h.map {|x| method_or_key(x, row).to_s}.uniq
  table_rows = {}   
  row_values.each {|r| table_rows[r] = 0}   
  h.each do |x|
    table_rows[method_or_key(x, row).to_s] += 1
  end

  table_rows['Total'] = table_rows.inject(0) {|sum, cell| sum + cell[1]}
  return table_rows
end  

  private
end  
  
