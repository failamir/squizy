"use strict"

var todayTime = new Date();
var DateTime = todayTime.toLocaleString("en-US", {timeZone: SYSTEM_TIMEZONE}); // m/d/yyyy format
var month = String(todayTime.getMonth() + 1);
var day = String(todayTime.getDate());
var year = String(todayTime.getFullYear());
var Todate = year + '-' + month + '-' + day;

var Tbody = $('#myTable').DataTable({
    dom: 'lBfrtip',
    "searching": false,
    "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
});

$(document).ready(function () {
    var data = {'get_datewise_leaderboard': '1', 'from': Todate, 'to': Todate};
    var result = get_apis_data(data);
    if (result['error'] == FALSE) {
        $.each(result['data'], function (key, val) {
            Tbody.row.add([val['user_rank'], val['name'], val['score']]).draw();
        });
    } else {
        Tbody.row.add(['', result['message'], '']).draw();
    }
});

$('#sort_leaderbord').on('change', function (e) {
    var data = '';
    var result = '';
    var leaderboard = $(this).val();
    if (leaderboard == 'monthly') {
        data = {'get_monthly_leaderboard': '1', 'date': Todate};
        result = get_apis_data(data);
    } else if (leaderboard == 'daily') {
        data = {'get_datewise_leaderboard': '1', 'from': Todate, 'to': Todate};
        result = get_apis_data(data);
    } else if (leaderboard == 'all') {
        data = {'get_global_leaderboard': '1'};
        result = get_apis_data(data);
    }
    Tbody.clear();
    if (result['error'] == FALSE) {
        $.each(result['data'], function (key, val) {
            Tbody.row.add([val['user_rank'], val['name'], val['score']]).draw();
        });
    } else {
        Tbody.row.add(['', result['message'], '']).draw();
    }

});