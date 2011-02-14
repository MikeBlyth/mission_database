# Initialize development database with some families and members
require './spec/factories'
 
class FamilySeed

  def self.seed
    raise "Don't run this in production!" if Rails.env.production?
    Family.delete_all
    Member.delete_all
    Contact.delete_all
    Travel.delete_all
    FieldTerm.delete_all

# Families
    adler = Factory.create(:family, :last_name=>'Adler', :first_name=>'Christina', :middle_name=>'Elizabeth',:short_name=>'Chris',  :sim_id => '502', 
        :status_id=>12)
    blackburn = Factory.create(:family, :last_name=>'Blackburn', :first_name=>'Justin', :middle_name=>'Graham', :sim_id => '501', 
        :status_id=>5, :location_id => '31')
    zinsser = Factory.create(:family, :last_name=>'Zinsser', :first_name=>'Carl', :middle_name=>'Steven', :sim_id => '500', 
        :status_id=>3, :location_id=>'30')

# Members
    adler.head.update_attributes(:sex => 'F', 
        :birth_date => '21 Oct 1990',
        :employment_status_id => '9', 
        :country_id => '167'
        )

    blackburn.head.update_attributes(:sex => 'M', :country_id => '74', :employment_status_id => '2',
        :birth_date => '21 Oct 1960',
        :date_active => '1 Jun 2004',
        :ministry_id => '3', :education_id => '24',
        :ministry_comment => 'youth discipleship',
        :bloodtype_id => '2',
        :allergies => 'none',
        :qualifications => '4-year Theology degree')
    Factory.create(:member, :family=>blackburn, :sex=>'F', :spouse=>blackburn.head, :first_name=>'Sonya', 
        :birth_date => '21 Nov 1962',
        :date_active => '1 Jun 2004',
        :bloodtype_id => '5',
        :country_id => '256', 
        :ministry_id => '47', 
        :education_id => '24',
        :ministry_comment => '4th grade at Hillcrest',
        :allergies => 'penicillin',
        :qualifications => 'Elementary education')

    zinsser.head.update_attributes(:sex => 'M', 
        :birth_date => '21 Jan 1980',
        :bloodtype_id => '7',
        :country_id => '227', 
        :employment_status_id => '5',
        :date_active => '13 Nov 2007',
        :ministry_id => '260', 
        :ministry_comment => 'Sports Friends',
        :education_id => '24',
        :allergies => 'none',
        :medications => 'mefloquine',
        :qualifications => 'BA Physical Ed'
        )
    Factory.create(:member, :family=>zinsser, :sex=>'F', :spouse=>zinsser.head, :first_name=>'Mary', 
        :birth_date => '21 Oct 1980',
        :bloodtype_id => '3',
        :country_id => '37', 
        :employment_status_id => '5',
        :date_active => '13 Nov 2007',
        :ministry_id => '16', 
        :ministry_comment => 'SIM Member Care',
        :education_id => '26',
        :allergies => 'none',
        :medications => 'mefloquine',
        :qualifications => ''
        )
    Factory.create(:member, :family=>zinsser, :first_name=>'Alyssa', :short_name=>'Lyssie', :middle_name=>'Ann', :sex=>'F', 
        :employment_status_id=>'6', 
        :bloodtype_id => '999999',
        :birth_date => '21 Oct 2005',
        :allergies => 'none',
        :medications => 'doxycycline',
        )

    puts "Created #{Family.count} families and #{Member.count} members."

# TERMS
    Factory.create(:field_term, :member_id => blackburn.head.id,
        :ministry_id => '3')
    Factory.create(:field_term, :member_id => blackburn.head.id, 
        :start_date => '1 Jun 2004', :end_date => '1 Sep 2007',
        :ministry_id => '3')
    Factory.create(:field_term_future, :member_id => blackburn.head.id, 
        :est_start_date => '1 Nov 2011', :est_end_date => '14 Mar 2013',
        :ministry_id => '3')
    Factory.create(:field_term, :member_id => blackburn.head.spouse.id,
        :ministry_id => '47')
    Factory.create(:field_term, :member_id => blackburn.head.spouse.id, 
        :start_date => '1 Jun 2004', :end_date => '1 Sep 2007',
        :ministry_id => '47')
    Factory.create(:field_term_future, :member_id => blackburn.head.spouse.id, 
        :est_start_date => '1 Nov 2011', :est_end_date => '14 Mar 2013',
        :ministry_id => '47')
    Factory.create(:field_term, :member_id => zinsser.head.id, 
        :start_date => '13 Nov 2007', :end_date => '1 Dec 2010',
        :employment_status_id => '5',
        :ministry_id => '260')
    Factory.create(:field_term_future, :member_id => zinsser.head.id, 
        :est_start_date => '1 Nov 2011', :est_end_date => '14 Mar 2013',
        :employment_status_id => '5',
        :ministry_id => '260')
    Factory.create(:field_term, :member_id => zinsser.head.spouse.id, 
        :start_date => '13 Nov 2007', :end_date => '1 Dec 2010',
        :employment_status_id => '5',
        :ministry_id => '16')
    Factory.create(:field_term_future, :member_id => zinsser.head.spouse.id, 
        :est_start_date => '1 Nov 2011', :est_end_date => '14 Mar 2013',
        :employment_status_id => '5',
        :ministry_id => '16')
    Factory.create(:field_term_future, :member_id => adler.head.id, 
        :est_start_date => '1 May 2011', :est_end_date => '1 Jan 2013',
        :employment_status_id => '5',
        )

# CONTACTS
    Factory.create(:contact, :member_id => blackburn.head.id, :email_1=>'MrBlackburn@example.com')
    Factory.create(:contact, :member_id => blackburn.head.spouse.id, :email_1=>'MrsBlackburn@example.com')
    Factory.create(:contact, :member_id => blackburn.head.id, :contact_type_id => 2, :email_1=>'GrampaBlackburn@example.com', :phone_1 => '+44 88 88 8888')

# TRAVELS
    Factory.create(:travel, :member_id => zinsser.head.id, :with_spouse=>true, :with_children=> true, :total_passengers => 3, :baggage=>'6')
    Factory.create(:travel_to_field, :member_id => blackburn.head.id, :with_spouse=>true, :total_passengers => 2, :baggage=>'4')
    Factory.create(:travel_to_field, :member_id => adler.head.id, :date => '31 Mar 2011', :baggage => '2')
  end
end

