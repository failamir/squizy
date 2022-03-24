<?php
session_start();
if (!isset($_SESSION['name']) && !isset($_SESSION['email']) && !isset($_SESSION['id'])) {
    header("location:index.php");
    return false;
}
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Play Random Quiz</title>
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
            <div class="container top-margin">
                <div class="row justify-content-center">                  

                    <div class="col-md-8 mb-40">
                        <div class="row top-margin justify-content-center shadow-box-quiz">                      
                            <div class="col-5 qpt-2 text-center">
                                Que: <span id="attempted_question"></span>/<span id="total_question"></span>
                            </div>
                            <div class="col-2">
                                <div id="app"></div>
                            </div>
                            <div class="col-2 qpt-2 text-center">
                                Coins: <span id="coins"></span>
                            </div> 
                            <div class="col-3 qpt-2 text-center">
                                Points: <span id="points">00</span>
                            </div>                      
                        </div>

                        <div class="row justify-content-center">
                            <div class="green_count" id="green_count">0</div>
                            <div class="blank_space_between_bar_counts"> </div>
                            <div class="red_count" id="red_count">0</div>
                        </div>

                        <div class="row justify-content-center pt-2 pb-4"> 
                            <div class="progressBarGreen">
                                <div class="progressBar_fill_green">
                                </div>
                            </div>
                            <div class="question-box">
                                <button id="boockmark_question" class="float-right">
                                    <em class="fa fa-bookmark-o" data-toggle="tooltip" data-placement="right" title="Bookmark Question"></em>
                                </button>
                                <div id="my-fonts-questions">                               
                                </div>
                                <div id="questionsimg">
                                </div>
                            </div>
                            <div class="progressBarRed">
                                <div class="progressBar_fill_red">
                                </div>
                            </div>              
                        </div>

                        <div class="row justify-content-center">
                            <div class="col-md-6 col-11">
                                <label class="shadow-box-options quizing-options" id="a">
                                    <div class="table_q">
                                        <div class="tbody_q">
                                            <div class="tr_q quizpro">
                                                <div class="td_q quizing-op"><span>a</span></div>
                                                <div class="td_q questions-options-td">
                                                    <span id="option_a" class="my-fonts"></span>
                                                </div>                                        
                                                <div class="td_q"><div class="progress" id="p1"></div></div>                                        
                                            </div>
                                        </div>
                                    </div>
                                    <input type="radio" class="hiddenRadioButton" name="sample-radio" id="radio-01" value="a" />
                                </label>
                            </div>
                            <div class="col-md-6 col-11">
                                <label class="shadow-box-options quizing-options" id="b">
                                    <div class="table_q">
                                        <div class="tbody_q">
                                            <div class="tr_q quizpro">
                                                <div class="td_q quizing-op"><span>b</span></div>
                                                <div class="td_q questions-options-td">
                                                    <span id="option_b" class="my-fonts"></span>
                                                </div>                                        
                                                <div class="td_q"><div class="progress" id="p2"></div></div>
                                            </div>                                    
                                        </div>
                                    </div>
                                    <input type="radio" class="hiddenRadioButton" name="sample-radio" id="radio-02" value="b" />
                                </label>
                            </div>
                        </div>

                        <div class="row justify-content-center" id="hide-option-tf">
                            <div class="col-md-6 col-11">
                                <label class="shadow-box-options quizing-options" id="c">
                                    <div class="table_q">
                                        <div class="tbody_q">
                                            <div class="tr_q quizpro">
                                                <div class="td_q quizing-op"><span>c</span></div>
                                                <div class="td_q questions-options-td">
                                                    <span id="option_c" class="my-fonts"></span>
                                                </div>                                       
                                                <div class="td_q"><div class="progress" id="p3"></div></div>
                                            </div>                                   
                                        </div>
                                    </div>
                                    <input type="radio" class="hiddenRadioButton" name="sample-radio" id="radio-03" value="c" />
                                </label>
                            </div>
                            <div class="col-md-6 col-11">
                                <label class="shadow-box-options quizing-options" id="d">
                                    <div class="table_q">
                                        <div class="tbody_q">
                                            <div class="tr_q quizpro">
                                                <div class="td_q quizing-op"><span>d</span></div>
                                                <div class="td_q questions-options-td">
                                                    <span id="option_d" class="my-fonts"></span>
                                                </div>                                        
                                                <div class="td_q"><div class="progress" id="p4"></div></div>
                                            </div>                                    
                                        </div>
                                    </div>
                                    <input type="radio" class="hiddenRadioButton" name="sample-radio" id="radio-04" value="d" />
                                </label>
                            </div>
                        </div>

                        <div class="row justify-content-center" id="hide-option-e">
                            <div class="col-md-6 col-11">
                                <label class="shadow-box-options quizing-options" id="e">
                                    <div class="table_q">
                                        <div class="tbody_q">
                                            <div class="tr_q quizpro">
                                                <div class="td_q quizing-op"><span>e</span></div>
                                                <div class="td_q questions-options-td"><span id="option_e" class="my-fonts"></span></div>                                        
                                                <div class="td_q"><div class="progress" id="p5"></div></div>
                                            </div>
                                        </div>                               
                                    </div>
                                    <input type="radio" class="hiddenRadioButton" name="sample-radio" id="radio-05" value="e" />
                                </label>
                            </div>
                        </div>

                        <div class="row justify-content-center" id="lifeline">
                            <div class="lifeline-box" id="fifty">
                                <img alt="fiftyfifty" src="assets/images/fiftyfifty.png" class="lifeline-box-img">
                            </div>
                            <div class="lifeline-box" id="right">
                                <img alt="skip" src="assets/images/skip.png" class="lifeline-box-img">
                            </div>
                            <div class="lifeline-box" id="audience_poll">
                                <img alt="audiencepool" src="assets/images/audiencepool.png" class="lifeline-box-img">
                            </div>
                            <div class="lifeline-box" id="reset_timer">
                                <img alt="resettime" src="assets/images/resettime.png" class="lifeline-box-img">
                            </div>
                        </div>

                    </div>
                </div>
            </div>   
        </div>

        <?php include('footer.php'); ?>

        <script src="assets/js/pages/random-quiz.js"></script>
    </body>
</html>