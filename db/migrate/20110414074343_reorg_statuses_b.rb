class ReorgStatusesB < ActiveRecord::Migration
  def self.up
    alumni = Status.find_by_code('alumni')
    retired = Status.find_by_code('retired')
    umbrella = Status.find_by_code('umbrella')
    inactive = Status.find_by_code('inactive')
    field = Status.find_by_code('field')
    unless alumni && retired && umbrella && inactive && field
      puts "Not all codes found"
      return
    end
    Family.update_all("status_id = #{inactive}","status_id = #{alumni}")
    Family.update_all("status_id = #{inactive}","status_id = #{retired}")
    Family.update_all("status_id = #{field}","status_id = #{umbrella}")
  end

  def self.down
  end
end
