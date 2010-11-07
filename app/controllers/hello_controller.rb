class HelloController < ApplicationController
   def index
    stuff = Member.select("family_id, last_name, first_name, bloodtype_id")
    output = HelloReport.new.to_pdf(stuff)

    respond_to do |format|
      format.pdf do
        send_data output, :filename => "hello.pdf", 
                          :type => "application/pdf"
      end
    end
  end
end
