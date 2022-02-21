"use strict"

$(document).ready(function () {
    var data = {'get_notifications': '1'};
    var result = get_apis_data(data);
    if (result['error'] == FALSE) {
        var html = "";
        $.each(result['data'], function (key, val) {
            if (key == 0) {
                html += '<div class="set">';
                html += '<a class="active text-center">' + val['title'] + '<em class="fa fa-plus"></em></a>';
                html += '<div class="content" style="display: block;">';
                html += '<div class="row">';
                html += '<div class="col-md-2 col-sm-6 text-center">';
                if (val['image'] != '') {
                    html += '<img src="' + val['image'] + '" width="100%"/>';
                } else {
                    html += '<img src="assets/images/icon.png"/>';
                }
                html += '</div>';
                html += '<div class="col-md-10 col-sm-6">' + val['message'] + '</div>';
                html += '</div>';
                html += '</div>';
                html += '</div>';
            } else {
                html += '<div class="set">';
                html += '<a class="text-center">' + val['title'] + '<em class="fa fa-plus"></em></a>';
                html += '<div class=" content">';
                html += '<div class="row">';
                html += '<div class="col-md-2 col-sm-6 text-center">';
                if (val['image'] != '') {
                    html += '<img src="' + val['image'] + '" width="100%"/>';
                } else {
                    html += '<img src="assets/images/icon.png" width="100%"/>';
                }
                html += '</div>';
                html += '<div class="col-md-10 col-sm-6">' + val['message'] + '</div>';
                html += '</div>';
                html += '</div>';
                html += '</div>';
            }
        });
    } else {
        var html = '<div class="col-md-6 col-sm-6 text-center">' + result['message'] + '</div>';
    }
    $("#notification").html(html);


    $(document).on("click", ".set > a", function () {
        if ($(this).hasClass("active")) {
            $(this).removeClass("active");
            $(this).siblings(".content").slideUp(200);
            $(".set > a em").removeClass("fa-minus").addClass("fa-plus");
        } else {
            $(".set > a em").removeClass("fa-minus").addClass("fa-plus");
            $(this).find("em").removeClass("fa-plus").addClass("fa-minus");
            $(".set > a").removeClass("active");
            $(this).addClass("active");
            $(".content").slideUp(200);
            $(this).siblings(".content").slideDown(200);
        }
    });
});


