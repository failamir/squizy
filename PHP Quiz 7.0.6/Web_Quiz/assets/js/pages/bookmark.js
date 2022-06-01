"use strict"

$(document).ready(function () {
    view_bookmark();
});

function view_bookmark() {
    var bookmarked = get_bookmark(user_id);

    if (bookmarked['error'] == "false") {
        var bookmark = bookmarked['data'];
        var html = '';
        $.each(bookmark, function (key, val) {
            var ans = 'None';
            if (val['answer'] == 'a' || val['answer'] == 'A') {
                ans = val['optiona'];
            } else if (val['answer'] == 'b' || val['answer'] == 'B') {
                ans = val['optionb'];
            } else if (val['answer'] == 'c' || val['answer'] == 'C') {
                ans = val['optionc'];
            } else if (val['answer'] == 'd' || val['answer'] == 'D') {
                ans = val['optiond'];
            } else if (val['answer'] == 'e' || val['answer'] == 'E') {
                ans = val['optione'];
            }
            html += '<li class="list-group-item" data-remove="' + key + '" data-id="' + val['id'] + '">';
            html += '<div class="row">';
            html += '<div class="col-sm-9">';
            html += '<span>' + (key + 1) + '. ' + val['question'] + '</span><br>';
            html += '<strong>Answer: </strong>' + ans + '';
            html += '</div>';
            html += '<div class="col-sm-2">';
            if (val['image'] != '') {
                html += '<img width="' + QUIZ_IMG_WIDTH + '" src="' + val['image'] + '">';
            }
            html += '</div>';
            html += '<div class="col-sm-1">';
            html += '<button class="delete_boockmark_question float-right pt-2" data-id="' + val['id'] + '" data-key="' + key + '">';
            html += '<img width="30" src="assets/images/delete-bookmark-btn.png">';
            html += '</button>';
            html += '</div>';
            html += '</div>';
            html += '</li>';
        });
        $("#hide_play_bookmark_btn").show();
        $("#bookmarked_questions_list").html(html);
    } else {
        $("#bookmarked_questions_list").html('<li class="list-group-item">No bookmarked questions found.</li>');
        $("#hide_play_bookmark_btn").hide();
    }
}
$(document).on('click', '.delete_boockmark_question', function () {
    var delete_boockmark_question_key = $(this).data('key');
    var delete_boockmark_question_id = $(this).data('id');
    $("[data-remove='" + delete_boockmark_question_key + "']").slideUp("normal", function () {
        $(this).remove();
    });
    if ($('#bookmark_length ul li').length == 1) {
        $("#bookmarked_questions_list").html('<li class="list-group-item">No bookmarked questions found.</li>');
        $("#hide_play_bookmark_btn").hide();
    }
    var status = '0';
    set_bookmark(user_id, delete_boockmark_question_id, status);
    $(".toast").toast('show');

    view_bookmark();
});
