<?php
session_start();

if (isset($_POST['score']) && $_POST['max_level'] != '' && isset($_POST['get_coin']) && isset($_POST['ratio']) && isset($_POST['total_question']) && isset($_POST['currect_ans']) && isset($_POST['wrong_ans']) && isset($_POST['user_id']) && isset($_POST['users_coins'])) {

    $type = $_POST['type'];
    if ($type == 'playquiz') {
        if (isset($_POST['category']) && isset($_POST['subcategory']) && isset($_POST['level'])) {
            $level = $_POST['level'];
            $category = $_POST['category'];
            $subcategory = $_POST['subcategory'];

            if (!empty($_POST['subcategory_name'])) {
                $subcategory_name = $_POST['subcategory_name'];
            } else {
                $subcategory_name = "";
            }
        } else {
            header("location:index.php");
        }
    }
    $total_question = $_POST['total_question'];
    $currect_ans = $_POST['currect_ans'];
    $wrong_ans = $_POST['wrong_ans'];
    $user_id = $_POST['user_id'];
    $users_coins = $_POST['users_coins'];
    $ratio = $_POST['ratio'];
    $get_coin = $_POST['get_coin'];

    $score = $_POST['score'];
    $per = $currect_ans * 100 / $total_question;
    $max_level = $_POST['max_level'];

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

                        <?php
                        if ($type == 'playquiz') {
                            if ($ratio < 30) {
                                ?>
                                <h2 class="text-danger">Oops!!</h2>
                                <h3>Level not Completed Play Again</h3>                                      
                                <?php
                            } else {
                                ?>
                                <h2 class="text-success">CONGRATULATIONS!!</h2>
                                <h3>You have Completed The Level</h3>                                      
                                <?php
                            }
                        } else if ($type == 'dailyquiz') {
                            ?>
                            <h2 class="text-success">CONGRATULATIONS!!</h2>
                            <h3>Daily Quiz Completed</h3>
                        <?php } else if ($type == 'truefalsequiz') { ?>
                            <h2 class="text-success">CONGRATULATIONS!!</h2>
                            <h3>True/False Completed</h3>
                        <?php } else if ($type == 'randomquiz') { ?>
                            <h2 class="text-success">CONGRATULATIONS!!</h2>
                            <h3>Random Quiz Completed</h3>
                        <?php } ?>                           
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
                        <h3>Coins: <?= htmlspecialchars($get_coin) ?></h3>                                      
                    </div>
                    <div class="col-md-4 d-flex justify-content-center pt-2">
                        <h3>Total Coins: <?= htmlspecialchars($users_coins) ?></h3>                                      
                    </div>
                </div>
            </div>
            <div class="container container-bg-set mb-4">
                <div class="row justify-content-center">  

                    <div class="col-md-3 text-center">
                        <a href="review.php" class="text-decoration-none">
                            <div class="shadow-box-theme add-cursor pt-2 pb-2"> 
                                <div class="text-center text-uppercase">
                                    Review Answer
                                </div> 
                            </div> 
                        </a>
                    </div>
                    <div class="col-md-3 text-center">
                        <?php if ($type == 'playquiz') { ?>
                            <?php if (($max_level > $level) && $ratio > 30) { ?>
                                <a href="javascript:void(0);" onclick="playNextAgain();" class="text-decoration-none">
                                    <div class="shadow-box-theme add-cursor pt-2 pb-2"> 
                                        <div class="text-center text-uppercase">
                                            Play Next Level
                                        </div> 
                                    </div> 
                                </a>
                            <?php } else { ?>
                                <a href="javascript:void(0);" onclick="playAgain();" class="text-decoration-none">
                                    <div class="shadow-box-theme add-cursor pt-2 pb-2"> 
                                        <div class="text-center text-uppercase">
                                            Play Again
                                        </div> 
                                    </div> 
                                </a>
                            <?php } ?>
                        <?php } else if ($type == 'dailyquiz') { ?>
                            <a href="javascript:void(0);" onclick="dailyAgain();" class="text-decoration-none">
                                <div class="shadow-box-theme add-cursor pt-2 pb-2"> 
                                    <div class="text-center text-uppercase">
                                        Play Again
                                    </div> 
                                </div> 
                            </a>
                        <?php } else if ($type == 'truefalsequiz') { ?>
                            <a href="javascript:void(0);" onclick="PlayTrueFalse();" class="text-decoration-none">
                                <div class="shadow-box-theme add-cursor pt-2 pb-2"> 
                                    <div class="text-center text-uppercase">
                                        Play Again
                                    </div> 
                                </div> 
                            </a>
                        <?php } else if ($type == 'randomquiz') { ?>
                            <a href="javascript:void(0);" onclick="PlayRandomQuiz();" class="text-decoration-none">
                                <div class="shadow-box-theme add-cursor pt-2 pb-2"> 
                                    <div class="text-center text-uppercase">
                                        Play Again
                                    </div> 
                                </div> 
                            </a>
                        <?php } ?>
                    </div>
                </div>
            </div>
        </div>

        <?php include('footer.php'); ?>     

        <script type="text/javascript">
//            window.exit = false;
            per_score = "<?= htmlspecialchars($per) ?>";
            user_id = "<?= htmlspecialchars($user_id) ?>";
            score = "<?= htmlspecialchars($score) ?>";

<?php if ($type == 'playquiz') { ?>
                window.level = "<?= ($level == $max_level) ? '1' : htmlspecialchars($level) ?>";
                window.category_id = "<?= htmlspecialchars($category) ?>";
                window.sub_id = "<?= htmlspecialchars($subcategory) ?>";
                window.sub_name = "<?= htmlspecialchars($subcategory_name) ?>";
                window.max_level = "<?= htmlspecialchars($max_level) ?>";
                window.next_level = "<?= htmlspecialchars($level + 1) ?>";
<?php } ?>
        </script>

        <script src="assets/js/pages/resulting.js"></script>

    </body>
</html>

