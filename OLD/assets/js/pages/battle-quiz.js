"use strict"
var value = 0;
window.exit = false;
window.correct = 0;
window.incorrect = 0;
window.current_question = 1;
window.count = 0;
window.attempt = 0;
var count_que = 0;
var is_option_e_mode_enabled = (OPTION_E_MODE == '1') ? true : false;
var is_answer_mode = (ANSWER_MODE == '1') ? true : false;
var USER_ID = curr_user_id;
//get user details
var user = get_details(USER_ID);
var FIREBASE_ID = user['data']['firebase_id'];
var USER_NAME = user['data']['name'];
var USER_PROFILE = user['data']['profile'];

var OPP_USER_ID = opp_user_id;
var opp_user = get_details(OPP_USER_ID);
var OPP_FIREBASE_ID = opp_user['data']['firebase_id'];
var OPP_USER_NAME = opp_user['data']['name'];
var OPP_USER_PROFILE = opp_user['data']['profile'];

var QUESTION = "Questions";

var isSelect = false;
var isOppSelect = false;
var OppuserSelect = '';
var selectAns = '';

var status = 1;

var userRef = dbRef.ref(DB_GAME_ROOM_NEW);
var auth = null;

window.onbeforeunload = function () {
    if (window.exit == false) {
        var data = {leftBattle: true};
        userRef.child(FIREBASE_ID).update(data).then(function () {});
        return "Do you really want to leave our brilliant application?";
    }
    if (window.exit == true) {
        var data = {leftBattle: true};
        userRef.child(FIREBASE_ID).update(data).then(function () {});
        var data1 = {'get_random_questions': '1', 'match_id': match_id, 'language_id': language_id, 'destroy_match': '1'};
        var result = get_apis_data(data1);
    }
};

$(document).ready(function () {
    setTimeout(function () {
        $("#preloader").css('display', 'none');
    }, 2000);

    var data = {'get_random_questions': '1', 'match_id': match_id, 'language_id': language_id};
    var result = get_apis_data(data);
    window.res = result['data'];
    loadQuestions(window.res);
    startTimer(0);

});

userRef.child(OPP_FIREBASE_ID).on('child_added', function (snapshot1) {
    if (snapshot1.key == "leftBattle") {
        if (snapshot1.val() == true) {
            swal({
                closeOnClickOutside: false,
                title: "You Win!!",
                text: OPP_USER_NAME + " has leave the game",
                icon: "success",
                type: "success",
            }).then(function () {
                window.exit = true;
                $.redirect('find-opponent.php');
            });
        }
    }
});

userRef.child(OPP_FIREBASE_ID).child(QUESTION).on('child_added', function (snapshot1) {
    if (snapshot1.key == window.count) {
//        status = 1;
        isOppSelect = true;
        OppuserSelect = snapshot1.val().userSelect;
        CheckForNextQue();
    }
});

$("input[type='radio']").click(function () {
    var radioValue = $("input[name='sample-radio']:checked").val();

    isSelect = true;

    window.attempt = window.attempt + 1;
    window.current_question = window.current_question + 1;

    selectAns = res[window.count]['option' + radioValue];

    var data = {userSelect: selectAns};
    userRef.child(FIREBASE_ID).child(QUESTION).child(window.count).set(data).then(function () {});

    $("input[name='sample-radio']").prop("disabled", true);
    if (radioValue == res[window.count]['answer'].toLowerCase()) {
        $("input[name='sample-radio'][value=" + radioValue + "]").parent().addClass('bg-success-green');
        window.correct = window.correct + 1;

        $('#green_count').html(window.correct);
        $('#green_count_curr_user').html(window.correct);
        $('#points').html(window.correct);

        var correct_percentage = window.correct * 100 / window.total_question_percentage;

        $('.progressBar_fill_green').animate({
            height: correct_percentage + "%"
        });

        var data = {rightAns: window.correct};
        userRef.child(FIREBASE_ID).update(data).then(function () {});
    } else {
        $("input[name='sample-radio'][value=" + radioValue + "]").parent().addClass('bg-danger-red');
        window.incorrect = window.incorrect + 1;

        $('#red_count').html(window.incorrect);
        $('#red_count_curr_user').html(window.incorrect);
        var incorrect_percentage = window.incorrect * 100 / window.total_question_percentage;

        $('.progressBar_fill_red').animate({
            height: incorrect_percentage + "%"
        });
        $("input[name='sample-radio'][value=" + res[window.count]['answer'].toLowerCase() + "]").parent().addClass('bg-success-green');
    }
//    status = 1;
    CheckForNextQue();
});

function loop(cb) {
    if (cb == 0) {
        window.current_question = window.current_question + 1;
        window.incorrect = window.incorrect + 1;

        $('#red_count').html(window.incorrect);
        var incorrect_percentage = window.incorrect * 100 / window.total_question_percentage;

        $('.progressBar_fill_red').animate({
            height: incorrect_percentage + "%"
        });

        selectAns = "";
        var data = {userSelect: selectAns};
        userRef.child(FIREBASE_ID).child(QUESTION).child(window.count).set(data).then(function () {});
        window.count += 1;
        clearInterval(timerInterval);
        startTimer(0);
        loadQuestions(window.res);
        setTimeout(loop, (QUESTION_TIME * 1000));
    }
}
setTimeout(loop, (QUESTION_TIME * 1000));

function CheckForNextQue() {
    userRef.child(OPP_FIREBASE_ID).once('value', function (opp_data) {
        if (opp_data && opp_data.val() != null) {
            if (opp_data.val().leftBattle != 'undefined' && opp_data.val().leftBattle == true) {
                swal({
                    closeOnClickOutside: false,
                    title: "You Win!!",
                    text: OPP_USER_NAME + " has leave the game",
                    icon: "success",
                    type: "success",
                }).then(function () {
                    window.exit = true;
                    $.redirect('find-opponent.php');
                });
            } else {
                if (isSelect == true) {
                    if (isOppSelect == true && OppuserSelect != '') {
                        if (OppuserSelect == $('#option_a').text()) {
                            $('#p1').html(OPP_USER_NAME);
                        }
                        if (OppuserSelect == $('#option_b').text()) {
                            $('#p2').html(OPP_USER_NAME);
                        }
                        if (OppuserSelect == $('#option_c').text()) {
                            $('#p3').html(OPP_USER_NAME);
                        }
                        if (OppuserSelect == $('#option_d').text()) {
                            $('#p4').html(OPP_USER_NAME);
                        }
                        if (OppuserSelect == $('#option_e').text()) {
                            $('#p5').html(OPP_USER_NAME);
                        }

                        if (opp_data.val().rightAns != 'undefined') {
                            $('#green_count_opp_user').html(opp_data.val().rightAns);
                        }
                        setTimeout(function () {
                            window.count += 1;
                            clearInterval(timerInterval);
                            startTimer(0);
                            loadQuestions(window.res);
                            setTimeout(loop, (QUESTION_TIME * 1000));
                        }, 1000);
                    }
                }
            }
        }
    });
}

function loadQuestions(res) {

    isSelect = false;
    isOppSelect = false;

    $("input[name='sample-radio']").prop("disabled", false).parent().removeClass('r_on').removeAttr("style");
    $("input[name='sample-radio']").parent().removeClass('bg-danger-red');
    $("input[name='sample-radio']").parent().removeClass('bg-success-green');

    userRef.child(OPP_FIREBASE_ID).on('value', function (opp_data) {
        if (opp_data && opp_data.val() != null) {
            if (opp_data.val().rightAns != 'undefined') {
                $('#green_count_opp_user').html(opp_data.val().rightAns);
            }
        }
    });

    if (window.current_question > res.length) {
        window.exit = true;
        clearInterval(timerInterval);
        userRef.child(OPP_FIREBASE_ID).on('value', function (opp_data) {
            if (opp_data && opp_data.val() != null) {
                if (opp_data.val().rightAns) {
                    var TITIE = QUIZ_V;
                    var TEXT = '';
                    if (window.correct > opp_data.val().rightAns) {
                        var data = {'set_battle_statistics': '1', 'user_id1': USER_ID, 'user_id2': OPP_USER_ID, 'winner_id': USER_ID, 'is_drawn': 0};
                        var result = get_apis_data(data);
                        TITIE = "Congratulation";
                        TEXT = USER_NAME + ", you win the Battle";
                    } else if (opp_data.val().rightAns > window.correct) {
                        TITIE = "Batter Luck Next Time!";
                        TEXT = OPP_USER_NAME + " win the Battle";
                    } else {
                        var data = {'set_battle_statistics': '1', 'user_id1': USER_ID, 'user_id2': OPP_USER_ID, 'winner_id': 0, 'is_drawn': 1};
                        var result = get_apis_data(data);
                        TITIE = QUIZ_V;
                        TEXT = "Draw..!!, The Game is Over play again";
                    }
                    swal({
                        title: TITIE,
                        text: TEXT,
                        icon: "success",
                        buttons: ["RE-BATTLE", "EXIT"],
                        cancel: {value: false},
                        confirm: {value: true},
                        closeOnClickOutside: false,
                    }).then(function (value) {
                        if (value) {
                            window.exit = true;
                            $.redirect('index.php');
                        } else {
                            $.redirect('find-opponent.php');
                        }
                    });
                }
            }
        });
    } else {
        if (res.length < 10) {
            swal({
                title: "No Enough Questions Found",
                text: "Try After Some Time",
                icon: "warning",
                type: "warning",
            }).then(function () {});
        }
        $('#p1').html('');
        $('#p2').html('');
        $('#p3').html('');
        $('#p4').html('');
        $('#p5').html('');

        $("#questionsimg img:last-child").remove();
        window.total_question_percentage = res.length;
        $('#my-fonts-questions').html(res[window.count]['question']);

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

        $('#total_question').html(res.length);
        $('#attempted_question').html(window.current_question);
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

