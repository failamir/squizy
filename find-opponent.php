<?php
session_start();
if (!isset($_SESSION['name']) && !isset($_SESSION['email']) && !isset($_SESSION['id'])) {
    header("location:index.php");
    return false;
}
?> 
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Find Opponent</title> 
        <?php include('include-css.php'); ?>
    </head> 

    <body class="bg-content-color"> 

        <?php include('header.php'); ?>  

        <div class="wapper">
            <div class="container container-bg-set top-margin"> 
                <div class="row justify-content-center pb-50" id="categories">

                </div>
                <div class="top-margin" id="find_Opponent" style="display: none">
                    <div class="row text-center justify-content-center top-margin"> 
                        <div class="col-8">
                        <div class="text-center text-bold" id="countdown"></div>
                        <div class="text-center" id="searchtext"></div>
                        </div>
                    </div>    
                    <div class="row justify-content-center text-center"> 
                        <div class="col-md-3 col-10 shadow-box">
                            <div id="curr_user" class="py-4">
                                <img class="findImg" alt="user" src="<?= empty($_SESSION['profile']) ? 'assets/images/user.png' : $_SESSION['profile']; ?>">
                                <p class='pt-4'><?= $_SESSION['name']; ?></p>
                            </div>
                        </div>
                        <div class="col-md-3 col-10 vs_img">
                            <img alt="vs" src="assets/images/vs.png">
                        </div>
                        <div class="col-md-3 col-10 shadow-box">
                            <div id="opp_image" class="py-4">
                                <img class="findImg" alt="find" src="assets/images/user.png" id="opp_image">
                                <p class='pt-4' id="opp_name">Player 2</p>
                            </div>
                        </div>
                    </div>
                    <div class="row mt-2 mb-4 text-white justify-content-center" id="battle_find">
                        <a onclick="findOpponent();" id="find_Opponent" class="btn shadow-box-theme position-box add-cursor">Find a Player</a>
                    </div> 
                </div>

                <div class="row justify-content-center" id="battle_title"></div>

                <div class="row justify-content-center text-center pb-4" >
                    <div class="col-8" id="battle_statistics"></div>
                </div>

            </div>
        </div>

        <?php include('footer.php'); ?> 

        <script src="assets/js/pages/find-opponent.js"></script>
    </body>
</html>