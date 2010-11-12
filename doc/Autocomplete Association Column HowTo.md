# Creating an Autocompleting Association Input in Rails3 + ActiveScaffold + JQuery

The Rails/ActiveScaffold project I’m working on has models for Member and Country. Each member belongs to a country—i.e. has a nationality. This is all done in the usual way using a key country_id in the member model to refer to the country:

    class Member < ActiveRecord::Base 
    belongs_to :country 

and

    class Country < ActiveRecord::Base 
    has_many :members 

The usual way of making an editing control in the member create and update forms is simply to add the line

    config.columns[:country].form_ui = :select 

to the members controller. This creates a dropdown select box populated with the labels and ids (values) of the countries table. If your list of options (countries in this case) is very large, however, it can be impractical to send the entire list for the user to select from. Hence the need for something like an Ajax-based autocompletion input. As the user enters characters, the newly forming string is sent back to the server, which returns a list of possible options that match the string to the current point. Type “Z” for the country and “Zimbabwe” and “Zambia” pop up (possibly along with all the country names with ‘z’ anywhere in them).

I've spent several days trying to convert a select-box to an autocompleting-text-box in my Rails project. One thought was that perhaps I should have left well-enough alone rather than make the change. Even selecting a list of several hundred options for a select list does not add too much overhead: say 300 items of 20 characters each = 6 KB, hardly worth worrying about. Still, I’ve done it so will document what worked for me.

My second thought is actually a question: why isn’t it dirt-easy to do this in Rails and/or ActiveScaffold? Is it so rarely used? Or perhaps I simply missed the easy way even though I did quite a bit of searching. There is an <a href=''>auto_complete</a> plugin but I couldn't get it to work with Rails 3 and ActiveScaffold--perhaps I could now that I understand more. I was greatly helped by Anup Narkhede's <a href='http://www.anup.info/2009/07/01/using-autocomplete-with-activescaffold-forms/'>helpful example</a>. In the end, though, I found a method that seems to me even easier than using the plugin!

## How to Do It

Anyway, this is how I did it – I’m sure there are better ways. To start with an overview, the way I did this is:

1. Adjust the member model so that we can set the `country_id` indirectly just by saying `this_member.country_name='France'`. To do this define accessor method's to read and write the member's country name. The read method looks up the `country_id` and returns the name, while the write method `country_name=` sets the `country_id` based on the name.

2. Replace the form's input for `country_id` with one for `country_name`.

3. Create a lookup function to be called by JQuery. For example, if JQuery sends 'Z' the function will return {'Zambia','Zimbabwe'}.

4. Add the JQuery autocomplete function to the `country_name` input.

### The Details

The details are actually simpler than the explanation! Start with these models:

	class Member < ActiveRecord::Base 
	  belongs_to :country
	end

	class Country < ActiveRecord::Base
	  validates_uniqueness_of :name
	  has_many :members
	end

### Step 1: add the accessor functions to the `member` model:

	class Member < ActiveRecord::Base 
	  belongs_to :country

       def country_name
         Country.find(country_id).name
       end
  
       def country_name= (name)
         self.country_id = Country.find_by_name(name).id
       end
	end

### Step 2: Replace the form's input for `country_id` with one for `country_name`:

	class MembersController < ApplicationController
	  active_scaffold :member do |config|
	    config.columns = [:name, :country_name]
	  end
     end
	
*Totally Optional Sidetrack:* Before I hit on the technique of using the accessor methods in the model, I was overriding the MemberController `update` and `create` methods, as <a href='http://www.anup.info/2009/07/01/using-autocomplete-with-activescaffold-forms/'>Anup Narkhede</a> had shown. If for some reason you use a variation of that technique, there is one gotcha to be aware of. You cannot simply look up the id and insert it as `params[:record][:country]` unless  the `:country` column was included in the form, because it will be ignored. This is part of the security of Rails 3: the user can't pass back arbitrary fields, because only those present in the form are processed. So, when I was overriding the controller `update` and `create` methods, I had to include the original `:country` column as a hidden field in the form. I'm guessing that this is also the reason that Anup first saved the country id in an instance variable @country, then used it in a `before_create_save` method rather than just adding the new element to the parameter hash.

*Sidetrack:* Note that you could compose any kind of string to use as the label rather than using "name." You would simply write the accessors for whatever you wanted. For example, you could use nationality rather than country name. Whatever is used, however, must be present and unique for each country so that the label-to-id lookup will return a single, valid country.

### Step 3: Create a lookup function to be called by JQuery.

_In app/controllers/countries\_autocomplete\_controller.rb_

    class CountriesAutocompleteController < ApplicationController
    
      def index
        @countries = Country.where("name LIKE ?", "#{params[:term]}%").select("id, name")
        @json_resp = []
        @countries.each do |c|
          @json_resp << c.name
        end
    
        respond_to do |format|
          format.js { render :json => @json_resp }
        end
      end
    
    end

I would have preferred to put this into the existing CountriesController, but for some reason when I did that the response was very slow (2+ seconds). In any case, it's important to get the routing right. I used 
   
      match 'countries_autocomplete/index'

### Step 4. Set up JQuery
