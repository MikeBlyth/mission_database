jQuery(function($){
  if (typeof($.datepicker) === 'object') {
    $.datepicker.regional['en'] = {"closeText":"Close","prevText":"Previous","nextText":"Next","currentText":"Today","monthNames":["January","February","March","April","May","June","July","August","September","October","November","December"],"monthNamesShort":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"dayNames":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],"dayNamesShort":["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],"dayNamesMin":["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],"changeYear":true,"changeMonth":true,"weekHeader":"Wk","firstDay":0,"isRTL":false,"showMonthAfterYear":false,"dateFormat":"%-1e M y"};
    $.datepicker.setDefaults($.datepicker.regional['en']);
  }
  if (typeof($.timepicker) === 'object') {
    $.timepicker.regional['en'] = {"ampm":false,"hourText":"Hour","minuteText":"Minute","secondText":"Seconds"};
    $.timepicker.setDefaults($.timepicker.regional['en']);
  }
});
$(document).ready(function() {
  $('form.as_form, form.inplace_form').live('as:form_loaded', function(event) {
    var as_form = $(this).closest("form");
    as_form.find('input.datetime_picker').each(function(index) {
      var date_picker = $(this);
      if (typeof(date_picker.datetimepicker) == 'function') {
        date_picker.datetimepicker();
      }
    });

    as_form.find('input.date_picker').each(function(index) {
      var date_picker = $(this);
      if (typeof(date_picker.datepicker) == 'function') {
        date_picker.datepicker();
      }
    });
    return true;
  });
  $('form.as_form, form.inplace_form').live('as:form_unloaded', function(event) {
    var as_form = $(this).closest("form");
    as_form.find('input.datetime_picker').each(function(index) {
      var date_picker = $(this);
      if (typeof(date_picker.datetimepicker) == 'function') {
        date_picker.datetimepicker('destroy');
      }
    });

    as_form.find('input.date_picker').each(function(index) {
      var date_picker = $(this);
      if (typeof(date_picker.datepicker) == 'function') {
        date_picker.datepicker('destroy');
      }
    });
    return true;
  });
});