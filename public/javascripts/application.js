// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
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


jQuery(function($) {
    matroska('all_comments');
    observe_element('paginator');
    jQuery('#new_link_form').css('display','none');
});

function vote(kind, link_id, el) {
    jQuery.ajax({
        dataType: 'script',
        url: "/link/vote",
        data: {
            kind: kind,
            link_id: link_id
        },
        type: 'post',
        success: function() {
            el.parentElement.innerHTML = "";
        }
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
//                var small_spinner = jQuery('<img>').attr({
//                    "id":"small-spinner",
//                    "src":'/images/ajax-loader2.gif',
//                    "alt":''
//                });

//                if (jQuery("#small-spinner").length != 0) jQuery("#small-spinner").remove();
//                jQuery(el).parent('.pagination').append(small_spinner);
                jQuery('#ajax_comments').html('');
                jQuery.ajax({
                    dataType:'script',
                    url:el.href,
                    type:'post'
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
function add_comment(id, body, image, created, name) {
    if (jQuery('a.previous_page').length != 0 || (jQuery('.comment_body').length >= 6 && jQuery('a.next_page').length == 0)) {
        jQuery('#ajax_comments').html('');
        var url = jQuery('a[rel=start]').attr('href');
        jQuery.ajax({
            dataType:'script',
            url:url,
            type:'post'
        });
    } else {
        var htm = '<tr class="comment_col" style="display:none;" id="' + id + '">';
        htm += '<td class="avatar" ><img src="' + image + '"/></td>';
        htm += '<td class="username">' + name + '</td>';
        htm += '<td class="comment_body">' + body + '</td>';
        htm += '<td class="comment_date">' + created + '</td>';
        htm += '</tr>';
        if (body != '') {
            jQuery(htm).prependTo('#ajax_comments');
            jQuery('#no_comments_message').fadeOut('slow');
            if (jQuery('.comment_body').length >= 7) {
                jQuery('.invisible').remove();
                jQuery('tr.comment_col:last').addClass('invisible').fadeOut();
            }
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

    var url_regexp = /[A-Za-z0-9\.-]{2,}\.[A-Za-z]{2}/;
    if (!url_regexp.test($("new_link_url").value)) {
        $("new_link_url_label").style.color = "#ff0000";
        errors++;
    }
    else
        $("new_link_url_label").style.color = "#000000";

    return (errors < 0);
}
function show_message(message,paint_url){
    $("new_link_url_label").style.color = (!paint_url) ? "#000000" :  "#ff0000";
    jQuery('#system_message').html('');
    jQuery('<span style="color: green;">'+message+'</span>').appendTo('#system_message');
}

