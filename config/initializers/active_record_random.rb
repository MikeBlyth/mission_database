# See http://paulbarry.com/articles/2009/08/30/active-record-random
# Let's you select a random record from any model, subject to scope. 
# Example: f = Family.random
class ActiveRecord::Base
  def self.random
    if (c = count) > 0
      first(:offset => rand(c)) 
    end
  end
end

