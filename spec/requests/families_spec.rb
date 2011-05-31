require 'spec_helper'
require 'sim_test_helper'

describe "Families" do
include SimTestHelper

  describe "by admin" do

    before(:each) do
      integration_test_sign_in(:admin=>true)
      @family = Factory(:family)
    end  

    it 'avoids "ambiguous status_id" bug' do
      visit families_path
      click_link "Active only"
    end

  end
end
