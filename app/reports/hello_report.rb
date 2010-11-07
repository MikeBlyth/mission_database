class HelloReport < Prawn::Document
  def to_pdf(stuff)
    text "SIM Nigeria Reports", :align => :left, :size => 18
    text "Member blood types (only showing those with known type)", :size => 14
    move_down 10
    stuff.each do |m|
      if m.bloodtype_id 
        text m.last_name+', ' + m.first_name + ': ' + m.bloodtype.full
      end
    end
    render
  end
end
