require 'spec_helper'
require 'application_helper'
require 'sim_test_helper'

describe Location do
include SimTestHelper

  it "makes a nice selection list from locations" do
    setup_cities
    setup_locations
    # The tests are dependent on the test data used. They expect the exact options shown and in the exact order, so
    # any changes to the test data will likely break the tests.
    choices = location_choices(2).gsub(/\n/, '')  # Rails procedure throws in random line-breaks; remove for testing
    choices.should =~ /^<optgroup label="Abuja"><option value="9">Abuja Guest House<\/option>/
    choices.should =~ /<optgroup label="Unspecified"><option value="999999">Unspecified<\/option><\/optgroup>$/
    choices.should =~ /<optgroup label="Jos"><option value="2" selected="selected">ECWA<\/option><option value="1">Evangel<\/option>/

  end
end

