#require Rails.root.join('spec/factories')
#require Rails.root.join('spec/spec_helper')
puts "**** INCLUDING MESSAGESTESTHELPER ***"
module MessagesTestHelper

  def rand_string(n=10)
    s = rand(36**n).to_s(36)
    s << 'a' if s.size < n
    return s
  end

  def random_phone
    "+#{rand(10**10-10**9)+10**9}"
  end

  def member_w_contact(use_stub=true)
    factory_method = use_stub ? :stub : :create   # can use either stub or create
    member = Factory.send(factory_method, :member) 
    contact = Factory.send(factory_method, :contact, :member=>member, 
        :phone_1 => random_phone,
        :email_1 => "#{rand_string(5)}@test.com")
    member.stub(:primary_contact).and_return(contact) if use_stub
    member.primary_contact.should_not be_nil
    return member
  end    

  def members_w_contacts(n=1, use_stub=true)
    all = []
    n.times { all << member_w_contact(use_stub)}
    # Set up group selection so that the generated members are the ones returned for every case
    Group.stub(:members_in_multiple_groups).and_return(all)
    # Make it appear that all these members are in country
    Member.stub(:those_in_country).and_return(all)
    return all
  end  

  # some shortcuts
  def select_media(params={})
    params.each {|medium, truefalse| @message.stub("send_#{medium}".to_sym).and_return(truefalse)}
  end

  def nominal_phone_number_string
    @members.map {|m| m.primary_contact.phone_1.gsub('+','')}.join(',')
  end

  def nominal_email_array
    @members.map {|m| m.primary_contact.email_1}
  end

  def nominal_body
    "#{@message.body} #{@message.timestamp}"
  end


end #Module
