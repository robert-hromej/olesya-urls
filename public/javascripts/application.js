// regexp for verification link url format
var URL_REGEXP = /[A-Za-z0-9\.-]{2,}\.[A-Za-z]{2}/;

// noscript stuff
document.write('<style>.noscript { display:none }</style>');

jQuery(function($) {
    observe_element('ajax_paginator');
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
    // show votes count
    jQuery(".VotesCountId" + link_id).html(votes);
    // hide arrows
    jQuery(".VoteArrowsId" + link_id).html("");
}

function observe_element(element) {
    jQuery('.' + element + ' a').bind('click', function () {
        jQuery.ajax({
            dataType:'script',
            url:this.href,
            type:'post',
            success: function() {
                observe_element(element);
            }
        });
        return false;
    });
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
        var url = window.location.pathname;
        jQuery.ajax({
            dataType:'script',
            url:url,
            type:'post'
        });
    } else {
        jQuery(comment_partial).css('display', 'none').prependTo('#ajax_comments').fadeIn('slow');
        // hide no comments message
        jQuery('#no_comments_message').fadeOut('slow');
        if (jQuery('.comment_body').length >= 6) {
            jQuery('.invisible').remove();
            jQuery('div.comment_col:last').addClass('invisible').fadeOut();
        }
        jQuery("#" + id).add('.head').fadeIn('slow');
    }
    // create new comment form
    jQuery('#comment_body').val('');
}

/**
 *  New link form verification.
 *  Used in onSubmit event to check data before sending to server.
 */
function verify_new_link() {
    jQuery("#new_link_title_label").add("#new_link_url_label").removeClass("error_field");

    // check value presence
    if (jQuery("#new_link_title").val() == "")
        jQuery("#new_link_title_label").addClass("error_field");

    // check URL format using REGEXP
    if (!URL_REGEXP.test(jQuery("#new_link_url").val()))
        jQuery("#new_link_url_label").addClass("error_field");
}

function redirect_to(url) {
    window.location = url;
}

/**
 * Show info,error messages using Ajax.
 * @param msg message to display, can contain html formatting
 */
function system_message(msg) {
    jQuery('#system_message').html(msg);
}

function replace_html(id, html) {
    jQuery("#" + id).html(html);
//    jQuery("." + id).html(html);
}
