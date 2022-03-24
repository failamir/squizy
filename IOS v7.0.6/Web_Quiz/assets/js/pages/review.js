"use strict"


window.onbeforeunload = function () {
    if (window.exit == false) {
        return "Do you really want to leave our brilliant application?";
    }
};

var value = 0;
window.exit = false;
window.correct = 0;
window.incorrect = 0;
window.current_question = 1;
window.boockmark_question = false;
window.count = 0;
window.attempt = 0;
window.uans = '';

var is_option_e_mode_enabled = (OPTION_E_MODE == '1') ? true : false;
var is_answer_mode = (ANSWER_MODE == '1') ? true : false;

$(document).ready(function () {
    window.res = JSON.parse(localStorage.getItem("review"));
    if (!window.res) {
        $.redirect('index.php');
    }
    window.que_length = window.res.length;
    window.current_question = 1;
    loadQuestions(window.res);
});

$(document).on("click", ".set > a", function () {
    if ($(this).hasClass("active")) {
        $(this).removeClass("active");
        $(this).siblings(".content").slideUp(200);
        $(".set > a i").removeClass("fa-minus").addClass("fa-plus");
    } else {
        $(".set > a i").removeClass("fa-minus").addClass("fa-plus");
        $(this).find("i").removeClass("fa-plus").addClass("fa-minus");
        $(".set > a").removeClass("active");
        $(this).addClass("active");
        $(".content").slideUp(200);
        $(this).siblings(".content").slideDown(200);
    }
});

$(document).on('click', '#boockmark_question', function () {
    var question_id = window.res[window.count]['id'];
    if ($(this).hasClass('active')) {
        $('#boockmark_question').removeClass('active');
        var status = '0';
        set_bookmark(user_id, question_id, status);
    } else {
        $('#boockmark_question').addClass('active');
        var status = '1';
        set_bookmark(user_id, question_id, status);
    }
});

$(document).on('click', '#ar-right', function () {
    if (window.current_question >= window.que_length) {
        $(this).onclick = false;
        $('#ar-right').html('<div class="text-center mt-1" id="homeData">Home</div>');
    } else {
        if (window.current_question == (window.que_length - 1)) {
            $('#ar-right').html('<div class="text-center mt-1" id="homeData">Home</div>');
        }
        window.attempt = window.attempt + 1;
        window.current_question = window.current_question + 1;
        $('#attempted_question').html(window.current_question);
        window.count += 1;
        loadQuestions(window.res);
    }
});

$(document).on('click', '#ar-left', function () {
    if (window.current_question == 1) {
        $(this).onclick = false;
    } else {
        $('#ar-right').html('<em class="fa fa-arrow-circle-right fa-2x"></em>');
        window.attempt = window.attempt - 1;
        window.current_question = window.current_question - 1;
        $('#attempted_question').html(window.current_question);
        window.count -= 1;
        loadQuestions(window.res);
    }
});

$(document).on('click', '#homeData', function () {
    window.exit = true;
    $.redirect('index.php');
});

function loadQuestions(res) {

    if (window.attempt >= window.que_length) {
        $('#ar-right').onclick = false;
    } else {
        if (window.count == 0) {
            $('#ar-left').html('');
        } else {
            $('#ar-left').html('<em class="fa fa-arrow-circle-left fa-2x"></em>');
        }
        $("input[name='sample-radio']").parent().removeClass('bg-success-green');
        $("input[name='sample-radio']").parent().removeClass('bg-danger-red');
        var attempted = res[window.count]['attempted'];
        var radioValue = res[window.count]['userans'];
        if (attempted != 0) {
            $('#attempted').html('Attempted');

            if (radioValue == res[window.count]['answer'].toLowerCase()) {
                $("input[name='sample-radio'][value=" + radioValue + "]").parent().addClass('bg-success-green');

                $('#green_count').html(window.correct);
                $('#points').html(window.correct);

                var correct_percentage = window.correct * 100 / window.total_question_percentage;

            }
            if (radioValue != res[window.count]['answer'].toLowerCase()) {
                $("input[name='sample-radio'][value=" + radioValue + "]").parent().addClass('bg-danger-red');

                $('#red_count').html(window.incorrect);
                var incorrect_percentage = window.incorrect * 100 / window.total_question_percentage;

                $("input[name='sample-radio'][value=" + res[window.count]['answer'].toLowerCase() + "]").parent().addClass('bg-success-green');
            }
        } else {
            $("input[name='sample-radio'][value=" + res[window.count]['answer'].toLowerCase() + "]").parent().addClass('bg-success-green');

            $('#green_count').html(window.correct);
            $('#points').html(window.correct);

            var correct_percentage = window.correct * 100 / window.total_question_percentage;

            $('#attempted').html('Un-Attempted');
        }
        $(".progress").empty();

        $("#questionsimg img:last-child").remove();
        $('#boockmark_question').removeClass('active');
        var bookmarked = get_bookmark(user_id);
        $.each(bookmarked['data'], function (key, val) {
            if (parseInt(val.id) == parseInt(res[window.count]['id'])) {
                $('#boockmark_question').addClass('active');
                return;
            }
        });

        $('#attempted_question').html(window.current_question);
        $('#total_question').html(window.que_length);
        $('#my-fonts-questions').html(res[window.count]['question']);
        $('#re_que').html(res[window.count]['question']);
        $('#que_id').val(res[window.count]['id']);
        $('#option_a').html(res[window.count]['optiona']);
        $('#option_b').html(res[window.count]['optionb']);
        if (res[window.count]['note'] != '') {
            $('#ex-note').show();
            $('#exnote').html(res[window.count]['note']);
        } else {
            $('#ex-note').hide();
        }

        if (res[window.count]['question_type'] == "1") {
            $('#hide-option-tf').show();
            $('#option_c').html(res[window.count]['optionc']);
            $('#option_d').html(res[window.count]['optiond']);
            if (is_option_e_mode_enabled) {
                if (res[window.count]['optione'] != '' && res[window.count]['optione'] != null) {
                    $('#option_e').html(res[window.count]['optione']);
                    $('#hide-option-e').show();
                } else {
                    $('#option_e').html('');
                    $('#hide-option-e').hide();
                }
            } else {
                $('#option_e').html('');
                $('#hide-option-e').hide();
            }
        } else if (res[window.count]['question_type'] == "2") {
            $('#option_c').html('');
            $('#option_d').html('');
            $('#hide-option-tf').hide();
            $('#option_e').html('');
            $('#hide-option-e').hide();
        }

        if (res[window.count]['image'] != '') {
            var html = "<img class='my-questions-img pt-2' src='" + res[window.count]['image'] + "' width='" + QUIZ_IMG_WIDTH + "'>";
            $('#questionsimg').html(html);
        }
    }
}

function set_report() {
    var que_id = $('#que_id').val();
    var report = $('#report').val();
    if (report == '') {
        $('#messageLabel').text("Please Enter Message");
        setTimeout(function () {
            $('#messageLabel').html('');
        }, 3000);
    } else {
        var data = {'report_question': '1', 'question_id': que_id, 'message': report, 'user_id': user_id};
        var result = get_apis_data(data);
        console.log(result);
        if (result['error'] == false) {
            $('#resultLabel').text(result['message']);
            setTimeout(function () {
                $('#report').val('');
                $('#myReportModal').modal('hide');
                $('#resultLabel').html('');
            }, 3000);
        }
    }

}