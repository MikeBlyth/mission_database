// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
// ****************** COUNTRY NAME **************************************  
    $(function() {
      $( ".country_name-input" ).live("click", function(){
        $(this).autocomplete({
          source: "autocomplete/country.js"
          });
      });
      
// ******************* MEMBER NAME MANIPULATION ON CREATE/UPDATE FORM
// **********************************************************************************      
// Name is disabled by default. If user clicks on it and the name-override is checked,
//   enable the input
    $('a.allow_edit').live('click', function() {
      var as_form = $(this).closest("form")
      var name_field = $('input.name-input',as_form)
      if (name_override(as_form)) 
      {
        name_field.removeAttr("disabled")  
        .focus()
      }
      else 
      {
        alert("Check the 'Name override' box if you want to set the name yourself.")
      }
    });
    $('input[name="record[name_override]"]').live('click', function() {
      var as_form = $(this).closest("form")
      var name_field = $('input.name-input',as_form)
      if (name_override(as_form))
      {
        name_field.removeAttr('disabled')
      }
      else
      {
        name_field.attr('disabled','disabled')
      }
    });
//
// Build full name from components whenever a key is pressed in a name input box
    $('.last_name-input', '.middle_name-input', '.first_name-input', '.short_name-input').live('keyup', function(){
      make_name($(this).closest("form"));
    });
    $('.last_name-input').live('click', function(){
      make_name($(this).closest("form"));
    });

// Need to have :name field enabled when form is submitted, otherwise it will not
// be sent back to be processed.
    $('input.submit').live('click', function(){
      var as_form = $(this).closest("form")
      var name_field = $('.name-input',as_form)
// trim all the parts of person and country name
      $('input[name$="_name]"]').each(function(index){
        var original = $(this).val()
        var trimmed = jQuery.trim(original)
        if (original != trimmed) {
          $(this).val(trimmed)
          $(this).keypress() // needed to alert ActiveScaffold or Rails of change 
        }
      })
      if (name_automatic(as_form)) {  // if user has not overriden auto-name-generation
        make_name(as_form)
      }  
      // unfortunately, we have to enable the input for Rails to see it
      name_field.removeAttr("disabled")
      name_field.keypress()
    });
//
//  Report whether the name_override box is checked
    function name_override(as_form) {
      var checked = $('input[name="record[name_override]"]',as_form).is(':checked')
      return checked
    }
    // This is just the opposite of name_override, for convenience
    function name_automatic(as_form) { 
      var checked = name_override(as_form)
      return !checked
      // why doesn't !name_override(as_form) work? 
    }
    // Compose the name from its parts unless name_override (!name_automatic) is checked
    function make_name(as_form) {
      if (name_automatic(as_form)) {
        var name_field = $('input.name-input',as_form)
        var last_name = $('.last_name-input',as_form).val()
        var first_name = $('.first_name-input',as_form).val()
        var initial = $('.middle_name-input',as_form).val()[0]
        var short_name = $('.short_name-input',as_form).val()
        var name = jQuery.trim(last_name) + ', ' + jQuery.trim(first_name) + (initial ? ' ' + initial+'.' : '');
        if (short_name) { 
          name += ' (' + jQuery.trim(short_name) + ')'
        }
        // To update the name, we must enable the input, insert the name, 
        //   signal a keypress. Then we again disable the input again.
        //   (When automatic name generation is in effect, the name input is
        //   disabled since the program determines the name)
        name_field.removeAttr("disabled")
        name_field.val(name)
        name_field.keypress()
        name_field.attr("disabled","disabled")
      }
    } 
  });
// ************************ GET ID OF MEMBER BEING UPDATED *************
  function get_update_id(as_form) { 
    part_match = as_form.attr('id').match(/update-(\d+)-/)
    return part_match == null ? 'new' : part_match[1]
    };
// ************************ FAMILY LOOKUP ******************************
// *********************************************************************
$(function() {
  $( "input.family_name-input" ).live("click", function(){
    $(this).autocomplete({
      source: "autocomplete/family.js"
      });
  });
});

// ************************ SPOUSE LOOKUP ******************************
// *********************************************************************
$(function() {
  $("select.spouse-input" ).live("click", function(){
  var as_form = $(this).closest("form")
  var select_control = $(this)
  var last_name = $('input.last_name-input',as_form).val()
  var sex = $('select.sex-input option:selected',as_form)
  var my_id = get_update_id(as_form)
  $.getJSON("members/spouse_select.js", 
            {name: last_name, 
             sex: sex.text()[0],
             id: my_id}, 
    function(data){
    // !!** need to do something to check whether data is returned before we 
    // !!**   destroy the existing option list
      select_control.empty()
      $.each(data, function(index,member){
        select_control.append("<option value='" + member.id + 
        "'>" + member.name + "</option>")
      }) 
    });
  });
});

