var LANG_ID = (language_id == 0) ? -1 : language_id;
var CATE_ID = "";
var USER_ID = user_id;

//get user details
var user = get_details(USER_ID);
var FIREBASE_ID = user['data']['firebase_id'];
var USER_NAME = user['data']['name'];
var USER_PROFILE = user['data']['profile'];

var userId1 = USER_ID;
var player1Name = USER_NAME;
var userProfile = USER_PROFILE;

var matchingId = '';
var opponentId = '';
var user1matchingId = '';
var user2matchingId = '';
var userId2 = '';
var player2Name = '';
var profilePlayer2 = '';
var isAvailable = false;

var userRef = dbRef.ref(DB_GAME_ROOM_NEW);
var auth = null;

var status = 1;

var timeleft = 10;
var downloadTimer = 0;

$(document).ready(function () {
    userRef.child(FIREBASE_ID).remove();
    var data1 = {'get_random_questions': '1', 'match_id': FIREBASE_ID, 'language_id': LANG_ID, 'destroy_match': '1'};
    var result1 = get_apis_data(data1);

    if (BATTLE_RANDOM_CATEGORY_MODE == '1') {
        var data = '';
        if (LANGUAGE_MODE == '0') {
            data = {'get_categories': '1'};
        } else {
            data = {'get_categories_by_language': '1', language_id: language_id};
        }
        var result = get_apis_data(data);
        var html = "";
        html += '<div class="col-md-12 col-sm-12 top-margin">';
        html += '<div class="row">';
        html += '<div class="col-md-12">';
        html += '<h2 class="text-uppercase">' + CATEGORY_TITLE + '</h2>';
        html += '</div>';
        html += '</div>';
        html += '</div>';
        if (result['error'] == TRUE) {
            html += '<div class="col-md-3 col-sm-6"><div class="shadow-box-category wow zoomIn"><div class="text-center text-bold mt-2 mb-4">' + result['message'] + '</div></div></div> ';
        } else {
            $.each(result['data'], function (key, val) {
                var IMG = SM_LOGO;
                if (val['image'] != '') {
                    IMG = val['image'];
                }
                html += '<div class="col-md-3 col-sm-6 mt-4">';
                html += '<div class="shadow-box-category set_battle_data add-cursor wow zoomIn" data-maincat="' + val['category_name'] + '">';
                html += '<img src="' + IMG + '" class="category-image rounded mt-4">';
                html += '<div class="text-center text-bold py-4" value=' + val['id'] + ' data-noofque="' + val['no_of_que'] + '">' + val['category_name'] + '</div></div>';
                html += '</div>';
            });
        }
        $("#categories").html(html);
    } else {
        $("#categories").hide();
        $('#find_Opponent').show();
    }

    var data1 = {'get_battle_statistics': '1', 'user_id': USER_ID};
    var result1 = get_apis_data(data1);
    var html = "";
    var html1 = '';
    if (result1['error'] == FALSE) {
        html1 = '<div class="col-12 text-center mb-2"><h2>Battle Statistics</h2></div> ';
        $.each(result1['data'], function (key, val) {
            html += '<div class="row justify-content-center shadow-box position-box pb-2">';
            var IMG1 = USER_IMG;
            var IMG2 = USER_IMG;
            if (USER_PROFILE != '') {
                IMG1 = USER_PROFILE;
            }
            html += '<div class="col-md-3 col-3 pt-2"><img src="' + IMG1 + '" class="statImg"><br/>' + USER_NAME + '</div>';
            html += '<div class="col-md-3 col-3 pt-2">' + val['mystatus'] + '<br/><img src="assets/images/vs.png" class="statImg"></div>';
            if (val['opponent_profile'] != '') {
                IMG2 = val['opponent_profile'];
            }
            html += '<div class="col-md-3 col-3 pt-2"><img src="' + IMG2 + '" class="statImg"><br/>' + val['opponent_name'] + '</div>';
            html += '</div>';
        });
    }
    $("#battle_title").html(html1);
    $("#battle_statistics").html(html);
});

$(document).on('click', '.set_battle_data', function () {
    var no_of_que = $(this).children("div").attr('data-noofque');
    CATE_ID = $(this).children("div").attr('value');
    $.blockUI({
        css: {color: '#fff', border: 'none', backgroundColor: 'transparent', },
        message: '<h1><img src="' + LOADER_LOGO + '" width="100" /></h1>'});
    if (no_of_que != '0') {
        $("#categories").hide();
        $('#find_Opponent').show();
        $.unblockUI();
    } else {
        no_question_alert();
        $.unblockUI();
    }

});

function findOpponent() {
    document.getElementById('find_Opponent').style.pointerEvents = 'none';
    var data = {
        userID: USER_ID.toString(),
        name: USER_NAME, //get the email from Form
        image: USER_PROFILE,
        isAvail: '1',
        langId: LANG_ID.toString(),
        cateId: CATE_ID.toString()
    };
    userRef.child(FIREBASE_ID).set(data).then(function () {}); //set data
    findOnlineUser();
}

$(document).on('click', '.play_robot', function () {
    window.exit = true;
    $.redirect('battle-robot.php', {'userId1': userId1, 'player1Name': player1Name, 'opp_name': 'Robot'});
});

function startTimer() {
    var downloadTimer = setInterval(function () {
        if (timeleft <= 0) {
            document.getElementById('find_Opponent').style.pointerEvents = 'auto';
            clearInterval(downloadTimer);
            userRef.child(FIREBASE_ID).remove();
            $('#countdown').html('');
            $('#searchtext').html('');

            var el = document.createElement("a");
            el.setAttribute('class', 'swal-button text-white play_robot');
            el.innerText = "Play With Robot";

            swal({
                title: "Oops!",
                text: "Player Not Available For Battle!",
                icon: "warning",
                type: "warning",
                content: el,
                buttons: ["Try Again", "Exit"],
                cancel: {value: false},
                confirm: {value: true},
                closeOnClickOutside: false,
            }).then(function (value) {
                if (value) {
                    window.exit = true;
                    $.redirect('find-opponent.php');
//                    $.redirect('battle-robot.php', {'userId1': userId1, 'player1Name': player1Name, 'opp_name': 'Robot'});
                } else {
                    timeleft = 10;
                    findOpponent();
                }
            });

        } else {
            checkMatchUser();
            $('#countdown').html(timeleft + " sec");
            $('#searchtext').html('Searching for an Opponent..');
        }
        timeleft -= 1;
    }, 1000);
}

function checkMatchUser() {
    if (!isAvailable) {
        userRef.child(FIREBASE_ID).on('child_added', (snapshot1) => {

            if (snapshot1.key == 'matchingID') {
                matchingId = snapshot1.val();
                userRef.child(matchingId).once("value", function (snapshot3) {
                    if (status == 1) {
                        status = 0;
                        opponentId = snapshot3.key;
                        player2Name = snapshot3.val().name;
                        profilePlayer2 = snapshot3.val().image;
                        userId2 = snapshot3.val().userID;
                        isAvailable = false;

                        $('#opp_name').text(player2Name);
                        $('#opp_image').attr("src", profilePlayer2);
                        playQuiz();
                    }
                });
            }
        });
    }
}

function findOnlineUser() {
    startTimer();
    userRef.once("value", function (users) {
        if (users.val() != null) {
            users.forEach(function (snapshot) {
                if (snapshot.key != FIREBASE_ID && snapshot.val().langId == LANG_ID && snapshot.val().cateId == CATE_ID) {
                    if (snapshot.val().isAvail != null && snapshot.val().isAvail == '1') {
                        opponentId = snapshot.key;
                        player2Name = snapshot.val().name;
                        profilePlayer2 = snapshot.val().image;
                        userId2 = snapshot.val().userID;
                        matchingId = FIREBASE_ID;
                        isAvailable = true;

                        $('#opp_name').text(player2Name);
                        $('#opp_image').attr("src", profilePlayer2);
                        var dataOpp = {
                            matchingID: matchingId,
                            isAvail: '0',
                            opponentID: matchingId
                        };
                        var dataUser = {
                            matchingID: matchingId,
                            isAvail: '0',
                            opponentID: opponentId
                        };
                        userRef.child(opponentId).update(dataOpp).then(function () {});
                        userRef.child(FIREBASE_ID).update(dataUser).then(function () {});
                        playQuiz();
                    }
                }
            });
        }
    });
}

function playQuiz() {
    if (matchingId) {
        $.redirect('battle-quiz.php', {'match_id': matchingId, 'userId1': userId1, 'opp_id': userId2, 'player1Name': player1Name, 'opp_name': player2Name});
    }
}

