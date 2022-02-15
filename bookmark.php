<?php
session_start();
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Bookmarks</title>
        <?php include('include-css.php'); ?>   
    </head>
    <body class="bg-content-color">
        <?php include('header.php'); ?>   

        <div class="wapper">
            <div class="container container-bg-set">
                <div class="row top-margin"> 
                    <div class="col-md-12 top-margin">                  
                        <div class="row"> 
                            <div class="col-md-12 text-center">  
                                <h2>Bookmarked Questions</h2>
                            </div>  
                            <div class="col-md-12 justify-content-center" id=hide_play_bookmark_btn>
                                <div class="text-center">
                                    <a href="bookmark-play.php">
                                        <button id="bookmark_show_question">
                                            <div class="shadow-box-theme p-2"> 
                                                <div class=" add-cursor text-center text-uppercase">
                                                    play bookmark
                                                </div> 
                                            </div> 
                                        </button>
                                    </a>
                                </div>
                            </div>
                            <div class="col-md-12 mt-4" id="bookmark_length">
                                <ul class="list-group mb-5" id="bookmarked_questions_list">

                                </ul>
                            </div>
                        </div>
                    </div>          
                </div>
            </div>          
        </div>

        <?php include('footer.php') ?>

        <script src="assets/js/pages/bookmark.js"></script> 

    </body>
</html>