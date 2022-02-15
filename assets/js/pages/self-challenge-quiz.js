"use strict"
window.exit = false;

window.correct = 0;
window.incorrect = 0;
window.current_question = 1;
window.boockmark_question = false;
window.count = 0;
window.life_line_reset = 0;
window.life_line_audience_poll = 0;
window.life_line_fifty = 0;
window.life_line_skip = 0;
window.attempt = 0;
window.uans = '';

window.onbeforeunload = function () {
    if (window.exit == false) {
        return "Do you really want to leave our brilliant application?";
    }
};

var is_option_e_mode_enabled = (OPTION_E_MODE == '1') ? true : false;
var is_answer_mode = (ANSWER_MODE == '1') ? true : false;

var QUE = -1;
//get bookmarked
var bookmarked = get_bookmark(user_id);

$(document).ready(function () {
    setTimeout(function () {
        $("#preloader").css('display', 'none');
    }, 2000);

    var data = {'get_questions_for_self_challenge': '1', 'limit': window.limit};
    if (window.sub_id != '0') {
        data['subcategory'] = window.sub_id;
    } else {
        data['category'] = window.category_id;
    }
    var result = get_apis_data(data);
    window.res = result['data'];
    localStorage.removeItem("review");

    var obj = {};
    obj["userans"] = '';
    obj["attempted"] = 0;
    window.localStorageData = JSON.parse(localStorage.getItem("review"));

    if (window.localStorageData == null) {
        $.each(result['data'], function (key, val) {
            if (key == 0) {
                window.localStorageData = [Object.assign(result['data'][key], obj)];
            } else {
                window.localStorageData.push(Object.assign(res[window.count], obj));
            }
            localStorage.setItem("review", JSON.stringify(window.localStorageData));
        });
    }
    startTimer(0);
    loadQuestions(window.res);
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

    $("input[type='radio']").click(function () {
        $("input[name='sample-radio']").parent().removeClass('bg-success-green');
        var radioValue = $("input[name='sample-radio']:checked").val();
        window.uans = radioValue;

        $("input[name='sample-radio'][value=" + radioValue + "]").parent().addClass('bg-success-green');
        window.bookmarked_list = JSON.parse(localStorage.getItem("review"));
        var obj = {};
        obj["userans"] = window.uans;
        obj["attempted"] = 1;

        Object.assign(res[window.count], obj);
        if (localStorage.getItem("review") != '') {

        }
        window.localStorageData = JSON.parse(localStorage.getItem("review"));
        if (window.localStorageData != null && window.localStorageData.length > 0 && window.localStorageData != '') {
            if (window.localStorageData[window.count] != null) {
                $.each(window.localStorageData, function (key, val) {
                    if (key == window.count) {
                        window.localStorageData[key] = Object.assign(res[window.count], obj);
                        localStorage.setItem("review", JSON.stringify(window.localStorageData));
                    }
                });
            } else {
                window.localStorageData.push(Object.assign(res[window.count], obj));
                localStorage.setItem("review", JSON.stringify(window.localStorageData));
            }
        } else {
            window.localStorageData = [Object.assign(res[window.count], obj)];
            localStorage.setItem("review", JSON.stringify(window.localStorageData));
        }

    });
});

$(document).on('click', '#ar-right', function () {
    if (QUE < window.count) {
        QUE = window.count;

        var obj = {};
        if (window.uans != "") {
            obj["userans"] = window.uans;
            obj["attempted"] = 1;
        } else {
            obj["userans"] = '';
            obj["attempted"] = 0;
        }

        Object.assign(res[window.count], obj);
        window.localStorageData = JSON.parse(localStorage.getItem("review"));
        if (window.localStorageData != null && window.localStorageData.length > 0 && window.localStorageData != '') {
            if (window.localStorageData[window.count] != null) {
                $.each(window.localStorageData, function (key, val) {
                    if (key == window.count) {
                        window.localStorageData[key] = Object.assign(res[window.count], obj);
                        localStorage.setItem("review", JSON.stringify(window.localStorageData));
                    }
                });
            } else {
                window.localStorageData.push(Object.assign(res[window.count], obj));
                localStorage.setItem("review", JSON.stringify(window.localStorageData));
            }
        } else {
            window.localStorageData = [Object.assign(res[window.count], obj)];
            localStorage.setItem("review", JSON.stringify(window.localStorageData));
        }

        if ($("input[name='sample-radio']:checked").val() == res[window.count]['answer'].toLowerCase()) {
            window.correct = window.correct + 1;
            var correct_percentage = window.correct * 100 / window.total_question_percentage;
        } else {
            window.incorrect = window.incorrect + 1;
            var incorrect_percentage = window.incorrect * 100 / window.total_question_percentage;
        }
    }

    if (window.current_question >= window.limit) {
        $('#ar-right').html('<div class="text-center mt-1" id="resultData">Submit</div>');
    } else {
        window.attempt = window.attempt + 1;
        window.current_question = window.current_question + 1;
        $('#attempted_question').html(window.current_question);
        window.count += 1;
        window.uans = '';
        loadQuestions(window.res);

        window.bookmarked_list = JSON.parse(localStorage.getItem("review"));

        $.each(window.bookmarked_list, function (key, val) {
            if (key == window.count) {
                if (val['userans'] != '') {
                    $("input[name='sample-radio']").parent().removeClass('bg-success-green');
                    $("input[name='sample-radio'][value=" + val['userans'] + "]").parent().addClass('bg-success-green');
                }
            }
        });
    }
});

$(document).on('click', '#ar-left', function () {
    if (window.current_question == 1) {
        $(this).onclick = false;
    } else {
        $('#ar-right').children().css('display', 'block');
        $('#ar-right').html('<em class="fa fa-arrow-circle-right fa-2x"></em>');
        window.attempt = window.attempt - 1;
        window.current_question = window.current_question - 1;
        $('#attempted_question').html(window.current_question);
        window.count -= 1;
        loadQuestions(window.res);
    }
    window.bookmarked_list = JSON.parse(localStorage.getItem("review"));

    $.each(window.bookmarked_list, function (key, val) {
        if (key == window.count) {
            if (val['userans'] != '') {
                $("input[name='sample-radio']").parent().removeClass('bg-success-green');
                $("input[name='sample-radio'][value=" + val['userans'] + "]").parent().addClass('bg-success-green');
            }
        }
    });
});

$(document).on('click', '#resultData', function () {
    var TIME_TAKE = ((window.time * 60) - timeLeft);
    swal({
        title: "Self Challenge",
        text: "Are you sure? You want to submit this test?",
        icon: "warning",
        type: "warning",
        buttons: ["No", "YES"],
        cancel: {value: false},
        confirm: {value: true},
        closeOnClickOutside: false,
    }).then(function (value) {
        if (value) {
            window.exit = true;
            window.bookmarked_list = JSON.parse(localStorage.getItem("review"));
            window.exit = true;
            $.redirect('self-challenge-result.php', {'bookmarked_list': window.bookmarked_list, 'currect_ans': window.correct, 'wrong_ans': window.incorrect, 'play_time': TIME_TAKE, 'challage_time': window.challage_time});
        }
    });
});

$(document).on('click', '#submitData', function () {
    var TIME_TAKE = ((window.time * 60) - timeLeft);
    swal({
        title: "Self Challenge",
        text: "Are you sure? You want to submit this test?",
        icon: "warning",
        type: "warning",
        buttons: ["No", "YES"],
        cancel: {value: false},
        confirm: {value: true},
        closeOnClickOutside: false,
    }).then(function (value) {
        if (value) {
            window.exit = true;
            window.bookmarked_list = JSON.parse(localStorage.getItem("review"));
            window.exit = true;
            $.redirect('self-challenge-result.php', {'bookmarked_list': window.bookmarked_list, 'currect_ans': window.correct, 'wrong_ans': window.incorrect, 'play_time': TIME_TAKE, 'challage_time': window.challage_time});
        }
    });
});

function loop(cb) {
    if (cb == 0) {
        var TIME_TAKE = ((window.time * 60) - timeLeft);
        window.exit = true;
        window.bookmarked_list = JSON.parse(localStorage.getItem("review"));
        $.redirect('self-challenge-result.php', {'bookmarked_list': window.bookmarked_list, 'currect_ans': window.correct, 'wrong_ans': window.incorrect, 'play_time': TIME_TAKE, 'challage_time': window.challage_time});

        setTimeout(function () {
            //bar.stop();
        }, 10);
        window.time = 0;
    }
}

setTimeout(loop, (window.time * 1000 * 60));

function loadQuestions(res) {
    if (window.attempt >= window.limit) {

        setTimeout(function () {
            //  bar.stop();
        }, 10);

    } else {
        if (window.count == 0) {
            $('#ar-left').html('');
        } else {
            $('#ar-left').html('<em class="fa fa-arrow-circle-left fa-2x"></em>');
        }
        $("input[name='sample-radio']").parent().removeClass('bg-success-green');
        $(".progress").empty();
        $("input[name='sample-radio']").prop("checked", false);
        //category & subcate name
        var temp = fetch_questions_category(window.category_id);
        var cat_name = temp['data']['category_name'];
        $('#catname').html(cat_name);
        $('#subname').html(window.sub_name);

        if (window.current_question >= window.limit) {
            $('#ar-right').children().css('display', 'none');
            $('#ar-right').html('<div class="text-center mt-1" id="resultData">Submit</div>');
        } else {
            $('#ar-right').children().css('display', 'block');
            $('#ar-right').html('<em class="fa fa-arrow-circle-right fa-2x"></em>');
        }

        $("#questionsimg img:last-child").remove();

        $('#attempted_question').html(window.current_question);
        $('#total_question').html(window.limit);
        $('#my-fonts-questions').html(res[window.count]['question']);
        $('#option_a').html(res[window.count]['optiona']);
        $('#option_b').html(res[window.count]['optionb']);

        if (res[window.count]['question_type'] == "1") {
            $('#hide-option-tf').show();
            $('#lifeline').show();
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

const TIME_LIMIT = (window.time * 60);
let timeLeft = TIME_LIMIT;
let timerInterval = null;
let remainingPathColor = COLOR_CODES.info.color;
let timePassed = 0;

function startTimer() {
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
    const minutes = Math.floor(time / 60);
    let seconds = time % 60;

    if (seconds < 10) {
        seconds = `0${seconds}`;
    }

    return `${minutes}:${seconds}`;
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