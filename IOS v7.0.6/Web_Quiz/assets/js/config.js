"use strict"
var data = {get_firebase_settings: '1'};
var res = get_apis_data(data);
var apiKey = '';
var authDomain = '';
var databaseURL = '';
var projectId = '';
var storageBucket = '';
var messagingSenderId = '';
var appId = '';
var ClientIdGoogle = '';
var AppIdFb = '';

if (res['error'] == FALSE) {
    apiKey = res['data']['apiKey'];
    authDomain = res['data']['authDomain'];
    databaseURL = res['data']['databaseURL'];
    projectId = res['data']['projectId'];
    storageBucket = res['data']['storageBucket'];
    messagingSenderId = res['data']['messagingSenderId'];
    appId = res['data']['appId'];
    ClientIdGoogle = res['data']['client_id_google'];
    AppIdFb = res['data']['app_id_fb'];
}
// Setting for FCM 
var config = {
    apiKey: apiKey, //paste your web api key here
    authDomain: authDomain, //only change you project id in this URL, For Example "YOURPROJECTID.firebaseapp.com"
    databaseURL: databaseURL, //only change you project id in this URL, For Example "https://YOURPROJECTID.firebaseio.com"
    projectId: projectId, //paste your project id here
    storageBucket: storageBucket, //only change you project id in this URL, For Example "YOURPROJECTID.appspot.com"
    messagingSenderId: messagingSenderId, //paste your sender id here
    appId: appId
};

firebase.initializeApp(config);
var Auth = firebase.auth();
var dbRef = firebase.database();
// Setting for Google Login 
var client_id_google = ClientIdGoogle; //paste your google client id here

// Setting for Facebook Login 
var app_id_fb = AppIdFb; //paste your facebook app id here
