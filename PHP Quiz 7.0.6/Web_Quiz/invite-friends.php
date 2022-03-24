<?php
session_start();
if (!isset($_SESSION['name']) && !isset($_SESSION['email'])) {
    header("location:index.php");
}
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Invite Friend</title>  
        <?php include('include-css.php'); ?> 
    </head>
    <body class="bg-content-color">
        <?php include('header.php'); ?>

        <div class="wapper">
            <div id="fb-root"></div>
            <div class="container container-bg-set top-margin"> 
                <div class="row card-body top-margin justify-content-center">               
                    <div class="col-md-4 text-center">
                        <img src="assets/images/invite-friend.png" alt="invite-friend" width="100%">
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12 text-center mt-10  b-4">
                        <p>"Refer your Friends, and you will get 50 coins each time your referral code is used and your friend will get 50 coins by using your referral code"</p>
                        <h5>Your Referral Code</h5><br>
                        <span class="border border-dark p-2" id="refer_code"></span><br>
                        <input type="text" value="" id="code-text" style="display: none;"><br>
                        <a class="" href="javascript:void(0);" onclick="copyCode();">Tap to Copy</a><br/>
                        <label id="toastmsg"></label>
                        <div class="refer-social-link share-section2 pb-4">
                            <h5 class="pb-2">Invite Now</h5>
                            <ul>
                                <li><a id='facebook' href="javascript:void(0);"><em class="fa fa-facebook"></em></a></li>
                                <li><a id="mobile" href="javascript:void(0);" ><em class="fa fa-whatsapp"></em></a></li>
                                <li><a id="web" href="javascript:void(0);" ><em class="fa fa-whatsapp"></em></a></li>
                                <li><a id='instagram' href="javascript:void(0);"><em class="fa fa-instagram"></em></a></li>
                            </ul>
                        </div>
                    </div>
                </div>            
            </div>    
        </div>


        <?php include('footer.php'); ?>

        <script src="assets/js/pages/invite-friends.js"></script>
    </body>
</html>