
<header>
    <div class="topbar">
        <div class="container">
            <div class="row">
                <div class="col-12 text-white text-bold">
                    <ul id="topdownmenu">
                        <?php if (isset($_SESSION['name']) && isset($_SESSION['email'])) { ?>
                            <li class="downmenu">                                
                                <a href="javascript:void(0)" id="uname">Hi, <?= $_SESSION['name']; ?><em class="fa fa-caret-down"></em></a>
                                <div class="downmenusub text-uppercase">
                                    <a href="profile.php">My Profile</a>
                                    <div class="downsub-divider"></div>
                                    <a href="leaderboard.php">Leaderboard</a>
                                    <div class="downsub-divider"></div>
                                    <a href="bookmark.php">Bookmark</a>
                                    <div class="downsub-divider"></div>
                                    <a href="invite-friends.php">Invite Friends</a>
                                    <div class="downsub-divider"></div>
                                    <a href="logout.php">Logout</a>
                                </div>
                            </li>
                        <?php } else { ?>  
                            <li>
                                <a class="add-cursor btn-modal" data-toggle="modal" data-target="#myModal" data-tab="login">Login</a>
                            </li>
                            <li>|</li>
                            <li>
                                <a class="add-cursor btn-modal" data-toggle="modal" data-target="#myModal" data-tab="register">Signup</a>
                            </li>              
                        <?php } ?>
                    </ul>
                </div>
            </div>
        </div>
    </div>
    <nav class="navbar navbar-expand-md" id="navbar">    
        <div class="container">
            <a class="navbar-brand" href="index.php">
                <img alt="webquiz" src="assets/images/quizlogo.png"/>
            </a>
            <button class="btn btn-primary navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarCollapse" aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation">
                <i class="fa fa-bars nav-btn-color" aria-hidden="true"></i>
            </button>
            <div class="collapse navbar-collapse" id="navbarCollapse">
                <ul id="menuactive" class="navbar-nav nav-margin-left text-uppercase">
                    <li class="nav-item">
                        <a class="nav-link" id="home" href="index.php">Home</a>
                    </li>  
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="javascript:void(0)" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            Play Quiz
                        </a>
                        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                            <?php if (isset($_SESSION['name']) && isset($_SESSION['email'])) { ?>
                                <a class="dropdown-item dailyQuiz" href="daily-quiz.php">Daily Quiz</a>                         
                            <?php } else { ?>                         
                                <a href="javascript:void(0)" class="dropdown-item add-cursor btn-modal dailyQuiz" data-toggle="modal" data-target="#myModal" data-tab="login">Daily Quiz</a>
                            <?php } ?>
                            <div class="dropdown-divider dailyQuiz"></div> 
                            
                            <?php if (isset($_SESSION['name']) && isset($_SESSION['email'])) { ?>
                                <a class="dropdown-item" href="play-quiz.php">Play Quiz</a>                         
                            <?php } else { ?>                         
                                <a href="javascript:void(0)" class="dropdown-item add-cursor btn-modal" data-toggle="modal" data-target="#myModal" data-tab="login">Play Quiz</a>
                            <?php } ?>
                            <div class="dropdown-divider"></div>
                            
                            <?php if (isset($_SESSION['name']) && isset($_SESSION['email'])) { ?>
                                <a class="dropdown-item" href="javascript:void(0)" onclick="PlayRandomQuiz()">Random Quiz</a>                         
                            <?php } else { ?>                         
                                <a href="javascript:void(0)" class="dropdown-item add-cursor btn-modal" data-toggle="modal" data-target="#myModal" data-tab="login">Random Quiz</a>
                            <?php } ?>
                            <div class="dropdown-divider"></div> 
                            
                            <?php if (isset($_SESSION['name']) && isset($_SESSION['email'])) { ?>
                                <a class="dropdown-item" href="self-challenge.php">Self Challenge</a>                    
                            <?php } else { ?>                         
                                <a href="javascript:void(0)" class="dropdown-item add-cursor btn-modal" data-toggle="modal" data-target="#myModal" data-tab="login">Self Challenge</a>
                            <?php } ?> 
                            <div class="dropdown-divider ContestQuiz"></div>  
                            
                            <?php if (isset($_SESSION['name']) && isset($_SESSION['email'])) { ?>
                                <a class="dropdown-item ContestQuiz" href="contest.php" >Contest Play</a>                    
                            <?php } else { ?>                         
                                <a href="javascript:void(0)" class="dropdown-item add-cursor btn-modal ContestQuiz" data-toggle="modal" data-target="#myModal" data-tab="login">Contest Play</a>
                            <?php } ?>
                            <div class="dropdown-divider"></div>
                            
                            <?php if (isset($_SESSION['name']) && isset($_SESSION['email'])) { ?>
                                <a class="dropdown-item" href="javascript:void(0)" onclick="PlayTrueFalse()">True/False Quiz</a>                    
                            <?php } else { ?>                         
                                <a href="javascript:void(0)" class="dropdown-item add-cursor btn-modal" data-toggle="modal" data-target="#myModal" data-tab="login">True/False Quiz</a>
                            <?php } ?>
                            <div class="dropdown-divider"></div> 
                            
                            <?php if (isset($_SESSION['name']) && isset($_SESSION['email'])) { ?>
                                <a class="dropdown-item" href="find-opponent.php">Random Battle Quiz</a>                     
                            <?php } else { ?>                         
                                <a href="javascript:void(0)" class="dropdown-item add-cursor btn-modal" data-toggle="modal" data-target="#myModal" data-tab="login">Random Battle Quiz</a>
                            <?php } ?>

                        </div>
                    </li>
                    <li class="nav-item">
                        <?php if (isset($_SESSION['name']) && isset($_SESSION['email'])) { ?>
                            <a class="nav-link" href="leaderboard.php">Leaderboard</a>                         
                        <?php } else { ?>                         
                            <a href="javascript:void(0)" class="nav-link add-cursor btn-modal" data-toggle="modal" data-target="#myModal" data-tab="login">Leaderboard</a>
                        <?php } ?>
                    </li>
                    <li class="nav-item">
                        <?php if (isset($_SESSION['name']) && isset($_SESSION['email'])) { ?>
                            <a class="nav-link" href="bookmark.php">Bookmark</a>                     
                        <?php } else { ?>                         
                            <a href="javascript:void(0)" class="nav-link add-cursor btn-modal" data-toggle="modal" data-target="#myModal" data-tab="login">Bookmark</a>
                        <?php } ?>   
                    </li>
                    <li class="nav-item">
                        <?php if (isset($_SESSION['name']) && isset($_SESSION['email'])) { ?>
                            <a class="nav-link" href="notification.php">Notification</a>                     
                        <?php } else { ?>                         
                            <a href="javascript:void(0)" class="nav-link add-cursor btn-modal" data-toggle="modal" data-target="#myModal" data-tab="login">Notification</a>
                        <?php } ?> 
                    </li>
                    <li class="nav-item">
                        <?php if (isset($_SESSION['name']) && isset($_SESSION['email'])) { ?>
                            <a class="nav-link" href="invite-friends.php">Invite Friends</a>                       
                        <?php } else { ?>                         
                            <a href="javascript:void(0)" class="nav-link add-cursor btn-modal" data-toggle="modal" data-target="#myModal" data-tab="login">Invite Friends</a>
                        <?php } ?>                        
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="instruction.php">Instruction</a>
                    </li>

                </ul>
            </div>
        </div>
    </nav>        
</header> 

