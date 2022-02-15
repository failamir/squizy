"use strict"

const usersRef = dbRef.ref('user');
const MOBILE = 'mobile';
const EMAIL = 'email';
const GMAIL = 'gmail';
const FACEBOOK = 'fb';
const TimeoutTime = 4000;
const DEACTIVATE_MSG = 'Your account is deactivate';
const ENTER_REFER_CODE = 'Please Enter Code';

const HOME_FILE = 'home.php';
const INDEX_FILE = 'index.php';
const SESSION_FILE = 'session_info.php';


function get_random_number() {
    var val = Math.floor(1000 + Math.random() * 9000);
    return val;
}

function get_refer_code(name) {
    var code = get_random_number();
    var refer = name.replace(" ", ".");
    var refer_code = refer + '' + code;
    return refer_code
}

$(document).ready(function () {
    var input = document.querySelector('#signin_mobile');
    var intl = window.intlTelInput(input, {
        separateDialCode: true,
        preferredCountries: ["in"],
        hiddenInput: "full",
        utilsScript: "assets/js/utils.js",
    });

    input.addEventListener('blur', function () {
        var full_number = intl.getNumber(intlTelInputUtils.numberFormat.E164);
        $("input[name='signin_mobile[full]'").val(full_number);
    });
});


//phone login $ register
function checkWithPhone() {
    $('#myPhoneModal').modal('toggle');
    $('#myPhoneModal').modal('show');
    $('#myModal').modal('hide');
}

function phoneWithReferCode() {
    $('#PhoneWCode').attr('disabled', true);
    if ($('#refferalcode').val() != '') {
        var friends_code = $('#refferalcode').val();
        firebase.auth().onAuthStateChanged(function (user) {
            if (user) {
                var uid = user.uid;
                var displayName = window.name;
                var email = (user.email != null) ? user.email : '';
                var phone = user.phoneNumber.toString();
                var photoURL = '';
                var refer_code = get_refer_code(phone);
                var data = {
                    firebase_id: uid,
                    email: email,
                    name: displayName,
                    profile: photoURL,
                    mobile: phone,
                    refer_code: refer_code,
                    friends_code: friends_code,
                    type: MOBILE,
                    user_signup: '1'
                };
                var result = get_apis_data(data);
                if (result['error'] == FALSE) {
                    var status = result.data.status;
                    var user_id = result.data.user_id;
                    var name = result.data.name;
                    var login_type = result.data.type;
                    var profile = result.data.profile;
                    var mobile = result.data.mobile;
                    var data = {
                        email: email, //get the email from Form
                        name: name, // get firstName
                        type: login_type,
                        profile: profile,
                        user_id: user_id
                    };
                    usersRef.child(user.uid).set(data).then(function () { });
                    if (status == 1) {
                        $.ajax({
                            type: "get",
                            url: SESSION_FILE,
                            dataTpe: 'json',
                            data: 'name=' + name + '&email=' + email + '&user_id=' + user_id + '&mobile=' + encodeURIComponent(mobile) + '&type=' + MOBILE + '&profile=' + profile,
                            //data: {name: name, email: email, user_id: user_id, mobile: encodeURIComponent(mobile), type: MOBILE, profile: profile},
                            success: function (data) {
                                window.location.href = INDEX_FILE;
                            }
                        });
                    } else {
                        $('#messageRLabel').text(DEACTIVATE_MSG);
                        setTimeout(function () {
                            $('#messageRLabel').html("");
                        }, TimeoutTime);
                    }
                } else {
                    $('#messageRLabel').text(result['message']);
                    setTimeout(function () {
                        $('#messageRLabel').html("");
                    }, TimeoutTime);
                }
            }
        });
    } else {
        $('#messageRLabel').text(ENTER_REFER_CODE);
        setTimeout(function () {
            $('#messageRLabel').html("");
            $('#PhoneWCode').attr('disabled', false);
        }, TimeoutTime);
    }
}

function phoneWithCancel() {
    $('#PhoneWCancel').attr('disabled', true);
    firebase.auth().onAuthStateChanged(function (user) {
        if (user) {
            var uid = user.uid;
            var displayName = window.name;
            var email = (user.email != null) ? user.email : '';
            var phone = user.phoneNumber.toString();
            var photoURL = '';
            var refer_code = get_refer_code(phone);

            var data = {
                firebase_id: uid,
                email: email,
                name: displayName,
                profile: photoURL,
                mobile: phone,
                refer_code: refer_code,
                type: MOBILE,
                user_signup: '1',
            };

            var result = get_apis_data(data);

            if (result['error'] == FALSE) {
                var status = result.data.status;
                var user_id = result.data.user_id;
                var name = result.data.name;
                var login_type = result.data.type;
                var profile = result.data.profile;
                var mobile = result.data.mobile;
                var data = {
                    email: email, //get the email from Form
                    name: name, // get firstName
                    type: login_type,
                    profile: profile,
                    user_id: user_id
                };
                usersRef.child(user.uid).set(data).then(function () {
                });
                if (status == 1) {
                    $.ajax({
                        type: "get",
                        url: SESSION_FILE,
                        dataTpe: 'json',
                        data: 'name=' + name + '&email=' + email + '&user_id=' + user_id + '&mobile=' + encodeURIComponent(mobile) + '&type=' + MOBILE + '&profile=' + profile,
                        //data: {'name': name, 'email': email, 'user_id': user_id, 'mobile': mobile, 'type': MOBILE, 'profile': profile},
                        success: function (data) {
                            window.location.href = INDEX_FILE;
                        }
                    });
                } else {
                    $('#messageLabelP').text(DEACTIVATE_MSG);
                    setTimeout(function () {
                        $('#messageLabelP').html("");
                    }, TimeoutTime);
                }
            } else {
                $('#messageLabelP').text(result['message']);
                setTimeout(function () {
                    $('#messageLabelP').html("");
                }, TimeoutTime);
            }
        }
    });
}


function phoneAuth() {
    $('#PhoneAuth').attr('disabled', true);
    var phone_number = $('input[name="signin_mobile[full]"').val();
    window.name = $('#Pname').val();
    if (window.name == '' && phone_number == '') {
        $('#messageLabelP').text("Please enter name or phone number");
        setTimeout(function () {
            $('#PhoneAuth').attr('disabled', false);
            $('#messageLabelP').html("");
        }, 3000);
    } else {
        window.recaptchaVerifier = new firebase.auth.RecaptchaVerifier('recaptcha-container', {
            'size': 'invisible',
            'callback': (response) => {
                // reCAPTCHA solved, allow signInWithPhoneNumber.
                //phoneAuth()
            },
        });

        var appVerifier = window.recaptchaVerifier;
        firebase.auth().signInWithPhoneNumber(phone_number, appVerifier).then(function (confirmationResult) {

            window.confirmationResult = confirmationResult;
//            var coderesult = confirmationResult;
            $('#messageLabelP').text('OTP Sent To Mobile Number');
            setTimeout(function () {
                $('#messageLabelP').html("");
                $('#myPhoneModal').modal('hide');
                $('#myOtpModal').modal('show');
            }, 3000);
        }).catch(function (error) {
            $('#messageLabelP').text(error.message);
            setTimeout(function () {
                $('#messageLabelP').html("");
                window.location.reload();
            }, 3000);
        });
    }
}

function codeverify() {
    $('#CodeVerify').attr('disabled', true);
    var code = $('#digit-code').val();
    if (code != '') {
        window.confirmationResult.confirm(code).then(function (result) {
            var user = result.user;
            var isNewUser = result.additionalUserInfo.isNewUser;
            if (isNewUser) {
                $('#login_type').val('mobile');
                $('#myOtpModal').modal('hide');
                $('#myReferralModal').modal('show');
                $('#Facebook_Refferal').hide();
                $('#Gmail_Refferal').hide();
            } else {
                var displayName = window.name;
                var email = (user.email != null) ? user.email : '';
                var uid = user.uid;
                var phone = user.phoneNumber.toString();
                var photoURL = '';
                var refer_code = get_refer_code(phone);

                var data = {
                    'firebase_id': uid,
                    'email': email,
                    'name': displayName,
                    'profile': photoURL,
                    'mobile': phone,
                    'refer_code': refer_code,
                    'type': MOBILE,
                    'user_signup': '1',
                };
                var result = get_apis_data(data);

                if (result['error'] == FALSE) {
                    var status = result.data.status;
                    var user_id = result.data.user_id;
                    var name = result.data.name;
                    var email = result.data.email;
                    var type = result.data.type;
                    var profile = result.data.profile;
                    var mobile = result.data.mobile;
                    var data = {
                        email: email, //get the email from Form
                        name: name, // get firstName
                        type: type,
                        profile: profile,
                        user_id: user_id
                    };
                    usersRef.child(user.uid).set(data).then(function () { });
                    if (status == 1) {
                        $.ajax({
                            type: "get",
                            url: SESSION_FILE,
                            dataTpe: 'json',
                            data: 'name=' + name + '&email=' + email + '&user_id=' + user_id + '&mobile=' + encodeURIComponent(mobile) + '&type=' + MOBILE + '&profile=' + profile,
                            //data: {'name': name, 'email': email, 'user_id': user_id, 'mobile': mobile, 'type': MOBILE, 'profile': profile},
                            success: function (data) {
                                window.location.href = INDEX_FILE;
                            }
                        });
                    } else {
                        $('#messageLabelO').text(DEACTIVATE_MSG);
                        setTimeout(function () {
                            $('#messageLabelO').html("");
                        }, TimeoutTime);
                    }
                } else {
                    $('#messageLabelO').text(result['message']);
                    setTimeout(function () {
                        $('#messageLabelO').html("");
                    }, TimeoutTime);
                }
            }
        }).catch(function (error) {
            $('#messageLabelO').text(error.message);
            setTimeout(function () {
                $('#messageLabelO').html("");
                $('#CodeVerify').attr('disabled', false);
            }, TimeoutTime);
        });
    } else {
        $('#messageLabelO').text('Please Enter Code');
        setTimeout(function () {
            $('#messageLabelO').html("");
            $('#CodeVerify').attr('disabled', false);
        }, TimeoutTime);
    }

}

// google login & register
function checkGoogleLoginState() {
    var auth = null;
    var provider = new firebase.auth.GoogleAuthProvider();
    provider.setCustomParameters({prompt: 'select_account'});
    provider.addScope('profile');
    provider.addScope('email');
    provider.addScope('https://www.googleapis.com/auth/plus.me');
    firebase.auth().signInWithPopup(provider).then(function (result) {
        var token = result.credential.accessToken; // This gives you a Google Access Token. You can use it to access the Google API.

        var user = result.user; // The signed-in user info.        
        var isNewUser = result.additionalUserInfo.isNewUser; // Check new user.
        if (isNewUser) {
            $('#login_type').val('gmail');
            $('#myReferralModal').modal('show');
            $('#Facebook_Refferal').hide();
            $('#Phone_Refferal').hide();
        } else {
            firebase.auth().onAuthStateChanged(function (user) {
                if (user) {
                    auth = user;
                    var displayName = user.displayName;
                    var email = user.email;
                    var photoURL = user.photoURL;
                    var phone = '';
                    if (user.phoneNumber != null) {
                        phone = user.phoneNumber;
                    }
                    var isAnonymous = user.isAnonymous;
                    var newuser = firebase.auth().currentUser;
                    var uid = user.uid;
                    var refer_code = get_refer_code(displayName);
                    var data = {
                        'firebase_id': uid,
                        'email': email,
                        'name': displayName,
                        'profile': photoURL,
                        'mobile': phone,
                        'refer_code': refer_code,
                        'type': GMAIL,
                        'user_signup': '1'
                    };
                    var result = get_apis_data(data);
                    if (result['error'] == FALSE) {
                        var status = result.data.status;
                        var user_id = result.data.user_id;
                        var name = result.data.name;
                        var email = result.data.email;
                        var type = result.data.type;
                        var profile = result.data.profile;
                        var mobile = result.data.mobile;
                        var data = {
                            email: email, //get the email from Form
                            name: name, // get firstName
                            type: type,
                            profile: profile,
                            user_id: user_id
                        };
                        usersRef.child(user.uid).set(data).then(function () { });
                        if (status == 1) {
                            $.ajax({
                                type: "get",
                                url: SESSION_FILE,
                                dataTpe: 'json',
                                data: 'name=' + name + '&email=' + email + '&user_id=' + user_id + '&mobile=' + mobile + '&type=' + GMAIL + '&profile=' + profile,
                                //data: {name: name, email: email, user_id: user_id, mobile: mobile, type: GMAIL, profile: profile},
                                success: function (data) {
                                    window.location.href = INDEX_FILE;
                                }
                            });
                        } else {
                            $('#messageLabel').text(DEACTIVATE_MSG);
                            setTimeout(function () {
                                $('#messageLabel').html("");
                            }, TimeoutTime);
                        }
                    } else {
                        $('#messageLabel').text(result['message']);
                        setTimeout(function () {
                            $('#messageLabel').html("");
                        }, TimeoutTime);
                    }
                }
            });
        }
    }).catch(function (error) {
        $('#messageLabel').text(error.message);
        setTimeout(function () {
            $('#messageLabel').html("");
        }, TimeoutTime);
    });

}

function gmailWithReferCode() {
    $('#GmailWCode').attr('disabled', true);
    if ($('#refferalcode').val() != '') {
        var friends_code = $('#refferalcode').val();
        var auth = null;
        var provider = new firebase.auth.GoogleAuthProvider();
        provider.addScope('profile');
        provider.addScope('email');
        provider.addScope('https://www.googleapis.com/auth/plus.me');
        firebase.auth().onAuthStateChanged(function (user) {
            if (user) {
                var displayName = user.displayName;
                var email = user.email;
                var phone = '';
                if (user.phoneNumber != null) {
                    phone = user.phoneNumber;
                }
                var photoURL = user.photoURL;
                var isAnonymous = user.isAnonymous;
                var newuser = firebase.auth().currentUser;
                var uid = user.uid;
                var refer_code = get_refer_code(displayName);
                var data = {
                    'firebase_id': uid,
                    'email': email,
                    'name': displayName,
                    'profile': photoURL,
                    'mobile': phone,
                    'refer_code': refer_code,
                    'friends_code': friends_code,
                    'type': 'gmail',
                    'user_signup': '1'
                };
                var result = get_apis_data(data);
                if (result['error'] == FALSE) {
                    var status = result.data.status;
                    var user_id = result.data.user_id;
                    var name = result.data.name;
                    var login_type = result.data.type;
                    var profile = result.data.profile;
                    var mobile = result.data.mobile;
                    var data = {
                        email: email, //get the email from Form
                        name: name, // get firstName
                        type: login_type,
                        profile: profile,
                        user_id: user_id
                    };
                    usersRef.child(user.uid).set(data).then(function () { });
                    if (status == 1) {
                        $.ajax({
                            type: "get",
                            url: SESSION_FILE,
                            dataTpe: 'json',
                            data: 'name=' + name + '&email=' + email + '&user_id=' + user_id + '&mobile=' + mobile + '&type=' + GMAIL + '&profile=' + profile,
                            //data: {name: name, email: email, user_id: user_id, mobile: mobile, type: GMAIL, profile: profile},
                            success: function (data) {
                                window.location.href = INDEX_FILE;
                            }
                        });
                    } else {
                        $('#messageRLabel').text(DEACTIVATE_MSG);
                        setTimeout(function () {
                            $('#messageRLabel').html("");
                        }, TimeoutTime);
                    }
                } else {
                    $('#messageRLabel').text(result['message']);
                    setTimeout(function () {
                        $('#messageRLabel').html("");
                    }, TimeoutTime);
                }
            }
        });
    } else {
        $('#messageRLabel').text(ENTER_REFER_CODE);
        setTimeout(function () {
            $('#messageRLabel').html("");
            $('#GmailWCode').attr('disabled', false);
        }, TimeoutTime);
    }
}

function gmailWithCancel() {
    $('#GmailWCancel').attr('disabled', true);
    var auth = null;
    var provider = new firebase.auth.GoogleAuthProvider();
    provider.addScope('profile');
    provider.addScope('email');
    provider.addScope('https://www.googleapis.com/auth/plus.me');
    firebase.auth().onAuthStateChanged(function (user) {
        if (user) {
            var email = user.email;
            var displayName = user.displayName;
            var phone = '';
            if (user.phoneNumber != null) {
                phone = user.phoneNumber;
            }
            var photoURL = user.photoURL;

            var isAnonymous = user.isAnonymous;
            var newuser = firebase.auth().currentUser;
            var uid = user.uid;
            var refer_code = get_refer_code(displayName);

            var data = {
                firebase_id: uid,
                email: email,
                name: displayName,
                profile: photoURL,
                mobile: phone,
                refer_code: refer_code,
                type: GMAIL,
                user_signup: '1',
            };

            var result = get_apis_data(data);

            if (result['error'] == FALSE) {
                var status = result.data.status;
                var user_id = result.data.user_id;
                var name = result.data.name;
                var login_type = result.data.type;
                var profile = result.data.profile;
                var mobile = result.data.mobile;
                var data = {
                    email: email, //get the email from Form
                    name: name, // get firstName
                    type: login_type,
                    profile: profile,
                    user_id: user_id
                };
                usersRef.child(user.uid).set(data).then(function () { });
                if (status == 1) {
                    $.ajax({
                        type: "get",
                        url: SESSION_FILE,
                        dataTpe: 'json',
                        data: 'name=' + name + '&email=' + email + '&user_id=' + user_id + '&mobile=' + mobile + '&type=' + GMAIL + '&profile=' + profile,
                        //  data: {name: name, email: email, user_id: user_id, mobile: mobile, type: GMAIL, profile: profile},
                        success: function (data) {
                            window.location.href = INDEX_FILE;
                        }
                    });
                } else {
                    $('#messageLabelS').text(DEACTIVATE_MSG);
                    setTimeout(function () {
                        $('#messageLabelS').html("");
                    }, TimeoutTime);
                }
            } else {
                $('#messageLabelS').text(result['message']);
                setTimeout(function () {
                    $('#messageLabelS').html("");
                }, TimeoutTime);
            }
        }
    });
}

// gmail login 
function LoginUser() {
    if ($('#email').val() != '' && $('#pass').val() != '') {
        $('#LgUser').attr('disabled', true);
        var email = $('#email').val();
        var password = $('#pass').val();
        var auth = null;
        firebase.auth().signInWithEmailAndPassword(email, password).then(function (user) {
            firebase.auth().onAuthStateChanged(function (user) {
                usersRef.child(user.uid).once("value", function (snapshot) {
                    if (user) { //login the user

                        if (user.emailVerified) {
                            var refer_code = '';
                            var email = user.email;
                            var displayName = snapshot.val().name;
                            if (snapshot.val().refer_code == '') {
                                refer_code = get_refer_code(displayName);
                            } else {
                                refer_code = snapshot.val().refer_code;
                            }
                            var uid = user.uid;
                            var photoURL = '';
                            var phone = '';
                            var data = {
                                firebase_id: uid,
                                email: email,
                                name: displayName,
                                profile: photoURL,
                                mobile: phone,
                                refer_code: refer_code,
                                type: EMAIL,
                                user_signup: '1',
                            };
                            var result = get_apis_data(data);
                            if (result['error'] == FALSE) {
                                var status = result.data.status;
                                var user_id = result.data.user_id;
                                var name = result.data.name;
                                var email = result.data.email;
                                var profile = result.data.profile;
                                var mobile = result.data.mobile;
                                if (status == 1) {
                                    $.ajax({
                                        type: "get",
                                        url: SESSION_FILE,
                                        dataTpe: 'json',
                                        data: 'name=' + name + '&email=' + email + '&user_id=' + user_id + '&mobile=' + mobile + '&type=' + EMAIL + '&profile=' + profile,
                                        //data: {name: name, email: email, user_id: user_id, mobile: mobile, type: EMAIL, profile: profile},
                                        success: function (data) {
                                            window.location.href = INDEX_FILE;
                                        }
                                    });
                                } else {
                                    $('#messageLabel').text(DEACTIVATE_MSG);
                                    setTimeout(function () {
                                        $('#messageLabel').html("");
                                    }, TimeoutTime);
                                }
                            } else {
                                $('#messageLabel').text(result['message']);
                                setTimeout(function () {
                                    $('#messageLabel').html("");
                                }, TimeoutTime);
                            }
                        } else {
                            $('#messageLabel').text("Please verify your email, that has just been sent to your email account");
                            setTimeout(function () {
                                $('#messageLabel').html("");
                                $('#LgUser').attr('disabled', false);
                            }, TimeoutTime);
                        }
                    }
                });
            });
        }).catch(function (error) {
            $('#messageLabel').text(error.message);
            setTimeout(function () {
                $('#messageLabel').html("");
                $('#LgUser').attr('disabled', true);
            }, TimeoutTime);
        });
    } else {
        $('#messageLabel').text("Please Enter Email or Password");
        setTimeout(function () {
            $('#messageLabel').html("");
        }, TimeoutTime);
    }
}

// gmail register
function userRegister() {

    var name = $('#username').val();
    var email = $('#useremail').val();
    var pass = $('#userpass').val();
    var type = 'email';
    var refer_code = $('#refer_code').val();

    if (refer_code == '') {
        refer_code = get_refer_code(name);
    }

    if (name == "") {
        $('#username1').html('Please enter name!');
        setTimeout(function () {
            $('#username1').html("");
        }, 3000);
    } else if (email == "") {
        $('#email1').html('Please enter email!');
        setTimeout(function () {
            $('#email1').html("");
        }, 3000);
    } else if (pass == "") {
        $('#password').html('Please enter password!');
        setTimeout(function () {
            $('#password').html("");
        }, 3000);
    } else {
        $('#URegister').attr('disabled', true);
        var data = {
            email: email,
            name: name,
            type: type,
            profile: '',
            refer_code: refer_code,
            password: pass
        };
        if (data.email != '' && data.password != '') {
            var auth = null;
//        //create the user
            firebase.auth().createUserWithEmailAndPassword(data.email, data.password).then(function (result) {

                firebase.auth().onAuthStateChanged(function (user) {
                    if (user) {
                        auth = user;
                        //now saving the profile data
                        usersRef.child(user.uid).set(data).then(function () {
                            user.sendEmailVerification();
                        }).catch(function (error) {
                            $('#messageLabelS').text(error);
                            etTimeout(function () {
                                $('#messageLabelS').html("");
                                $('#URegister').attr('disabled', false);
                            }, TimeoutTime);
                        });
                        swal({
                            title: "User Registered successfully",
                            text: "Please Verifiy your email address than login",
                            icon: "success",
                            type: "success",
                        }).then(function () {
                            $.redirect(INDEX_FILE);
                        });
                    }
                });
            }).catch(function (error) {
                $('#messageLabelS').text(error.message);
                setTimeout(function () {
                    $('#messageLabelS').html("");
                    $('#URegister').attr('disabled', false);
                }, TimeoutTime);
            });
        }
    }
}

// forget Password
function resetPassword() {
    $('#resPassword').attr('disabled', true);
    var email = $('#emailforget').val();
    if (email != '') {
        var auth = null;

        firebase.auth().sendPasswordResetEmail(email).then(function () {
            swal({
                title: "Forget Password",
                text: "Email has been sent to you, Please check and verified.",
                icon: "success",
                type: "success",
            }).then(function () {
                $.redirect(INDEX_FILE);
            });
        }).catch(function (error) {
            $('#messageFLabel').text(error.message);
            setTimeout(function () {
                $('#messageFLabel').html("");
                $('#resPassword').attr('disabled', false);
            }, TimeoutTime);
        });
    } else {
        $('#messageFLabel').text("Please Enter your email first!");
        setTimeout(function () {
            $('#messageFLabel').html("");
            $('#resPassword').attr('disabled', false);
        }, TimeoutTime);
    }
}

//facebook
window.fbAsyncInit = function () {
    FB.init({
        appId: app_id_fb,
        cookie: true,
        xfbml: true,
        version: 'v6.0.1'
    });
    FB.AppEvents.logPageView();
};

(function (d, s, id) {
    var js, fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) {
        return;
    }
    js = d.createElement(s);
    js.id = id;
    js.src = "https://connect.facebook.net/en_US/sdk.js";
    fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));

//facebook login & register
function checkLoginState() {
    FB.getLoginStatus(function (response) {
        statusChangeCallback(response);
    });
    var auth = null;
    var provider = new firebase.auth.FacebookAuthProvider();
    provider.setCustomParameters({prompt: 'select_account'});
    provider.addScope('email');
    firebase.auth().signInWithPopup(provider).then(function (result) {
        var user = result.user;
        var isNewUser = result.additionalUserInfo.isNewUser;
        if (isNewUser) {
            $('#login_type').val('facebook');
            $('#myReferralModal').modal('show');
            $('#Gmail_Refferal').hide();
            $('#Phone_Refferal').hide();
        } else {
            firebase.auth().onAuthStateChanged(function (user) {
                if (user) {
                    var displayName = user.displayName;
                    var email = (user.email != null) ? user.email : '';
                    var phone = (user.phoneNumber != null) ? user.phoneNumber : '';
                    var photoURL = user.photoURL;

                    var uid = user.uid;
                    var isAnonymous = user.isAnonymous;
                    var newuser = firebase.auth().currentUser;
                    var refer_code = get_refer_code(displayName);
                    var data = {
                        'firebase_id': uid,
                        'email': email,
                        'name': displayName,
                        'profile': photoURL,
                        'mobile:': phone,
                        'refer_code': refer_code,
                        'type': FACEBOOK,
                        'user_signup': '1',
                    };

                    var result = get_apis_data(data);
                    if (result['error'] == FALSE) {
                        var status = result.data.status;
                        var user_id = result.data.user_id;
                        var name = result.data.name;
                        var email = result.data.email;
                        var login_type = result.data.type;
                        var profile = result.data.profile;
                        var mobile = result.data.mobile;
                        var data = {
                            email: email, //get the email from Form
                            name: name, // get firstName
                            type: login_type,
                            profile: profile,
                            user_id: user_id
                        };
                        usersRef.child(user.uid).set(data).then(function () { })
                        if (status == 1) {
                            $.ajax({
                                type: "get",
                                url: SESSION_FILE,
                                dataTpe: 'json',
                                data: 'name=' + name + '&email=' + email + '&user_id=' + user_id + '&mobile=' + mobile + '&type=' + FACEBOOK + '&profile=' + profile,
                                //data: {name: name, email: email, user_id: user_id, mobile: mobile, type: FACEBOOK, profile: profile},
                                success: function (data) {
                                    window.location.href = INDEX_FILE;
                                }
                            });
                        } else {
                            $('#messageLabel').text(DEACTIVATE_MSG);
                            setTimeout(function () {
                                $('#messageLabel').html("");
                            }, TimeoutTime);
                        }
                    } else {
                        $('#messageLabel').text(result['message']);
                        setTimeout(function () {
                            $('#messageLabel').html("");
                        }, TimeoutTime);
                    }
                }
            });
        }
    }).catch(function (error) {
        $('#messageLabel').text(error.message);
        setTimeout(function () {
            $('#messageLabel').html("");
        }, TimeoutTime);
    });

}

function fbWithReferCode() {
    $('#FBWCode').attr('disabled', true);
    if ($('#refferalcode').val() != '') {
        var friends_code = $('#refferalcode').val();
        var auth = null;
        var provider = new firebase.auth.FacebookAuthProvider();
        provider.addScope('email');
        firebase.auth().onAuthStateChanged(function (user) {
            if (user) {
                var displayName = user.displayName;
                var email = (user.email != null) ? user.email : '';
                var phone = (user.phoneNumber != null) ? user.phoneNumber : '';

                var photoURL = user.photoURL;
                var isAnonymous = user.isAnonymous;
                var newuser = firebase.auth().currentUser;
                var uid = user.uid;
                var refer_code = get_refer_code(displayName);
                var data = {
                    firebase_id: uid,
                    email: email,
                    name: displayName,
                    profile: photoURL,
                    mobile: phone,
                    refer_code: refer_code,
                    friends_code: friends_code,
                    type: FACEBOOK,
                    user_signup: '1'
                };

                var result = get_apis_data(data);
                if (result['error'] == FALSE) {
                    var status = result.data.status;
                    var user_id = result.data.user_id;
                    var name = result.data.name;
                    var login_type = result.data.type;
                    var profile = result.data.profile;
                    var mobile = result.data.mobile;
                    var data = {
                        email: email, //get the email from Form
                        name: name, // get firstName
                        type: login_type,
                        profile: profile,
                        user_id: user_id
                    };
                    usersRef.child(user.uid).set(data).then(function () {})
                    if (status == 1) {
                        $.ajax({
                            type: "get",
                            url: SESSION_FILE,
                            dataTpe: 'json',
                            data: 'name=' + name + '&email=' + email + '&user_id=' + user_id + '&mobile=' + mobile + '&type=' + FACEBOOK + '&profile=' + profile,
                            //data: {name: name, email: email, user_id: user_id, mobile: mobile, type: FACEBOOK, profile: profile},
                            success: function (data) {
                                if (data == 1) {
                                    window.location.href = HOME_FILE;
                                } else {
                                    window.location.href = INDEX_FILE;
                                }
                            }
                        });
                    } else {
                        $('#messageRLabel').text(DEACTIVATE_MSG);
                        setTimeout(function () {
                            $('#messageRLabel').html("");
                        }, TimeoutTime);
                    }
                } else {
                    $('#messageRLabel').text(result['message']);
                    setTimeout(function () {
                        $('#messageRLabel').html("");
                    }, TimeoutTime);
                }
            }
        });
    } else {
        $('#messageRLabel').text(ENTER_REFER_CODE);
        setTimeout(function () {
            $('#messageRLabel').html("");
            $('#FBWCode').attr('disabled', false);
        }, TimeoutTime);
    }
}

function fbWithCancel() {
    $('#FBWCancel').attr('disabled', true);
    var auth = null;
    var provider = new firebase.auth.FacebookAuthProvider();
    provider.addScope('email');
    firebase.auth().onAuthStateChanged(function (user) {
        if (user) {
            var displayName = user.displayName;
            var email = (user.email != null) ? user.email : '';
            var phone = (user.phoneNumber != null) ? user.phoneNumber : '';
            var photoURL = user.photoURL;
            var isAnonymous = user.isAnonymous;
            var newuser = firebase.auth().currentUser;
            var uid = user.uid;
            var refer_code = get_refer_code(displayName);

            var data = {
                'firebase_id': uid,
                'email': email,
                'name': displayName,
                'profile': photoURL,
                'mobile:': phone,
                'refer_code': refer_code,
                'type': FACEBOOK,
                'user_signup': '1',
            };

            var result = get_apis_data(data);
            if (result['error'] == FALSE) {
                var status = result.data.status;
                var user_id = result.data.user_id;
                var name = result.data.name;
                var login_type = result.data.type;
                var profile = result.data.profile;
                var mobile = result.data.mobile;
                var data = {
                    email: email, //get the email from Form
                    name: name, // get firstName
                    type: login_type,
                    profile: profile,
                    user_id: user_id
                };
                usersRef.child(user.uid).set(data).then(function () {})
                if (status == 1) {
                    $.ajax({
                        type: "get",
                        url: SESSION_FILE,
                        dataTpe: 'json',
                        data: 'name=' + name + '&email=' + email + '&user_id=' + user_id + '&mobile=' + mobile + '&type=' + FACEBOOK + '&profile=' + profile,
                        //data: {name: name, email: email, user_id: user_id, mobile: mobile, type: FACEBOOK, profile: profile},
                        success: function (data) {
                            if (data == 1) {
                                window.location.href = HOME_FILE;
                            } else {
                                window.location.href = INDEX_FILE;
                            }
                        }
                    });
                } else {
                    $('#messageRLabel').text(DEACTIVATE_MSG);
                    setTimeout(function () {
                        $('#messageRLabel').html("");
                    }, TimeoutTime);
                }
            } else {
                $('#messageRLabel').text(result['message']);
                setTimeout(function () {
                    $('#messageRLabel').html("");
                }, TimeoutTime);
            }
        }
    });
}

//signOut 
function signOut() {
    firebase.auth().signOut().then(function () {
        window.location.href = 'logout.php';
    }).catch(function (error) {
    });
}
