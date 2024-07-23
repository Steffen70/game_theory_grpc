<?php

require '../vendor/autoload.php';

use App\Controllers\StrategyController;

// Get the playing field port from the environment variable
$playingFieldPort = getenv('PLAYING_FIELD_PORT');
if ($playingFieldPort === false) {
    // Terminate the script if the PLAYING_FIELD_PORT environment variable is not set
    die("PLAYING_FIELD_PORT environment variable not set");
}

// Get the certificate settings from the environment variable
$certSettings = json_decode(getenv('CERTIFICATE_SETTINGS'), true);
if ($certSettings === null) {
    // Terminate the script if the CERTIFICATE_SETTINGS environment variable is not set or is invalid
    die("CERTIFICATE_SETTINGS environment variable not set or invalid");
}

// Create an instance of the StrategyController with the playing field port and certificate settings
$controller = new StrategyController($playingFieldPort, $certSettings);

// Handle the incoming request
$controller->handleRequest();

?>
