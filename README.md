Mission Personnel Database
==========================

Mission Database is a web-based personnel database and message broadcast system designed for small-to-medium size international organizations such as missions and NGOs. Its purpose is to provide a unified, consistent and accessible source of the organization's personnel data in a single location. Its details are arranged specifically for the group SIM in Nigeria, but it can be modified to fit the needs of many other organizations. The main features include

*	Since it is web based, any authorized user can access the data from anywhere
	as long as an Internet connection is available.

*	Users can also use email and SMS (mobile phone text messages) to retrieve
	information such as a calendar, report, or contact info for another user.
	This means that Internet access is not needed for basic information retrieval.  
	
*	Users can *broadcast* messages to all employees or selected subsets, with
	the messages sent by email and/or SMS. For example, an authorized user can
	use her mobile phone to send a text message to the system, which will then
	rebroadcast it to all the members in a certain location.
 
*	The system can email notices about updates to the travel and contact
	data. Travelers receive email reminders about their planned travel, so
	that they can communicate any changed plans before it's too late.

*	Report capabilities (most of these can be shown in the browser as well as 
	downloaded as PDF files)
	*    directory (phone and email list) by name and/or location
	*    travel schedule
	*    current and projected tours of duty
	*    calendar (one month) showing birthdays and travel
	*    birthday list (by name and by date)
	*    blood type list (great when emergency donors are needed)
	*    a few basic statistical reports such as tables of members by age
	     and sex, locations, positions, and so on

*	Data an be exported into comma-separated-value (CSV) files for importing
	into spreadsheets or other databases.

*	Employee data includes 
	*    demographics such as birthdate, nationality, sex, and current location,
	     spouse (may also be employed), children ...
	*    basic health data including blood type, medications, medical problems
	*    organization data such as position (ministry), qualifications, and date 
	     employed
	*    contact information (email addresses, phone numbers, blogs, emergency
	     contacts ...)
	*    current and past travel (assumed to be international travel to and from
	     the assigned country)
	*    tours of duty (in missions parlance, "terms") past, current, and planned

	Employees/members are organized in family units [since SIM uses the term
	"members", we will use that term interchangeably with "employees" in this
	document].

Technical Overview
------------------

Framework: Ruby on Rails version 3.0.7, with ActiveScaffold.

Database: PostgreSQL 

Pre-configured SMS Gateways: Clickatell, Twilio

Security:

*	Username-password authentication
*	*All* Internet access is secure (HTTPS)
*	Group-based authorization
*	Email and SMS communication is authenticated based on the phone number
	or email address. (While an email "from" address could be spoofed, the reply
	can only be sent to the valid email address.)