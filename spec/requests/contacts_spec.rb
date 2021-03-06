require 'spec_helper'
require '~/simjos/spec/support/sim_test_helper'
  include ApplicationHelper
  include SimTestHelper

describe 'Contacts' do
    before(:each) do
      integration_test_sign_in(:admin=>true)
    end  

    it "renders the submit button within the form (not outside it)", :slow=>true do
      visit new_contact_path
      page.should have_css('form.create input.submit')
     # assert_select "form", :action => contacts_path(@record), :method => "post" do
     #   assert_select "input#contact_name", :name => "record[name]"
     # end
    end     
 

#    before(:each) do
#     # require 'cleaner'
#      integration_test_sign_in(:admin=>true)
#      @contact_type = Factory(:contact_type)
#      @form_data = {'address'=>'MyAddress', 'blog' => 'MyBlog', 'contact_name'=>'my Contact name',
#                    'email_1' => 'me@example.com', 'email_2' => 'me2@example.com',
#                    'phone_1' => '0808-888-8888', 'phone_2' => '0808-888-8889', 
#                    'skype' => 'MySkype', 'facebook' => 'MyFacebook', 'photos' => 'MyPhotos',
#                    'other_website'=> 'My Other Website'
#                    }
#    end  

#  
#    it "should add a contact record with all info for an existing member" do
#      lambda do
#        member = factory_member_basic
#        visit members_path
#        click_link "as_members-edit-#{member.id}-link"
#        within(:xpath, "//li[@id='as_members-#{member.id}-contacts-subform']") do
#          @form_data.each {|key, value| fill_in key.humanize, :with=>value}
#          check 'Phone private'
#          check 'Email private'
#          select @contact_type.description
#        end
#        click_link_or_button('Update')
#      end.should change(Contact, :count).by(1)
#      c = Contact.last
#      @form_data['phone_1'] = @form_data['phone_1'].phone_std
#      @form_data['phone_2'] = @form_data['phone_2'].phone_std
#      @form_data.each {|key, value| c.send(key).should == value}
#      c.phone_private.should be_true
#      c.email_private.should be_true
#      c.skype_private.should be_false
#    end      

end
