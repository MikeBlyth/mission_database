include ApplicationHelper
describe ApplicationHelper do
  
  describe 'export_csv' do
    it 'builds a export csv string' do
      @member = Factory.build(:member, :birth_date => Date.new(1980,1,1))
      csv = export_csv([@member],%w{last_name birth_date})
      puts csv
      csv.should match(@member.last_name)
      csv.should match(@member.birth_date.to_s(:long))
    end
  end
  
end
