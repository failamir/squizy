<?php
session_start();
if (!isset($_SESSION['name']) && !isset($_SESSION['email'])) {
    header("location:index.php");
}
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Contest Quiz</title>
        <?php include('include-css.php'); ?>   
    </head>

    <body class="bg-content-color">
        <?php include('header.php'); ?>

        <div class="wapper">
            <div class="container container-bg-set">
                <div class="row top-margin mb-40 justify-content-center"> 
                    <div class="col-md-12 top-margin" >                  
                        <h2 class="text-uppercase">Contest</h2>
                    </div>  

                    <div class="col-md-12 pt-4">
                        <div class="border-contest">
                            <a class="projects_select add-cursor tab-link " data-tab="tab-1">PAST</a>
                            <a class="projects_select add-cursor tab-link current" data-tab="tab-2">LIVE</a>
                            <a class="projects_select add-cursor tab-link" data-tab="tab-3">UPCOMING</a>

                            <div class="text-center" id="contest">                              

                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>   

        <!-- Modal -->
        <div class="modal fade" id="myPointsModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header text-center d-block">
                        <h5 class="modal-title" id="exampleModalLabel">Prize</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body text-center" id="contestPoint">

                    </div>
                    
                </div>
            </div>
        </div>

        <?php include('footer.php'); ?>

        <script src="assets/js/pages/contest.js"></script>

    </body>
</html>