<?php
session_start();
if (!isset($_SESSION['name']) && !isset($_SESSION['email'])) {
    header("location:index.php");
}
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Profile</title>  
        <?php include('include-css.php'); ?>   
    </head>
    <body class="bg-content-color">
        <?php include('header.php'); ?> 

        <div class="wapper">
            <div class="container container-bg-set">        
                <div class="row  top-margin"> 
                    <div class="card col-md-12 border-theme top-margin mb-4">
                        <form method="POST" id="user_update" class="card-body mt-2">
                            <div class="row">
                                <div class="col-xl-3 col-md-6 text-center">
                                    <div class="file__upload">
                                        <img id="user_profile" class="profile-rounded" src="assets/images/user.png" alt="User">
                                        <div class="camera-icon">
                                            <em class="fa fa-camera"></em>
                                        </div>
                                        <input class="file-upload" id="update-profile" type="file" name="image" accept="image/*"/>
                                    </div>
                                </div>
                                <div class="col-xl-3 col-md-6 pt-4">
                                    <ul class="list-group">
                                        <li class="list-group-item d-flex justify-content-between align-items-center">
                                            Rank
                                            <span class="badge badge-theme badge-pill" id="rank">0</span>
                                        </li>
                                        <li class="list-group-item d-flex justify-content-between align-items-center">
                                            Coins
                                            <span class="badge badge-theme badge-pill" id="coins">0</span>
                                        </li>
                                        <li class="list-group-item d-flex justify-content-between align-items-center">
                                            Score
                                            <span class="badge badge-theme badge-pill" id="score">0</span>
                                        </li>                                                
                                    </ul>
                                </div>
                                <div class="col-xl-3 col-md-6 pt-4">
                                    <ul class="list-group">
                                        <li class="list-group-item d-flex justify-content-between align-items-center">
                                            Attended Questions
                                            <span class="badge badge-theme badge-pill" id="attended_question">0</span>
                                        </li>
                                        <li class="list-group-item d-flex justify-content-between align-items-center">
                                            Correct Answers
                                            <span class="badge badge-success badge-pill" id="correct_answers">0</span>
                                        </li>
                                        <li class="list-group-item d-flex justify-content-between align-items-center">
                                            Incorrect Answers
                                            <span class="badge badge-danger badge-pill" id="incorrect_answers">0</span>
                                        </li>
                                    </ul>
                                </div>
                                <div class="col-xl-3 col-md-6 text-center pt-4" id="stat_graph">
                                    <div class="card pt-2">                                      
                                        <!-- Canvas for Chart.js -->
                                        <canvas id="canvas" height="140"></canvas>                                        
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <input type="hidden" name="access_key" value="6808">
                                <input type="hidden" name="update_profile" value="1">
                                <input type="hidden" id="user_id" name="user_id">
                                <div class="form-group col-md-6">
                                    <label for="name">Name</label>                                   
                                    <input type="text" class="form-control" id="name" name="name">
                                </div>
                                <div class="form-group col-md-6">
                                    <label for="mobile">Mobile</label>
                                    <input type="text" class="form-control" minlength="6" maxlength="15" id="mobile" name="mobile" <?= ($_SESSION['type'] == 'mobile') ? 'readonly' : '' ?>>
                                </div>
                                <div class="form-group col-md-12">
                                    <label for="email">Email</label>
                                    <input type="email" class="form-control" id="email" name="email" <?= ($_SESSION['type'] != 'mobile') ? 'readonly' : '' ?>>
                                </div>
                                <div class="form-group col-md-4">
                                    <button type="submit" id="submit_btn" class="btn btn-theme">Update</button>
                                </div>
                                <div class="form-group col-md-8">
                                    <button id="result" class="btn btn-theme" style="display: none;" disabled></button>
                                </div>
                            </div>
                        </form>                

                    </div>

                </div>
            </div> 
        </div>

        <?php include('footer.php'); ?>

        <script src='https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.0/Chart.js'></script>

        <script src="assets/js/pages/profile.js"></script>

    </body>
</html>