"use strict"
var JWTKEY = encodeURIComponent(JWT_KEY);

const ACCESS_KEY = '6808';
const FALSE = 'false';
const TRUE = 'true';
const DB_GAME_ROOM_NEW = 'RandomBattleRoom';
const CATEGORY_TITLE = 'Categories';
const SUBCATEGORY_TITLE = 'Sub Categories';
const LEVEL_TITLE = 'Levels';
const SELECT_ON_OF_QUE = 'Select Number of Questions';
const SELECT_TIME_OF_MINUTES ='Select Time Period in Minutes';
const LETS_START = 'Lets Start';
const SM_LOGO = 'assets/images/icon.png';
const LOADER_LOGO = 'assets/images/loader.gif';
const USER_IMG = 'assets/images/user.png';

let SYSTEM_TIMEZONE = 'Asia/Kolkata';
let APP_LINK = '';
let IOS_APP_LINK = '';
let ANSWER_MODE = '0';
let LANGUAGE_MODE = '0';
let OPTION_E_MODE = '0';
let DAILY_QUIZ_MODE = '0';
let CONTEST_MODE = '0';
let BATTLE_RANDOM_CATEGORY_MODE = '0';
let SHAREAPP_TEXT = '';
let INSTAGRAM_LINK = '';
let FACEBOOK_LINK = '';
let YOUTUBE_LINK = '';

// get jwt token
function get_token() {
    $.ajaxSetup({async: false, dataType: 'json'});
    var returnUserData = null;
    $.post("assets/verify-token.php?jwt_key=" + JWTKEY, function (data) {
        returnUserData = data;
    });
    $.ajaxSetup({async: true});
    return returnUserData;
}
const JWT_TOKEN = get_token();

var SETTING = fetch_systemConfiguration();

if (SETTING['error'] == FALSE) {
    SYSTEM_TIMEZONE = SETTING['data']['system_timezone']
    APP_LINK = SETTING['data']['app_link'];
    IOS_APP_LINK = SETTING['data']['ios_app_link'];
    ANSWER_MODE = SETTING['data']['answer_mode'];
    LANGUAGE_MODE = SETTING['data']['language_mode'];
    OPTION_E_MODE = SETTING['data']['option_e_mode'];
    DAILY_QUIZ_MODE = SETTING['data']['daily_quiz_mode'];
    CONTEST_MODE = SETTING['data']['contest_mode'];
    BATTLE_RANDOM_CATEGORY_MODE = SETTING['data']['battle_random_category_mode'];
    SHAREAPP_TEXT = SETTING['data']['shareapp_text'];
    INSTAGRAM_LINK = SETTING['data']['instagram_link'];
    FACEBOOK_LINK = SETTING['data']['facebook_link'];
    YOUTUBE_LINK = SETTING['data']['youtube_link'];
}

function get_apis_data(data) {
    data['access_key'] = ACCESS_KEY;
    $.ajaxSetup({async: false, dataType: 'json', headers: {Authorization: 'Bearer ' + JWT_TOKEN}});
    var returnUserData = null;
    $.post(QUIZ_URL, data, function (result) {
        returnUserData = result;
    });
    $.ajaxSetup({async: true});
    return returnUserData;
}

function showHideOptions() {
    $("input[name='sample-radio']").parent().parent().show();
}

$(document).on('click', '.topbar li a', function () {
    if ($(this).parent().hasClass("show")) {
        $('.downmenusub').hide();
        $(this).parent().removeClass('show');
    } else {
        $('.downmenusub').show();
        $(this).parent().addClass('show');
    }
});

$(window).scroll(function () {
    if ($(this).scrollTop() >= 200) {
        $('#return-to-top').fadeIn(200);
    } else {
        $('#return-to-top').fadeOut(200);
    }
    if ($(this).scrollTop() > 1) {
        $('#navbar').addClass("sticky");
    } else {
        $('#navbar').removeClass("sticky");
    }
});

// Open active tab based on button clicked
$(document).on('click', '.btn-modal', function () {
    var switchTab = $(this).data('tab');
    $('#logintTab').find('li').removeClass('active');
    activaTab(switchTab);
    function activaTab(switchTab) {
        $('.nav-tabs a[href="#' + switchTab + '"]').tab('show');
        $('.nav-tabs a[href="#' + switchTab + '"]').tab('show').parent("li").addClass('active');
    }
});

$(document).on("click", '#logintTab li a', function () {
    $('#logintTab').find('li').removeClass('active');
    $(this).parent('li').addClass('active');
});

$(document).on("click", '.lgTag', function () {
    var data = $(this).attr("href");
    $('#logintTab').find('li').removeClass('active');
    $('#logintTab li a[href="' + data + '"]').parent('li').addClass('active');
    $('.nav-tabs a[href="' + data + '"]').tab('show');
});

function topReturn() {
    $('body,html').animate({
        scrollTop: 0
    }, 500);
}

var scroll = new SmoothScroll('a[href*="#"]');

new WOW().init();

document.onreadystatechange = function () {
    if (document.readyState === "complete") {
        $("#preloader").css('display', 'none');
    }

    if (LANGUAGE_MODE != 0 && language_id == 0) {
        $("#editModal").modal("show");
    }
}

$(document).ready(function () {

    $('.wapper').css('min-height', $(window).height() - 316);

    var url = window.location.href;
    var index = url.lastIndexOf("/") + 1;
    var page = url.substr(index);

    if (page === '') {
        $('#home').addClass("active");
    }

    $("#menuactive a").each(function () {
        if (url.indexOf(this.href) >= 0) {
            $(this).closest("a").addClass("active");
            $(this).parent().closest("a");
            $(this).parent().closest('li').addClass("active");
        }
    });

    $('.app_link').attr("href", APP_LINK);
    if (IOS_APP_LINK == "") {
        $('.ios_app_link').hide();
    } else {
        $('.ios_app_link').show();
        $('.ios_app_link').attr("href", IOS_APP_LINK);
    }
    if (DAILY_QUIZ_MODE == '0') {
        $('.dailyQuiz').hide();
    } else {
        $('.dailyQuiz').show();
    }
    if (CONTEST_MODE == '0') {
        $('.ContestQuiz').hide();
    } else {
        $('.ContestQuiz').show();
    }
    
    var SocialMedia = '';
    if(INSTAGRAM_LINK !=''){
        SocialMedia += '<a href="'+INSTAGRAM_LINK+'" target="_blank" rel="noopener noreferrer">';
        SocialMedia +='<img src="assets/images/insta.png" alt="instagram">';
        SocialMedia +='</a>';
    }
    if(FACEBOOK_LINK !=''){
        SocialMedia += '<a href="'+FACEBOOK_LINK+'" target="_blank" rel="noopener noreferrer">';
        SocialMedia +='<img src="assets/images/fb.png" alt="facebook">';
        SocialMedia +='</a>';
    }
    if(YOUTUBE_LINK !=''){
        SocialMedia += '<a href="'+YOUTUBE_LINK+'" target="_blank" rel="noopener noreferrer">';
        SocialMedia +='<img src="assets/images/ty.png" alt="youtube">';
        SocialMedia +='</a>';
    }
    $('.SocialMedia').html(SocialMedia);

});

$(document).click(function () {
    $(this).find('.navbar-collapse').removeClass("show");
});

$(document).on("click", function (event) {
    var $trigger = $(".topbar");
    if ($trigger !== event.target && !$trigger.has(event.target).length) {
        $('.downmenusub').hide();
        $('.topbar li a').parent().removeClass('show');
    }
});

function shuffleOptions(array) {
    for (let i = array.length - 1; i > 0; i--) {
        let j = Math.floor(Math.random() * (i + 1));
        let temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }
    return array;
}

function stop_alert(timerInterval, timeLeft) {
    stop_timer(timerInterval);
    swal({
        title: "Not enough coins!",
        text: "You have no enough coins to use life line. Play quiz and earn some coins first.",
        icon: "warning",
        type: "warning",
    }).then(function () {
        startTimer(timeLeft);
    });
}

function life_line_alert(timerInterval, timeLeft) {
    stop_timer(timerInterval);
    swal({
        title: "Life Line Already Used!",
        text: "You can use only once per quiz.",
        icon: "warning",
        type: "warning",
    }).then(function () {
        startTimer(timeLeft);
    });
}

//stop timer
function stop_timer(timerInterval) {
    clearInterval(timerInterval);
}

function no_question_alert() {
    swal({
        title: "No Questions Available",
        icon: "warning",
        type: "warning",
    }).then(function () {
    });
}

function progress_bar() {
    var startColor = '#1D6CBA';
    var endColor = '#1D6CBA';
    $('.progress').each(function (i) {
        var circle = new ProgressBar.Circle(this, {
            color: startColor,
            easing: 'linear',
            strokeWidth: 8,
            duration: 1500,
            text: {value: '0'}
        });

        var value = ($(this).attr('value') / 100);

        circle.animate(value, {
            from: {color: startColor},
            to: {color: endColor},
            step: function (state, circle, bar) {
                circle.path.setAttribute('stroke', state.color);
                circle.setText((circle.value() * 100).toFixed(0) + '%');
            }
        });
    });
}

function randomIntFromInterval(min, max) // min and max included
{
    return Math.floor(Math.random() * (max - min + 1) + min);
}



// get user details
function get_details(user_id) {
    var data = {get_user_by_id: '1', id: user_id};
    var result = get_apis_data(data);
    return result;
}

// for get category name
function fetch_questions_category(cat_id) {
    var data = {get_categories: '1', id: cat_id};
    var result = get_apis_data(data);
    return result;
}

//system_configurations
function fetch_systemConfiguration() {
    var data = {get_system_configurations: '1'};
    var result = get_apis_data(data);
    return result;
}

//fetch_language_by_id
function fetch_language(lang_id) {
    var data = {get_languages: '1', id: lang_id};
    var result = get_apis_data(data);
    return result;
}

// set_level_data
function set_level_data(user_id, cat_id, sub_id, level) {
    var data = {set_level_data: '1', user_id: user_id, category: cat_id, subcategory: sub_id, level: level};
    var result = get_apis_data(data);
    return result;
}

// fetch_level_data
function fetch_level_data(user_id, cat_id, sub_id) {
    var data = {get_level_data: '1', user_id: user_id, category: cat_id, subcategory: sub_id};
    var result = get_apis_data(data);
    return result;
}

// set_bookmark
function set_bookmark(user_id, question_id, status) {
    var data = {set_bookmark: '1', user_id: user_id, question_id: question_id, status: status};
    var result = get_apis_data(data);
    return result;
}

// get_bookmark
function get_bookmark(user_id) {
    var data = {get_bookmark: '1', user_id: user_id};
    var result = get_apis_data(data);
    return result;
}

// get_bookmark
function get_user_coin_score(user_id) {
    var data = {get_user_coin_score: '1', user_id: user_id};
    var result = get_apis_data(data);
    return result;
}

// get_bookmark
function set_user_coin_score(user_id, coins) {
    var data = {set_user_coin_score: '1', user_id: user_id, coins: coins};
    var result = get_apis_data(data);
    return result;
}

$(document).on('show.bs.modal', '#editModal', function () {
    if (LANGUAGE_MODE != 0) {
        var data = {'get_languages': '1'};
        var result = get_apis_data(data);
        var html = "";
        if (result['error'] == FALSE) {
            html += '<input type="hidden" name="id" id="lang_id">';
            html += '<input type="hidden" name="language" id="language_name">';
            $.each(result['data'], function (key, val) {
                html += '<div class="shadow-box-lang add-cursor get_language_id" id=' + val['id'] + ' value="' + val['language'] + '">' + val['language'] + '</div>';
            });
        }
        $('#langData').html(html);
    }
});

$(document).on('click', '.get_language_id', function () {
    var language_name = $(this).attr('value');
    var lang_id = $(this).attr("id");
    $('#lang_id').val(lang_id);
    $('#language_name').val(language_name);
    $('#langForm').submit();
});

function PlayTrueFalse() {
    var data = {
        get_questions_by_type: '1',
        type: '2',
        language_id: language_id,
        limit: '10'
    }
    var result = get_apis_data(data);
    if (result['error'] == TRUE) {
        swal({
            text: result['message'],
            icon: "warning",
            type: "warning",
        }).then(function () {});
    } else {
        window.location.href = 'true-false-quiz.php';
    }
}


function PlayRandomQuiz() {
    var data = {
        get_questions_by_type: '1',
        type: '1',
        language_id: language_id,
        limit: '10'
    }
    var result = get_apis_data(data);
    if (result['error'] == TRUE) {
        swal({
            text: result['message'],
            icon: "warning",
            type: "warning",
        }).then(function () {});
    } else {
        window.location.href = 'random-quiz.php';
    }
}
