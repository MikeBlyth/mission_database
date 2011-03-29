require 'spec_helper'

describe CalendarEventsController do
  
  before(:each) do
  end

  describe "authentication before controller access" do

    describe "for signed-in admin users" do
 
      before(:each) do
        @user = Factory(:user, :admin=>true)
        test_sign_in(@user)
        @attrs = {:date => Time.now, :event=>'Fun event'}
      end
      
      it "should allow access to 'new'" do
        CalendarEvent.should_receive(:new).at_least(1).times # not sure why, but it is receiving msg twice!
        get :new
      end

      it "should add a new event" do
        lambda do
          post :create, :record => @attrs
        end.should change(CalendarEvent, :count).by(1)
        e = CalendarEvent.last
        e.date.strftime("%D %T %z").should == @attrs[:date].strftime("%D %T %z")
        e.event.should == @attrs[:event]
      end
        
      it "should allow access to 'destroy'" do
        e = CalendarEvent.create(@attrs)
        e.id.should_not be_nil
        lambda {put :destroy, :id => e.id}.should change(CalendarEvent, :count).by(-1)
      end
      
      it "should allow access to 'update'" do
        e = CalendarEvent.create(@attrs)
        e.id.should_not be_nil
        put :update, :id => e.id, :record => @attrs.merge(:event=>'New Event')
        CalendarEvent.last.event.should == 'New Event'
      end
      
    end # for signed-in users

    describe "for non-signed-in users" do

      it "should deny access to 'new'" do
        get :new
        response.should redirect_to(signin_path)
      end

    end # for non-signed-in users

  end # describe "authentication before controller access"

end
