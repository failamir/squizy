"use strict"

$(document).ready(function () {
    get_categories();
});

function get_categories() {
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
    if (language_id == '0') {
        html += '<div class="col-md-12">';
        html += '<h2 class="text-uppercase">' + CATEGORY_TITLE + '</h2>';
        html += '</div>';
    } else {
        html += '<div class="col-md-9">';
        html += '<h2 class="text-uppercase">' + CATEGORY_TITLE + '</h2>';
        html += '</div>';
        html += '<div class="col-md-3">';
        html += '<div class="form-group">';
        html += '<select class="form-control" id="change_language" name="change_language"></select>';
        html += '</div>';
        html += '</div>';
    }
    html += '</div>';
    html += '</div>';
    if (result['error'] == TRUE) {
        html += '<div class="col-md-3 col-sm-6"><div class="shadow-box-category wow zoomIn"><div class="text-center text-bold mt-2 mb-4">No categories found!</div></div></div> ';
    } else {
        $.each(result['data'], function (key, val) {
            var IMG = SM_LOGO;
            if (val['image'] != '') {
                IMG = val['image'];
            }
            html += '<div class="col-md-3 col-sm-6 mt-4">';
            if (val['no_of'] == '0') {
                html += '<div class="shadow-box-category limitdata add-cursor wow zoomIn" data-maincat="' + val['category_name'] + '">';
                html += '<img src="' + IMG + '" class="category-image rounded mt-4">';
                html += '<div class="text-center text-bold py-4" value=' + val['id'] + ' data-noofque="' + val['no_of_que'] + '" data-forward="' + val['no_of'] + '" data-level=' + val['maxlevel'] + ' >' + val['category_name'] + '</div></div>';
            } else {
                html += '<div class="shadow-box-category get_subcategories add-cursor wow zoomIn" data-maincat="' + val['category_name'] + '">';
                html += '<img src="' + IMG + '" class="category-image rounded mt-4">';
                html += '<div class="text-center text-bold py-4" value=' + val['id'] + ' data-noofque="' + val['no_of_que'] + '" data-forward="' + val['no_of'] + '" >' + val['category_name'] + '</div></div>';
            }
            html += '</div>';
        });
    }
    $("#categories").html(html);
    get_languages();
}

function get_languages() {
    var data = {'get_languages': '1'};
    var result = get_apis_data(data);
    var html1 = "";
    if (result['error'] == FALSE) {
        $.each(result['data'], function (key, val) {
            if (language_id == val['id']) {
                html1 += '<option value=' + val['id'] + ' selected>' + val['language'] + '</option>';
            } else {
                html1 += '<option value=' + val['id'] + '>' + val['language'] + '</option>';
            }
        });
    }
    $("#change_language").html(html1);
}


$(document).ajaxStop($.unblockUI);

$(document).on('change', '#change_language', function (e) {
    var lan = $(this).val();
    var data = {'get_languages': '1', 'id': lan};
    var result = get_apis_data(data);
    if (result['error'] == FALSE) {
        var langName = result['data'][0]['language'];
        window.location = 'languages.php?id=' + lan + '&language=' + langName + '&rUrl=self-challenge.php';
    }
});

$(document).on('click', '.get_subcategories', function () {
    var cat_id = $(this).children("div").attr('value');
    var no_of = $(this).children("div").attr('data-forward');
    var que_no = $(this).children("div").attr('data-noofque');
    var cat_name = $(this).attr('data-maincat');
    $.blockUI({
        css: {
            color: '#fff',
            border: 'none',
            backgroundColor: 'transparent',
        },
        message: '<h1><img src="' + LOADER_LOGO + '" width="100" /></h1>'});
    if (parseFloat(no_of) != 0) {
        var data = {'get_subcategory_by_maincategory': '1', 'main_id': cat_id};
        var result = get_apis_data(data);
        var html = "";
        if (result['error'] == FALSE) {
            $('#categories').html('');
            html = '<div class="col-md-12 top-margin text-center mb-4">';
            html += '<h2 class="text-uppercase mb-4">' + SUBCATEGORY_TITLE + '</h2>';
            html += '<nav><ol class="breadcrumb">';
            html += '<li class="breadcrumb-item"><a href="javascript:void(0)" onclick="get_categories();">' + CATEGORY_TITLE + '</a></li>';
            html += '<li class="breadcrumb-item"><a href="javascript:void(0)">' + cat_name + '</a></li>';
            html += '</ol></nav>';
            html += '</div>';
            $.each(result['data'], function (key, val) {
                html += '<div class="col-md-3 col-sm-6">';
                html += '<div class="shadow-box-category add-cursor limitdata pt-3 pb-3" data-subcat="' + val['subcategory_name'] + '">';
                html += '<div value=' + cat_id + ' data-sub=' + val['id'] + ' data-noofque="' + val['no_of'] + '" data-forward="' + val['no_of'] + '" >' + val['subcategory_name'] + '</div> ';
                html += '</div>';
                html += '</div>';
            });
            $('#categories').html(html);
            $('.breadcrumb-item a').css('color', 'white');
        } else {
            no_question_alert();
        }
    } else {
        no_question_alert();
    }
    $.unblockUI();
});

$(document).on('click', '.get_subcategories1', function () {
    var cat_id = $(this).children("a").attr('value');
    var no_of = $(this).children("a").attr('data-forward');
    var que_no = $(this).children("a").attr('data-noofque');
    var cat_name = $(this).children("a").attr('data-maincat');

    $.blockUI({
        css: {
            color: '#fff',
            border: 'none',
            backgroundColor: 'transparent',
        },
        message: '<h1><img src="' + LOADER_LOGO + '" width="100" /></h1>'});
    if (no_of != '0') {
        var data = {'get_subcategory_by_maincategory': '1', 'main_id': cat_id};
        var result = get_apis_data(data);
        var html = "";
        if (result['error'] == FALSE) {
            $('#categories').html('');
            html = '<div class="col-md-12 top-margin text-center mb-4">';
            html += '<h2 class="text-uppercase mb-4">' + SUBCATEGORY_TITLE + '</h2>';
            html += '<nav><ol class="breadcrumb">';
            html += '<li class="breadcrumb-item"><a href="javascript:void(0)" onclick="get_categories();">' + CATEGORY_TITLE + '</a></li>';
            html += '<li class="breadcrumb-item"><a href="javascript:void(0)">' + cat_name + '</a></li>';
            html += '</ol></nav>';
            html += '</div>';
            $.each(result['data'], function (key, val) {
                html += '<div class="col-md-3 col-sm-6">';
                html += '<div class="shadow-box-category add-cursor limitdata pt-3 pb-3" data-subcat="' + val['subcategory_name'] + '">';
                html += '<div value=' + cat_id + ' data-sub=' + val['id'] + ' data-noofque="' + val['no_of'] + '" data-forward="' + val['no_of'] + '" >' + val['subcategory_name'] + '</div> ';
                html += '</div>';
                html += '</div>';
            });
            $('#categories').html(html);
            $('.breadcrumb-item a').css('color', 'white');
        } else {
            no_question_alert();
        }
    } else {
        no_question_alert();
        $.unblockUI();
    }
});

$(document).on('click', '.limitdata', function () {
    var no_of = $(this).children("div").attr('data-forward');
    var sub_id = $(this).children("div").attr('data-sub');
    var cat_id = $(this).children("div").attr('value');
    var sub_name = $(this).attr('data-subcat');
    var que_no = $(this).children("div").attr('data-noofque');

    if (sub_id == undefined) {
        sub_id = 0;
    }
    var temp = fetch_questions_category(cat_id);
    var cat_name = temp['data']['category_name'];
    $.blockUI({
        css: {
            color: '#fff',
            border: 'none',
            backgroundColor: 'transparent',
        },
        message: '<h1><img src="' + LOADER_LOGO + '" width="100" /></h1>'
    });
    if (parseInt(no_of) != 0 && parseInt(que_no) >= LIMIT_QUESTION) {
        var html = '<div class="col-md-12 top-margin text-center mb-4">';
        html += '<nav><ol class="breadcrumb"> ';
        html += '<li class="breadcrumb-item"><a href="javascript:void(0)" onclick="get_categories();">' + CATEGORY_TITLE + '</a></li>';
        html += '<li class="breadcrumb-item get_subcategories1 add-cursor"><a value=' + cat_id + ' data-noofque="' + que_no + '"  data-forward="' + no_of + '" data-maincat="' + cat_name + '">' + cat_name + '</a></li>';
        html += '<li class="breadcrumb-item"><a href="javascript:void(0)">' + sub_name + '</a></li>';
        html += '</ol></nav>';
        html += '</div>';

        html += get_list(no_of);

        html += '<div class="col-md-12"><br/>';
        html += '<div class="shadow-box-category theme-gradient text-white add-cursor subcategories pt-2 pb-2">';
        html += '<div class="text-center text-uppercase" data-cat=' + cat_id + ' data-sub=' + sub_id + ' data-subname="' + sub_name + '" data-noque="" data-timelimit="" id="qdata">' + LETS_START + '</div> ';
        html += '</div></div>';

        $('#categories').html(html);
        $('.breadcrumb-item a').css('color', 'white');
    } else if (parseInt(no_of) == 0 && parseInt(que_no) >= LIMIT_QUESTION) {
        var html = '<div class="col-md-12 top-margin text-center mb-4">';
        html += '<nav> <ol class="breadcrumb"> ';
        html += '<li class="breadcrumb-item"><a href="javascript:void(0)" onclick="get_categories();">Categories</a></li>';
        html += '<li class="breadcrumb-item"><a href="javascript:void(0)">' + cat_name + '</a></li>';
        html += '</ol></nav>';
        html += '</div>';

        html += get_list(que_no);

        html += '<div class="col-md-12"><br/>';
        html += '<div class="shadow-box-category theme-gradient text-white add-cursor subcategories pt-2 pb-2">';
        html += '<div class="text-center text-uppercase" data-cat=' + cat_id + ' data-sub=' + sub_id + ' data-noque="" data-timelimit="" id="qdata">' + LETS_START + '</div>';
        html += '</div></div>';

        $('#categories').html(html);
        $('.breadcrumb-item a').css('color', 'white');
    } else {
        no_question_alert();
    }
    $.unblockUI();
});

function get_list(no_of) {
    var html = '<div class="col-md-12 mt-2 mb-2 text-white">';
    html += '<div class="text-center text-uppercase theme-gradient py-2">';
    html += '<strong>' + SELECT_ON_OF_QUE + '</strong>';
    html += '</div></div>';

    html += '<div class="col-md-12 btn-group activebtn">';
    for (var i = 5; i <= no_of; i += 5) {
        html += '<button type="button" class="col-md-2 col-sm-6 btn btn-default shadow-box-self" id="queno' + i + '">' + i + '</button>';
    }
    html += '</div>';

    html += '<div class="col-md-12 mt-2 mb-2 text-white">';
    html += '<div class="text-center text-uppercase theme-gradient py-2">';
    html += '<strong>' + SELECT_TIME_OF_MINUTES + '</strong>';
    html += '</div></div>';

    html += '<div class="col-md-12 btn-group1 activebtn">';
    for (var j = 3; j <= MAX_MINUTES; j += 3) {
        html += '<button type="button" class="col-md-2 col-sm-6 btn btn-default shadow-box-self" id="timelimit' + j + '">' + j + '</button>';
    }
    html += '</div>';
    return html;
}

$(document).on('click', '.btn-group button', function () {
    $(this).siblings().removeClass('active');
    $(this).addClass('active');
    $('#qdata').attr("data-noque", $(this).text());
});

$(document).on('click', '.btn-group1 button', function () {
    $(this).siblings().removeClass('active');
    $(this).addClass('active');
    $('#qdata').attr("data-timelimit", $(this).text());
});

$(document).on('click', '.subcategories', function () {
    var sub_id = $(this).children("div").attr('data-sub');
    var cat_id = $(this).children("div").attr('data-cat');
    var noque = $(this).children("div").attr('data-noque');
    var timelimit = $(this).children("div").attr('data-timelimit');
    var subname = $(this).children("div").attr('data-subname');
    if (subname == undefined) {
        subname = "";
    }
    if (noque == '') {
        swal({
            title: "Please select questions",
            icon: "warning",
            type: "warning",
        }).then(function () {
        });
    } else if (timelimit == '') {
        swal({
            title: "Please select minutes",
            icon: "warning",
            type: "warning",
        }).then(function () {
        });
    } else {
        $.redirect('self-challenge-quiz.php', {'category_id': cat_id, 'subcategory_id': sub_id, 'limit': noque, 'time': timelimit, 'subcategory_name': subname});
    }
    $.unblockUI();

});
        