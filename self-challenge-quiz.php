<?php
session_start();

if (empty($_POST['time']) && empty($_POST['limit']) && empty($_POST['category_id']) && !is_numeric($_POST['limit']) && !is_numeric($_POST['subcategory_id']) && !is_numeric($_POST['category_id'])) {
    header("location:self-challenge.php");
}
if (!isset($_POST['subcategory_name']) && !isset($_POST['time']) && !isset($_POST['limit']) && !isset($_POST['subcategory_id']) && !isset($_POST['category_id'])) {
    header("location:self-challenge.php");
} else {
    $limit = $_POST['limit'];
    $time = $_POST['time'];
    if (!empty($_POST['subcategory_name'])) {
        $subcategory_name = $_POST['subcategory_name'];
    } else {
        $subcategory_name = "";
    }
}
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Playing Self Challenge</title>
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
                <div class="row justify-content-center">
                    <div class="justify-content-center col-md-8">

                        <div class="row mt-4 justify-content-center">                
                            <nav class="quiz">
                                <ol class="breadcrumb text-bold background-white"> 
                                    <li class="breadcrumb-item" id="catname">Category</li>
                                    <?php if (!empty($_POST['subcategory_name'])) { ?>
                                        <li class="breadcrumb-item" id="subname">Subcategory</li>
                                    <?php } ?>  
                                </ol>
                            </nav>
                        </div>

                        <div class="row justify-content-center text-center shadow-box-quiz pt-2 pb-2">                      
                            <div class="col-4 spt-3">
                                Que: <span id="attempted_question"></span>/<span id="total_question"></span>
                            </div>                      
                            <div class="col-4 d-flex justify-content-center">
                                <div id="app"></div>
                            </div>                        
                            <div class="col-4 add-cursor spt-3" id="submitData">
                                <span class="border border-light p-2">Submit</span>

                            </div>                      
                        </div>

                        <div class="row justify-content-center pb-2">
                            <div class="question-box" style="min-height: 150px; margin-top: 15px;">                           
                                <div id="my-fonts-questions">
                                </div>
                                <div id="questionsimg">
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
                                            <div class="tr_q">
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
                                            <div class="tr_q">
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
                                            <div class="tr_q">
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
                                            <div class="tr_q">
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

                        <div class="row justify-content-center text-center pb-2">
                            <div class="col-3 col-md-2 shadow-box-theme add-cursor" id="ar-left">
                                <em class="fa fa-arrow-circle-left fa-2x"></em>
                            </div>
                            <div class="col-3 col-md-2 shadow-box-theme add-cursor" id="ar-right">
                                <em class="fa fa-arrow-circle-right fa-2x"></em>
                            </div>
                        </div>
                    </div>
                </div>

            </div> 
        </div>

        <?php include('footer.php'); ?>

        <script type="text/javascript">
            window.limit = "<?= htmlspecialchars($_POST['limit']) ?>";
            window.category_id = "<?= htmlspecialchars($_POST['category_id']) ?>";
            window.sub_id = "<?= htmlspecialchars($_POST['subcategory_id']) ?>";
            window.time = "<?= htmlspecialchars($_POST['time']) ?>";
            window.sub_name = "<?= htmlspecialchars($subcategory_name) ?>";
            window.challage_time = "<?= htmlspecialchars($_POST['time']) ?>";
        </script>

        <script src="assets/js/pages/self-challenge-quiz.js"></script>

    </body> 
</html> 