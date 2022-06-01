
"use strict"

$(document).ready(function () {
    var temp = get_details(user_id);
    var refer_code = temp['data']['refer_code'];
    $('#refer_code').text(refer_code);
    $('#code-text').val(refer_code);

    var web_url = window.location.protocol + '://' + window.location.hostname;

    window.text = 'I have earned coins using quiz. you can also earn coin by join the quiz from below link and enter referral code while login- "' + refer_code + '"\n' + web_url + ' ';
});

$(document).on("click", '#web', function () {
    var sMsg = encodeURIComponent(window.text);
    var whatsapp_url = "https://api.whatsapp.com/send?text=" + sMsg;
    window.open(whatsapp_url, "_blank");
});

$(document).on("click", '#mobile', function () {
    var sMsg = encodeURIComponent(window.text);
    var whatsapp_url = "https://api.whatsapp.com/send?text=" + sMsg;
    window.open(whatsapp_url, "_blank");
});

$(document).on("click", '#facebook', function () {
    var sMsg = encodeURIComponent(window.text);
    var whatsapp_url = "https://www.facebook.com/sharer/sharer.php?text=" + sMsg;
    window.open(whatsapp_url, "_blank");
});

$(document).on("click", '#instagram', function () {
    var sMsg = encodeURIComponent(window.text);
    var whatsapp_url = "https://www.instagram.com?text=" + sMsg;
    window.open(whatsapp_url, "_blank");
});

function copyCode() {
    var str = document.getElementById("code-text");
    str.removeAttribute("style");
    str.focus();
    str.select();
    document.execCommand('copy');
    str.setAttribute("style", "display:none");
    $('#toastmsg').text("Referral code copied");

    setTimeout(function () {
        $('#toastmsg').html("");
    }, 4000);

}

