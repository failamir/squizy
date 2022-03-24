<?php
session_start();

if (isset($_POST['currect_ans']) && isset($_POST['wrong_ans']) && isset($_POST['play_time']) && isset($_POST['challage_time'])) {

    $currect_ans = $_POST['currect_ans'];
    $wrong_ans = $_POST['wrong_ans'];
    $play_time1 = $_POST['play_time'];
    $play_time = gmdate("i:s", $play_time1);
    $challage_time = $_POST['challage_time'];

    if ($currect_ans != '' && $wrong_ans != '' && empty($play_time) && empty($challage_time)) {
        header("location:index.php");
    }
} else {
    header("location:index.php");
}
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Self Challenge Result</title>
        <?php include('include-css.php'); ?>
    </head>

    <body class="bg-content-color">

        <?php include('header.php'); ?> 

        <div class="wapper">
            <section>
                <div class="container result-bottom-top-margin">
                    <div class="row shadow-box container-bg-set shadow-box-battle-result">
                        <div class="col-md-12 col-12 col-md-6 text-center sign-in">
                            <h2 class="text-success">CONGRATULATIONS</h2>
                            <h2>You have Completed challenge in <?= $play_time ?>sec</h2>                    
                        </div>                    
                        <div class="d-flex col-md-12">
                            <div class="col-md-3 d-flex justify-content-center pt-50">
                                <em class="fa fa-check-circle text-success wrong_svg">
                                    <span class="text-dark"> <?= htmlspecialchars($currect_ans) ?> </span>
                                </em>
                            </div>

                            <div class="col-md-6 text-center justify-content-center">
                                <div class="m-50 d-flex justify-content-center">
                                    <div id="app" ></div>
                                </div>
                            </div>  
                            <div class="col-md-3 d-flex justify-content-center pt-50">                                
                                <em class="fa fa-times-circle text-danger wrong_svg">
                                    <span class="text-dark"> <?= htmlspecialchars($wrong_ans) ?> </span>
                                </em>                                                        
                            </div>

                        </div>
                        <div class="col-md-12 d-flex justify-content-center pt-2">
                            <h2>Challenge Time <?php echo ($challage_time != 60) ? gmdate('i:s', ($challage_time * 60)) : $challage_time . ':00'; ?></h2>                                      
                        </div>
                    </div>
                </div>
            </section> 
            <section>
                <div class="container mb-4 mt-4">
                    <div class="row">
                        <div class="col-md-4 text-center">
                            <a href="review.php" class="text-decoration-none">
                                <div class="shadow-box-theme add-cursor pt-2 pb-2"> 
                                    <div class="text-center text-uppercase">
                                        Review Answer
                                    </div> 
                                </div> 
                            </a>
                        </div>
                        <div class="col-md-4 text-center">
                            <?php if (isset($_SESSION['name']) && isset($_SESSION['email'])) { ?>
                                <a class="text-decoration-none" href="play-quiz.php">                   
                                <?php } else { ?>                         
                                    <a href="javascript:void(0)" class="text-decoration-none add-cursor btn-modal" data-toggle="modal" data-target="#myModal" data-tab="login">
                                    <?php } ?>                            
                                    <div class="shadow-box-theme add-cursor pt-2 pb-2"> 
                                        <div class="text-center text-uppercase">Play Quiz</div> 
                                    </div> 
                                </a>
                        </div>   
                        <div class="col-md-4 text-center">
                            <?php if (isset($_SESSION['name']) && isset($_SESSION['email'])) { ?>
                                <a class="text-decoration-none" href="find-opponent.php">                   
                                <?php } else { ?>                         
                                    <a href="javascript:void(0)" class="text-decoration-none add-cursor btn-modal" data-toggle="modal" data-target="#myModal" data-tab="login">
                                    <?php } ?>  
                                    <div class="shadow-box-theme add-cursor pt-2 pb-2"> 
                                        <div class="text-center text-uppercase">
                                            Battle Quiz
                                        </div> 
                                    </div> 
                                </a>
                        </div>                            
                    </div>
                </div>
            </section>
        </div>

        <?php include('footer.php'); ?>

        <script type="text/javascript">
            window.exit = false;
            window.time = "<?= $play_time1 ?>";
            window.limit = "<?= $challage_time ?>";
        </script>

        <script src="assets/js/pages/self-challenge-result.js"></script>
    </body>
</html>

