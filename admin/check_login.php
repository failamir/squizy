<?php

session_start();
if (isset($_POST['username']) && isset($_POST['password'])) {
    include 'library/crud.php';
    $db = new Database();
    $db->connect();

    $username = htmlspecialchars(stripslashes($_POST['username']));
    $username = $db->escapeString($username);

    $password = htmlspecialchars(stripslashes($_POST['password']));
    $password = $db->escapeString($password);

    $pwordhash = md5($password);

    if (!empty($username) && !empty($password)) {
        $sql = "SELECT * FROM authenticate WHERE auth_username='$username' AND auth_pass='$pwordhash' ";
        if ($db->sql($sql)) {
            $result = $db->getResult();
            
            if (!empty($result)) {
                if (strcmp($result[0]["auth_username"], $username) == 0) {
                    foreach ($result as $row) {
                        $_SESSION['id'] = $row["ID"];
                        $_SESSION['role'] = $row["role"];
                        $_SESSION['username'] = $row["auth_username"];
                        $_SESSION['company_name'] = 'SQuizy';
                        $q = "SELECT * FROM question WHERE username='$username'";
                        $sql = $db->sql($q);
                        $result = $db->getResult();
                        $num_rows = mysqli_num_rows($result);
                        var_dump($num_rows); die;
                        $sql = "Update `authenticate` set `contribute`='" . $num_rows . "' where `auth_username`='" . $username . "'";
                        $db->sql($sql);
                    }
                    echo "1";
                } else {
                    echo "<p class='alert alert-danger'>Id or password does not match</p>";
                }
            } else {
                echo "<p class='alert alert-danger'>username or password does not match</p>";
            }
        } else {
            echo " <p class='alert alert-danger'>Please import database</p></p>";
        }
    } else {
        echo " <p class='alert alert-danger'>!!every field is mandetary</p></p>";
    }
}
?>