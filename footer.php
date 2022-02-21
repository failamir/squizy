
        <footer class="page-footer font-small blue pt-4" id="gotofooter">
            <div class="container text-center text-md-left">
                <div class="row">
                    <div class="col-md-4 text-md-left text-center">
                        <h5 class="text-capitalized">Contact Us</h5>
                        <p>Address: #262-263,<br>
                            Time Square Empire,SH 42<br>      
                            Mirjapar Highway, Bhuj - Kutch
                        </p>
                        <p>Website: <a href="https://wrteam.in/" target="_blank" rel="noopener noreferrer">wrteam.in</a><br>
                            Email:<email data-user="info" data-domain="wrteam.in"></email><br>      
                        Phone: +919033646589
                        </p>      
                    </div>
                    <div class="col-md-4">
                        <h5 class="text-capitalized">Supports</h5>
                        <ul class="list-unstyled">
                            <li><a href="about.php">About Us</a></li>
                            <li><a href="instruction.php">Instruction</a></li>
                            <li><a href="privacy-policy.php">Privacy Policy</a></li>
                            <li><a href="terms-and-conditions.php">Terms & Conditions</a></li>                   
                        </ul>
                    </div>            
                    <div class="col-md-4">
                        <h5 class="text-capitalized">Downloads</h5>
                        <small>Online Quiz for Android or IOS</small>
                        <div class="footer-download-section-style"> 
                            <a class="app_link" target="_blank">
                                <img alt="android" src="assets/images/google-downloader@2x.png" width="132px">
                            </a>                    
                            <a class="ios_app_link" target="_blank">
                                <img alt="iod" src="assets/images/ios-downloader@2x.png" width="132px">
                            </a>    
                        </div>
                    </div>
                </div>
            </div>
            <div class="footer-copyright py-2">
                <div  class="container">
                    <div class="row">
                        <div class="col-md-6 col-sm-12">
                            <a href="index.php"><img alt="quiz" src="assets/images/quizlogo.png" width="100"></a>
                            © <?= date('Y') ?> WRTeam. All Right Reserved  
                        </div>
                        <div class="col-md-6 col-sm-12">
                            <div class="float-right SocialMedia">

                            </div>                
                        </div>
                    </div>
                </div>
            </div>
            <a href="javascript:void(0);" id="return-to-top" onclick="topReturn();"><em class="fa fa-chevron-up"></em></a> 
        </footer>

        <div class="modal fade lang-model" id='editModal' tabindex="-1" role="dialog" aria-labelledby="myModalLabel" data-backdrop="static">
            <div class="modal-dialog" role="document">
                <div class="modal-content">

                    <div class="modal-body">
                        <div class="text-center">  
                            <div class="modal-title shadow-box-lang1 text-bold">
                                <h5>Select Language</h5>
                            </div>               
                        </div>
                        <form action="languages.php" class="form" id="langForm" method="GET">
                            <div class="form-group row justify-content-center">
                                <div class='col-md-12 col-sm-12 text-center' id="langData">
                                </div>                             
                            </div>                     
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <?php include('signup.php'); ?> 

        <script type="text/javascript">
        <?php if (isset($_SESSION['lang_id']) && !empty($_SESSION['lang_id'])) { ?>
                    language_id = <?= $_SESSION['lang_id'] ?>;
        <?php } else { ?>
                    language_id = 0;
        <?php } ?>

        <?php if (isset($_SESSION['name']) && isset($_SESSION['id'])) { ?>
                    user_id = <?= $_SESSION['id'] ?>;
        <?php } else { ?>
                    user_id = 0;
        <?php } ?>
        </script>

        <script type="text/javascript">
            $(document).ready(function () {
                //Disable full page
                $("body").on("contextmenu", function (e) {
                    return false;
                });
            });
            $(document).keydown(function (e) {
                if (e.keyCode == 123) {
                    return false;
                }
                if (e.ctrlKey && e.shiftKey && e.keyCode == 'I'.charCodeAt(0)) {
                    return false;
                }
                if (e.ctrlKey && e.shiftKey && e.keyCode == 'J'.charCodeAt(0)) {
                    return false;
                }
                if (e.ctrlKey && e.keyCode == 'U'.charCodeAt(0)) {
                    return false;
                }
                if (e.ctrlKey && e.shiftKey && e.keyCode == 'C'.charCodeAt(0)) {
                    return false;
                }
            });
            $(document).ready(function () {
                //Disable cut copy paste
                $('body').bind('selectstart', function (e) {
                    e.preventDefault();
                });
            });
        </script>


