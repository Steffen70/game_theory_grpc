<?php

require './vendor/autoload.php';

use Grpc\ChannelCredentials;
use PlayingField\PlayingFieldClient;
use PlayingField\RunMatchRequest;
use Google\Protobuf\GPBEmpty;

// Function to get the list of subscribed strategies
function getSubscribedStrategies($playingFieldClient) {
    error_log("Fetching subscribed strategies...");
    $call = $playingFieldClient->GetSubscribedStrategies(new GPBEmpty());
    $strategies = [];

    // Iterate over the streamed responses
    foreach ($call->responses() as $response) {
        $strategies[] = $response;
    }

    error_log("Fetched " . count($strategies) . " strategies.");
    return $strategies;
}

// Function to run the match and get the results
function runMatch($playingFieldClient, $strategyA, $strategyB, $rounds) {
    error_log("Running match between $strategyA and $strategyB for $rounds rounds.");
    $request = new RunMatchRequest();
    $request->setStrategyA($strategyA);
    $request->setStrategyB($strategyB);
    $request->setRounds($rounds);

    $call = $playingFieldClient->RunMatch($request);
    $results = [];

    // Iterate over the streamed responses
    foreach ($call->responses() as $response) {
        $results[] = $response;
    }

    error_log("Match completed with " . count($results) . " results.");
    return $results;
}

// Get the playing field port from the environment variable
$playingFieldPort = getenv('PLAYING_FIELD_PORT');
if ($playingFieldPort === false) {
    die("PLAYING_FIELD_PORT environment variable not set");
}

// Get the certificate settings from the environment variable
$certSettings = json_decode(getenv('CERTIFICATE_SETTINGS'), true);
if ($certSettings === null) {
    die("CERTIFICATE_SETTINGS environment variable not set or invalid");
}

error_log("Connecting to PlayingField service on port $playingFieldPort...");
// Initialize gRPC client with TLS credentials
$playingFieldClient = new PlayingFieldClient("localhost:$playingFieldPort", [
    'credentials' => ChannelCredentials::createSsl(file_get_contents($certSettings['path'] . '.crt'))
]);

$subscribedStrategies = [];
$roundResults = [];

try {
    $subscribedStrategies = getSubscribedStrategies($playingFieldClient);
} catch (Exception $e) {
    error_log("Error fetching subscribed strategies: " . $e->getMessage());
    echo "Error: " . $e->getMessage();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    error_log("Handling form submission...");
    $strategies = $_POST['strategies'];
    if (count($strategies) === 2) {
        $strategyA = $strategies[0];
        $strategyB = $strategies[1];
        $rounds = $_POST['rounds'];

        try {
            $roundResults = runMatch($playingFieldClient, $strategyA, $strategyB, $rounds);
        } catch (Exception $e) {
            error_log("Error running match: " . $e->getMessage());
            echo "Error: " . $e->getMessage();
        }
    } else {
        error_log("Invalid number of strategies selected.");
        echo "Please select exactly two strategies.";
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Strategy Match</title>
</head>
<body>
    <h1>Strategy Match</h1>

    <form method="POST">
        <h2>Select Strategies</h2>
        <?php foreach ($subscribedStrategies as $strategy): ?>
            <label>
                <input type="checkbox" name="strategies[]" value="<?= $strategy->getName() ?>">
                <?= $strategy->getName() ?>
            </label><br>
        <?php endforeach; ?>
        <input type="hidden" name="rounds" value="10">
        <button type="submit">Run Match</button>
    </form>

    <?php if (!empty($roundResults)): ?>
        <h2>Round Results</h2>
        <ul>
            <?php foreach ($roundResults as $result): ?>
                <li>Round <?= $result->getRoundNumber() ?>: <?= $result->getStrategyA() ?> (<?= $result->getAnswerA() ?>) vs <?= $result->getStrategyB() ?> (<?= $result->getAnswerB() ?>)</li>
            <?php endforeach; ?>
        </ul>
    <?php endif; ?>
</body>
</html>
