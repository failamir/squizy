"use strict"
var Tbody = $('#myTable').DataTable({
    dom: 'lBfrtip',
    "searching": false,
    "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
});

$(document).ready(function () {
    var data = {get_contest_leaderboard: '1', contest_id: contest_id};
    var result = get_apis_data(data);
    if (result['error'] == FALSE) {
        $.each(result['data'], function (key, val) {
            Tbody.row.add([val['user_rank'], val['name'], val['score']]).draw();
        });
    } else {
        Tbody.row.add(['', result['message'], '']).draw();
    }
});
