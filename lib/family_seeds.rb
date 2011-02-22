# Initialize development database with some families and members
require './spec/factories'
 
class FamilySeed

@@mens_names = %w(Patrick Malcolm Francis Sandy Jerome Neal Alex Eric Wesley Franklin Dwight Wayne Neal Tim Jerome Douglas Donald Paul Louis Harvey) +
  %w( William Frederick Jason Don Scott Pat Evan Calvin Eugene Luis Allan Kyle Calvin Gary Mike Leon Steve Curtis Brett Brandon Keith Ronnie Scott) +
  %w( Gene Geoffrey Shawn Vincent Kurt Danny Danny Marshall Jack Benjamin Clifford Martin Jimmy Vincent Sidney Jeff Raymond Roger Troy Neal Martin) +
  %w( Jack Vincent Milton Mitchell Franklin Leroy Glen Bruce Ronnie Jose Robert Stephen Ben Ryan Mark Louis Leo Jerome Vincent Joseph Eric Terry Ken) +
  %w( Clyde Timothy Ted Lester Johnny Louis Ben Brett Glen Don Gregory Randy Sidney Marvin Alex Alexander Karl Robert Bill Clifford Arthur Wesley) +
  %w( Jeremy Wesley Justin Philip Christopher Brian Juan Leroy Tommy Adam Larry)

@@womens_names = %w( Kristina Paige Sherri Gretchen Karen Elsie Hazel Dolores Marion Beth Julia Jean Kristine Crystal Claire Marian Marcia) +
  %w( Stephanie Gretchen Shelley Priscilla Elsie Beth Erica Katherine Patricia Lois Christina Darlene Shirley Judith Gretchen Glenda) +
  %w( Michelle Jessica Melinda Vickie Melanie Marianne Natalie Caroline Arlene Samantha Sara Stacy Gladys Lynne Faye Diana Ethel Alison) +
  %w( Sherri Patsy Kelly Stacy Dana Jennifer Joann Louise Patricia Jennifer Mary Charlene Alice Joan Betty Peggy Leslie Sara Martha) +
  %w( Gayle Roberta Patricia Joanne Toni Beth Jessica Samantha Dianne Rhonda Tamara Mary Sandra Katie Natalie Kathy Beth Tamara Judith) +
  %w( Alice Kathleen Amy Martha Lynn Pauline Peggy Donna Doris Kristin Tracey Janet Constance Sarah Gladys Hazel Hazel Kim Alison ) +
  %w(Heather Claire Michele Judy Sandra Billie Katharine Ashley Lauren Carolyn Charlene Ashley Sheryl Linda Sarah Dana Rebecca Glenda) +
  %w( Geraldine Edna Faye Kathy Marguerite Marsha Laura Melinda Eva Edna Penny Glenda Allison Florence Claire Christy Lucy Susan Nancy) +
  %w( Monica Margaret Miriam Miriam Joanna Stacy Janice Alice )

@@last_names = %w( Song Wagner McNamara Raynor Wallace Lawrence May Steele Teague Vick Monroe Connolly Middleton Watts Johnston Ross Chung) +
  %w(  Woods Rosenthal Underwood Jones Baker Cross Sharpe Hoyle Allen Grant Diaz Graham Hinton Marsh Watts Christensen Parks Whitehead) +
  %w(  Pearson Graves Love Lamb James Chandler Cowan Golden Bowling Clapp Boykin Sumner Cassidy Davidson Byrne Gross Palmer Rowe Li Justice) +
  %w(  Graves Fischer Lane Kaplan Jennings Hanna Jones Glover Vick O'Donnell Goldman Starr McClure Watson Monroe Abbott Farrell Atkins Sykes) +
  %w(  Reid Finch Whitaker Conner Becker Rollins Adkins Joyce Welch Chappell Kane Barton Kennedy Thornton McNeill Weinstein Rich Carlton) +
  %w(  Harvey West Snyder Olsen Pittman Weiner Petersen Terrell Parrott Henry Gray McLean Puckett Heath Garrett Goldman Shaffer House Moser) +
  %w(  Spencer Liu McKay Braswell Steele Donovan Barrett Washington Rogers Chung Chen Melton Hill Puckett Hamilton Bender McLaughlin Moon) +
  %w(  Woodard Desai Griffin Dougherty Powers Gallagher Solomon Walsh Hawkins Goldstein Weeks Wilkerson Barton Walton Hall Bender Mangum) +
  %w(  Joseph Bowden Barton Merritt Cooper Holmes Morgan Rich Rich Proctor Watkins Hewitt Branch Walton O'Brien Case Hardin Lucas Eason) +
  %w(  Davidson Rose Sparks Moore Rodgers Scarborough Sutton Sinclair Bowman Olsen McLean Christian Stout Beasley Abrams Tilley Morse Heath) +
  %w(  Blanchard McAllister McKenzie Schroeder Griffin Perkins Robertson Brady Zhang Hodge Bowling Glass Willis Hester Floyd Norman Chan Hunt) +
  %w(  Byrd Heller May Locklear Holloway McKenna Stone Singer Hall Lucas Norman Monroe Robertson Chandler Hobbs Adkins Kinney Alexander) +
  %w(  Waters Love Black Fox Hatcher Wu Lloyd Matthews MacDonald Butler Pickett Bowman Branch Middleton Moss Lucas Brady Schultz Nichols) +
  %w(  Stevenson Houston Dunn O'Brien Barr Cain Heath Boswell Davis Coleman Norman Burch Weiner Chang Eason Weeks Siegel Hoyle Neal Baker) +
  %w(  Choi Carver Shelton Lyons Dickinson Abbott Hobbs Dodson Burgess Wong Blackburn Middleton Frazier Reid Nance McMahon Miles Kramer Jennings) +
  %w(  Bowles Brown Bolton Craven Hendrix Nichols Saunders Lehman Sherrill Cash Pittman Sullivan Whitehead Mack Rice Ayers Cherry Richmond York) +
  %w(  Wiley Harrington Reed Nash Wilkerson )
  
@@boys_names = %w(Jacob William Joshua Christopher Michael Matthew James John David Zachary Austin Brandon Tyler Nicholas Andrew Christian) +
  %w( Joseph Cameron Dylan Daniel Caleb Jonathan Justin Noah Ethan Samuel Hunter Benjamin Robert Alexander Anthony Logan Thomas Ryan Jordan) +
  %w( Elijah Nathan Aaron Jackson Kevin Jose Isaiah Charles Timothy Luke Jason Gabriel Cody Adam Mason Isaac Seth Brian Eric Nathaniel) +
  %w( Connor Evan Steven Chase Colby Devin Ian Garrett Jalen Kyle Bryan Sean Juan Trevor Patrick Jeremiah Richard Stephen Luis Jared Carlos) +
  %w( Alex Gavin Dalton Carson Chandler Dakota Lucas Tanner Bryson Blake Jesus Antonio Jack Jeremy Spencer Xavier Jesse Landon Tristan Mark) +
  %w( Kaleb Wesley Jeffrey Kenneth Travis )

@@girls_names = %w( Hannah Madison Emily Sarah Taylor Elizabeth Abigail Alexis Anna Kayla Lauren Ashley Jessica Destiny Olivia Brianna Emma Haley Samantha Morgan) +
  %w( Alyssa Sydney Savannah Rachel Megan Grace Jasmine Victoria Caroline Kaitlyn Katherine Jennifer Hailey Mary Jordan Mackenzie Makayla Chloe) +
  %w( Maria Amber Katelyn Jada Allison Natalie Jenna Gabrielle Rebecca Courtney Isabella Julia Alexandra Brittany Sara Autumn Faith Sierra) +
  %w( Summer Bailey Kimberly Stephanie Trinity Brooke Andrea Erin Madeline Zoe Angel Amanda Aaliyah Nicole Kathryn Danielle Shelby Katie Breanna) +
  %w( Laura Lillian Sophia Kaylee Leah Margaret Ashlyn Mckenzie Catherine Skylar Alexandria Christina Caitlin Michelle Heather Cheyenne Kelsey) +
  %w( Diamond Melissa Gracie Kristen Molly Logan Cassidy Erica Lindsey Lydia )
  
@@sexes = %w( M F )
  
  
  # Pick a first name
  def pick_first_name(sex, age=:adult)
    if age == :adult
      sex.upcase == 'M' ? @@mens_names.sample : @@womens_names.sample
    else
      sex.upcase == 'M' ? @@boys_names.sample : @@girls_names.sample  
    end
  end
  
  def pick_last_name
    @@last_names.sample
  end

  def pick_country
    country_code = case rand(100)
      when 0..6 then 'CA'
      when 7..40 then 'US'
      when 41..50 then 'UK'
      when 51..60 then 'NZ'
      when 61..70 then 'AU'
      when 71..75 then 'ZA'
      when 76..80 then 'UKI'
      when 81..85 then 'KO'
      when 86..88 then 'SG'
      when 88..91 then 'DK'
      when 92..94 then 'MY'
      else             '??'
    end
    Country.find_by_code(country_code) || UNSPECIFIED
  end

  def pick_ministry
    Ministry.random
  end
  
  def pick_employment_status
    EmploymentStatus.random
  end
  
  def pick_education
    Education.random
  end  

  def pick_bloodtype
    Bloodtype.random
  end
  
  def pick_status
    basic_statuses = ['On the field', 'Home assignment', 'On leave', 'Pipeline', 'Alumni']
    status = case rand(100)
      when 0..5   then 'Pipeline'
      when 10..40 then 'On the field'
      when 50..65 then 'Home assignment'
      when 66..75 then 'On leave'
      when 6..9, 75..100 then 'Alumni'
    end
    return Status.find_by_description(status) || Status.find(UNSPECIFIED)
  end
  
  def pick_location
    Location.random
  end
  
  # Make a single person
  def make_a_single(sex=nil)
    sex ||= @@sexes.sample  # pick one randomly if not specified
    sim_id = rand(10000) until !Family.find_by_sim_id(sim_id)
    f = Factory(:family, :last_name=>pick_last_name, :first_name=>pick_first_name(sex), :middle_name => pick_first_name(sex),
              :status => pick_status, :location => pick_location, :sim_id => sim_id)
    h = f.head
    birth_date = pick_birth_date(20,70)
    age = (Date::today()-birth_date)/365  # Gives integer result, which is ok
    date_active = pick_birth_date(0,age-20)  # Picks a date between when person was 20 and the present
    h.update_attributes(:birth_date => birth_date, 
              :sex => sex,
              :ministry=>pick_ministry, 
              :employment_status=>pick_employment_status,
              :country=>pick_country, 
              :education=>pick_education, 
              :bloodtype => pick_bloodtype,
              :date_active => date_active
              )
        
  end
  
  def add_spouse(member)
    spouse = Member.new(member.attributes)  # This clones all the attributes, then we'll change some
    spouse.sex = opposite_sex(member.sex)
    spouse.first_name = pick_first_name(spouse.sex)
    spouse.middle_name = pick_first_name(spouse.sex)
    spouse.name = nil
    spouse.birth_date = member.birth_date + (rand(2000) - 1000).days
    spouse.ministry = pick_ministry
    spouse.country = pick_country if rand > 0.85
    spouse.education = pick_education
    spouse.bloodtype = pick_bloodtype
    spouse.spouse = member
    if spouse.save
      puts "Spouse saved" 
      member.update_attributes(:spouse => spouse)
    else
      puts "Spouse not saved, errors = #{spouse.errors}"
    end
    return spouse
  end  
        
  def child_status(child, age)
    if age < 19
      status = case child.family.head.status.description
        when 'Alumni' then 'Alumni MK'
        when 'Pipeline' then 'Pipeline'
        when 'On the field' then 'On field w parents'
        when 'Home assignment' then 'Home assignment'
        when 'On leave' then 'On leave'
        else 'Unspecified'        
      end
    else
      if age < 22
        status = 'College'
      else
        status = 'Adult MK'
      end  
    end      
    child.status = Status.find_by_description(status) || Status.find(UNSPECIFIED)
  end

  def add_child(member, age)
    child = Member.new(member.attributes)  # This clones all the attributes, then we'll change some
    child.sex = sex ||= @@sexes.sample
    child.first_name = pick_first_name(child.sex, :child)
    child.middle_name = pick_first_name(child.sex, :child)
    child.name = nil
    child.spouse_id = nil
    child.birth_date = pick_birth_date(age, age+1)
    child.date_active = nil
    child.ministry = Ministry.find_by_description('MK')  # Could put this somewhere so it's not looked up each time
    child_status(child,age) # Choose reasonable status (like 'on field') based on parents' status and child's age
    if age < 19
      child.employment_status = EmploymentStatus.find_by_code('MKD')
    else
      child.employment_status = EmploymentStatus.find_by_code('MKA')
    end      
    child.bloodtype = pick_bloodtype
    if child.save
      puts "Child saved" 
    else
      puts "Child not saved, errors = #{child.errors}"
    end
    return child
  end  
    
  
  def pick_birth_date(min_age, max_age)
    base_date = Date::today() - max_age.to_i.years
    age_days = rand*365.25*(max_age-min_age)
    birth_date = base_date + age_days.to_i.days
  end

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

