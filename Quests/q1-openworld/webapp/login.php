<?php
$username = $_GET['username'];
$password = $_GET['password'];

if($username == "claymore" && $password == "MyChemicalRomance") {
    header("location: welcome.php");
} else {
    $error = "Your Login Name or Password is invalid";
}
?>