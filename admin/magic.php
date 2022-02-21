<?php
session_start();
set_time_limit(1000);
// echo 1; die;
if (require __DIR__ . '/../vendor/autoload.php') {
    // echo 5;
}
// var_dump(__DIR__);die;
// require __DIR__ . '/../vendor/autoload.php';
// require __DIR__.'/../vendor/autoload.php';
// echo 1; 
// die;
use \Dejurin\GoogleTranslateForFree;
$source = 'id';
$target = 'en';
$attempts = 5;
// $text = 'With attempts connecting on failure and array support';

$trans = new GoogleTranslateForFree();
// $result = $tr->translate($source, $target, $text, $attempts);
// echo $result;
// die;
// var_dump($result);

// use \Statickidz\GoogleTranslate;
// $source = 'id';
// $target = 'en';
// $text = 'siapa dia';

// $trans = new GoogleTranslate();

// $result = $trans->translate($source, $target, $text);
// var_dump($result);
// use Stichoza\GoogleTranslate\GoogleTranslate;
// $tr = new GoogleTranslate(); // Translates to 'en' from auto-detected language by default
// $tr->setSource('en'); // Translate from English
// $tr->setSource(); // Detect language automatically
// $tr->setTarget('ka'); // Translate to Georgian
// var_dump($tr);
// die;
// echo $tr->translate('Hello World!');
// var_dump( $tr->translate('Hello World!'));
// echo GoogleTranslate::trans('Hello again', 'ka', 'en');
// var_dump($source);
// var_dump($target);
// var_dump($text);

// die;
// Good morning

// echo $result;
// die;
// $source = 'id';
// $target = 'en';

// $trans = new GoogleTranslate();
// $result = $trans->translate($source, $target, 'aku suka dia');
// $q = $result;

// die;

include 'library/crud.php';
include 'library/functions.php';
$fn = new Functions();
$config = $fn->get_configurations();
$db = new Database();
$db->connect();

if (isset($config['system_timezone']) && !empty($config['system_timezone'])) {
    date_default_timezone_set($config['system_timezone']);
} else {
    date_default_timezone_set('Asia/Kolkata');
}
if (isset($config['system_timezone_gmt']) && !empty($config['system_timezone_gmt'])) {
    $db->sql("SET `time_zone` = '" . $config['system_timezone_gmt'] . "'");
} else {
    $db->sql("SET `time_zone` = '+05:30'");
}

function get_count($field, $table, $where = '')
{
    if (!empty($where))
        $where = "where " . $where;

    $sql = "SELECT COUNT(" . $field . ") as total FROM " . $table . " " . $where;
    global $db;
    $db->sql($sql);
    $res = $db->getResult();
    foreach ($res as $row)
        return $row['total'];
}

$auth_username = $db->escapeString($_SESSION["username"]);

function checkadmin($auth_username)
{
    $db = new Database();
    $db->connect();
    $db->sql("SELECT `auth_username`,`role` FROM `authenticate` WHERE `auth_username`='$auth_username' LIMIT 1");
    $res = $db->getResult();
    if (!empty($res)) {
        if ($res[0]["role"] == "admin") {
            return true;
        } else {
            return false;
        }
    }
}

if (!checkadmin($auth_username)) {
    $pages = array('languages.php', 'users.php', 'monthly-leaderboard.php', 'send-notifications.php', 'user-accounts-rights.php', 'notification-settings.php', 'privacy-policy.php');
    foreach ($pages as $page) {
        if (basename($_SERVER['PHP_SELF']) == $page) {
            exit("<center><h2 style='color:#fff;'><br><br><br><br><em style='color:#f7d701;' class='fas fa-exclamation-triangle fa-4x'></em><br><br>Access denied - You are not authorized to access this.</h2></center>");
        }
    }
}
if (basename($_SERVER['PHP_SELF']) == 'languages.php' && !$fn->is_language_mode_enabled()) {
    exit("<center><h2 style='color:#fff;'><br><br><br><br><em style='color:#f7d701;' class='fas fa-exclamation-triangle fa-4x'></em><br><br>Language mode is disabled - You are not allowed to access this page.</h2></center>");
}


// Good morning
echo $result;
//================================================================
$role = $_SESSION['role'];
if ($role == 'admin') {
    // echo "magic works";
    $sql = "SELECT * FROM `question` ORDER BY id DESC";
    $db->sql($sql);
    $q = $db->getResult();
    // $source = 'id';
    // $target = 'en';
    // $trans = new GoogleTranslate();
    foreach ($q as $que) {
        $qu = (object)$que;
        // var_dump((object)$qu);
        // var_dump($qu->question);
        // die;
        // $source = 'id';
        // $target = 'en';
        // $trans = new GoogleTranslate();
        if($qu->id == 9 or $qu->id == 10){
            // var_dump($qu);
        $result = $trans->translate($source, $target, $qu->question);
        $q = $result;
        // $trans = new GoogleTranslate();
        $result = $trans->translate($source, $target, $qu->optionanswer);
        $a = $result;
        // $trans = new GoogleTranslate();
        $result = $trans->translate($source, $target, $qu->note);
        $n = $result;
        // var_dump($qu);
        // die;
        if ($qu->optiona != null) {
            // $trans = new GoogleTranslate();
            $result = $trans->translate($source, $target, $qu->optiona);
            $qu->optiona = $result;
        }
        if ($qu->optionb != null) {
            // $trans = new GoogleTranslate();
            $result = $trans->translate($source, $target, $qu->optionb);
            $qu->optionb = $result;
        }
        if ($qu->optionc != null) {
            // $trans = new GoogleTranslate();
            $result = $trans->translate($source, $target, $qu->optionc);
            $qu->optionc = $result;
        }
        if ($qu->optiond != null) {
            // $trans = new GoogleTranslate();
            $result = $trans->translate($source, $target, $qu->optiond);
            $qu->optiond = $result;
        }
        if ($qu->optione != null) {
            // $trans = new GoogleTranslate();
            $result = $trans->translate($source, $target, $qu->optione);
            $qu->optione = $result;
        }
        $sql = "INSERT INTO `question`(`category`, `subcategory`, `language_id`, `image`, `question`, `question_type`, `optiona`, `optionb`, `optionc`, `optiond`, `optione`, `level`, `answer`, `note`) VALUES 
        ('" . $qu->optioncategory . "','" . $qu->subcategory . "','" . 2 . "','" . $qu->filename . "','" . $q . "','" . $qu->question_type . "','" . $qu->optiona . "','" . $qu->optionb . "','" . $qu->optionc . "','" . $qu->optiond . "','" . $qu->optione . "','" . $qu->level . "','" . $a . "','" . $n . "')";

        
        // var_dump($db->sql($sql));
        var_dump($sql);
        // sleep(10);
    }}
    // print_r(json_encode($q));
}
