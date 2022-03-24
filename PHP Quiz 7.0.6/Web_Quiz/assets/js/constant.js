"use strict"
const DOMAIN_URL = "https://yourdomain.com/"; //admin panel url
const JWT_KEY = "set_your_strong_jwt_secret_key";

const QUIZ_V = "Quiz(6.0.1)";
const QUIZ_URL = DOMAIN_URL + "api-v2.php";  //api url

const QUESTION_TIME = 25; // set second for each question,
const FOR_CORRECT_ANS = 4; // mark for correct answer
const FOR_INCORRECT_ANS = 2; // minus mark for incorrect

const PASSING_PER = 30; //count level complete when user give >30 percent correct answer
const giveOneCoin = 1;  //give coin when user give 30 to 40 percent correct answer
const giveTwoCoins = 2;  //give coins when user give 40 to 50 percent correct answer
const giveThreeCoins = 3; //give coin when user give 50 to 60 percent correct answer
const giveFourCoins = 4;  //give coin when user give > 60  percent correct answer

//Life Line Coin
const RIGHT_ANS = 2;
const FIFTY_FIFTY = 4;
const AUDIENCE_POLL = 4;
const RESET_TIMER = 2;

const MAX_MINUTES = 60; //max minutes for self challenge quiz
const LIMIT_QUESTION = 5; //min limit question for self challenge

const QUIZ_IMG_WIDTH = '100';
