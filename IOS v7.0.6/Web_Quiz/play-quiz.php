<?php
session_start();
if (!isset($_SESSION['name']) && !isset($_SESSION['email'])) {
    header("location:index.php");
}
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Play Quiz</title>
        <?php include('include-css.php'); ?>   
    </head>

    <body class="bg-content-color">
        <?php include('header.php'); ?>

        <div class="wapper">
            <div class="container container-bg-set">
                <div class="row top-margin mb-40 justify-content-center" id="categories"> 


                </div>
            </div>
        </div>   

        <?php include('footer.php'); ?>

        <script src="assets/js/pages/play-quiz.js"></script>
    </body>
</html>