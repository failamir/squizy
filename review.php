<?php
session_start();
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Review Quiz</title>
        <?php include('include-css.php'); ?>
    </head>

    <body class="bg-content-color-quizing">
        <?php include('header.php'); ?>  

        <div class="wapper">
            <div class="container-bg-set container top-margin">

                <div class="row justify-content-center">
                    <div class="justify-content-center col-md-8">

                        <div class="col-md-12 top-margin text-center">
                            <h4 class="simple-box1 breadcrumb-bg"> Review Answers</h4>              
                        </div>

                        <div class="row text-center shadow-box-quiz pt-2 pb-2 mt-4"> 
                            <div class="col-5">
                                Que: <span id="attempted_question"></span>/<span id="total_question"></span>
                            </div>
                            <div class="col-5">
                                <span id="attempted"></span>
                            </div>  
                            <div class="col-2 text-white">
                                <a href="javascript:void(0)" class="text-white add-cursor btn-modal" data-toggle="modal" data-target="#myReportModal"><em class="fa fa-exclamation-triangle"></em></a>                            
                            </div>
                        </div>

                        <div class="row justify-content-center pb-2">
                            <div class="question-box" style="min-height: 150px; margin-top: 15px;">
                                <button id="boockmark_question" class="float-right">
                                    <em class="fa fa-bookmark-o" data-toggle="tooltip" data-placement="right" title="Bookmark Question"></em>
                                </button>
                                <div id="my-fonts-questions">
                                </div>
                                <div id="questionsimg">
                                </div>
                            </div>
                        </div>

                        <div class="row justify-content-center review">
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

                        <div class="row justify-content-center review" id="hide-option-tf">
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

                        <div class="row justify-content-center review" id="hide-option-e">
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

                        <div class="row justify-content-center" >
                            <div class="col-md-10 mt-10 mb-1" id="ex-note">  
                                <div class="set">
                                    <a class="">Extra Note<em class="fa fa-plus"></em></a>
                                    <div class="content" id="exnote"></div>                                    
                                </div>
                            </div>
                        </div>

                        <div class="row justify-content-center text-center pb-4">
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
        <!-- Modal -->
        <div class="modal fade" id="myReportModal" role="dialog">
            <div class="modal-dialog">

                <!-- Modal content-->
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                        <h4 class="modal-title">Report Question</h4>
                    </div>
                    <div class="modal-body">
                        <form method="post" id="frm_report">
                            <p><span>Que : </span><span id="re_que"></span></p>
                            <input type="hidden" name="que_id" id="que_id" value=""/>
                            <div class="">
                                <input type="text" id="report" name="report" maxlength="500" placeholder="Type a message" required class="form-control">
                                <label class="text-danger" id="messageLabel"></label>
                            </div>
                            <div class="float-right">
                                <a class="shadow-box-theme p-2 text-white add-cursor" onclick="set_report()">Submit</a>
                            </div>
                            <div class="form-group">
                                <label class="text-info" id="resultLabel"></label>
                            </div>
                        </form>
                    </div>

                </div>
            </div>
        </div>

        <?php include('footer.php'); ?>

        <script src="assets/js/pages/review.js"></script>

    </body> 
</html> 