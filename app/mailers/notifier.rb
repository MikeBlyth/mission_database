class Notifier < ActionMailer::Base
  default :from => "database@sim-nigeria.org"

  def send_test(recipients, content)
    @content = "Test from database@sim-nigeria.org\n\n#{content}"
    mail(:to => recipients, :subject=>'Test from database') do |format|
      format.text {render 'generic'}
    end 
  end

  def send_info(recipients, member)
    @content = "Test from database@sim-nigeria.org\n\n#{content}"
    mail(:to => recipients, :subject=>'Test from database') do |format|
      format.text {render 'generic'}
    end 
  end

  def travel_mod(recipients)
    @mods = Travel.where("travels.updated_at > ?", Date.today-7.days).includes(:member)
    mail :to => recipients, :subject=>'Travel schedule updates'
  end

  def contact_mod(recipients)
    @greeting = "Hi"
    mail :to => recipients, :subject=>'Contact information updates'
  end

end
