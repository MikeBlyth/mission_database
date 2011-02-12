# Initialize development database with some families and members
require './spec/factories'
 
class FamilySeed

  def self.seed
    raise "Don't run this in production!" if Rails.env.production?
    Family.delete_all
    Member.delete_all

# Families
    adler = Factory.create(:family, :last_name=>'Adler', :first_name=>'Fran', :sim_id => '502', 
        :status_id=>12)
    blackburn = Factory.create(:family, :last_name=>'Blackburn', :first_name=>'Greg', :sim_id => '501', 
        :status_id=>5, :location_id => '31')
    zinsser = Factory.create(:family, :last_name=>'Zinsser', :first_name=>'Carl', :sim_id => '500', 
        :status_id=>3, :location_id=>'30')

# TERMS
    Factory.create(:field_term, :member_id => blackburn.head.id)

# Members
    adler.head.update_attributes(:sex => 'F', 
        :birth_date => '21 Oct 1990',
        :employment_status_id => '9', 
        :country_id => '167'
        )

    blackburn.head.update_attributes(:sex => 'M', :country_id => '74', :employment_status_id => '2',
        :birth_date => '21 Oct 1960',
        :bloodtype_id => '2',
        :ministry_id => '3', :education_id => '24',
        :ministry_comment => 'youth discipleship',
        :allergies => 'none',
        :qualifications => '4-year Theology degree')
    Factory.create(:member, :family=>blackburn, :sex=>'F', :spouse=>blackburn.head, :first_name=>'Sonya', 
        :birth_date => '21 Nov 1962',
        :bloodtype_id => '5',
        :country_id => '256', :ministry_id => '47', :education_id => '24',
        :ministry_comment => '4th grade at Hillcrest',
        :allergies => 'penicillin',
        :qualifications => 'Elementary education')

    zinsser.head.update_attributes(:sex => 'M', 
        :birth_date => '21 Jan 1980',
        :bloodtype_id => '7',
        :country_id => '227', 
        :employment_status_id => '5',
        :ministry_id => '260', 
        :ministry_comment => 'Sports Friends',
        :education_id => '24',
        :allergies => 'none',
        :qualifications => 'BA Physical Ed'
        )
    Factory.create(:member, :family=>zinsser, :sex=>'F', :spouse=>zinsser.head, :first_name=>'Mary', 
        :birth_date => '21 Oct 1980',
        :bloodtype_id => '3',
        :country_id => '37', 
        :employment_status_id => '5',
        :ministry_id => '16', 
        :ministry_comment => 'SIM Member Care',
        :education_id => '26',
        :allergies => 'none',
        :qualifications => ''
        )
    Factory.create(:member, :family=>zinsser, :first_name=>'Alyssa', :sex=>'F', 
        :employment_status_id=>'6', 
        :bloodtype_id => '999999',
        :birth_date => '21 Oct 2005',
        :allergies => 'none'
        )

    puts "Created #{Family.count} families and #{Member.count} members."
# CONTACTS
    Factory.create(:contact, :member_id => blackburn.head.id, :email_1=>'MrBlackburn@example.com')
    Factory.create(:contact, :member_id => blackburn.head.spouse.id, :email_1=>'MrsBlackburn@example.com')
    Factory.create(:contact, :member_id => blackburn.head.id, :contact_type_id => 2, :email_1=>'GrampaBlackburn@example.com', :phone_1 => '+44 88 88 8888')

# TRAVELS
    
  end
end

