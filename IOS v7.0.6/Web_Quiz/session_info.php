<?php

session_start();
if (isset($_GET['user_id'])) {
    $_SESSION['id'] = $_GET['user_id'];
    $_SESSION['name'] = $_GET['name'];
    $_SESSION['email'] = $_GET['email'];
    $_SESSION['type'] = $_GET['type'];
    $_SESSION['mobile'] = $_GET['mobile'];
    $_SESSION['profile'] = $_GET['profile'];
    echo 1;
} else {
    echo 0;
}
if (isset($_GET['update']) && isset($_GET['name'])) {
    $_SESSION['name'] = $_GET['name'];
    echo 1;
} else {
    echo 0;
}   




        

