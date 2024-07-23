<?php

namespace App\Controllers;

use App\Services\StrategyService;
use App\Utils\GrpcUtil;

class StrategyController
{
    private $playingFieldPort;
    private $certSettings;
    private $service;

    /**
     * Constructor for StrategyController.
     *
     * @param string $playingFieldPort The port for the PlayingField service.
     * @param array $certSettings The certificate settings for secure gRPC communication.
     */
    public function __construct($playingFieldPort, $certSettings)
    {
        $this->playingFieldPort = $playingFieldPort;
        $this->certSettings = $certSettings;
        // Initialize the StrategyService with the playing field port and certificate settings.
        $this->service = new StrategyService($playingFieldPort, $certSettings);
    }

    /**
     * Handles the incoming HTTP request.
     */
    public function handleRequest()
    {
        $subscribedStrategies = [];
        $roundResults = [];

        // Fetch subscribed strategies from the PlayingField service.
        try {
            $subscribedStrategies = $this->service->getSubscribedStrategies();
        } catch (\Exception $e) {
            echo "Error: " . $e->getMessage();
        }

        // Check if the request method is POST (form submission).
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $strategies = $_POST['strategies'];
            // Ensure exactly two strategies are selected.
            if (count($strategies) === 2) {
                $strategyA = $strategies[0];
                $strategyB = $strategies[1];
                $rounds = $_POST['rounds'];

                // Run the match between the selected strategies.
                try {
                    $roundResults = $this->service->runMatch($strategyA, $strategyB, $rounds);
                } catch (\Exception $e) {
                    echo "Error: " . $e->getMessage();
                }
            } else {
                echo "Please select exactly two strategies.";
            }
        }

        // Render the results and subscribed strategies.
        $this->render($subscribedStrategies, $roundResults);
    }

    /**
     * Renders the template with the subscribed strategies and round results.
     *
     * @param array $subscribedStrategies The list of subscribed strategies.
     * @param array $roundResults The results of the match rounds.
     */
    private function render($subscribedStrategies, $roundResults)
    {
        // Include the template file for rendering the HTML.
        include '../public/template.php';
    }
}
