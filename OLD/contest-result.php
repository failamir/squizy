<?php
session_start();

if (isset($_POST['score']) && isset($_POST['total_question']) && isset($_POST['currect_ans']) && isset($_POST['wrong_ans']) && isset($_POST['user_id']) && isset($_POST['users_coins'])) {

    $total_question = $_POST['total_question'];
    $currect_ans = $_POST['currect_ans'];
    $wrong_ans = $_POST['wrong_ans'];
    $user_id = $_POST['user_id'];
    $users_coins = $_POST['users_coins'];
    $score = $_POST['score'];
    $per = $currect_ans * 100 / $total_question;
    if (empty($total_question) && $currect_ans == '' && $wrong_ans == '' && $user_id == '' && $users_coins == '') {
        header("location:index.php");
    }
} else {
    header("location:index.php");
}
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Quiz Result</title>
        <?php include('include-css.php'); ?>
    </head>

    <body class="bg-content-color">

        <?php include('header.php'); ?>  

        <div class="wapper">
            <div class="container container-bg-set top-margin">
                <div class="row top-margin justify-content-center shadow-box-battle-result">

                    <div class="col-md-12 col-12 col-md-6 text-center">

                        <h2 class="text-success">CONGRATULATIONS!!</h2>
                        <h3>Contest Completed</h3>                
                    </div>                    
                    <div class="d-flex col-md-12">
                        <div class="col-md-3 d-flex justify-content-center pt-50">  
                            <em class="fa fa-check-circle text-success wrong_svg">
                                <span class="text-dark"> <?= htmlspecialchars($currect_ans) ?> </span>
                            </em>                           
                        </div>
                        <div class="col-md-6 justify-content-center text-center">
                            <div class="progress m-50" id="score" value="0"></div>
                        </div>   
                        <div class="col-md-3 d-flex justify-content-center pt-50">
                            <em class="fa fa-times-circle text-danger wrong_svg">
                                <span class="text-dark"> <?= htmlspecialchars($wrong_ans) ?> </span>
                            </em>                                                        
                        </div>
                    </div>
                    <div class="col-md-4 d-flex justify-content-center pt-2">
                        <h3>Score: <?= htmlspecialchars($score) ?></h3>                                      
                    </div>

                    <div class="col-md-4 d-flex justify-content-center pt-2">
                        <h3>Total Coins: <?= htmlspecialchars($users_coins) ?></h3>                                      
                    </div>
                </div>
            </div>
            <div class="container container-bg-set mb-4">
                <div class="row justify-content-center">  

                    <div class="col-md-3 text-center">
                        <a href="index.php" class="text-decoration-none">
                            <div class="shadow-box-theme add-cursor pt-2 pb-2"> 
                                <div class="text-center text-uppercase">
                                    Home
                                </div> 
                            </div> 
                        </a>
                    </div>
                    <div class="col-md-3 text-center">
                        <a href="play-quiz.php" class="text-decoration-none">
                            <div class="shadow-box-theme add-cursor pt-2 pb-2"> 
                                <div class="text-center text-uppercase">
                                    Play Quiz
                                </div> 
                            </div> 
                        </a>

                    </div>
                </div>
            </div>
        </div>

        <?php include('footer.php'); ?>     

        <script type="text/javascript">
            per_score = "<?= htmlspecialchars($per) ?>";
            user_id = "<?= htmlspecialchars($user_id) ?>";
            score = "<?= htmlspecialchars($score) ?>";
        </script>

        <script src="assets/js/pages/contest-result.js"></script>
    </body>
</html>

