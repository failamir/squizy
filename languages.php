<?php

ob_start();
include('include-css.php');
?>     
<script type="text/javascript">
    var temp = fetch_systemConfiguration();
    var language_mode = temp['data']['language_mode'];
</script>
<?php

session_start();
if (isset($_GET['id']) && is_numeric($_GET['id']) && !empty($_GET['id']) && !empty($_GET['language'])) {
    $lg_id = $_GET['id'];
    $lg_name = $_GET['language'];
    if (!empty($lg_id) && !empty($lg_name)) {
        $_SESSION['lang_id'] = $lg_id;
        $_SESSION['language'] = $lg_name;
        if (isset($_GET['rUrl']) && !empty($_GET['rUrl'])) {
            header("location:" . $_GET['rUrl']);
        } else {
            header("location:index.php");
        }
    } else {
        $_SESSION['lang_id'] = '';
        $_SESSION['language'] = '';
        header("location:index.php");
    }
} else {
    header("location:index.php");
}
?>

