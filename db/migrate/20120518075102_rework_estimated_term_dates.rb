class ReworkEstimatedTermDates < ActiveRecord::Migration
  # Removes estimated end and start of term fields, and
  # replaces them with flags indicating whether the end_date
  # and/or start_date are estimated. Migration copies the estimated
  # dates into the actual dates if actual dates are empty, and then
  # sets the "estimated" flag.
  def self.up
    add_column :field_terms, :end_estimated, :boolean
    add_column :field_terms, :start_estimated, :boolean
    puts 'Executing'
    FieldTerm.all.each do |f|
      if f.start_date.blank? && !f.est_start_date.blank?
        puts "#{f.start_date}:#{f.est_start_date}"
        f.start_date = f.est_start_date 
        f.start_estimated = true
      else
        f.start_estimated = false
      end
      if f.end_date.blank? && !f.est_end_date.blank?
        f.end_date = f.est_end_date 
        f.end_estimated = true
      else
        f.end_estimated = false
      end
      f.save
    end
    remove_column :field_terms, :est_end_date
    remove_column :field_terms, :est_start_date
  end

  def self.down
    add_column :field_terms, :est_end_date, :date
    add_column :field_terms, :est_start_date, :date
    FieldTerm.all.each do |f|
      if f.start_estimated
        f.est_start_date = f.start_date 
        f.start_date = nil 
      end
      if f.end_estimated
        f.est_end_date = f.end_date 
        f.end_date = nil
      end
      f.save
    end
    remove_column :field_terms, :end_estimated
    remove_column :field_terms, :start_estimated
  end
end
