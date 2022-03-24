<?php
session_start();
if (!isset($_POST['contest_id']) && !isset($_SESSION['name']) && !isset($_SESSION['email']) && !isset($_SESSION['id'])) {
    header("location:index.php");
    return false;
}
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Leaderboard</title>
        <?php include('include-css.php'); ?>
    </head>

    <body class="bg-content-color">
        <?php include('header.php'); ?> 

        <div class="wapper">
            <div class="container-bg-set container top-margin">
                <div class="shadow-box quizing justify-content-center top-margin">
                    <div class="row"> 
                        <div class="col-md-9">
                            <h2 id="mydesc">Leaderboard</h2>
                        </div>

                    </div>
                    <div class="table-responsive">
                        <table class="table" id="myTable" aria-describedby="mydesc">
                            <thead>
                                <tr>
                                    <th id="tb_Rank">Rank</th>
                                    <th id="tb_Players">Players</th>
                                    <th id="tb_Score">Score</th>
                                </tr>
                            </thead>
                            <tbody id="tbody-append">

                            </tbody>
                        </table>
                    </div>
                </div> 
            </div> 
        </div>

        <?php include('footer.php'); ?>

        <script>
            window.contest_id = <?= $_POST['contest_id'] ?>;
        </script>

        <script src="assets/js/pages/contest-leaderboard.js"></script>
    </body>
</html>