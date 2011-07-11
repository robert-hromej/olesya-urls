// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function show_element(element) {
    jQuery(document).ready(function() {
        jQuery("#" + element).slideToggle("slow");
    });
}