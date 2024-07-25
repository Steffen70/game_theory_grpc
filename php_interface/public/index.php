<?php
/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 * 
 * Author: Steffen70 <steffen@seventy.mx>
 * Creation Date: 2024-07-25
 * 
 * Contributors:
 * - Contributor Name <contributor@example.com>
 */

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
