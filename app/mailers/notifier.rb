class Notifier < ActionMailer::Base
  default :from => "mike.blyth@sim.org"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.travel_mod.subject
  #
  def travel_mod
    @greeting = "Hi"
    @mods = Travel.where("travels.updated_at > ?", Date.today-7.days).includes(:member)
    mail :to => "to@example.org", :subject=>'Travel schedule updates'
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.contact_mod.subject
  #
  def contact_mod
    @greeting = "Hi"
    mail :to => "to@example.org", :subject=>'Contact information updates'
  end

end
