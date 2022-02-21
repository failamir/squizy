"use strict"
window.onbeforeunload = function () {
    if (window.exit == false) {
        return "Do you really want to leave our brilliant application?";
    }
};
var value = 0;
window.exit = false;

window.points = 0;
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

var temp = get_user_coin_score(user_id);

window.coins = (temp['error'] == 'false') ? temp['data']['coins'] : 0;

var is_option_e_mode_enabled = (OPTION_E_MODE == '1') ? true : false;
var is_answer_mode = (ANSWER_MODE == '1') ? true : false;

//get bookmarked
var bookmarked = get_bookmark(user_id);

var RIGHT_STATUS = 1;
var FIFTY_STATUS = 1;
var AUDIENCE_POLL_STATUS = 1;
var RESET_TIMER_STATUS = 1;

$(document).ready(function () {
    setTimeout(function () {
        $("#preloader").css('display', 'none');
    }, 2000);

    var data_param = {
        get_questions_by_type: '1',
        type: '1',
        limit: '10'
    };

    if (language_id == '1') {
        data_param['language_id'] = language_id;
    }

    var result = get_apis_data(data_param);

    if (result['error'] == FALSE) {
        localStorage.removeItem("review");
        window.res = result['data'];
        window.questions_answered = result['data'].length;

        loadQuestions(window.res);
        startTimer(0);
        window.obj = {};
    } else {
        swal({
            title: "No Questions Found",
            text: "Try After Some Time",
            icon: "warning",
            type: "warning",
        }).then(function () {
            window.exit = true;
            $.redirect('index.php');
        });
    }

    $("input[type='radio']").click(function () {
        var radioValue = $("input[name='sample-radio']:checked").val();

        if (radioValue != "") {
            obj["userans"] = radioValue;
            obj["attempted"] = 1;
        }

        Object.assign(res[window.count], obj);
        if (localStorage.getItem("review") != '') {
            window.localStorageData = JSON.parse(localStorage.getItem("review"));
            if (window.localStorageData != null && window.localStorageData.length > 0 && window.localStorageData != '') {
                window.localStorageData.push(Object.assign(res[window.count], obj));
            } else {
                window.localStorageData = [Object.assign(res[window.count], obj)];
            }
        } else {
            window.localStorageData = [Object.assign(res[window.count], obj)];
        }
        localStorage.setItem("review", JSON.stringify(window.localStorageData));

        window.attempt = window.attempt + 1;
        window.current_question = window.current_question + 1;

        setTimeout(function () {
            $("input[name='sample-radio']").prop("disabled", false).parent().removeClass('r_on').removeAttr("style");
            $("input[name='sample-radio'][value=" + radioValue + "]").parent().removeClass('bg-danger-red');

            $("input[name='sample-radio'][value=" + res[window.count]['answer'].toLowerCase() + "]").parent().removeClass('bg-success-green');
            window.count += 1;

            clearInterval(timerInterval);
            startTimer(0);
            loadQuestions(window.res);
            setTimeout(loop, (QUESTION_TIME * 1000));
        }, 1000);

        $("input[name='sample-radio']").prop("disabled", true);
        if (radioValue == res[window.count]['answer'].toLowerCase()) {
            $("input[name='sample-radio'][value=" + radioValue + "]").parent().addClass('bg-success-green');
            window.correct = window.correct + 1;

            $('#green_count').html(window.correct);
            $('#points').html(parseInt(window.points) + parseInt(FOR_CORRECT_ANS));

            var correct_percentage = window.correct * 100 / window.total_question_percentage;

            $('.progressBar_fill_green').animate({
                height: correct_percentage + "%"
            });
        } else {

            $("input[name='sample-radio'][value=" + radioValue + "]").parent().addClass('bg-danger-red');
            window.incorrect = window.incorrect + 1;

            $('#red_count').html(window.incorrect);
            $('#points').html(parseInt(window.points) - parseInt(2));
            var incorrect_percentage = window.incorrect * 100 / window.total_question_percentage;

            $('.progressBar_fill_red').animate({
                height: incorrect_percentage + "%"
            });
            if (is_answer_mode) {
                $("input[name='sample-radio'][value=" + res[window.count]['answer'].toLowerCase() + "]").parent().addClass('bg-success-green');
            }
        }
    });
});

$(document).on('click', '#boockmark_question', function () {
    var question_id = window.res[window.count]['id'];
    if ($(this).hasClass('active')) {
        $('#boockmark_question').removeClass('active');
        var status = '0';
    } else {
        $('#boockmark_question').addClass('active');
        var status = '1';
    }
    set_bookmark(user_id, question_id, status);
});

$(document).on('click', '#right', function () {
    if (window.coins >= RIGHT_ANS) {
        if (RIGHT_STATUS == 1) {
            var coin = set_user_coin_score(user_id, (-RIGHT_ANS));
            window.coins = (coin['error'] == 'false') ? coin['data']['coins'] : 0;
            $('#coins').html(window.coins);

            window.attempt = window.attempt + 1;
            window.current_question = window.current_question + 1;
            $('#attempted_question').html(window.current_question);
            $("input[name='sample-radio']").prop("disabled", false).parent().removeClass('r_on').removeAttr("style");
            window.count += 1;

            clearInterval(timerInterval);
            startTimer(0);
            loadQuestions(window.res);
            setTimeout(loop, (QUESTION_TIME * 1000));
            RIGHT_STATUS = 0;
        } else {
            life_line_alert(timerInterval, timeLeft);
        }
    } else {
        stop_alert(timerInterval, timeLeft);
    }
});

$(document).on('click', '#fifty', function () {
    if (window.coins >= FIFTY_FIFTY) {
        if (FIFTY_STATUS == 1) {
            var coin = set_user_coin_score(user_id, (-FIFTY_FIFTY));
            window.coins = (coin['error'] == 'false') ? coin['data']['coins'] : 0;
            $('#coins').html(window.coins);

            var ans = res[window.count]['answer'].toLowerCase();
            if (ans == 'a') {
                $("input[name='sample-radio'][value='c']").parent().parent().hide();
                $("input[name='sample-radio'][value='d']").parent().parent().hide();
            } else if (ans == 'b') {
                $("input[name='sample-radio'][value='c']").parent().parent().hide();
                $("input[name='sample-radio'][value='d']").parent().parent().hide();
            } else {
                $("input[name='sample-radio'][value='a']").parent().parent().hide();
                $("input[name='sample-radio'][value='b']").parent().parent().hide();
            }
            FIFTY_STATUS = 0;
        } else {
            life_line_alert(timerInterval, timeLeft);
        }
    } else {
        stop_alert(timerInterval, timeLeft);
    }
});

$(document).on('click', '#audience_poll', function () {
    if (window.coins >= AUDIENCE_POLL) {
        if (AUDIENCE_POLL_STATUS == 1) {
            var coin = set_user_coin_score(user_id, (-AUDIENCE_POLL));
            window.coins = (coin['error'] == 'false') ? coin['data']['coins'] : 0;
            $('#coins').html(window.coins);

            var minValue = 45;
            var maxValue = 70;
            var per_count = randomIntFromInterval(minValue, maxValue);
            var final = 100 - per_count;

            var $a = $('#a').find('.progress');
            var $b = $('#b').find('.progress');
            var $c = $('#c').find('.progress');
            var $d = $('#d').find('.progress');

            if (is_option_e_mode_enabled && $('#option_e').text() != '') {
                var $e = $('#e').find('.progress');
                var tf = Math.floor((final - 8) + 1);
                var final1 = final - tf;
                var st = Math.floor((final1 - 4) + 1);
                var final2 = final1 - st;
                var ft = Math.round((final2 - 2) + 1);
                var kt = final2 - ft;
            } else {
                var tf = Math.floor((final - 10) + 1);
                var final1 = final - tf;
                var st = Math.floor((final1 - 5) + 1);
                var ft = final1 - st;
            }
            var ans = res[window.count]['answer'].toLowerCase();
            if (ans == 'a') {
                $a.attr('value', per_count);
                $b.attr('value', tf);
                $c.attr('value', st);
                $d.attr('value', ft);
                if (is_option_e_mode_enabled) {
                    if ($('#option_e').text() != '' && $e != undefined && $e != null) {
                        $e.attr('value', kt);
                    }
                }
            } else if (ans == 'b') {
                $b.attr('value', per_count);
                $c.attr('value', tf);
                $a.attr('value', st);
                $d.attr('value', ft);
                if (is_option_e_mode_enabled) {
                    if ($('#option_e').text() != '' && $e != undefined && $e != null) {
                        $e.attr('value', kt);
                    }
                }
            } else if (ans == 'c') {
                $c.attr('value', per_count);
                $b.attr('value', tf);
                $d.attr('value', st);
                $a.attr('value', ft);
                if (is_option_e_mode_enabled) {
                    if ($('#option_e').text() != '' && $e != undefined && $e != null) {
                        $e.attr('value', kt);
                    }
                }
            } else if (ans == 'd') {
                $d.attr('value', per_count);
                $b.attr('value', tf);
                $c.attr('value', st);
                $a.attr('value', ft);
                if (is_option_e_mode_enabled) {
                    if ($('#option_e').text() != '' && $e != undefined && $e != null) {
                        $e.attr('value', kt);
                    }
                }
            } else if (is_option_e_mode_enabled && ans == 'e' && $e != undefined && $e != null) {
                if ($('#option_e').text() != '') {
                    $e.attr('value', per_count);
                    $b.attr('value', tf);
                    $c.attr('value', st);
                    $a.attr('value', ft);
                    $d.attr('value', kt);
                }
            }
            progress_bar(100);
            AUDIENCE_POLL_STATUS = 0;
        } else {
            life_line_alert(timerInterval, timeLeft);
        }
    } else {
        stop_alert(timerInterval, timeLeft);
    }
});

$(document).on('click', '#reset_timer', function () {
    if (window.coins >= RESET_TIMER) {
        if (RESET_TIMER_STATUS == 1) {
            var coin = set_user_coin_score(user_id, (-RESET_TIMER));

            window.coins = (coin['error'] == 'false') ? coin['data']['coins'] : 0;
            $('#coins').html(window.coins);

            setTimeout(function () {
                clearInterval(timerInterval);
                startTimer(0);
            });
            RESET_TIMER_STATUS = 0;
        } else {
            life_line_alert(timerInterval, timeLeft);
        }
    } else {
        stop_alert(timerInterval, timeLeft);
    }
});


function loop(cb) {
    if (cb == 0) {
        if (window.attempt < (res.length - 1)) {
            window.current_question = window.current_question + 1;
            $('#attempted_question').html(window.current_question);
        }

        obj["userans"] = '';
        obj["attempted"] = 0;
        Object.assign(res[window.count], obj);
        if (localStorage.getItem("review") != '') {
            window.localStorageData = JSON.parse(localStorage.getItem("review"));
            if (window.localStorageData != null && window.localStorageData.length > 0 && window.localStorageData != '') {
                window.localStorageData.push(Object.assign(res[window.count], obj));
            } else {
                window.localStorageData = [Object.assign(res[window.count], obj)];
            }
        } else {
            window.localStorageData = [Object.assign(res[window.count], obj)];
        }
        localStorage.setItem("review", JSON.stringify(window.localStorageData));

        $("input[name='sample-radio']").prop("disabled", false).parent().removeClass('r_on').removeAttr("style");
        window.count += 1;
        window.attempt = window.attempt + 1;

        window.incorrect = window.incorrect + 1;
        $('#points').html(parseInt(window.points) - parseInt(FOR_INCORRECT_ANS));

        $('#red_count').html(window.incorrect);
        var incorrect_percentage = window.incorrect * 100 / window.total_question_percentage;

        $('.progressBar_fill_red').animate({
            height: incorrect_percentage + "%"
        });

        clearInterval(timerInterval);
        startTimer(0);
        loadQuestions(window.res);
        setTimeout(loop, (QUESTION_TIME * 1000));
    }
}
setTimeout(loop, (QUESTION_TIME * 1000));

function loadQuestions(res) {
    if (window.attempt >= res.length) {

        setTimeout(function () {
            clearInterval(timerInterval);
        }, 10);

        swal({
            closeOnClickOutside: false,
            title: "Congratulation",
            text: "Quiz completed. Click OK to see your result",
            icon: "success",
            type: "success",
        }).then(function () {
            window.exit = true;
            window.ratio = (window.correct * 100) / window.questions_answered;
            //coin distribution
            var temp1 = get_user_coin_score(user_id);
            var USER_COIN = (temp1['error'] == 'false') ? temp1['data']['coins'] : 0;
            var GET_COIN = 0;
            if (window.ratio >= 30 && window.ratio <= 39) {
                USER_COIN = (parseInt(giveOneCoin) + parseInt(USER_COIN));
                GET_COIN = giveOneCoin;
            } else if (window.ratio >= 40 && window.ratio <= 59) {
                USER_COIN = (parseInt(giveTwoCoins) + parseInt(USER_COIN));
                GET_COIN = giveTwoCoins;
            } else if (window.ratio >= 60 && window.ratio <= 79) {
                USER_COIN = (parseInt(giveThreeCoins) + parseInt(USER_COIN));
                GET_COIN = giveThreeCoins;
            } else if (window.ratio >= 80) {
                USER_COIN = (parseInt(giveFourCoins) + parseInt(USER_COIN));
                GET_COIN = giveFourCoins;
            }

            window.points = $('#points').text();
            if (parseInt(user_id) != 0) {
                if (window.ratio >= PASSING_PER) {
                    var data = {'set_monthly_leaderboard': '1', 'user_id': user_id, 'score': window.points};
                    get_apis_data(data);
                }

                var data = {'set_users_statistics': '1', 'user_id': user_id, 'questions_answered': window.questions_answered, 'correct_answers': window.correct, 'category_id': '0', 'ratio': window.ratio, 'coins': USER_COIN};
                get_apis_data(data);

            }
            window.bookmarked_list = JSON.parse(localStorage.getItem("review"));
            $.redirect('resulting.php', {'bookmarked_list': window.bookmarked_list, 'get_coin': GET_COIN, 'users_coins': USER_COIN, 'total_question': window.total_question_percentage, 'currect_ans': window.correct, 'wrong_ans': window.incorrect, 'user_id': user_id, 'ratio': window.ratio, 'score': window.points, 'level': window.level, 'subcategory': window.sub_id, 'category': window.category_id, 'subcategory_name': window.sub_name, 'type': 'randomquiz'});
        });
    } else {

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

        $('#boockmark_question').removeClass('active');
        $(".progress").empty();
        window.points = $('#points').text();

        $('#coins').text(window.coins);

        $("#questionsimg img:last-child").remove();
        window.total_question_percentage = res.length;

        $.each(bookmarked['data'], function (key, val) {
            if (parseInt(val.id) == parseInt(res[window.count]['id'])) {
                $('#boockmark_question').addClass('active');
                return;
            }
        });

        $('#level').html(res[window.count]['level']);
        $('#attempted_question').html(window.current_question);
        $('#total_question').html(res.length);
        $('#my-fonts-questions').html(res[window.count]['question']);
        showHideOptions();
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
            var html = "<img class='my-questions-img pt-2' src='" + res[window.count]['image'] + "' width='" + QUIZ_IMG_WIDTH + "'>";
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
