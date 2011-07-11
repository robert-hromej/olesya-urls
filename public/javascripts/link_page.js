/**
 * Created by .
 * User: edgar
 * Date: 7/7/11
 * Time: 1:55 PM
 * To change this template use File | Settings | File Templates.
 */
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
        var url = jQuery('a.previous_page').attr('href');
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
            if (jQuery('.comment_body').length >= 7) {
                jQuery('.invisible').remove();
                jQuery('tr.comment_col:last').addClass('invisible').fadeOut();
            }
        }
        jQuery("#" + id).fadeIn('slow');
        matroska('all_comments');
    }
    jQuery('#comment_body').val('');
}
