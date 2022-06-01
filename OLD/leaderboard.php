<?php
session_start();
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
                <div class="shadow-box quizing justify-content-center top-margin pb-2">
                    <div class="row"> 
                        <div class="col-md-9">
                            <h2 id="mydesc">Leaderboard</h2>
                        </div>
                        <div class="col-md-3">
                            <div class="form-group">
                                <label for="sort_leaderbord">Sort Leaderboard</label>
                                <select class="form-control" id="sort_leaderbord" name="sort_leaderbord">
                                     <option value="daily" selected>Daily</option>
                                     <option value="monthly">Monthly</option>
                                    <option value="all" >All</option> 
                                </select>
                            </div>
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

        <script src="assets/js/pages/leaderboard.js"></script>
    </body>
</html>