"use strict"
var levelData;

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
        html += '<div class="col-md-3 col-sm-6"><div class="shadow-box-category wow zoomIn"><div class="text-center text-bold mt-2 mb-4">' + result['message'] + '</div></div></div> ';
    } else {
        $.each(result['data'], function (key, val) {
            var IMG = SM_LOGO;
            if (val['image'] != '') {
                IMG = val['image'];
            }
            html += '<div class="col-md-3 col-sm-6 mt-4">';
            if (val['no_of'] == '0' && val['no_of_que'] != '0') {
                html += '<div class="shadow-box-category subcategories add-cursor wow zoomIn" data-maincat="' + val['category_name'] + '">';
                html += '<img src="' + IMG + '" class="category-image rounded mt-4">';
                html += '<div class="text-center text-bold py-4" value=' + val['id'] + ' data-noofque="' + val['no_of_que'] + '"  data-forward="' + val['no_of'] + '" data-level=' + val['maxlevel'] + ' >' + val['category_name'] + '</div></div>';
            } else {
                html += '<div class="shadow-box-category get_subcategories add-cursor wow zoomIn" data-maincat="' + val['category_name'] + '">';
                html += '<img src="' + IMG + '" class="category-image rounded mt-4">';
                html += '<div class="text-center text-bold py-4" value=' + val['id'] + ' data-noofque="' + val['no_of_que'] + '"  data-forward="' + val['no_of'] + '" >' + val['category_name'] + '</div></div>';
            }
            html += '</div>';
        });
    }
    $("#categories").html(html);
    get_languages();
}


function get_languages() {
    var data_param = {'get_languages': '1'};
    var result = get_apis_data(data_param);
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
        window.location = 'languages.php?id=' + lan + '&language=' + langName + '&rUrl=play-quiz.php';
    }
});

$(document).on('click', '.get_subcategories', function () {
    $.blockUI({
        css: {color: '#fff', border: 'none', backgroundColor: 'transparent', },
        message: '<h1><img src="' + LOADER_LOGO + '" width="100" /></h1>'
    });

    var cat_id = $(this).children("div").attr('value');
    var no_of = $(this).children("div").attr('data-forward');
    var no_of_que = $(this).children("div").attr('data-noofque');
    var cat_name = $(this).attr('data-maincat');

    if (no_of != '0') {
        var data = {'get_subcategory_by_maincategory': '1', 'main_id': cat_id};
        var result = get_apis_data(data);

        if (result['error'] == FALSE) {
            $('#categories').html('');
            var html = '<div class="col-md-12 top-margin text-center mb-4"><h2 class="text-uppercase">' + SUBCATEGORY_TITLE + '</h2>';
            html += '<nav> <ol class="breadcrumb"><li class="breadcrumb-item"><a href="javascript:void(0)" onclick="get_categories();">' + CATEGORY_TITLE + '</a></li><li class="breadcrumb-item"><a href="javascript:void(0)">' + cat_name + '</a></li></ol></nav></div>';
            $.each(result['data'], function (key, val) {
                html += '<div class="col-md-3 col-sm-6">';
                html += '<div class="shadow-box-category add-cursor subcategories pt-3 pb-3" data-subcat="' + val['subcategory_name'] + '">';
                html += '<div class="text-center text-uppercase" value=' + cat_id + ' data-sub=' + val['id'] + ' data-level=' + val['maxlevel'] + ' data-que-no="' + no_of_que + '" data-forward="' + no_of + '">' + val['subcategory_name'] + '</div> ';
                html += '</div> </div>';
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

$(document).on('click', '.get_subcategories1', function () {

    $.blockUI({
        css: {color: '#fff', border: 'none', backgroundColor: 'transparent', },
        message: '<h1><img src="' + LOADER_LOGO + '" width="100" /></h1>'
    });

    var cat_id = $(this).children("a").attr('value');
    var no_of = $(this).children("a").attr('data-forward');
    var no_of_que = $(this).children("a").attr('data-que-no');
    var cat_name = $(this).children("a").attr('data-maincat');

    if (no_of != '0') {
        var data = {'get_subcategory_by_maincategory': '1', 'main_id': cat_id};
        var result = get_apis_data(data);
        if (result['error'] == FALSE) {
            $('#categories').html('');
            var html = '<div class="col-md-12 top-margin text-center mb-4"><h2 class="text-uppercase">' + SUBCATEGORY_TITLE + '</h2>';
            html += '<nav> <ol class="breadcrumb"><li class="breadcrumb-item"><a href="javascript:void(0)" onclick="get_categories();">' + CATEGORY_TITLE + '</a></li><li class="breadcrumb-item"><a href="javascript:void(0)">' + cat_name + '</a></li></ol></nav></div>';
            $.each(result['data'], function (key, val) {
                html += '<div class="col-md-3 col-sm-6">';
                html += '<div class="shadow-box-category add-cursor subcategories pt-3 pb-3" data-subcat="' + val['subcategory_name'] + '">';
                html += '<div class="text-center text-uppercase" value=' + cat_id + ' data-sub=' + val['id'] + ' data-level=' + val['maxlevel'] + ' data-que-no="' + no_of_que + '" data-forward="' + no_of + '">' + val['subcategory_name'] + '</div> ';
                html += '</div> </div>';
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

$(document).on('click', '.subcategories', function () {

    $.blockUI({
        css: {color: '#fff', border: 'none', backgroundColor: 'transparent', },
        message: '<h1><img src="' + LOADER_LOGO + '" width="100" /></h1>'
    });

    var no_of = $(this).children("div").attr('data-forward');
    var no_of_que = $(this).children("div").attr('data-que-no');
    var sub_levels = $(this).children("div").attr('data-level');
    var sub_id = $(this).children("div").attr('data-sub');
    var cat_id = $(this).children("div").attr('value');
    var sub_name = $(this).attr('data-subcat');

    if (sub_levels != 0) {
        sub_id = (sub_id == undefined) ? 0 : sub_id;
        no_of = (no_of == undefined) ? '0' : no_of;
        no_of_que = (no_of_que == undefined) ? '0' : no_of_que;

        var Level;
        var levelData;
        Level = fetch_level_data(user_id, cat_id, sub_id);
        levelData = Level['data'].level;

        var temp = fetch_questions_category(cat_id);
        var cat_name = temp['data']['category_name'];

        var html = '<div class="col-md-12 top-margin text-center mb-4">';
        html += '<h2 class="text-uppercase">' + LEVEL_TITLE + '</h2>';
        html += '<nav> <ol class="breadcrumb"> ';
        if (sub_name == undefined) {
            html += '<li class="breadcrumb-item"><a href="play-quiz.php">' + CATEGORY_TITLE + '</a></li>';
            html += '<li class="breadcrumb-item"><a href="play-quiz.php">' + cat_name + '</a></li>';
        } else {
            html += '<li class="breadcrumb-item"><a href="javascript:void(0)" onclick="get_categories();">' + CATEGORY_TITLE + '</a></li>';
            html += '<li class="breadcrumb-item get_subcategories1 add-cursor"><a value=' + cat_id + ' data-que-no="' + no_of_que + '"  data-forward="' + no_of + '" data-maincat="' + cat_name + '">' + cat_name + '</a></li>';
            html += '<li class="breadcrumb-item"><a href="javascript:void(0)">' + sub_name + '</a></li>';

        }
        html += '</ol></nav>';
        html += '</div>';
        sub_name = (sub_name == undefined) ? '' : sub_name;

        for (var i = 1; i <= sub_levels; i++) {
            html += '<div class="col-md-3 col-sm-6">';
            if (levelData >= i) {
                html += '<div class="shadow-box-category levels add-cursor pt-3 pb-1"> ';
                html += '<div class="text-center text-uppercase" value=' + i + ' data-maxlevel=' + sub_levels + ' data-cat=' + cat_id + ' data-sub=' + sub_id + ' data-subname="' + sub_name + '">';
                html += '<i class="fa fa-unlock-alt font-24"></i> <p> Level ' + i + '</p>';
                html += '</div></div>';
            } else {
                html += '<div class="shadow-box-category add-cursor pt-3 pb-1">';
                html += '<div class="text-center text-uppercase" value=' + i + ' data-maxlevel=' + sub_levels + ' data-cat=' + cat_id + ' data-sub=' + sub_id + ' data-subname="' + sub_name + '">';
                html += '<i class="fa fa-lock font-24"></i> <p> Level ' + i + '</p>';
                html += '</div></div>';
            }
            html += '</div>';
        }
        $('#categories').html(html);
        $('.breadcrumb-item a').css('color', 'white');
    } else {
        no_question_alert();
    }
    $.unblockUI();
});

$(document).on('click', '.levels', function () {
    var sub_id = $(this).children("div").attr('data-sub');
    var level_id = $(this).children("div").attr('value');
    var cat_id = $(this).children("div").attr('data-cat');
    var subname = $(this).children("div").attr('data-subname');
    var max_level = $(this).children("div").attr('data-maxlevel');

    var data = {'get_questions_by_level': '1', 'level': level_id};
    if (sub_id != '0') {
        data['subcategory'] = sub_id;
    } else {
        data['category'] = cat_id;
    }
    var result = get_apis_data(data);
    if (result['error'] == FALSE) {        
        $.redirect('quizing.php', {'subcategory_id': sub_id, 'level': level_id, 'max_level': max_level, 'category_id': cat_id, 'subcategory_name': subname});
    } else {
        no_question_alert();
    }
});
        