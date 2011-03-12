module AuthorizationHelper

ROLES =  {'admin'=>"System administrator", 
          'personnel'=> "Personnel manager",
          'asst_personnel'=>"Personnel assistant", 
          'travel'=>"Travel", 
          'immigration'=>"Immigration", 
          'medical'=>'Medical',
          'member' => "Member"
          }

MODELS = [:bloodtype, :city, :contact, :contact_type, :country, :education, :employment_status, :family, :field_term] + 
         [:health_data, :location, :member, :ministry, :role, :state, :status, :travel, :user]
         
LOOKUPS =[:bloodtype, :city, :contact_type, :country, :education, :employment_status, :location, :ministry, :state, :status]

MEMBER_DATA = [:contact, :family, :field_term, :health_data, :member, :travel]

USER_DATA = [:role, :user]
         
    
end  
  
