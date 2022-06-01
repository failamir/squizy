<?php
session_start();

if (empty($_POST['level']) && $_POST['max_level'] != '' && $_POST['subcategory_id'] != '' && empty($_POST['category_id']) && !is_numeric($_POST['level']) && !is_numeric($_POST['subcategory_id']) && !is_numeric($_POST['category_id'])) {
    header("location:index.php");
}
if (!isset($_POST['subcategory_name']) && !isset($_POST['level']) && !isset($_POST['subcategory_id']) && !isset($_POST['category_id'])) {
    header("location:index.php");
} else {
    $level = $_POST['level'];
}

$subcategory_name = (!empty($_POST['subcategory_name'])) ? $_POST['subcategory_name'] : "";
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Play Quiz</title>
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

                        <div class="row mt-4 justify-content-center"> 
                            <nav class="quiz">
                                <ol class="breadcrumb text-bold background-white">
                                    <li class="breadcrumb-item" id="catname">Category</li>
                                    <?php if (!empty($_POST['subcategory_name'])) { ?>
                                        <li class="breadcrumb-item" id="subname">Subcategory</li>
                                    <?php } ?>                               
                                    <li class="breadcrumb-item">Level <?= htmlspecialchars($level) ?></li>
                                </ol>
                            </nav>      
                        </div>

                        <div class="row justify-content-center shadow-box-quiz">                      
                            <div class="col-3 qpt-2">
                                Que: <span id="attempted_question"></span>/<span id="total_question"></span>
                            </div>
                            <div class="col-2 qpt-2">
                                Level: <span id="level"></span>
                            </div>                       
                            <div class="col-2">
                                <div id="app"></div>
                            </div>  
                            <div class="col-2 qpt-2">
                                Coins: <span id="coins"></span>
                            </div> 
                            <div class="col-3 qpt-2">
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

        <script type="text/javascript">
            window.level = "<?= htmlspecialchars($_POST['level']) ?>";
            window.category_id = "<?= htmlspecialchars($_POST['category_id']) ?>";
            window.sub_id = "<?= htmlspecialchars($_POST['subcategory_id']) ?>";
            window.sub_name = "<?= htmlspecialchars($subcategory_name) ?>";
            window.max_level = "<?= htmlspecialchars($_POST['max_level']) ?>";
        </script>

        <script src="assets/js/pages/quizing.js"></script>

    </body>
</html>