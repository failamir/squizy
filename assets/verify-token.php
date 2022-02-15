<?php

include_once('jwt.php');

function generate_token() {
    $jwt = new JWT();
    $payload = [
        'iat' => time(), /* issued at time */
        'iss' => 'quiz',
        'exp' => time() + (30 * 60 * 60), /* expires after 1 minute */
        'sub' => 'quiz Authentication'
    ];
    $token = $jwt::encode($payload, $_GET['jwt_key']);
    print_r(json_encode($token));
}
// generate_token();
$token = generate_token();
echo $token;

?>