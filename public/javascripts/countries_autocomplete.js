// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
<script type="text/javascript">  
 $(function() {
    $( ".country_name-input" ).live("click", function(){
      $(this).autocomplete({
        source: "countries_autocomplete/index.js"
        });
    });
  });
</script>

