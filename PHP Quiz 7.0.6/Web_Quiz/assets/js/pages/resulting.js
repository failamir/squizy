"use strict"

$(document).ready(function () {
    $('#score').attr('value', per_score);
    progress_bar();
});

function playAgain() {
    $.redirect('quizing.php', {'subcategory_id': window.sub_id, 'level': window.level,'max_level': max_level, 'category_id': window.category_id, 'subcategory_name': window.sub_name});
}

function dailyAgain() {
    $.redirect('daily-quiz.php');
}

function playNextAgain() {
    $.redirect('quizing.php', {'subcategory_id': window.sub_id, 'level': window.next_level,'max_level': max_level, 'category_id': window.category_id, 'subcategory_name': window.sub_name});
}