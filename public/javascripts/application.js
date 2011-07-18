// regexp for verification link url format
var URL_REGEXP = /[A-Za-z0-9\.-]{2,}\.[A-Za-z]{2}/;
// noscript stuff
document.write('<style>.noscript { display:none }</style>');

jQuery(function($) {
    matroska('all_comments');
    observe_element('paginator');
//    jQuery('#new_link_form').css('display', 'none');
});

/**
 * Show element using jQuery slide animation
 * @param element id of needed element
 */
function show_element(element) {
    jQuery(document).ready(function() {
        jQuery("#" + element).slideToggle("slow");
        // clean new link form
        jQuery("#new_link_title").val('');
        jQuery("#new_link_url").val('');
    });
}

/**
 * Show element using jQuery slide animation
 * @param element id of needed element
 */
function hide_element(element) {
    jQuery(document).ready(function() {
        jQuery("#" + element).slideUp("slow");
    });
}

/**
 *  Show votes info.
 *  Is called after voting
 * @param link_id link id to find needed divs
 * @param votes votes count
 */
function vote(link_id, votes) {
    var vc = ".VotesCountId" + link_id;
    var va = ".VoteArrowsId" + link_id;

    // show votes count
    jQuery.each(jQuery(vc), function(index, value) {
        value.innerHTML = votes;
    });

    // hide arrows
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

/**
 * Add comment.
 * Add new comment into comment's list
 * @param id comment id
 * @param comment_partial html for comment item
 */
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
        // hide no comments message
        jQuery('#no_comments_message').fadeOut('slow');
        if (jQuery('.comment_body').length >= 6) {
            jQuery('.invisible').remove();
            jQuery('div.comment_col:last').addClass('invisible').fadeOut();
        }
        jQuery("#" + id).add('.head').fadeIn('slow');
        // update table view
        matroska('all_comments');
    }
    // create new comment form
    jQuery('#comment_body').val('');
}

/**
 *  New link form verification.
 *  Used in onSubmit event to check data before sending to server.
 */
function verify_new_link() {
    var errors = 0;

    // check value presence
    if ($("new_link_title").value == "") {
        $("new_link_title_label").style.color = "#ff0000";
        errors++;
    }
    else
        $("new_link_title_label").style.color = "#000000";

    // check URL format using REGEXP
    if (!URL_REGEXP.test($("new_link_url").value)) {
        $("new_link_url_label").style.color = "#ff0000";
        errors++;
    }
    else
        $("new_link_url_label").style.color = "#000000";

    // return false to stop sending form
    return (errors < 0);
}

function redirect_to(url) {
    window.location = url;
}

/**
 * Show info,error messages using Ajax.
 * @param msg message to display, can contain html formatting
 */
function system_message(msg){
    // output msg to all 'system_message' divs
    jQuery.each(jQuery('#system_message'), function(index, value) {
        value.innerHTML = msg;
    });
}