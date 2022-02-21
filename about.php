<?php
session_start();
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>About Us</title>

        <?php include('include-css.php'); ?>   

        <script type="text/javascript">
            var res = get_apis_data({get_about_us: 1});
            var data = '';
            if (res['error'] == FALSE) {
                var data = res['data'];
            }
        </script>

    </head>

    <body class="bg-content-color">
        <?php include('header.php'); ?>

        <div class="wapper">
            <div class="container container-bg-set pb-4">
                <div class="row top-margin"> 
                    <div class="col-md-12 top-margin">                  
                        <script>document.write(data);</script>
                    </div>          
                </div>
            </div>     
        </div>

        <?php include('footer.php'); ?>

    </body>
</html>