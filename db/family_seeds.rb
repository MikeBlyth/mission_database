
# Initialize development database with some families and members
#ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require './spec/factories'

Family.delete_all
Member.delete_all
zinsser = Factory.create(:family, :last_name=>'Zinsser', :first_name=>'Carl', :sim_id => '500')
blackburn = Factory.create(:family, :last_name=>'Blackburn', :first_name=>'Greg', :sim_id => '501')
adler = Factory.create(:family, :last_name=>'Adler', :first_name=>'Fran', :sim_id => '502')
adler.head.sex = 'F'
Factory.create(:member, :family=>zinsser, :sex=>'F', :spouse=>zinsser.head, :first_name=>'Mary')
Factory.create(:member, :family=>zinsser, :first_name=>'Child_1', :sex=>'M')
Factory.create(:member, :family=>blackburn, :sex=>'F', :spouse=>blackburn.head, :first_name=>'Sonya')
puts "Created #{Family.count} families and #{Member.count} members."

