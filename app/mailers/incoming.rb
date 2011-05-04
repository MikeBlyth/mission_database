class Incoming < ActionMailer::Base

  # Is this message from someone in our database?
  # (look for a contact record having an email_1 or email_2 matching the message From: header)
  def from_member?(message)
    !Contact.find_by_email_1(message.from.first).nil? || 
    !Contact.find_by_email_2(message.from.first).nil?
  end  

  # with incoming body like
  #   COMMAND_1 
  #   command_2 Parameters for this command 
  #   ...
  # make array like [ [command_1, ''], [command_2, 'Parameters for this command']]
  def extract_commands(message)
    commands = message.body.to_s.lines.map do |line| 
      line =~ /\s*(\w+)( .*)?/ 
      [($1 || '').downcase, ($2 || '').strip.chomp]
    end  
  end
  
  def receive(message)
    return false unless from_member?(message)
    # with incoming body like
    #   COMMAND_1 
    #   command_2 Parameters for this command 
    #   ...
    # make array like [ [command_1, ''], [command_2, 'Parameters for this command']]
    extract_commands(message).each do |command|
      case command[0]
        when 'test'
          Notifier.send_test('test@example.com', 
             "You sent 'test' with parameter string (#{command[1]})").deliver
      else
      end
    end
    
    return true
  end

end

