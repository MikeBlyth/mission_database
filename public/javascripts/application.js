// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Message page
// SMS Selection
    $('#record_send_sms').live("change", function(){
        if ($(this).is(':checked')) {
          $('.counter').css('display','block')
          $('#record_retries').css('display','inline')
          $('label[for=record_retries]').css('display','inline')
          }
        else {
          $('.counter').css('display','none')
          $('#record_retries').css('display','none')
          $('label[for=record_retries]').css('display','none')
        }  
      });

// ****************** DATEPICKER **************************************  
	$(function() {
    $(".datepicker").live("click", function(){
        $(this).datepicker();
      });
   });
  
// ****************** COUNTRY NAME **************************************  
    $(function() {
      $( ".country_name-input" ).live("click", function(){
        $(this).autocomplete({
          source: "autocomplete/country.js"
          });
      });
    });

    $(function() {
      $('#show_wife').live('click', function() {
        if ($(this).is(':checked')) {
          $('.wife_hidden').css('display','block')
          }
        else {
          $('.wife_hidden').css('display','none')
        }  
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
//    $('.last_name-input').live('keyup', function(){
//      make_name($(this).closest("form"));
//    });
//    $('.first_name-input').live('keyup', function(){
//      make_name($(this).closest("form"));
//    });
//    $('.middle_name-input').live('keyup', function(){
//      make_name($(this).closest("form"));
//    });
//    $('.short_name-input').live('keyup', function(){
//      make_name($(this).closest("form"));
//    });
//    $('.last_name-input').live('click', function(){
//      make_name($(this).closest("form"));
//    });

// Need to have :name field enabled when form is submitted, otherwise it will not
// be sent back to be processed.
//    $('input.submit').live('click', function(){
//      var as_form = $(this).closest("form")
//      var name_field = $('.name-input',as_form)
//// trim all the parts of person and country name
//      $('input[name$="_name]"]').each(function(index){
//        var original = $(this).val()
//        var trimmed = jQuery.trim(original)
//        if (original != trimmed) {
//          $(this).val(trimmed)
//          $(this).keypress() // needed to alert ActiveScaffold or Rails of change 
//        }
//      })
//      if (name_automatic(as_form)) {  // if user has not overriden auto-name-generation
//        make_name(as_form)
//      }  
//      // unfortunately, we have to enable the input for Rails to see it
//      name_field.removeAttr("disabled")
//      name_field.keypress()
//    });
////
////  Report whether the name_override box is checked
//    function name_override(as_form) {
//      var checked = $('input[name="record[name_override]"]',as_form).is(':checked')
//      return checked
//    }
//    // This is just the opposite of name_override, for convenience
//    function name_automatic(as_form) { 
//      var checked = name_override(as_form)
//      return !checked
//      // why doesn't !name_override(as_form) work? 
//    }
//    // Compose the name from its parts unless name_override (!name_automatic) is checked
//    function make_name(as_form) {
//      if (name_automatic(as_form)) {
//        var name_field = $('input.name-input',as_form)
//        var last_name = $('.last_name-input',as_form).val()
//        var first_name = $('.first_name-input',as_form).val()
//        var initial = $('.middle_name-input',as_form).val()[0]
//        var short_name = $('.short_name-input',as_form).val()
//        var name = jQuery.trim(last_name) + ', ' + jQuery.trim(first_name) + (initial ? ' ' + initial+'.' : '');
//        if (short_name) { 
//          name += ' (' + jQuery.trim(short_name) + ')'
//        }
//        // To update the name, we must enable the input, insert the name, 
//        //   signal a keypress. Then we again disable the input again.
//        //   (When automatic name generation is in effect, the name input is
//        //   disabled since the program determines the name)
//        name_field.removeAttr("disabled")
//        name_field.val(name)
//        name_field.keypress()
//        name_field.attr("disabled","disabled")
//      }
//    } 
//  });
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
  $( "input.last_name-input" ).live("change", function() {
    set_spouse_choices($(this).closest("form"))
    });
  });
$(function() {
  $( "select.sex-input" ).live("change", function() {
    set_spouse_choices($(this).closest("form"))
    });
  });

function set_spouse_choices(as_form) {
  var select_control = $('select.spouse-input',as_form)
  var last_name = $('input.last_name-input',as_form).val()
  var sex = $('select.sex-input option:selected',as_form)
  var my_id = get_update_id(as_form)
  var my_selected = $("option.spouse-input:selected").text()
  $.getJSON("members/spouse_select.js", 
            {name: last_name, 
             sex: sex.text()[0],
             id: my_id}, 
    function(data){
    // !!** need to do something to check whether data is returned before we 
    // !!**   destroy the existing option list
//      select_control.empty()
      $("option.spouse-input:not(:selected)").remove()
      $.each(data, function(index,member){
        if (my_selected != member.name) {
          select_control.append("<option class='spouse-input' value='" + member.id + 
          "'>" + member.name + "</option>")
        }
      }) 
    });
  };

// ************************ CHARCOUNT ******************************
// *********************************************************************
// ** It might be worth putting this in a separate file since it's not used in most pages
/*
If you want to use this script, please keep the original author in this header!

Purpose:	Script for applying maxlengths to textareas and monitoring their character lengths.
Author: 	James O'Cull
Date: 		08/14/08

To use, simply apply a maxlenth value to a textarea.
If you need it to prevent typing past a certain point, add lengthcut="true"

Example:
<textarea maxlength="1000" lengthcut="true"></textarea>

If you add a new text area with javascript, simply call parseCharCounts() again find the new textarea(s) and label them!
*/
var LabelCounter = 0;

function parseCharCounts()
{
	//Get Everything...
	var elements = document.getElementsByTagName('textarea');
	var element = null;
	var maxlength = 9;
	var newlabel = null;
	
	for(var i=0; i < elements.length; i++)
	{
		element = elements[i];
		
		if(element.getAttribute('maxlength') != null && element.getAttribute('limiterid') == null)
		{
			maxlength = element.getAttribute('maxlength');
			
			//Create new label
			newlabel = document.createElement('label');
			newlabel.id = 'limitlbl_' + LabelCounter;
			newlabel.style.color = 'red';
			newlabel.style.display = 'block'; //Make it block so it sits nicely.
			newlabel.innerHTML = "Updating...";
			
			//Attach limiter to our textarea
			element.setAttribute('limiterid', newlabel.id);
			element.onkeyup = function(){ displayCharCounts(this); };
			
			//Append element
			element.parentNode.insertBefore(newlabel, element);
			
			//Force the update now!
			displayCharCounts(element);
		}
		
		//Push up the number
		LabelCounter++;
	}
}

/*
 * 	Character Count Plugin - jQuery plugin
 * 	Dynamic character count for text areas and input fields
 *	written by Alen Grakalic	
 *	http://cssglobe.com/post/7161/jquery-plugin-simplest-twitterlike-dynamic-character-count-for-textareas
 *
 *	Copyright (c) 2009 Alen Grakalic (http://cssglobe.com)
 *	Dual licensed under the MIT (MIT-LICENSE.txt)
 *	and GPL (GPL-LICENSE.txt) licenses.
 *
 *	Built for jQuery library
 *	http://jquery.com
 *
 */
 
(function($) {

	$.fn.charCount = function(options){
	  
		// default configuration properties
		var defaults = {	
			allowed: 140,		
			warning: 25,
			css: 'counter',
			counterElement: 'span',
			cssWarning: 'warning',
			cssExceeded: 'exceeded',
			counterText: ''
		}; 
			
		var options = $.extend(defaults, options); 
		
		function calculate(obj){
			var count = $(obj).val().length;
			var available = options.allowed - count;
			if(available <= options.warning && available >= 0){
				$(obj).next().addClass(options.cssWarning);
			} else {
				$(obj).next().removeClass(options.cssWarning);
			}
			if(available < 0){
				$(obj).next().addClass(options.cssExceeded);
			} else {
				$(obj).next().removeClass(options.cssExceeded);
			}
			$(obj).next().html(options.counterText + available);
		};
				
		this.each(function() {  			
			$(this).after('<'+ options.counterElement +' class="' + options.css + '">'+ options.counterText +'</'+ options.counterElement +'>');
			calculate(this);
			$(this).keyup(function(){calculate(this)});
			$(this).change(function(){calculate(this)});
		});
	  
	};

})(jQuery);
