# For generating different kinds of reports output to PDF
# Perhaps should be refactored so that each report is inside its own main model's controller?
class ReportsController < ApplicationController
  include AuthenticationHelper
  include ApplicationHelper


  before_filter :authenticate 

  def index
    # this just displays a view that lets the user select from reports
  end

  def whereis
    # Who to include in the report ... options not implemented yet
    # include_home_assignment = params[:include_home_assignment]
    # include_active = params[:include_active]
    @families = Family.those_on_field_or_active.includes(:members, :residence_location).order("name ASC")
    @title = "Where Is Everyone?"
    respond_to do |format|
      format.html do 
        if params[:by] == 'location'
          render :template=>'reports/whereis_by_location' 
        else
          render :template=>'reports/whereis' 
        end
      end
      format.pdf do
        output = WhereIsTable.new(:page_size=>Settings.reports.page_size).
             to_pdf(@families)
        send_data output, :filename => "where_is_everyone.pdf", 
                         :type => "application/pdf"
      end
    end
  end

  def whereis_original
#    active_statuses = Status.where(:active=>true).select('id').collect {|m| m.id}
    selected = Member.includes(:residence_location, :work_location, :contacts, :spouse).where(:child=> false).limit(20).
             select("id, status_id, spouse_id, last_name, first_name, middle_name, short_name, residence_location_id, work_location_id," +
                     " temporary_location, temporary_location_from_date, temporary_location_until_date")
#puts "Whereis selected="
#selected.each  {|x| puts "\t#{x.attributes}"    }
#    member_locations = selected.collect{ |m| {:name=>m.last_name_first(:initial=>true, :short=>true),
#                                             :location=>m.current_location}
#                                       }
    field_contact_id = ContactType.find_by_code(1).id  # Use this to select the right contact for field
    @member_locations = []
    @title = "Where Is Everyone?"
    selected.each do |m|
      work_location = description_or_blank(m.work_location)
      work_location = '' if work_location.downcase == 'unspecified'
      if m.on_field || m.visiting_field?
        field_contact = m.contacts.where(:contact_type_id=>field_contact_id).first
        if field_contact
          email = field_contact.email_1
          phone = field_contact.phone_1
      else
        puts "No field contact for #{m.full_name}, field_contact_id = #{field_contact_id}, contacts=#{m.contacts.count}"
        end  
        @member_locations << {:name=>m.last_name_first(:initial=>true, :short=>true), 
                              :current_location=>m.current_location,
                              :residence_location=>description_or_blank(m.residence_location),
                              :work_location=> work_location,
                              :travel_location=>m.travel_location,
                              :temporary_location=>m.temporary_location,
                              :email => email,
                              :phone => phone,
                              :spouse => m.spouse
                              }
      end  
    end
    @member_locations.sort! {|x,y| x[:name] <=> y[:name]}
    @members_by_location = @member_locations.sort {|x,y| (x[:residence_location] + x[:name]) <=> (y[:residence_location]+y[:name])}
    respond_to do |format|
      format.html
      format.pdf do
#        output = WhereisReport.new.to_pdf(@member_locations, @members_by_location)
        output = WhereIsTable.new.to_pdf(@member_locations, @members_by_location, '')
        send_data output, :filename => "where_is.pdf", 
                         :type => "application/pdf"
      end
    end
  end

   # Blood Type Reports
   def bloodtypes
     selected = Member.select("family_id, last_name, first_name, middle_name, status_id, id, child")
#selected.each {|x| puts ">> #{x.first_name}, #{x.status.description}, #{x.on_field}, #{x.health_data.bloodtype_id}, #{x.health_data.bloodtype}" }
     # Delete members we don't want on the report
     selected = selected.delete_if{|x| 
                                    !x.on_field || 
                                    x.health_data.nil? || 
                                    x.child || 
                                    x.health_data.bloodtype.nil? || 
                                    x.health_data.bloodtype_id == UNSPECIFIED
                                    } 

     respond_to do |format|
       format.pdf do
         output = BloodtypeReport.new(:page_size=>Settings.reports.page_size).
              to_pdf(selected,"Includes only those currently on the field")
         send_data output, :filename => "bloodtypes.pdf", 
                          :type => "application/pdf"
       end
     end
   end

  # Birthday reports
   def birthdays
    selected = Member.where(conditions_for_collection).select("family_id, last_name, first_name, middle_name, short_name, birth_date, status_id")
 #   selected = selected.delete_if{|x| !x.active }   # delete members not on the field
    filter = (session[:filter] || "").gsub('_', ' ')
    left_head = filter.blank? ? '' : "with status = #{filter}" 

    respond_to do |format|
      format.pdf do
        output = BirthdayReport.new(:page_size=>Settings.reports.page_size).
              to_pdf(selected,:left_head=>left_head)
        send_data output, :filename => "birthdays.pdf", 
                          :type => "application/pdf"
      end
    end
  end

  # Contact reports
   def phone_email
    selected = Member.where(conditions_for_collection).
                      where("child is false").
            select("family_id, child, last_name, first_name, middle_name, short_name, id")
    filter = (session[:filter] || "").gsub('_', ' ')
    left_head = filter.blank? ? '' : "with status = #{filter}" 

    respond_to do |format|
      format.pdf do
        output = PhoneEmailReport.new(:page_size=>Settings.reports.page_size).
              to_pdf(selected,:left_head=>left_head)
        send_data output, :filename => "phonelist.pdf", 
                          :type => "application/pdf"
      end
    end
  end

  # Travedl reports
   def travel_schedule
    starting_date = Date::today
    selected = Travel.where("date >= ?", starting_date).order("date ASC")
    # We will assume for now that we do not need to filter for different member statuses, since if there is a travel
    # record for someone, it means that we wanted it on the travel schedule.
    left_head = "#{starting_date}"

    respond_to do |format|
      format.pdf do
#        output = TravelScheduleReport.new.to_pdf(selected, :title=>'Travel Schedule', :left_head=>left_head)
        output = TravelScheduleTable.new(:page_size=>Settings.reports.page_size).
              to_pdf(selected, params)
        send_data output, :filename => "travel_schedule.pdf", 
                          :type => "application/pdf"
      end
    end
  end

   # 
   # TODO Does this actually have to be here duplicating the one in members_controller?
   def conditions_for_collection
    status_groups = {'active' => %w( field home_assignment mkfield),
                'field' => %w( field mkfield visitor),
                'home_assignment' => %w( home_assignment ),
                'home_assignment_or_leave' => %w( home_assignment leave),
                'pipeline' => %w( pipeline ),
                'visitor' => %w( visitor visitor_past ),
                'other' => %w( alumni college mkadult retired deceased mkalumni unspecified )
                }
      # The groups reflect the status codes matched by the various filters. So, for example,
      #   the filter "active" (or :active) should trigger a selection string that includes the statuses with codes
      #   'field', 'home_assignment', and 'mkfield'

    target_statuses = status_groups[session[:filter]]
    return "TRUE" if target_statuses.nil?
    # Find all status records that match that filter
    matches = [] # This will be the list of matching status ids. 
    Status.where("statuses.code IN (?)", target_statuses).each do |status|
      matches << status.id 
    end
    return ['members.status_id IN (?)', matches]
  end
  
  # Return starting date for calendar. If the date is not specified in params,
  #    use the first of the next month.
  def date_for_calendar
    if params[:date]
      date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1)
    else
      next_m = Date::today().next_month
      date = Date.new(next_m.year, next_m.month, 1)
    end
#puts "date_for_calendar = #{date}"
    return date
  end

  # Set up a new calendar object using parameters supplied in params, or defaults
  def calendar_setup
    date = date_for_calendar
    page_size = params[:page_size] || Settings.reports.page_size
    page_layout = params[:page_layout] || :landscape
    box = params[:box] || false
    title = params[:title] || "#{Date::MONTHNAMES[date.month]} #{date.year.to_s}"
#    title << " [filter = #{session[:filter]}]"
    return CalendarMonthPdf.new(:title=>title, :date=>date, :page_size=>page_size, :page_layout=>page_layout, :box=>box)
  end

  def calendar
    # Set up the calendar form for right month (page size, titles, etc.)
#puts "Calendar, params=#{params}"
    calendar = calendar_setup
       
    birthday_data = params[:birthdays] ? birthday_calendar_data({:month=>date_for_calendar.month}) : []
    travel_data = params[:travel] ? travel_calendar_data({:date=>date_for_calendar}) : []
    events_data = params[:events] ? calendar_events_data({:date=>date_for_calendar}) : []
    # Merge the different arrays of data--birthdays, travel, anything else
    merged = merge_calendar_data([travel_data, birthday_data, events_data])

    # Actually print the strings

    respond_to do |format|
      format.pdf do
        calendar.put_data_into_days(merged)
        send_data calendar.render, :filename => "calendar.pdf", 
                          :type => "application/pdf"
      end
    end
  end
 
  def birthday_travel_calendar
    # Set up the calendar form for right month (page size, titles, etc.)
    calendar = calendar_setup
       
    # Select the people born this month and to put on the calendar
    birthday_data = birthday_calendar_data({:month=>date_for_calendar.month})

    # Select the people born this month and to put on the calendar
    travel_data = travel_calendar_data({:date=>date_for_calendar})

    # Actually print the strings
    merged = merge_calendar_data([travel_data, birthday_data])

    respond_to do |format|
      format.pdf do
        calendar.put_data_into_days(merged)
        send_data calendar.render, :filename => "birthday_travel_calendar.pdf", 
                          :type => "application/pdf"
      end
    end
  end
 
  def travel_calendar
    # Set up the calendar form for right month (page size, titles, etc.)
    calendar = calendar_setup
       
    # Select the people born this month and to put on the calendar
    travel_data = travel_calendar_data({:date=>date_for_calendar})

    # Actually print the strings

    respond_to do |format|
      format.pdf do
        calendar.put_data_into_days(travel_data)
        send_data calendar.render, :filename => "travel_calendar.pdf", 
                          :type => "application/pdf"
      end
    end
  end

  def birthday_calendar
    # Set up the calendar form for right month (page size, titles, etc.)
    calendar = calendar_setup
       
    # Select the people born this month and to put on the calendar
    birthday_data = birthday_calendar_data({:month=>date_for_calendar.month})

    # Actually print the strings

    respond_to do |format|
      format.pdf do
        calendar.put_data_into_days(birthday_data)
        send_data calendar.render, :filename => "birthday_travel_calendar.pdf", 
                          :type => "application/pdf"
      end
    end
  end
 
 
  # Test showing how to generate tables with Prawn
   def tabletest
    selected = Member.select("family_id, last_name, first_name, status_id")
    output = TableTest.new.to_pdf(selected,"Includes only those currently on the field")

    respond_to do |format|
      format.pdf do
        send_data output, :filename => "tabletest.pdf", 
                          :type => "application/pdf"
      end
    end
  end

#  # Test showing how to use multi-column layout with Prawn and our own (temporary?) flow_in_columns method
#   def multi_col_test
#    output = MultiColumnTest.new.to_pdf()

#    respond_to do |format|
#      format.pdf do
#        send_data output, :filename => "test.pdf", 
#                          :type => "application/pdf"
#      end
#    end
#  end

private

  # Generate data structure for birthdays to insert into calendar
  def birthday_calendar_data(params={})
    prefix = Settings.reports.birthday_calendar.birthday_prefix # Something like "BD: " or icon of a cake, to precede each name
    month = params[:month] || 1
    selected = Member.where(conditions_for_collection).select("family_id, last_name, first_name, middle_name, birth_date, short_name, status_id")

    # Make a hash like { 1 => {:text=>"BD: John Doe\nBD: Mary Smith"}, 8 => {:text=>"BD: Adam Smith\n"}}
    # Using the inner hash leaves us room to add options/parameters in the future
    data = {} 
    selected.each do |m|
      if m.birth_date && (m.birth_date.month == month ) # Select people who were born in this month
        data[m.birth_date.day] ||= {:text=>''}
        data[m.birth_date.day][:text] << prefix + m.full_name_short + "\n" 
      end
    end
    return data
  end # birthday_calendar_data

  # Generate data structure for travel to insert into calendar
  def travel_calendar_data(params={})
    prefixes = {true=>Settings.reports.travel_calendar.arrival_prefix, false=>Settings.reports.travel_calendar.departure_prefix}
    starting_date = params[:date]
    selected = Travel.where("date > ? and date < ?", starting_date, starting_date.next_month).order("date ASC")
    # Make a hash like { 1 => {:text=>"AR: John Doe\nDP: Mary Smith"}, 8 => {:text=>"AR: Adam Smith\n"}}
    data = {} 
    selected.each do |trip|
      data[trip.date.day] ||= {:text=>''}
      data[trip.date.day][:text] << prefixes[trip.arrival?] + trip.member.full_name_short + "\n" 
    end
    return data
  end # travel_calendar_data

  # Generate data structure for travel to insert into calendar
  def calendar_events_data(params={})
    starting_date = params[:date]
    selected = CalendarEvent.where("date > ? and date < ?", starting_date, starting_date.next_month).order("date ASC")
    # Make a hash like { 1 => {:text=>"AR: John Doe\nDP: Mary Smith"}, 8 => {:text=>"AR: Adam Smith\n"}}
    data = {} 
    selected.each do |e|
      data[e.date.day] ||= {:text=>''}
      event_time = e.date.strftime("%l:%M %p").strip
      data[e.date.day][:text] << e.event
      data[e.date.day][:text] << " " << event_time if event_time != "12:00 AM"
      data[e.date.day][:text] << "\n"
    end
    return data
  end # travel_calendar_data

  def merge_calendar_data(data_hashes)
    merged = {}
    data_hashes.each do |data_hash|
      data_hash.each do |date, content|
        merged[date] ||= {:text=>''}
        content.each do |key, value|  # Remember content is a hash with text plus options
          if key == :text
            merged[date][:text] << value
          else
            merged[date][key] ||= value  # Idea here is to set the parameter only once, first come first saved
          end    
        end # of each element in content for this date in this data_hash
      end  # of data_hash.each, handling a single list such as the travel data  
    end  # of data_hashes.each, handling the whole set of data to be merged
    return merged
  end # of merge_calendar_data
  

end
