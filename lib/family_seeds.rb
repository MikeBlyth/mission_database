# Initialize development database with some families and members
require './spec/factories'
 
class FamilySeed

  def self.seed
    raise "Don't run this in production!" if Rails.env.production?
    Family.delete_all
    Member.delete_all

    zinsser = Factory.create(:family, :last_name=>'Zinsser', :first_name=>'Carl', :sim_id => '500', 
        :status_id=>1)
    zinsser.head.update_attributes(:sex => 'M')
    blackburn = Factory.create(:family, :last_name=>'Blackburn', :first_name=>'Greg', :sim_id => '501', 
        :status_id=>1)
    blackburn.head.update_attributes(:sex => 'M')
    adler = Factory.create(:family, :last_name=>'Adler', :first_name=>'Fran', :sim_id => '502', 
        :status_id=>1)
    adler.head.update_attributes(:sex => 'F')
    Factory.create(:member, :family=>zinsser, :sex=>'F', :spouse=>zinsser.head, :first_name=>'Mary')
    Factory.create(:member, :family=>zinsser, :first_name=>'Child_1', :sex=>'M')
    Factory.create(:member, :family=>blackburn, :sex=>'F', :spouse=>blackburn.head, :first_name=>'Sonya')
    puts "Created #{Family.count} families and #{Member.count} members."
  end
end

