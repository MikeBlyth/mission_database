module FamilyTestData
include ApplicationHelper
MENS_NAMES = %w(Patrick Malcolm Francis Sandy Jerome Neal Alex Eric Wesley Franklin Dwight Wayne Neal Tim Jerome Douglas Donald Paul Louis Harvey) +
  %w( William Frederick Jason Don Scott Pat Evan Calvin Eugene Luis Allan Kyle Calvin Gary Mike Leon Steve Curtis Brett Brandon Keith Ronnie Scott) +
  %w( Gene Geoffrey Shawn Vincent Kurt Danny Danny Marshall Jack Benjamin Clifford Martin Jimmy Vincent Sidney Jeff Raymond Roger Troy Neal Martin) +
  %w( Jack Vincent Milton Mitchell Franklin Leroy Glen Bruce Ronnie Jose Robert Stephen Ben Ryan Mark Louis Leo Jerome Vincent Joseph Eric Terry Ken) +
  %w( Clyde Timothy Ted Lester Johnny Louis Ben Brett Glen Don Gregory Randy Sidney Marvin Alex Alexander Karl Robert Bill Clifford Arthur Wesley) +
  %w( Jeremy Wesley Justin Philip Christopher Brian Juan Leroy Tommy Adam Larry)

WOMENS_NAMES = %w( Kristina Paige Sherri Gretchen Karen Elsie Hazel Dolores Marion Beth Julia Jean Kristine Crystal Claire Marian Marcia) +
  %w( Stephanie Gretchen Shelley Priscilla Elsie Beth Erica Katherine Patricia Lois Christina Darlene Shirley Judith Gretchen Glenda) +
  %w( Michelle Jessica Melinda Vickie Melanie Marianne Natalie Caroline Arlene Samantha Sara Stacy Gladys Lynne Faye Diana Ethel Alison) +
  %w( Sherri Patsy Kelly Stacy Dana Jennifer Joann Louise Patricia Jennifer Mary Charlene Alice Joan Betty Peggy Leslie Sara Martha) +
  %w( Gayle Roberta Patricia Joanne Toni Beth Jessica Samantha Dianne Rhonda Tamara Mary Sandra Katie Natalie Kathy Beth Tamara Judith) +
  %w( Alice Kathleen Amy Martha Lynn Pauline Peggy Donna Doris Kristin Tracey Janet Constance Sarah Gladys Hazel Hazel Kim Alison ) +
  %w(Heather Claire Michele Judy Sandra Billie Katharine Ashley Lauren Carolyn Charlene Ashley Sheryl Linda Sarah Dana Rebecca Glenda) +
  %w( Geraldine Edna Faye Kathy Marguerite Marsha Laura Melinda Eva Edna Penny Glenda Allison Florence Claire Christy Lucy Susan Nancy) +
  %w( Monica Margaret Miriam Miriam Joanna Stacy Janice Alice )

LAST_NAMES = %w( Song Wagner McNamara Raynor Wallace Lawrence May Steele Teague Vick Monroe Connolly Middleton Watts Johnston Ross Chung) +
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
  %w(  Wiley Harrington Reed Nash Wilkerson Ho Lee Choi Chung Jang Kaldestadt Tranh )
  
BOYS_NAMES = %w(Jacob William Joshua Christopher Michael Matthew James John David Zachary Austin Brandon Tyler Nicholas Andrew Christian) +
  %w( Joseph Cameron Dylan Daniel Caleb Jonathan Justin Noah Ethan Samuel Hunter Benjamin Robert Alexander Anthony Logan Thomas Ryan Jordan) +
  %w( Elijah Nathan Aaron Jackson Kevin Jose Isaiah Charles Timothy Luke Jason Gabriel Cody Adam Mason Isaac Seth Brian Eric Nathaniel) +
  %w( Connor Evan Steven Chase Colby Devin Ian Garrett Jalen Kyle Bryan Sean Juan Trevor Patrick Jeremiah Richard Stephen Luis Jared Carlos) +
  %w( Alex Gavin Dalton Carson Chandler Dakota Lucas Tanner Bryson Blake Jesus Antonio Jack Jeremy Spencer Xavier Jesse Landon Tristan Mark) +
  %w( Kaleb Wesley Jeffrey Kenneth Travis )

GIRLS_NAMES = %w( Hannah Madison Emily Sarah Taylor Elizabeth Abigail Alexis Anna Kayla Lauren Ashley Jessica Destiny Olivia Brianna Emma Haley Samantha Morgan) +
  %w( Alyssa Sydney Savannah Rachel Megan Grace Jasmine Victoria Caroline Kaitlyn Katherine Jennifer Hailey Mary Jordan Mackenzie Makayla Chloe) +
  %w( Maria Amber Katelyn Jada Allison Natalie Jenna Gabrielle Rebecca Courtney Isabella Julia Alexandra Brittany Sara Autumn Faith Sierra) +
  %w( Summer Bailey Kimberly Stephanie Trinity Brooke Andrea Erin Madeline Zoe Angel Amanda Aaliyah Nicole Kathryn Danielle Shelby Katie Breanna) +
  %w( Laura Lillian Sophia Kaylee Leah Margaret Ashlyn Mckenzie Catherine Skylar Alexandria Christina Caitlin Michelle Heather Cheyenne Kelsey) +
  %w( Diamond Melissa Gracie Kristen Molly Logan Cassidy Erica Lindsey Lydia )
  
SEXES = %w( M F )
  
US_ADDRESSES = [ ["Juana C. Waldron","15251 Nordhoff St","North Hills, CA 91343-2249","(818) 892-7557"],
  ["Marilyn T. Champagne","109 Shartom Dr","Augusta, GA 30907-4712","(706) 651-2147"],
  ["Thomas C. Chacon","102 E Johnson St","Cary, NC 27513-4615","(919) 481-8577"],
  ["Deena T. Robertson","1017 Murray Dr","Santa Maria, CA 93454-5512","(805) 922-7337"],
  ["Sam L. Stafford","6320 Boca Del Mar Dr","Boca Raton, FL 33433-5735","(561) 368-2531"],
  ["Yolanda G. Brown","3500 NW Boca Raton Blvd","Boca Raton, FL 33431-5851","(561) 368-5032"],
  ["Ashley J. Hoskinson","4411 Gardendale St","San Antonio, TX 78240-1194","(210) 561-4840"],
  ["Patrick L. Flanigan","2317 Dickens Ave","Charlotte, NC 28208-381","(704) 394-7568"],
  ["Wallace G. Tabone","12226 SE 259th Pl","Kent, WA 98030-8653","(253) 639-4638"],
  ["Henry C. Butler","9105 Tyler Ave","Jacksonville, FL 32208-2356","(904) 683-4717"],
  ["Gladys M. Bishop","18214 Via Calma","Rowland Heights, CA 91748-3350","(626) 965-4074"],
  ["Eric B. Sheley","1604 Sierra Woods Dr","Reston, VA 20194-5623","(703) 709-6887"],
  ["Alvin M. Davila","999 E Valley Blvd","Alhambra, CA 91801-0900","(626) 576-4579"],
  ["Patricia B. Mithani","535 Pierce St, Apt 1206","Albany, CA 94706-1053","(510) 558-4248"],
  ["Kim M. Ebersole","7326 Oakland Ave","Minneapolis, MN 55423-3226","(612) 869-8109"],
  ["Rosie B. Rineer","144 Leland Ave","San Francisco, CA 94134-2806","(415) 586-3038"],
  ["Shirley K. Singletar","3777 S Gessner Rd","Houston, TX 77063-5212","(713) 278-3526"],
  ["Lois N. Sanders","393 Cattail Rd","Livingston Manor, NY 12758-6745","(845) 439-7873"],
  ["William G. Morrison","2216 Cropsey Ave","Brooklyn, NY 11214-5608","(718) 265-4740"],
  ["William M. Eccles","10 N Main St","Lamar, CO 81052-2576","(719) 336-7588"],
  ["Constance G. Martinez","44 NE Third St","Ontario, OR 97914-2521","(541) 881-5214"],
  ["Patricia J. Mcdole","401 Ashbourne Ave","Lindenwold, NJ 08021-2620","(856) 566-8523"],
  ["Rene J. Capriola","1129 N Memorial Dr","Racine, WI 53404-3043","(262) 456-4422"],
  ["Larry A. Jenkins","524 E Linden Ave","Lindenwold, NJ 08021-1521","(856) 566-2783"],
  ["Lora R. Irons","4626 N Harlem Ave","Harwood Heights, IL 60706-4714","(708) 867-3852"],
  ["Lydia W. Purvis","5441 Western Ave, Ste 2","Boulder, CO 80301-2733","(303) 447-2372"],
  ["James E. Matlock","1201 Boynton Dr","Chattanooga, TN 37402-2144","(423) 267-4172"],
  ["Wendy T. Guerrero","4701 Randolph Rd, Ste 103","Rockville, MD 20852-2260","(301) 816-2733"],
  ["Donald L. Causey","24000 Edgehill Dr","Beachwood, OH 44122-1228","(216) 381-4494"],
  ["Timothy J. Mccabe","42473 Magellan Sq","Ashburn, VA 20148-5608","(703) 542-4731"],
   ["Paul K. Schroeder","410 Gardenia Ln","Buffalo Grove, IL 60089-1661","(847) 541-7954"],
  ["Harold L. Robinson","1511 E 86th St","Chicago, IL 60619-6518","(773) 684-4178"],
  ["Patrick M. Fraley","28 Milford St","Medway, MA 02053-1631","(508) 533-4864"],
  ["Linda E. Berthold","9402 Bentridge Ave","Potomac, MD 20854-2870","(301) 424-3748"],
  ["Ryan M. Chastain","1018 Adams Ave, Apt 3C","Salisbury, MD 21804-6687","(410) 341-4264"],
  ["Shirley A. Smith","1901 Kylemore Dr","Greensboro, NC 27406-6440","(336) 315-7986"],
  ["Arlene J. Blake","201 Railroad Ave","East Rutherford, NJ 07073-1943","(201) 340-5848"],
  ["Monica E. Cruz","3333 228th St SE","Bothell, WA 98021-8950","(425) 482-2245"],
  ["Tammy D. Benavides","4510 W Capitol Dr","Milwaukee, WI 53216-1564","(414) 449-7593"],
  ["Joseph C. Morgan","1803 S Eighth St","Rogers, AR 72756-5912","(479) 636-4634"],
  ["Daniel S. Newton","1812 Chartwell Dr","Fort Wayne, IN 46816-1382","(260) 447-8173"],
  ["Adam G. Woodard","2739 Westerwood Village Dr","Charlotte, NC 28214-2563","(704) 391-7784"],
  ["Irene J. Iversen","1411 Legends Ct","Lawrence, KS 66049-5818","(785) 749-7665"],
  ["Gertrude M. Blackwell","2412 Hardie St","Greensboro, NC 27403-3710","(336) 852-2971"],
  ["Anthony G. Bartlett","1411 Legends Ct","Lawrence, KS 66049-5818","(785) 749-4565"],
  ["Brandy M. Baird","2286 Pimmit Run Ln","Falls Church, VA 22043-2260","(703) 942-7928"],
  ["Andrew C. Wray","2510 E Arkansas Ln, Ste 114","Arlington, TX 76014-1746","(817) 277-8741"],
  ["Kelly J. Whitehead","1801 S Main St","Findlay, OH 45840-1324","(419) 422-2529"],
  ["Justin D. Mccormack","2245 N Decatur Blvd","Las Vegas, NV 89108-2910","(702) 638-4228"],
  ["Michelle T. Latham","32 Stovel Cir","Colorado Springs, CO 80916-4704","(719) 570-4181"],
  ["Margaret M. Norris","102 Robinson St, Apt 2","Woonsocket, RI 02895-2154","(401) 597-7633"],
  ["Marjorie L. Holleman","1601 Murdock Rd","Charlotte, NC 28205-2093","(704) 372-4839"],
  ["Joshua C. Richardson","1601 Murdock Rd","Charlotte, NC 28205-2093","(704) 372-3839"],
  ["Martina B. Starling","2308 Ashley Rd","Charlotte, NC 28208-4802","(704) 391-7329"],
  ["James R. Hellman","2227 Woodberry Dr","Greensboro, NC 27403-3749","(336) 315-4986"],
  ["Dan J. Copeland","4840 Eastern Ave NE","Washington, DC 20017-3129","(202) 832-7673"],
  ["Michael M. Hill","1201 S Ervay St","Dallas, TX 75215-1124","(214) 747-5018"],
  ["Diane D. Lovelace","2200 Oneida St","Joliet, IL 60435-6578","(815) 730-7623"],
  ["Brenda R. Wilson","1110 Dennis Ct","Rodeo, CA 94572-1929","(510) 799-4503"],
  ["Bernadette J. Hulme","845 Dracut Ln","Schaumburg, IL 60173-5927","(847) 519-7045"]
  ]
  
UK_ADDRESSES = [ ["Kevin D. Beatty","39 Floral St","London, WC2E 9DG","020 73798678"],
  ["Johnny J. Wilson","24 Old Bond St","London, W1S 4AL","020 76294142"],
  ["Alfred T. Jones","196 Regent Street","London, W1B 5BT","0800 280 2444"],
  ["Omar B. Camacho","38 Great Castle St","London, W1W 8LG","020 76367700"],
  ["James D. Heck","43 Brewer Street","London, W1F 9UD","020 7439 8525"],
  ["Carol J. Quenett","37 Neal St","London, WC2H 9PR","020 72402783"],
  ["Patrick S. Dillon","34 Floral St","London, WC2E 9DJ","020 78361131"],
  ["Amy E. Ruth","235 Regent Street","London, W1B 2EL","020 7153 9000"],
  ["Marco A. Hernandez","","Michelin House, 81 Fulham Rd","London, SW3 6RD?","020 75897401"],
  ["Ruth M. Alvear","","Benson House, Unit 3, Hatfields","London, SE1 8DQ","020 79286898"],
  ["Timothy D. Smith","374 Oxford St","London, W1C 1JR","020 74097868"],
  ["Ruth B. Allisons","199 Regent St","London, W1B 4LZ","020 77344088"],
  ["Michael D. Adams","21 Great Marlborough Street","London, W1F 7HL","020 7734 4477"],
  ["Christi R. Sharon","7 Royal Opera Arcade","London, SW1Y 4UY","020 7930 4587"],
  ["Florence N. Sharp","86 Lower Marsh","London, SE1 7AB","020 74018219"],
  ["Aharon E. Karon","78 Neal Street","London, WC2H 9PA","020 7813 3051"],
  ["Sharon A. Berg","55a Tooley Street","London, SE1 2QN","020 7378 1998"],
  ["Becky M. Berkeley","72 Strand","London, WC2N 5LR","0870 376 3373"],
  ["William F. Maule","2179 Shaftesbury Avenue","London, WC2H 8JR","020 7420 3666"],
  ["Charlotte S. Sharon","205 Piccadilly","London, W1J 9HD","020 78512400"],
  ["Katrina B. Nbdelhamid","82 Brewer St","London, W1F 9UA","020 74393705"],
  ["Lillian L. Frieden","53 Kings Rd","London, SW3 4ND","020 77307562"],
  ["Daniel M. Cohn","85 Ebury St","Westminster, SW1W 9QU","020 7730 2235"],
  ["Salomea B. Holst","24 Denmark St","London, WC2H 8NJ","020 73791139"],
  ["Sarabeth L. Reingold","32 Great Marlborough St","London, W1F 7JB","087 0376 3287"],
  ["Tamra A. Ho","27 Neal Street","Covent Garden, WC2H 9PR","087 0376 3256"],
  ["Wasiu A. Okeowo","82 Moorgate","London, EC2M 6SE","087 0376 3314"],
  ["Danielle V. Keys","24 Lower Regent Street","London, SW1Y 4QF","087 0333 9600"],
  ["Michael B. Haynes","25 Bury Street","London, SW1Y 6AL","020 7807 9990"],
  ["Grant G. Dakan","504 Oxford St","London, W1C 1HG","020 74950420"],
  ["David G. Oldfield","97 Hatton Garden","London, EC1N 8NX","020 7405 2453"],
  ["Michelle A. Nash","89 Oxford Street","London, W1D 2EZ","087 0376 3123"],
  ["Laura A. Feige","203 Oxford St","London, W1D 2LE","020 72921600"],
  ["Lora B. King","8 Leadenhall Market","London, EC3V 1LR","020 76210959"],
  ["Horace N. Bradley","197 Piccadilly","London, W1J 9LL","020 7734 4551"],
  ["Herbert H. Whitford","14 Portsmouth St","London, WC2A 2ES","020 74059891"],
  ["Nancy W. Kingsford","261 Oxford St","London, W1C 2DE","0870 376 3851"]
 ]

AIRPORTS = %w(Abuja London Charlotte Denver Nairobi Accra Lagos Minneapolis Portland Dallas Houston)
AIRPORTS_NG = %w(Abuja Lagos Kano)
AIRPORTS_INTL = %w(London Charlotte Denver Nairobi Accra Minneapolis Portland Dallas Houston Auckland Sydney Mumbai)
FLIGHTS = %w(BA251 BA92 LH270 US210 KL540 KL541 RY444)
TRAVEL_PURPOSES = ['Personal','Home assignment','Mission','Medical', 'Begin Term', 'Other']
GUESTHOUSES = ['Baptist','ECWA','Peniel','Hilton','St. Matthew\s', 'Unspecified']
STATUS_CODES = %w( alumni mkfield field college home_assignment leave mkadult retired deceased ) +
     %w( pipeline mkalumni visitor_past visitor unspecified)
STATUS_CODES_MEMBERS =  %w( alumni field  home_assignment leave retired deceased )


  def coin_toss
    rand > 0.5
  end  

  # Pick a first name
  def pick_first_name(sex=nil, age=:adult)
    sex ||= ['M', 'F'].sample
    if age == :adult
      sex.upcase == 'M' ? MENS_NAMES.sample : WOMENS_NAMES.sample
    else
      sex.upcase == 'M' ? BOYS_NAMES.sample : GIRLS_NAMES.sample  
    end
  end
  
  def pick_last_name
    LAST_NAMES.sample
  end

  def pick_full_name(sex=nil, age=:adult)
    pick_first_name(sex, age) + " " + pick_last_name
  end  
  
  def pick_birth_date(min_age, max_age)
    base_date = Date::today() - max_age.to_i.years
    age_days = rand*365.25*(max_age-min_age)
    birth_date = base_date + age_days.to_i.days
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
  
  def pick_status(age)
#    basic_statuses = ['On the field', 'Home assignment', 'On leave', 'Pipeline', 'Alumni']
#    basic_status_codes = ['field', 'home assignment', 'leave', 'pipeline', 'alumni']
    if age < 65
      status = case rand(100)
        when 0..3   then 'pipeline'
        when 5..7   then 'visitor'
        when 8..12  then 'visitor_past'
        when 13..50 then 'field'
        when 51..60 then 'home assignment'
        when 61..67 then 'leave'
        when 68..97 then 'alumni'
        when 98..99 then 'deceased'
      end
    else
      if age + rand(35) > 100
        status = 'deceased'
      else
        status = ['Alumni', 'Alumni-Retired'].sample
      end
    end        
    return Status.find_by_code(status) || Status.find(UNSPECIFIED)
  end
  
  def pick_location
    Location.random
  end

  # Make a single person
  def make_a_single(params={})
    sex = params[:sex] || SEXES.sample  # pick one randomly if not specified
    max_age = params[:max_age] || 90
    min_age = params[:min_age] || 20
    age = params[:age] || min_age + rand(max_age-min_age)
    birth_date = pick_birth_date(age,age+1)
    date_active = params[:date_active] || pick_birth_date(0,age-20)  # Picks a date between when person was 20 and the present
    status_code = params[:status_code] 
    if status_code
      status = Status.find_by_code(status_code)
    else
      status = pick_status(age) # ~ randomly
    end
    if ['visitor', 'visitor_past', 'pipeline', 'mk_field','mk_adult','college', 'mkalumni'].include?(status.code)
      date_active = nil
    end  
    if ['visitor', 'visitor_past'].include?(status.code)
      employment_status = EmploymentStatus.find_by_code('visitor')
    end  
    location = params[:location] || pick_location
    sim_id = rand(10000) until !Family.find_by_sim_id(sim_id)
    puts "***make single--nil date_active, status=#{status}" if date_active.nil?
    f = Family.create(:last_name=>pick_last_name, :first_name=>pick_first_name(sex), :middle_name => pick_first_name(sex),
              :status => status, :location => location, :sim_id => sim_id)
    head = f.head
    head.update_attributes(:birth_date => birth_date, 
              :sex => sex,
              :ministry=>params[:ministry] || pick_ministry, 
              :employment_status=>params[:employment_status] || pick_employment_status,
              :country=>params[:country] || pick_country, 
              :education=>params[:education] || pick_education, 
              :bloodtype => params[:bloodtype] || pick_bloodtype,
              :date_active => date_active
              )
# puts "#{head.name}, #{head.age}, #{head.status.description}"
    return head 
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
#      puts "Spouse saved" 
      member.update_attributes(:spouse => spouse)
    else
      puts "Spouse not saved, errors = #{spouse.errors}"
    end
    return spouse
  end  
        
  def child_status(child, age)
    if age < 19
      status = case child.family.head.status.code
        when 'alumni' then 'mkalumni'
        when 'pipeline' then 'pipeline'
        when 'field' then 'mkfield'
        when 'home_assignment' then 'home_assignment'
        when 'leave' then 'leave'
        else 'Unspecified'        
      end
    else
      if age < 22
        status = 'college'
      else
        status = 'mkadult'
      end  
    end      
    child.status = Status.find_by_code(status) || Status.find(UNSPECIFIED)
  end

  def add_child(member, age)
    child = Member.new(member.attributes)  # This clones all the attributes, then we'll change some
    child.sex = sex ||= SEXES.sample
    child.first_name = pick_first_name(child.sex, :child)
    child.middle_name = pick_first_name(child.sex, :child)
    child.name = nil
    child.spouse_id = nil
    if age.class==Fixnum
      child.birth_date = pick_birth_date(age, age+1)
    else
      child.birth_date = Date.today.years_ago(age)
    end  
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
#      puts "Child #{child.first_name}, #{child.birth_date}, #{child.age}"
    else
      puts "Child not saved, errors = #{child.errors}"
    end
    return child
  end  
    
  def add_contact(member, contact_type=nil)
    c = member.contacts.new
    if contact_type
      c.contact_type = ContactType.find_by_code(contact_type)
    else
      c.contact_type = ContactType.random 
    end  
    case c.contact_type.code
    when 1 # field
      addr = ''
      c.contact_name = member.name
      c.phone_1 = '0808-999-9999'
      c.phone_2 = '0707-888-8888' if rand > 0.6
      c.email_1 = member.first_name + "." + member.last_name + "@example.com"
      if rand > 0.8
        c.email_2 = member.first_name + rand(1000).to_s + "@example.com"
      end
      if rand > 0.8
        c.blog = 'http://' + member.first_name + member.last_name + ['blogspot.com','wordpress.com',member.last_name+'.com'].sample
      end
      if rand > 0.6
        c.facebook = 'http://www.facebook.com/group.php?gid=9999999999#!/profile.php?id=8888888888'
      end
      c.email_public = coin_toss
      c.skype_public = coin_toss
      c.phone_public = coin_toss
         
    when 2 #home country
      addr = case member.country.code
        when 'US' then US_ADDRESSES.sample
        when 'UK' then UK_ADDRESSES.sample
        else US_ADDRESSES.sample
      end
      c.contact_name = member.name
      c.address = addr[1] + "\n" + addr[2]
      c.email_1 = member.first_name + "." + member.last_name + "@example.com"
      c.phone_1 = addr[3]
      c.phone_2 = addr[3].gsub('4','x').gsub('2','4').gsub('x','2') if rand > 0.9
      c.email_public = coin_toss
      c.skype_public = coin_toss
      c.phone_public = coin_toss
    else
      addr = case member.country.code
        when 'US' then US_ADDRESSES.sample
        when 'UK' then UK_ADDRESSES.sample
        else US_ADDRESSES.sample
      end
      if c.contact_type.code == 3
        sex = opposite_sex(member.sex)
      else
        sex = nil
      end
      c.contact_name = pick_first_name(sex) + " " + member.last_name
      c.address = addr[1] + "\n" + addr[2]
      c.email_1 = c.contact_name.gsub(' ', '.') + "@example.com"
      c.phone_1 = addr[3]
      c.phone_2 = addr[3].gsub('4','x').gsub('2','4').gsub('x','2') if rand > 0.9
      c.email_public = coin_toss
      c.skype_public = coin_toss
      c.phone_public = coin_toss
    end # case contact_type...
    if c.save
#      puts "contact saved" 
    else
      puts "contact not saved, errors = #{c.errors}"
    end
    return c
  end # add_contact
  
  def add_travel(member,params={})
      date = params[:date] || Date::today
      origin = params[:origin] || AIRPORTS.sample
      destination = params[:destination] 
      if destination.nil? 
        destination = AIRPORTS.sample # There must be a better way to do this, oh well
        destination = AIRPORTS.sample while origin == destination 
      end
      purpose = params[:purpose] || TRAVEL_PURPOSES.sample
      guesthouse = params[:guesthouse] || GUESTHOUSES.sample
      flight = params[:flight] || FLIGHTS.sample
      return_date = params[:return_date] || date + rand(365).days
      with_spouse = params[:with_spouse] || (coin_toss && member.spouse)
      with_children = params[:with_children] || (coin_toss && member.children)
      other_travelers_count = params[:other_travelers_count] || [0,0,0,0,0,1,1,1,2,3].sample
      other_travelers = params[:other_travelers] # This is the list of names
      # Make up some names if there are extra passengers but no names are given
      if other_travelers_count>0 && other_travelers.nil?
        other_travelers = []
        other_travelers_count.times { other_travelers << pick_full_name }
        other_travelers = other_travelers.join(', ')
      end
      total_passengers = params[:total_passengers]
      if total_passengers.nil?
#puts "with_spouse=#{with_spouse}, children=#{member.children.count}, other_travelers_count = #{other_travelers_count}"
        total_passengers = 1
        total_passengers += 1 if with_spouse
        total_passengers += member.children.count if with_children
        total_passengers += other_travelers_count
      end  
      baggage = params[:baggage] || total_passengers*2
      t = member.travels.create(:date => date, :return_date => return_date,
                                :origin => origin, :destination => destination,
                                :flight => flight,
                                :purpose => purpose, :guesthouse => guesthouse,
                                :with_spouse => with_spouse, :with_children => with_children,
                                :other_travelers => other_travelers,
                                :total_passengers => total_passengers, :baggage => baggage)
  end

  def add_field_term(member, params={})
    location = params[:location] || Location.random
    ministry= params[:ministry] || Ministry.random
    employment_status = params[:employment_status] || EmploymentStatus.random
    duration = params[:duration] || (rand(46) + 1).months
    start_date = params[:start_date] 
    if start_date.nil?
      # Come up with a reasonable current term based on what the last term, if any, was
      last_term = member.field_terms.last
      if last_term.nil?  #if this is the first term being created for the person...
        start_date=member.date_active
      else  # base current term on the end of the last term
        if last_term.end_date.nil?
          start_date=last_term + (rand(46) + 7).months              
        else
          start_date=last_term.end_date + (rand(9) + 3).months                  
        end
      end
    end    
puts "NIL start_date in add_field_term, member.status=#{member.status.code}, date_active=#{member.date_active}" if start_date.nil?
    return nil if start_date > Date::today
    end_date  = params[:end_date] || start_date + duration
    est_start_date  = params[:est_start_date] # No default on this one
    est_end_date   = params[:est_end_date] || est_start_date + duration if est_start_date
    employment_status = params[:employment_status] || EmploymentStatus.random
    f = member.field_terms.create( :location => location, :ministry=>ministry,
                :start_date=>start_date, :end_date =>end_date,
                :est_start_date=>est_start_date, :est_end_date=>est_end_date,
                :employment_status=>employment_status
                )
  end # add_field_term

  def add_some_singles(n,params={})
    n.times { make_a_single(params)}
  end  
    
  def add_some_couples(n,params={})
    n.times do      
      h = make_a_single(params)
      s = add_spouse(h)
# puts "Couple: #{h.name}:#{s.first_name}, members.count = #{h.family.members.count}"
    end  
  end  

  def add_some_children
    distribution=[0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 5, 6]
    p_twins = 0.03
    Member.where("spouse_id IS NOT NULL AND sex = 'F' ").each do |head|
      remaining_kids = distribution.sample
      child_age = head.age_years - (19+rand(17))   # This is age of first child
      while child_age >= 0 && remaining_kids >= 0 do
        remaining_kids += -1
        add_child(head,child_age)
        add_child(head,child_age) if rand < p_twins
        # calculate age of next oldest child
        child_age = child_age - (1+6*rand*rand)  # where (1+...) is birth interval, average about 2.4 years
      end
      
    end # family each
  end # add_some_children 

  def add_some_field_terms
    Member.all.each do |m|
      if STATUS_CODES_MEMBERS.include?(m.status.code) && m.status.code != 'pipeline'
        length_of_service_years = [(30*rand*rand), 0.17].max # years
        length_of_service_days = (length_of_service_years*365.25).to_i
        start_date = m.date_active
        end_date = m.date_active
#        puts "#{m.age}: active=#{m.date_active}, length=#{sprintf("%.1f",length_of_service_years)} years:"
member=m
puts "NIL start_date in add_some_field_terms, member.status=#{member.status.code}, date_active=#{member.date_active}" if start_date.nil?
        while start_date < Date::today && ((start_date-m.date_active) < length_of_service_days)
          t = add_field_term(m) 
          if t
#            puts "\t#{t.start_date} to #{t.end_date}, #{(t.end_date-t.start_date).to_i/30} months"
            start_date = t.end_date + 3.months
          else
            start_date = Date::today.tomorrow  
   #       puts " >>> start_date=#{start_date}, service=#{(start_date-m.date_active)/365.25} years"
   #       puts " >>> delta=#{(start_date-m.date_active)}, length_of_service=#{length_of_service_days}"
          end
        end  
      end # if STATUS_CODES_...
    end  # Member.all.each
  end # add_some_field_terms
  
  def add_some_travels
    FieldTerm.all.each do |term|  # This assumes there are already terms defined!
      t = add_travel(term.member, :date=>term.start_date, :origin=>AIRPORTS_INTL.sample,
            :destination=>AIRPORTS_NG.sample, :purpose=>'Begin term', :return_date=>nil)
      if term.end_date < Date::today
        add_travel(term.member, :date=>term.end_date, :destination=>AIRPORTS_INTL.sample,
            :origin=>AIRPORTS_NG.sample, :purpose=>'Home assignment', :return_date=>nil)
      end      
#      puts "Travel: member=#{term.member.name}, date=#{term.start_date}, #{t.errors}"
    end #FieldTerm.all.each
  end # add some travels
      
end # module

 
