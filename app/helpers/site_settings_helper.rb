module SiteSettingsHelper

  def settings_field(field)
    ("<div class='site_setting' id='#{field}_form'>".html_safe +
    label_tag(field, field.to_s.humanize) +
    "<br>".html_safe +
    text_field_tag(field, SiteSetting[field]) +
    "</div>".html_safe
    )
  end

end
