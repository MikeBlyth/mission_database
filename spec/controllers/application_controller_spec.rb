require 'spec_helper'

describe ApplicationController do

  describe 'set_member_filter' do
  
    it 'sets filter to Active Only' do
      get :set_member_filter, :filter=>'active'
      session[:filter].should == 'active'
      response.should redirect_to(root_path)
    end # set_member_filter

    it 'redirects to members page if referred from there' do
      request.env['HTTP_REFERER'] = 'http://www.example.com/members'
      get :set_member_filter, :filter=>'active'
      session[:filter].should == 'active'
      response.should redirect_to(members_path)
    end

    it 'redirects to families page if referred from there' do
      request.env['HTTP_REFERER'] = 'http://www.example.com/families'
      get :set_member_filter, :filter=>'pineapple'
      session[:filter].should == 'pineapple'
      response.should redirect_to(families_path)
    end

  end

  describe 'set_travel_filter' do
  
    it 'sets filter to Active Only' do
      get :set_travel_filter, :travel_filter=>'coconut'
      session[:travel_filter].should == 'coconut'
      response.should redirect_to(travels_path)
    end # set_member_filter

  end # set travel filter
end

