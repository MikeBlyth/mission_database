// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
  
    $(function() {
      $( ".country_name-input" ).live("click", function(){
        $(this).autocomplete({
          source: "autocomplete/country.js"
          });
      });
// Enable the default-disabled :name field in the member form
    $('a.allow_edit').live('click', function() {
      $(this).prev().removeAttr("disabled")
      .focus()
      });
// Build full name from components
    $('.name-input').live('click', function(){
      $(this).val('name clicked')
    });
    $('.first_name-input').live('keyup', function(){
      var as_form = $(this).closest("form");
//      $('.name-input',as_form).removeAttr('disabled');
      $('.name-input',as_form).val(make_name(as_form));
//      $('.name-input',as_form).attr('disabled', 'disabled');
    });
    $('.last_name-input').live('keyup', function(){
      var as_form = $(this).closest("form");
      $('.name-input',as_form).val(make_name(as_form));
    });
    $('.middle_name-input').live('keyup', function(){
      var as_form = $(this).closest("form");
      $('.name-input',as_form).val(make_name(as_form));
    });
    $('.short_name-input').live('keyup', function(){
      var as_form = $(this).closest("form");
      $('.name-input',as_form).val(make_name(as_form));
    });
    $('input.submit').live('click', function(){
      var as_form = $(this).closest("form");
      $('.name-input',as_form).removeAttr("disabled");
    });
//
    function make_name(as_form) {
      var last_name = $('.last_name-input',as_form).val()
      var first_name = $('.first_name-input',as_form).val()
      var initial = $('.middle_name-input',as_form).val()[0] + '.'
      var short_name = $('.short_name-input',as_form).val()
      var name = last_name + ', ' + first_name + ' ' + initial
      if (short_name) { 
        name += ' (' + short_name + ')'
      }
      return name      
    } 
//test
$('#actest').keyup(function() {
  alert('Handler for .keyup() called.');
});
    
  });

