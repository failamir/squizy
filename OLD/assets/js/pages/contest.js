"use strict"

$(document).ready(function () {
    $('.projects_select').click(function () {
        var tab_id = $(this).attr('data-tab');

        $('.projects_select').removeClass('current');
        $('.tab-contest').removeClass('current');

        $(this).addClass('current');
        $("#" + tab_id).addClass('current');
    });

    var data = {'get_contest': '1', 'user_id': user_id};
    var result = get_apis_data(data);
    var html = "";
    if (result) {
        //past tab
        html += '<div id="tab-1" class="tab-contest">';
        html += '<div class="row pt-20 justify-content-center">';
        if (result['past_contest']['error'] == true) {
            html += '<div class="col-md-6 col-sm-12 col-xs-12 pt-20">' + result['past_contest']['message'] + '</div>';
        } else {
            $.each(result['past_contest']['data'], function (key, val) {
                html += '<div class="col-md-6 col-sm-12 col-xs-12">';
                html += '<div class="shadow-box position-box wow zoomIn">';
                html += '<div class="row m-15">';
                html += '<div class="col-md-12 col-sm-12 contest-b">';
                html += '<img src="' + val['image'] + '" class="contest-img rounded"/>';
                html += '<div><b>' + val['name'] + '</b></div>';
                html += '</div>';
                html += '<div class="col-md-6 col-sm-12 mb-2 mt-2">';
                html += '<div><b>Price : </b><a class="view_points add-cursor" data-points=' + JSON.stringify(val['points']) + '>View</a></div>';
                html += '<div><b>Entry fee : </b>' + val['entry'] + ' Coins</div>';
                html += '<div><b>End on : </b>' + val['end_date'] + '</div>';
                html += '</div>';
                html += '<div class="col-md-6 col-sm-12 mb-2 mt-2">';
                html += '<div><b>Participants : </b>' + val['participants'] + '</div>';
                html += '<a data-id="' + val['id'] + '" class="leaderboard_contest btn btn-theme mt-1 add-cursor">Leaderboard</a>';
                html += '</div>';
                html += '<div class="col-md-12 col-sm-12 contest-bt">' + val['description'] + '</div>';
                html += '</div>';
                html += '</div>';
                html += '</div>';
            });
        }
        html += ' </div>';
        html += ' </div>';
        //live tab
        html += '<div id="tab-2" class="tab-contest current">';
        html += '<div class="row pt-20 justify-content-center">';
        if (result['live_contest']['error'] == true) {
            html += '<div class="col-md-6 col-sm-12 col-xs-12 pt-20">' + result['past_contest']['message'] + '</div>';
        } else {
            $.each(result['live_contest']['data'], function (key1, val1) {
                html += '<div class="col-md-6 col-sm-12 col-xs-12">';
                html += '<div class="shadow-box position-box wow zoomIn">';
                html += '<div class="row m-15">';
                html += '<div class="col-md-12 col-sm-12 contest-b">';
                html += '<img src="' + val1['image'] + '" class="contest-img rounded"/>';
                html += '<div><b>' + val1['name'] + '</b></div>';
                html += '</div>';
                html += '<div class="col-md-6 col-sm-12 mb-2 mt-2">';
                html += '<div><b>Price : </b><a class="view_points add-cursor" data-points=' + JSON.stringify(val1['points']) + '>View</a></div>';
                html += '<div><b>Entry fee : </b>' + val1['entry'] + ' Coins</div>';
                html += '<div><b>End on : </b>' + val1['end_date'] + '</div>';
                html += '</div>';
                html += '<div class="col-md-6 col-sm-12 mb-2 mt-2">';
                html += '<div><b>Participants : </b>' + val1['participants'] + '</div>';
                html += '<a data-id="' + val1['id'] + '" data-entry="' + val1['entry'] + '" class="play_contest btn btn-theme mt-1 add-cursor">Play Quiz</a>';
                html += '</div>';
                html += '<div class="col-md-12 col-sm-12 contest-bt">' + val1['description'] + '</div>';
                html += '</div>';
                html += '</div>';
                html += '</div>';
            });
        }
        html += '</div>';
        html += '</div>';
        //upcoming tab
        html += '<div id="tab-3" class="tab-contest">';
        html += '<div class="row pt-20 justify-content-center">';
        if (result['upcoming_contest']['error'] == true) {
            html += '<div class="col-md-6 col-sm-12 col-xs-12 pt-20">' + result['past_contest']['message'] + '</div>';
        } else {
            $.each(result['upcoming_contest']['data'], function (key2, val2) {
                html += '<div class="col-md-6 col-sm-12 col-xs-12">';
                html += '<div class="shadow-box position-box wow zoomIn">';
                html += '<div class="row m-15">';
                html += '<div class="col-md-12 col-sm-12 contest-b">';
                html += '<img src="' + val2['image'] + '" class="contest-img rounded"/>';
                html += '<div><b>' + val2['name'] + '</b></div>';
                html += '</div>';
                html += '<div class="col-md-6 col-sm-12 mb-2 mt-2">';
                html += '<div><b>Price : </b><a class="view_points add-cursor" data-points=' + JSON.stringify(val2['points']) + '>View</a></div>';
                html += '<div><b>Entry fee : </b>' + val2['entry'] + ' Coins</div>';
                html += '<div><b>Start on : </b>' + val2['start_date'] + '</div>';
                html += '</div>';
                html += '<div class="col-md-12 col-sm-12 contest-bt">' + val2['description'] + '</div>';
                html += '</div>';
                html += '</div>';
                html += '</div>';
            });
        }
        html += '</div>';
        html += '</div>';
    }

    $("#contest").html(html);
});

$(document).on('click', '.view_points', function () {
    $('#myPointsModal').modal('show');
    var point = $(this).data('points');
    var html = '<div class="row justify-content-center"><div class="col-6"><b>Top Winner</b></div><div class="col-6"><b>Coins</b></div></div>';
    $.each(point, function (key, val) {
        html += '<div class="row justify-content-center"><div class="col-6">' + val['top_winner'] + '</div><div class="col-6">' + val['points'] + '</div></div>';
    });
    $('#contestPoint').html(html);
});

$(document).on('click', '.play_contest', function () {
    var get_coin = get_user_coin_score(user_id);
    var contest_id = $(this).data("id");
    var entry_coin = $(this).data("entry");

    if (get_coin['error'] == "false") {
        var user_coin = get_coin['data']['coins'];
        if (parseInt(user_coin) < parseInt(entry_coin)) {
            no_enought_coin();
        } else {
            set_user_coin_score(user_id, (-entry_coin));    //deduct coin
            $.redirect('contest-quiz.php', {'contest_id': contest_id});
        }
    } else {
        no_enought_coin();
    }
});

$(document).on('click', '.leaderboard_contest', function () {
    var contest_id = $(this).data("id");
    $.redirect('contest-leaderboard.php', {'contest_id': contest_id});
});

function no_enought_coin() {
    swal({
        title: "No Enought Entry Coin",
        icon: "warning",
        type: "warning",
    }).then(function () {
    });
}