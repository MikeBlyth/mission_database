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
      $('.name-input',as_form).val(make_name(as_form));
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
// Need to have :name field enabled when form is submitted, otherwise it will not
// be sent back to be processed.
    $('input.submit').live('click', function(){
      var as_form = $(this).closest("form");
      $('.name-input',as_form).removeAttr("disabled");
      $('input[name$="_name]"]').each(function(index){
        var original = $(this).val()
        var trimmed = jQuery.trim(original)
        if (original != trimmed) {
          $(this).val(trimmed);
          $(this).keypress(); // needed to alert ActiveScaffold or Rails of change 
        }
      })
    });
//
    function make_name(as_form) {
      var last_name = $('.last_name-input',as_form).val()
      var first_name = $('.first_name-input',as_form).val()
      var initial = $('.middle_name-input',as_form).val()[0]
      var short_name = $('.short_name-input',as_form).val()
      var name = jQuery.trim(last_name) + ', ' + jQuery.trim(first_name) + (initial ? ' ' + initial+'.' : '')
      if (short_name) { 
        name += ' (' + jQuery.trim(short_name) + ')'
      }
      return name      
    } 
//test
$('#actest').keyup(function() {
  alert('Handler for .keyup() called.');
});
    
  });

