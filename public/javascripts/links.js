function verify_new_link() {
    var errors = 0;

    if ($("new_link_title").value == "") {
        $("new_link_title_label").style.color = "#ff0000";
        errors++;
    }
    else
        $("new_link_title_label").style.color = "#000000";

    var url_regexp = /[A-Za-z0-9\.-]{3,}\.[A-Za-z]{2}/;
    if (!url_regexp.test($("new_link_url").value)) {
        $("new_link_url_label").style.color = "#ff0000";
        errors++;
    }
    else
        $("new_link_url_label").style.color = "#000000";

    return (errors > 0) ? false : true;
}