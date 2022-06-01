"use strict"

var TIME_LIMIT = window.limit;
var timeLeft = window.time;
$(document).ready(function () {
    var remainingPathColor = timeLeft;
    document.getElementById("app").innerHTML = `
        <div class="base-timer">
          <svg class="base-timer__svg" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
            <g class="base-timer__circle">
              <circle class="base-timer__path-elapsed" style="stroke-width: 8px;" cx="50" cy="50" r="45"></circle>
              <path
                id="base-timer-path-remaining"
                stroke-dasharray="283"
                class="base-timer__path-remaining ${remainingPathColor}"
                d=" M 50, 50 m -45, 0 a 45,45 0 1,0 90,0 a 45,45 0 1,0 -90,0 "></path>
            </g>
          </svg>
          <span id="base-timer-label" class="base-timer__label">${formatTime(timeLeft)}</span>
        </div> `;
    setCircleDasharray();
    setRemainingPathColor(timeLeft);
    $('.base-timer').css('width', '60px');
    $('.base-timer').css('height', '60px');
    $('.base-timer__label').css('width', '60px');
    $('.base-timer__label').css('height', '60px');
});

// timer code
const FULL_DASH_ARRAY = 283; //283
const ALERT_THRESHOLD = 10;

const COLOR_CODES = {
    info: {
        color: "red"
    },
    alert: {
        color: "red",
        threshold: ALERT_THRESHOLD
    }
};

function formatTime(time) {
    const minutes = Math.floor(time / 60);
    let seconds = time % 60;

    if (seconds < 10) {
        seconds = `0${seconds}`;
    }

    return `${minutes}:${seconds}`;
}

function setRemainingPathColor(timeLeft) {
    const {alert, info} = COLOR_CODES;
    if (timeLeft <= alert.threshold) {
        document.getElementById("base-timer-path-remaining").classList.add(alert.color);
    }
}

const countSeconds = (str) => {
    const [hh = '0', mm = '0', ss = '0'] = (str || '0:0:0').split(':');
    const hour = parseInt(hh, 10) || 0;
    const minute = parseInt(mm, 10) || 0;
    const second = parseInt(ss, 10) || 0;
    return (hour * 3600) + (minute * 60) + (second);
};

function setCircleDasharray() {
    var minutes1 = Math.floor(countSeconds(TIME_LIMIT) / 60);
    const rawTimeFraction = timeLeft / minutes1;
    rawTimeFraction - (1 / TIME_LIMIT) * (1 - rawTimeFraction);
    const circleDasharray = `${(rawTimeFraction * FULL_DASH_ARRAY).toFixed(0)} 283`;
    $('.base-timer__path-remaining').css('stroke-width', '8px');
    document.getElementById("base-timer-path-remaining").setAttribute("color", '#39819C');
    document.getElementById("base-timer-path-remaining").setAttribute("stroke-dasharray", circleDasharray);
}


function playAgain() {
    $.redirect('quizing.php', {'subcategory_id': window.sub_id, 'level': window.level, 'category_id': window.category_id, 'subcategory_name': window.sub_name});
}
    