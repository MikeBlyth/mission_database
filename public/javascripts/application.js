// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
  
    $(function() {
      $( ".country_name-input" ).live("click", function(){
        $(this).autocomplete({
          source: "autocomplete/country.js"
          });
      });
    $('a.allow_edit').live('click', function() {
      $(this).prev().removeAttr("disabled")
      .focus()
      });
  });

