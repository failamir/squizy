<?php
session_start();
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Online Quiz</title>
        <?php include('include-css.php'); ?>   
    </head>
    <body class="bg-content-color">
        <!-- Preloader -->
        <div id="preloader"> 
            <div id="loader-img">
            </div>
        </div>
        <!--  -->
        <?php include('header.php'); ?>  

        <div class="wapper">
            <div class="theme-gradient">
                <div class="container container-bg-set style-wave wave">
                    <div class="row wow fadeInLeft top-margin1">  
                        <div class="col-md-6 col-sm-12 text-left pt-100 text-white">                  
                            <span class="lobster-font top-header-title-1">Want to Make Your Own Quiz</span><br>  
                            <p class="text-justify">Make the perfect online quiz for any subject! Get the flexibility you need to get the answers you want. The Quiz Online power by WRteam Maker makes it easy for you to see what people know.</p>

                            <div class="footer-download-section-style">   
                                <a class="text-decoration-none app_link" target="_blank">
                                    <img alt="android" src="assets/images/google-downloader@2x.png">
                                </a>                    
                                <a class="text-decoration-none ios_app_link" target="_blank">
                                    <img alt="ios" src="assets/images/ios-downloader@2x.png">
                                </a>   
                            </div>
                        </div>    
                        <div class="col-md-6 col-sm-12 top-header-image"> 
                            <img class="col-12" src="assets/images/screen.png" alt="image"> 
                        </div>
                    </div>
                </div>          
            </div>

            <div class="container-bg-set container bg-content-color mb-40 mt-4">
                <div class="row mt-4">
                    <div class="col-md-12 title-border">
                        <h2 class="text-center">Awesome Features</h2>
                    </div>
                </div>    
                <div class="row pt-4">
                    <div class="col-md-3 col-sm-6">
                        <div class="shadow-box feature-box wow zoomIn text-center">
                            <img src="assets/images/quiz.png" alt="quiz" class="feature-image rounded mt-4">
                            <p class="mt-2 mb-2 feature-title"><strong>Player vs Player Battle</strong></p>  
                            <div class="hight-box">
                                <p>A virtual quiz competition designed exclusively for learn with fun ,You have 25 seconds to answer each question. The faster you answer, the higher your score.</p>
                            </div>        
                        </div>
                    </div>
                    <div class="col-md-3 col-sm-6">
                        <div class="shadow-box feature-box wow zoomIn text-center">
                            <img src="assets/images/lifelines.png" alt="lifelines" class="feature-image rounded mt-4">
                            <p class="mt-2 mb-2 feature-title"><strong>Life - Lines</strong></p>   
                            <div class="hight-box">
                                <p>lifelines is the most fun feature with quiz online game it will help the users to keep more active with learning.</p>
                            </div>
                        </div>                            
                    </div>
                    <div class="col-md-3 col-sm-6">
                        <div class="shadow-box feature-box wow zoomIn text-center">
                            <img src="assets/images/selfchallenge.png" alt="selfchallenge" class="feature-image rounded mt-4">
                            <p class="mt-2 mb-2 feature-title"><strong>Self Challenge</strong></p> 
                            <div class="hight-box">
                                <p>let's make fun with self-challenge with self-improvement, here user can make self challenge with time, category, questions and many more!</p>
                            </div>    
                        </div>                        
                    </div>
                    <div class="col-md-3 col-sm-6">
                        <div class="shadow-box feature-box wow zoomIn text-center">
                            <img src="assets/images/userstatistics.png" alt="userstatistics" class="feature-image mt-4">
                            <p class="mt-2 mb-2 feature-title"><strong>User Statistics</strong></p>   
                            <div class="hight-box">
                                <p>let's check with update stats with your performance and you can watch your strength and weakness.</p>
                            </div> 
                        </div>
                    </div>
                </div>  
            </div>

            <!--Play Quiz-->
            <div class="bg-content-color-1">
                <div class="container-bg-set container mb-40">
                    <div class="row wow fadeInLeft">
                        <div class="col-md-6 col-sm-12 py-4">
                            <img src="assets/images/play-quiz.png" alt="playquiz" class="home-image">
                        </div>
                        <div class="col-md-6 col-sm-12 py-4">
                            <p class="text-bold">Play Quiz</p>
                            <h2 class="text-bold">Online Quiz is an amazing trivia game</h2>
                            <div class="text-justify">
                                <p>Many other games, General Knowledge Quiz gives you unlimited time to answer each question.</p>
                                <p>With the super database of questions and always adding more, General Knowledge Quiz will test your Knowledge to the fullest.</p>
                            </div>
                            <div class="pt-4">
                                <?php if (isset($_SESSION['name']) && isset($_SESSION['email'])) { ?>
                                    <a class="text-decoration-none" href="play-quiz.php">    
                                        <div class="shadow-box-button add-cursor pt-2 pb-2"> 
                                            <div class="text-center text-bold text-uppercase">Play Now</div> 
                                        </div>                         
                                    </a>
                                <?php } else { ?>                         
                                    <a href="javascript:void(0)" class="text-decoration-none add-cursor btn-modal" data-toggle="modal" data-target="#myModal" data-tab="login">
                                        <div class="shadow-box-button add-cursor pt-2 pb-2"> 
                                            <div class="text-center text-bold text-uppercase">Play Now</div> 
                                        </div>                         
                                    </a>
                                <?php } ?>                        
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!--End Play Quiz-->
            <!--Battle Quiz-->
            <div class="bg-content-color">
                <div class="container-bg-set container mb-40">
                    <div class="row wow fadeInRight">
                        <div class="col-md-6 col-sm-12 py-4">
                            <p class="text-bold">Battle Quiz</p>
                            <h2 class="text-bold">Battle Quiz is an amazing trivia game</h2>
                            <div class="text-justify">
                                <p>Many other games, General Knowledge Quiz gives you unlimited time to answer each question.</p>
                                <p>With the super database of questions and always adding more, General Knowledge Quiz will test your Knowledge to the fullest.</p>
                            </div>
                            <div class="pt-4">
                                <?php if (isset($_SESSION['name']) && isset($_SESSION['email'])) { ?>
                                    <a class="text-decoration-none" href="find-opponent.php">     
                                        <div class="shadow-box-button add-cursor pt-2 pb-2"> 
                                            <div class="text-center text-bold text-uppercase">Battle Now</div> 
                                        </div>                         
                                    </a>
                                <?php } else { ?>                         
                                    <a href="javascript:void(0)" class="text-decoration-none add-cursor btn-modal" data-toggle="modal" data-target="#myModal" data-tab="login">
                                        <div class="shadow-box-button add-cursor pt-2 pb-2"> 
                                            <div class="text-center text-bold text-uppercase">Battle Now</div> 
                                        </div>                         
                                    </a>
                                <?php } ?>                                     
                            </div>
                        </div>
                        <div class="col-md-6 col-sm-12 py-4">
                            <img src="assets/images/battle-quiz.png" alt="battlequiz" class="home-image">
                        </div>
                    </div>
                </div>
            </div>
            <!--End Battle Quiz-->
            <!--Self Challenge-->
            <div class="bg-content-color-1">
                <div class="container-bg-set container mb-40">
                    <div class="row wow fadeInLeft">
                        <div class="col-md-6 col-sm-12 py-4">
                            <img src="assets/images/self-challage.png" alt="selfchallage" class="home-image">
                        </div>
                        <div class="col-md-6 col-sm-12 py-4">
                            <p class="text-bold">Self Challenge</p>
                            <h2 class="text-bold">Self Challenge Quiz is an amazing trivia game</h2>
                            <div class="text-justify">
                                <p>Many other games, General Knowledge Quiz gives you unlimited time to answer each question.</p>
                                <p>With the super database of questions and always adding more, General Knowledge Quiz will test your Knowledge to the fullest.</p>
                            </div>
                            <div class="pt-4">
                                <?php if (isset($_SESSION['name']) && isset($_SESSION['email'])) { ?>
                                    <a href="self-challenge.php" class="text-decoration-none">   
                                        <div class="shadow-box-button add-cursor pt-2 pb-2"> 
                                            <div class="text-center text-bold text-uppercase">Challenge Now</div> 
                                        </div>                         
                                    </a>
                                <?php } else { ?>                         
                                    <a href="javascript:void(0)" class="text-decoration-none add-cursor btn-modal" data-toggle="modal" data-target="#myModal" data-tab="login">
                                        <div class="shadow-box-button add-cursor pt-2 pb-2"> 
                                            <div class="text-center text-bold text-uppercase">Challenge Now</div> 
                                        </div>                         
                                    </a>
                                <?php } ?>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!--End Self Challenge-->

            <div class="bg-content-color">
                <div class="container-bg-set container mb-40">
                    <div class="row py-4">
                        <div class="col-md-12 col-12 title-border">
                            <h2 class="text-center">Simple & Beautiful Interface</h2>   
                        </div>
                        <div class="col-md-12 col-12  pt-2">
                            <p class="text-center">Lorem Ipsum is simply dummy text of the printing and typesetting industry.</p>
                        </div>
                    </div>    
                    <div class="row pb-4 pt-4">
                        <div class="col-md-12 col-12">
                            <div id="slider-img" class="owl-carousel">

                                <div class="item">
                                    <div class="shadow-effect">
                                        <img class="img-circle" src="assets/images/Intersection-1.png" alt="slider">
                                    </div>
                                </div>
                                <div class="item">
                                    <div class="shadow-effect">
                                        <img class="img-circle" src="assets/images/Intersection-2.png" alt="slider">
                                    </div>
                                </div>
                                <div class="item">
                                    <div class="shadow-effect">
                                        <img class="img-circle" src="assets/images/Intersection-3.png" alt="slider">
                                    </div>
                                </div>
                                <div class="item">
                                    <div class="shadow-effect">
                                        <img class="img-circle" src="assets/images/Intersection-4.png" alt="slider">
                                    </div>
                                </div>
                                <div class="item">
                                    <div class="shadow-effect">
                                        <img class="img-circle" src="assets/images/Intersection-5.png" alt="slider">
                                    </div>
                                </div>
                                <div class="item">
                                    <div class="shadow-effect">
                                        <img class="img-circle" src="assets/images/Intersection-6.png" alt="slider">
                                    </div>
                                </div>
                                <div class="item">
                                    <div class="shadow-effect">
                                        <img class="img-circle" src="assets/images/Intersection-7.png" alt="slider">
                                    </div>
                                </div>
                                <div class="item">
                                    <div class="shadow-effect">
                                        <img class="img-circle" src="assets/images/Intersection-8.png" alt="slider">
                                    </div>
                                </div>
                                <div class="item">
                                    <div class="shadow-effect">
                                        <img class="img-circle" src="assets/images/Intersection-9.png" alt="slider">
                                    </div>
                                </div>
                                <div class="item">
                                    <div class="shadow-effect">
                                        <img class="img-circle" src="assets/images/Intersection-10.png" alt="slider">
                                    </div>
                                </div>
                                <div class="item">
                                    <div class="shadow-effect">
                                        <img class="img-circle" src="assets/images/Intersection-11.png" alt="slider">
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div>

        <?php include('footer.php'); ?>

        <script src="assets/js/pages/index.js"></script>

    </body>
</html>