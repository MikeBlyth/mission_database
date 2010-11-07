UPDATE

"REQUEST_METHOD"=>"PUT"
"QUERY_STRING"=>"record[abo]=A&record[comment]=MyString&record[created_at]=2010-10-13+10%3A25%3A31+UTC&record[full]=A-&record[id]=980190962&record[rh]=neg&record[updated_at]=2010-10-13+10%3A25%3A31+UTC",
"action_dispatch.request.request_parameters"=>{"record"=>{"abo"=>"A", "comment"=>"MyString", "created_at"=>2010-10-13 10:25:31 UTC, "full"=>"A-", "id"=>980190962, "rh"=>"neg", "updated_at"=>2010-10-13 10:25:31 UTC}}, 
"action_dispatch.request.path_parameters"=>{"id"=>"980190962", "controller"=>"bloodtypes", "action"=>"update"}, 
"action_dispatch.request.parameters"=>{"record"=>{"abo"=>"A", "comment"=>"MyString", "created_at"=>2010-10-13 10:25:31 UTC, "full"=>"A-", "id"=>980190962, "rh"=>"neg", "updated_at"=>2010-10-13 10:25:31 UTC}, "id"=>"980190962", "controller"=>"bloodtypes", "action"=>"update"}, 
@fullpath="/bloodtypes/980190962?record[abo]=A&record[comment]=MyString&record[created_at]=2010-10-13+10%3A25%3A31+UTC&record[full]=A-&record[id]=980190962&record[rh]=neg&record[updated_at]=2010-10-13+10%3A25%3A31+UTC", 
"_response_body"=>["<html><body>You are being <a href=\"http://test.host/bloodtypes\">redirected</a>.</body></html>"]
"_action_name"=>"update"
"record"=>#<Bloodtype id: 980190962, abo: "A", rh: "neg", comment: "MyString", created_at: "2010-10-13 10:25:31", updated_at: "2010-10-13 10:25:31", full: "A-">

SHOW

"REQUEST_METHOD"=>"GET",
"QUERY_STRING"=>""
"action_dispatch.request.query_parameters"=>{}, 
"action_dispatch.request.path_parameters"=>{"id"=>"980190962", "controller"=>"bloodtypes", "action"=>"show"}, 
"action_dispatch.request.request_parameters"=>{}, 
"action_dispatch.request.parameters"=>{"id"=>"980190962", "controller"=>"bloodtypes", "action"=>"show"}
"record"=>#<Bloodtype id: 980190962, abo: "A", rh: "neg", comment: "MyString", created_at: "2010-10-13 10:25:31", updated_at: "2010-10-13 10:25:31", full: "A-">

NEW

"action_dispatch.request.path_parameters"=>{"controller"=>"bloodtypes", "action"=>"new"}, 
"action_dispatch.request.request_parameters"=>{}, 
"action_dispatch.request.parameters"=>{"controller"=>"bloodtypes", "action"=>"new"}, 
"PATH_INFO"=>"/bloodtypes/new", 
@fullpath="/bloodtypes/new"
"record"=>#<Bloodtype id: nil, abo: nil, rh: nil, comment: nil, created_at: nil, updated_at: nil, full: nil>,

INDEX

"action_dispatch.request.path_parameters"=>{"controller"=>"bloodtypes", "action"=>"index"},
"action_dispatch.request.request_parameters"=>{}
"action_dispatch.request.parameters"=>{"controller"=>"bloodtypes", "action"=>"index"}
"PATH_INFO"=>"/bloodtypes", 
"page"=>#<Paginator::Page:0x437f250 
        @number=1, 
        @pager=#<Paginator:0x437f358 
		@per_page=999999999, 
		@count=2, 
		@select=#<Proc:0x437f328@C:/Users/Mike/Documents/SIMDB/SIM2/vendor/plugins/active_scaffold/lib/active_scaffold/finder.rb:306>
                >, 
        @offset=0, 
        @select=#<Proc:0x437f280@C:/Users/Mike/Documents/SIMDB/SIM2/vendor/plugins/active_scaffold/lib/paginator.rb:62 (lambda)>,
        @items=[#<Bloodtype id: 980190962, abo: "A", rh: "neg", comment: "MyString", created_at: "2010-10-13 10:25:31", updated_at: "2010-10-13 10:25:31", full: "A-">, 
                #<Bloodtype id: 298486374, abo: "O", rh: "+", comment: "MyString", created_at: "2010-10-13 10:25:31", updated_at: "2010-10-13 10:25:31", full: "O+">]>, "records"=>[#<Bloodtype id: 980190962, abo: "A", rh: "neg", comment: "MyString", created_at: "2010-10-13 10:25:31", updated_at: "2010-10-13 10:25:31", full: "A-">, #<Bloodtype id: 298486374, abo: "O", rh: "+", comment: "MyString", created_at: "2010-10-13 10:25:31", updated_at: "2010-10-13 10:25:31", full: "O+">],
"nested_auto_open"=>nil}

EDIT

"action_dispatch.request.path_parameters"=>{"id"=>"980190962", "controller"=>"bloodtypes", "action"=>"edit"}, "action_dispatch.request.request_parameters"=>{}, 
"action_dispatch.request.query_parameters"=>{}, 
"action_dispatch.request.request_parameters"=>{}, 
"action_dispatch.request.parameters"=>{"id"=>"980190962", "controller"=>"bloodtypes", "action"=>"edit"}, 
"PATH_INFO"=>"/bloodtypes/980190962/edit", 
"record"=>#<Bloodtype id: 980190962, 
	abo: "A", rh: "neg", comment: "MyString", created_at: "2010-10-13 10:25:31", updated_at: "2010-10-13 10:25:31", full: "A-">, 
"component_flash"=>{}, 
"params_for"=>{"id"=>"980190962", "controller"=>"/bloodtypes", "action"=>"edit"}

CREATE

"QUERY_STRING" => "record[abo]=A&record[comment]=MyString&record[created_at]=2010-10-13+12%3A00%3A40+UTC&record[full]=CREATE&record[id]=980190962&record[rh]=neg&record[updated_at]=2010-10-13+12%3A00%3A40+UTC"
"action_dispatch.request.request_parameters"=>
	{"record"=>
		{"abo"=>"A", "comment"=>"MyString", "created_at"=>2010-10-13 12:00:40 UTC, "full"=>"CREATE", "id"=>980190962, 
			"rh"=>"neg", "updated_at"=>2010-10-13 12:00:40 UTC
		}
	}, 
"action_dispatch.request.path_parameters"=>{"controller"=>"bloodtypes", "action"=>"create"},
"action_dispatch.request.flash_hash"=>{:info=>"Created CREATE"}, 
"action_dispatch.request.parameters"=>
	{"record"=>{"abo"=>"A", "comment"=>"MyString", "created_at"=>2010-10-13 12:00:40 UTC, "full"=>"CREATE", "id"=>980190962, 
	"rh"=>"neg", "updated_at"=>2010-10-13 12:00:40 UTC}, "controller"=>"bloodtypes", "action"=>"create"
	}, 
"PATH_INFO"=>"/bloodtypes", 

DESTROY

"component_flash"=>{"info"=>"Deleted A-"}, 
"params_for"=>{"id"=>"980190962", "controller"=>"/bloodtypes", "action"=>"destroy"}
"record" => #<Bloodtype id: 980190962, 	abo: "A", 	rh: "neg", 	comment: "MyString", 	created_at: "2010-10-13 10:25:31", 	updated_at: "2010-10-13 10:25:31", 	full: "A-">