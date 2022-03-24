<?php
session_start();
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Notifications</title>
        <?php include('include-css.php'); ?>   
    </head>

    <body class="bg-content-color">
        <?php include('header.php'); ?> 

        <div class="wapper">
            <div class="container container-bg-set pb-4">
                <div class="row top-margin"> 
                    <div class="col-md-12 text-center top-margin mb-2">  
                        <h2>Notifications</h2>
                    </div>  
                    <div class="col-md-12 text-justify mt-10 mb-40" id="notification">                  

                    </div>          
                </div>
            </div>  
        </div>

        <?php include('footer.php'); ?>

        <script src="assets/js/pages/notification.js"></script>
    </body>
</html>