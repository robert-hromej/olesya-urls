var URL_REGEXP = /[A-Za-z0-9\.-]{2,}\.[A-Za-z]{2}/;

jQuery(function($) {
    matroska('all_comments');
    observe_element('paginator');
    jQuery('#new_link_form').css('display', 'none');
});

function show_element(element) {
    jQuery(document).ready(function() {
        jQuery("#" + element).slideToggle("slow");
        jQuery("#new_link_title").val('');
        jQuery("#new_link_url").val('');
    });
}

function hide_element(element) {
    jQuery(document).ready(function() {
        jQuery("#" + element).slideUp("slow");
    });
}

function vote(link_id, votes) {
    var vc = ".VotesCountId" + link_id;
    var va = ".VoteArrowsId" + link_id;

    jQuery.each(jQuery(vc), function(index, value) {
        value.innerHTML = votes;
    });

    jQuery.each(jQuery(va), function(index, value) {
        value.innerHTML = "";
    });
}

function observe_element(element) {
    var container = $(element);
    if (container) {
        container.observe('click', function(e) {
            var el = e.element();

            jQuery(".next_page").css({ "display": "block", "float":"right" });
            jQuery(".previous_page").css({ "display": "block", "float":"left" });

            if (el.match('.pagination a')) {
                jQuery('#ajax_comments').html('');
                jQuery.ajax({
                    dataType:'script',
                    url:el.href,
                    type:'get'
                });
                e.stop();
            }

        });
    }
}

function matroska(id) {
    jQuery('#' + id + ' tr.even_tr').removeClass('even_tr');
    jQuery('#' + id + ' tr.odd_tr').removeClass('odd_tr');
    jQuery('#' + id + ' tr:even').not('.head').addClass('even_tr');
    jQuery('#' + id + ' tr:odd').not('.head').addClass('odd_tr');
}

function add_comment(id, comment_partial) {
    if (jQuery('a.previous_page').length != 0 ||
        (jQuery('.comment_body').length >= 5 && jQuery('a.next_page').length == 0)) {

        jQuery('#ajax_comments').html('');
        var url = jQuery('a[rel=start]').attr('href');
        jQuery.ajax({
            dataType:'script',
            url:url,
            type:'get'
        });
    } else {
        var htm = comment_partial;
        jQuery(htm).css('display','none').prependTo('#ajax_comments').fadeIn('slow');
        jQuery('#no_comments_message').fadeOut('slow');
        if (jQuery('.comment_body').length >= 6) {
            jQuery('.invisible').remove();
            jQuery('div.comment_col:last').addClass('invisible').fadeOut();
        }
        jQuery("#" + id).add('.head').fadeIn('slow');
        matroska('all_comments');
    }
    jQuery('#comment_body').val('');
}

function verify_new_link() {
    var errors = 0;

    if ($("new_link_title").value == "") {
        $("new_link_title_label").style.color = "#ff0000";
        errors++;
    }
    else
        $("new_link_title_label").style.color = "#000000";

    if (!URL_REGEXP.test($("new_link_url").value)) {
        $("new_link_url_label").style.color = "#ff0000";
        errors++;
    }
    else
        $("new_link_url_label").style.color = "#000000";

    return (errors < 0);
}

function redirect_to(url) {
    window.location = url;
}

function system_message(msg){
    jQuery.each(jQuery('#system_message'), function(index, value) {
        value.innerHTML = msg;
    });

//    jQuery('#system_message').val(msg);
}