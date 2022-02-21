<!-- Login / Register Modal -->
<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" data-backdrop="static">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>

            <!-- Nav tabs -->
            <ul class="nav nav-tabs" role="tablist" id="logintTab">
                <li role="presentation">
                    <a href="#login" aria-controls="login" role="tab" data-toggle="tab">Account Login</a>
                </li>
                <li role="presentation">
                    <a href="#register" aria-controls="register" role="tab" data-toggle="tab">Create an Account</a>
                </li>
            </ul>

            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane fade in active show" id="login">
                    <div class="modal-body mt-4">
                        <form data-parsley-validate method="post" id="login_frm">
                            <div class="form-group">
                                <input type="email" class="form-control" id="email" name="email" placeholder="Email">
                            </div>
                            <div class="form-group">
                                <input type="password" class="form-control" id="pass" name="pass" placeholder="Password">
                            </div>
                            <div class="">
                                <label class="text-danger" id="messageLabel"></label>
                            </div>
                            <div class="float-right pb-2">
                                <a href="javascript:void(0);" class="add-cursor" data-toggle="modal" data-target="#myForgetModal">Forgot password?</a>
                            </div>
                            <div class="form-group justify-content-center">
                                <button id="LgUser" class="btn btn-signup form-control" onclick="LoginUser(); return false" aria-label="Log In">Log in</button> 
                            </div>
                            <hr/>
                            <div class="text-center">login with social network</div>
                            <div class="col-12 text-center pb-4 pt-2">
                                <div class="row justify-content-center">
                                    <div class="col-md-4">
                                        <a class="shadow-box-login add-cursor" onclick="checkGoogleLoginState();">
                                            <div class="google"><em class="fa fa-google"></em></div>                                           
                                        </a>  
                                    </div>
                                    <div class="col-md-4">
                                        <a class="shadow-box-login add-cursor" onclick="checkLoginState();">
                                            <div class="facebook"><em class="fa fa-facebook"></em></div>                                           
                                        </a>  
                                    </div>
                                    <div class="col-md-4">
                                        <a class="shadow-box-login add-cursor" onclick="checkWithPhone();">
                                            <div class="phone"><em class="fa fa-phone"></em></div>                                           
                                        </a>  
                                    </div>
                                </div>
                            </div>
                            <div class="text-center">Not a registered ?
                                <a href="#register" class="lgTag" aria-controls="register" role="tab" data-toggle="tab">Sign Up</a>
                            </div>
                        </form>                        
                    </div>
                </div>
                <div role="tabpanel" class="tab-pane fade" id="register">
                    <div class="modal-body mt-4">
                        <form data-parsley-validate method="post">
                            <div class="">
                                <input type="text" class="form-control" name="username" id="username" placeholder="Name">
                                <label class="text-danger mb-0" id="username1"></label>
                            </div>
                            <div class="">
                                <input type="email" class="form-control" id="useremail" name="useremail" placeholder="Email">
                                <label class="text-danger mb-0" id="email1"></label>
                            </div>
                            <div class="">
                                <input type="password" class="form-control" id="userpass" name="userpass" placeholder="Password">
                                <label class="text-danger mb-0" id="password"></label>
                            </div>
                            <div class="">
                                <input type="text" class="form-control" id="refer_code" name="refer_code" placeholder="Referral Code">
                            </div>
                            <div class=""><label class="text-danger" id="messageLabelS"></label></div>
                            <div class="form-group">
                                <button id="URegister" onclick="userRegister(); return false" class="btn btn-signup form-control">Sign Up</button>
                            </div>
                            <hr/>
                            <div class="text-center">login with social network</div>
                            <div class="col-md-12 col-sm-12 col-12 text-center pb-4 pt-2">
                                <div class="row justify-content-center">
                                    <div class="col-md-4">
                                        <a class="shadow-box-login add-cursor" onclick="checkGoogleLoginState();">
                                            <div class="google"><em class="fa fa-google"></em></div>                                           
                                        </a>  
                                    </div>
                                    <div class="col-md-4">
                                        <a class="shadow-box-login add-cursor" onclick="checkLoginState();">
                                            <div class="facebook"><em class="fa fa-facebook"></em></div>                                           
                                        </a>  
                                    </div>
                                    <div class="col-md-4">
                                        <a class="shadow-box-login add-cursor" onclick="checkWithPhone();">
                                            <div class="phone"><em class="fa fa-phone"></em></div>                                           
                                        </a>  
                                    </div>
                                </div>
                            </div>
                            <div class="text-center">Already have an account ?
                                <a href="#login" class="lgTag" aria-controls="login" role="tab" data-toggle="tab">Login</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Forget Password Modal -->
<div class="modal fade" id="myForgetModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" data-backdrop="static">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>

            <!-- Nav tabs -->
            <ul class="nav nav-tabs" role="tablist">
                <li role="presentation">
                    <a href="" aria-controls="login" role="tab" data-toggle="tab">Forgot Password</a>
                </li>
            </ul>

            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane fade in active show" id="login">

                    <div class="modal-body mt-2">
                        <form data-parsley-validate method="post" id="reset_frm1">
                            <div class="form-group">
                                <p>Please enter your email address bellow and we will send you information to recover your account.</p>
                            </div>
                            <div class="form-group">
                                <input type="email" class="form-control" id="emailforget" name="emailforget" placeholder="Email">
                            </div>
                            <div class="form-group">
                                <label class="text-danger" id="messageFLabel"></label>
                            </div>
                            <div class="form-group">
                                <button id="resPassword" onclick="resetPassword(); return false" class="btn btn-signup form-control">Reset Password</button>
                            </div>
                        </form>                        
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Login / Register Phone Modal -->
<div class="modal fade" id="myPhoneModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" data-backdrop="static">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>

            <!-- Nav tabs -->
            <ul class="nav nav-tabs" role="tablist">
                <li role="presentation">
                    <a href="" aria-controls="login" role="tab" data-toggle="tab">Sign In With Phone</a>
                </li>
            </ul>

            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane fade in active show">

                    <div class="modal-body mt-4">
                        <form data-parsley-validate method="post" id="phone_frm">
                            <div class="form-group">
                                <input type="text" class="form-control" id="Pname" name="Pname" placeholder="Name">
                            </div>   
                            <div class="form-group">
                                <input type="text" class="form-control" id="signin_mobile" name="signin_mobile[main]" placeholder="Phone Nubmer">
                            </div>                            
                            <div class="form-group">
                                <div id="recaptcha-container"></div>                      
                            </div>
                            <div>
                                <label class="text-danger" id="messageLabelP"></label>
                            </div>
                            <div class="form-group row justify-content-center">
                                <div class="col-md-6 mb-2">
                                    <button id="PhoneAuth" onclick="phoneAuth(); return false" class="btn btn-signup form-control">Verify</button>
                                </div>
                                <div class="col-md-6">
                                    <button class="btn btn-signup form-control" data-dismiss="modal" aria-label="Close">Cancel</button>
                                </div>                                    
                            </div>
                        </form>                        
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- OTP Modal -->
<div class="modal fade" id="myOtpModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" data-backdrop="static">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <!-- Nav tabs -->
            <ul class="nav nav-tabs" role="tablist">
                <li role="presentation">
                    <a href="" aria-controls="login" role="tab" data-toggle="tab">Verify Otp</a>
                </li>
            </ul>

            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane fade in active show">
                    <div class="modal-body mt-4">
                        <form data-parsley-validate method="post" id="otp_frm">
                            <div class="form-group">
                                <input type="number" class="form-control" id="digit-code" name="digit-code" placeholder="6-digit Code">
                            </div>
                            <div>
                                <label class="text-danger" id="messageLabelO"></label>
                            </div>
                            <div class="form-group">
                                <button id="CodeVerify" onclick="codeverify(); return false" class="btn btn-signup form-control">Continue</button>
                            </div>
                        </form>                        
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Referral Code Modal -->
<div class="modal fade" id="myReferralModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" data-backdrop="static">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>

            <!-- Nav tabs -->
            <ul class="nav nav-tabs" role="tablist">
                <li role="presentation">
                    <a href="" aria-controls="login" role="tab" data-toggle="tab">Apply Refferal Code</a>
                </li>
            </ul>

            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane fade in active show" id="refferal_code">

                    <div class="modal-body mt-2">
                        <form data-parsley-validate method="post" id="reset_frm">     
                            <input type="hidden" name="login_type" id="login_type" value="">
                            <div class="form-group">
                                <input type="text" class="form-control" id="refferalcode" name="refferalcode" placeholder="Refferal Code" required>
                            </div>
                            <div class="">
                                <label class="text-danger" id="messageRLabel"></label>
                            </div>
                            <div class="form-group row justify-content-center" id="Gmail_Refferal">
                                <div class="col-md-6">
                                    <button id="GmailWCancel" onclick="gmailWithCancel(); return false" class="btn btn-signup form-control">Cancel</button>
                                </div>
                                <div class="col-md-6">
                                    <button id="GmailWCode" onclick="gmailWithReferCode(); return false" class="btn btn-signup form-control">Apply</button>
                                </div>
                            </div>
                            <div class="form-group row justify-content-center" id="Facebook_Refferal">
                                <div class="col-md-6">
                                    <button id="FBWCancel" onclick="fbWithCancel(); return false" class="btn btn-signup form-control">Cancel</button>
                                </div>
                                <div class="col-md-6">
                                    <button id="FBWCode" onclick="fbWithReferCode(); return false" class="btn btn-signup form-control">Apply</button>
                                </div>
                            </div>
                            <div class="form-group row justify-content-center" id="Phone_Refferal">
                                <div class="col-md-6">
                                    <button id="PhoneWCancel" onclick="phoneWithCancel(); return false" class="btn btn-signup form-control">Cancel</button>
                                </div>
                                <div class="col-md-6">
                                    <button id="PhoneWCode" onclick="phoneWithReferCode(); return false" class="btn btn-signup form-control">Apply</button>
                                </div>
                            </div>
                        </form>                        
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>