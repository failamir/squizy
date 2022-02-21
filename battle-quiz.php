<?php
session_start();

if (!isset($_POST['match_id']) && !isset($_POST['userId1']) && !isset($_POST['opp_id']) && !isset($_POST['player1Name']) && !isset($_POST['opp_name'])) {
    header("location:index.php");
} else {
    $curr_user = $_POST['player1Name'];
    $opp_user = $_POST['opp_name'];
    $match_id = $_POST['match_id'];
    $my_id = $_SESSION['id'];
}
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Battle</title>
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
            <div class="container-bg-set container top-margin"> 

                <div class="row justify-content-center top-margin">

                    <div class="justify-content-center col-md-8 mb-40">

                        <div class="row justify-content-center shadow-box-quiz">
                            <div class="col-md-2 col-sm-2 col-2 mt-center">
                                Q: <span id="attempted_question"></span>/<span id="total_question"></span>
                            </div>
                            <div class="col-md-3 col-sm-3 col-3">
                                <div class="table_q w-100 mt-1">
                                    <div class="tbody_q">
                                        <div class="tr_q">                                        
                                            <div class="td_q text-center">You</div>
                                            <div class="td_q"><div class="green_count" id="green_count_curr_user">0</div></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-2 col-sm-2 col-2">
                                <div id="app"></div> 
                            </div>
                            <div class="col-md-5 col-sm-5 col-5">
                                <div class="table_q w-100 mt-1">
                                    <div class="tbody_q">
                                        <div class="tr_q">
                                            <div class="td_q"><div class="green_count" id="green_count_opp_user">0</div></div>
                                            <div class="td_q"><?= htmlspecialchars($opp_user) ?></div>                                        
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row justify-content-center">
                            <div class="green_count" id="green_count">0</div>
                            <div class="blank_space_between_bar_counts invisible">
                            </div>
                            <div class="red_count" id="red_count">0</div>
                        </div>

                        <div class="row justify-content-center pb-2">
                            <div class="progressBarGreen">
                                <div class="progressBar_fill_green">
                                </div>
                            </div>
                            <div class="question-box">
                                <span class="float-left" id="current_question"></span>
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
                                            <div class="tr_q">
                                                <div class="td_q quizing-op"><span>a</span></div>
                                                <div class="td_q questions-options-td">
                                                    <span id="option_a" class="my-fonts"></span>
                                                </div>                                        
                                                <div class="td_q"><div class="op_name" id="p1"></div></div>                                        
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
                                            <div class="tr_q">
                                                <div class="td_q quizing-op"><span>b</span></div>
                                                <div class="td_q questions-options-td">
                                                    <span id="option_b" class="my-fonts"></span>
                                                </div>                                        
                                                <div class="td_q"><div class="op_name" id="p2"></div></div>
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
                                            <div class="tr_q">
                                                <div class="td_q quizing-op"><span>c</span></div>
                                                <div class="td_q questions-options-td">
                                                    <span id="option_c" class="my-fonts"></span>
                                                </div>                                       
                                                <div class="td_q"><div class="op_name" id="p3"></div></div>
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
                                            <div class="tr_q">
                                                <div class="td_q quizing-op"><span>d</span></div>
                                                <div class="td_q questions-options-td">
                                                    <span id="option_d" class="my-fonts"></span>
                                                </div>                                        
                                                <div class="td_q"><div class="op_name" id="p4"></div></div>
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
                                            <div class="tr_q">
                                                <div class="td_q quizing-op"><span>e</span></div>
                                                <div class="td_q questions-options-td"><span id="option_e" class="my-fonts"></span></div>                                        
                                                <div class="td_q"><div class="op_name" id="p5" ></div></div>
                                            </div>
                                        </div>                               
                                    </div>
                                    <input type="radio" class="hiddenRadioButton" name="sample-radio" id="radio-05" value="e" />
                                </label>
                            </div>
                        </div>

                    </div>
                </div>
            </div> 
        </div>

        <?php include('footer.php'); ?>

        <script type="text/javascript">
            date = "<?= date('Y-m-d') ?>";

            opp_user_id = "<?= htmlspecialchars($_POST['opp_id']) ?>";
            session_user_id = "<?= htmlspecialchars($_SESSION['id']) ?>";
            match_id = "<?= htmlspecialchars($_POST['match_id']) ?>";
            curr_user_id = "<?= htmlspecialchars($_POST['userId1']) ?>";
        </script>
        <script src="assets/js/pages/battle-quiz.js"></script>
    </body>
</html>