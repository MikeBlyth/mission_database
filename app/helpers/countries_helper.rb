module CountriesHelper

  def name_column(record, column)
    record.name ||= "** not found **"
    record.name.force_encoding('utf-8')
  end
  def nationality_column(record, column)
    record.nationality ||= "** not found **"
    record_nationality = record.nationality.force_encoding("UTF-8")
  end


end
