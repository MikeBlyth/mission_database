require 'family_seeds'

desc 'Deletes all existing family and member records and sets up test data'
namespace :seed do
  task :families => :environment do
    FamilySeed.seed
  end
end

task :delete_all => :environment do
  require Rails.root.join('spec/factories')
  Family.delete_all
  Member.delete_all
  zinsser = Factory.create(:family, :last_name=>'Zinsser', :first_name=>'Carl', :sim_id => '500')
  blackburn = Factory.create(:family, :last_name=>'Blackburn', :first_name=>'Greg', :sim_id => '501')
  puts "2 families created"
end

