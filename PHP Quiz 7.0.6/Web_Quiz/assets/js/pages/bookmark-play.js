"use strict"

// Warning before leaving the page (back button, or outgoinglink)
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
window.count = 0;
window.attempt = 0;

var is_option_e_mode_enabled = (OPTION_E_MODE == '1') ? true : false;
var is_answer_mode = (ANSWER_MODE == '1') ? true : false;

$(document).ready(function () {
    setTimeout(function () {
        $("#preloader").css('display', 'none');
    }, 2000);
    var result = get_bookmark(user_id);
    if (result['error'] == TRUE) {
        swal({
            title: result['message'],
            icon: "warning",
            type: "warning",
            closeOnClickOutside: false,
        }).then(function () {
            window.exit = true;
            $.redirect('bookmark.php');
        });
    } else {
        window.res = result['data'];
        window.questions_answered = result.length;
        loadQuestions(window.res);
        startTimer(0);
    }
});

$("#bookmark_show_question").click(function () {
    $("input[name='sample-radio'][value=" + res[window.count]['answer'].toLowerCase() + "]").parent().addClass('bg-success-green');
});

$("input[type='radio']").click(function () {
    var radioValue = $("input[name='sample-radio']:checked").val();
    window.attempt = window.attempt + 1;
    window.current_question = window.current_question + 1;

    setTimeout(function () {
        $("input[name='sample-radio']").prop("disabled", false).parent().removeClass('r_on').removeAttr("style");
        $("input[name='sample-radio'][value=" + radioValue + "]").parent().removeClass('bg-danger-red');

        $("input[name='sample-radio'][value=" + res[window.count]['answer'].toLowerCase() + "]").parent().removeClass('bg-success-green');
        window.count += 1;

        loadQuestions(window.res);
        clearInterval(timerInterval);
        startTimer(0);
        setTimeout(loop, (QUESTION_TIME * 1000));
    }, 1000);

    $("input[name='sample-radio']").prop("disabled", true);
    if (radioValue == res[window.count]['answer'].toLowerCase()) {
        $("input[name='sample-radio'][value=" + radioValue + "]").parent().addClass('bg-success-green');
        window.correct = window.correct + 1;

        $('#green_count').html(window.correct);

        var correct_percentage = correct * 100 / window.total_question_percentage;

        $('.progressBar_fill_green').animate({
            height: correct_percentage + "%"
        });
    } else {
        $("input[name='sample-radio'][value=" + radioValue + "]").parent().addClass('bg-danger-red');
        window.incorrect = window.incorrect + 1;

        $('#red_count').html(window.incorrect);
        var incorrect_percentage = window.incorrect * 100 / window.total_question_percentage;

        $('.progressBar_fill_red').animate({
            height: incorrect_percentage + "%"
        });
        $("input[name='sample-radio'][value=" + res[window.count]['answer'].toLowerCase() + "]").parent().addClass('bg-success-green');
    }

});

function loop(cb) {
    if (cb == 0) {
        if (window.attempt < (res.length - 1)) {
            window.current_question = window.current_question + 1;
            $('#attempted_question').html(window.current_question);
        }
        $("input[name='sample-radio']").prop("disabled", false).parent().removeClass('r_on').removeAttr("style");
        window.count += 1;
        window.attempt = window.attempt + 1;

        window.incorrect = window.incorrect + 1;

        $('#red_count').html(window.incorrect);
        var incorrect_percentage = window.incorrect * 100 / window.total_question_percentage;

        $('.progressBar_fill_red').animate({
            height: incorrect_percentage + "%"
        });

        loadQuestions(window.res);
        clearInterval(timerInterval);
        startTimer(0);
        setTimeout(loop, (QUESTION_TIME * 1000));
    }
}
setTimeout(loop, (QUESTION_TIME * 1000));


function loadQuestions(res) {

    if (window.attempt >= res.length) {
        window.exit = true;
        clearInterval(timerInterval);
        swal({
            closeOnClickOutside: false,
            title: "Want to play again?",
            text: "Totol Questions: " + window.total_question_percentage + " Correct Answer: " + window.correct + " Incorrect Answer: " + window.incorrect,
            icon: "success",
            type: "success",
            buttons: ["NO", "YES"],
            cancel: {value: false},
            confirm: {value: true}
        }).then(function (value) {
            if (value) {
                window.location.reload();
            } else {
                window.location = 'index.php';
            }
        });
    } else {
        $(".progress").empty();

        $("#questionsimg img:last-child").remove();

        document.getElementById("app").innerHTML = `
        <div class="base-timer">
          <svg class="base-timer__svg" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
            <g class="base-timer__circle">
              <circle class="base-timer__path-elapsed" cx="50" cy="50" r="45"></circle>
              <path
                id="base-timer-path-remaining"
                stroke-dasharray="283"
                class="base-timer__path-remaining ${remainingPathColor}"
                d=" M 50, 50 m -45, 0 a 45,45 0 1,0 90,0 a 45,45 0 1,0 -90,0 "></path>
            </g>
          </svg>
          <span id="base-timer-label" class="base-timer__label">${formatTime(timeLeft)}</span>
        </div> `;

        window.total_question_percentage = res.length;
        $('#attempted_question').html(window.current_question);
        $('#total_question').html(res.length);
        $('#my-fonts-questions').html(res[window.count]['question']);
        $('#option_a').html(res[window.count]['optiona']);
        $('#option_b').html(res[window.count]['optionb']);

        if (res[window.count]['question_type'] == "1") {
            $('#hide-option-tf').show();
            $('#lifeline').show();
            $('#option_c').html(res[window.count]['optionc']);
            $('#option_d').html(res[window.count]['optiond']);
            if (is_option_e_mode_enabled == true) {
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
            $('#lifeline').hide();
            $('#option_e').html('');
            $('#hide-option-e').hide();
        }

        if (res[window.count]['image'] != '') {
            var html = "<img class='my-questions-img' src='" + res[window.count]['image'] + "' width='" + QUIZ_IMG_WIDTH + "'>";
            $('#questionsimg').html(html);
        }
    }
}


// timer code
const FULL_DASH_ARRAY = 283; //283
const ALERT_THRESHOLD = 10;

const COLOR_CODES = {
    info: {
        color: "red"
    },
    alert: {
        color: "red",
        threshold: ALERT_THRESHOLD
    }
};

const TIME_LIMIT = QUESTION_TIME;
let timeLeft = TIME_LIMIT;
let timerInterval = null;
let remainingPathColor = COLOR_CODES.info.color;

function startTimer(timePassed1) {
    let timePassed = (timePassed1 == 0) ? 0 : (TIME_LIMIT - timePassed1);
    timerInterval = setInterval(() => {
        timePassed = timePassed += 1;
        timeLeft = TIME_LIMIT - timePassed;
        document.getElementById("base-timer-label").innerHTML = formatTime(timeLeft);
        setCircleDasharray();
        setRemainingPathColor(timeLeft);

        if (timeLeft === 0) {
            loop(timeLeft);
        }
    }, 1000);
}

function formatTime(time) {
    let seconds = time % 60;
    if (seconds < 10) {
        seconds = `0${seconds}`;
    }
    return `${seconds}`;
}

function setRemainingPathColor(timeLeft) {
    const {alert, info} = COLOR_CODES;
    if (timeLeft <= alert.threshold) {
        document.getElementById("base-timer-path-remaining").classList.add(alert.color);
    }
}

function calculateTimeFraction() {
    const rawTimeFraction = timeLeft / TIME_LIMIT;
    return rawTimeFraction - (1 / TIME_LIMIT) * (1 - rawTimeFraction);
}

function setCircleDasharray() {
    const circleDasharray = `${(
            calculateTimeFraction() * FULL_DASH_ARRAY
            ).toFixed(0)} 283`;
    document.getElementById("base-timer-path-remaining").setAttribute("stroke-dasharray", circleDasharray);
}