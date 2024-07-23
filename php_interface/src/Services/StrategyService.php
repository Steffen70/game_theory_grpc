<?php

namespace App\Services;

use Grpc\ChannelCredentials;
use PlayingField\PlayingFieldClient;
use PlayingField\RunMatchRequest;
use Google\Protobuf\GPBEmpty;
use App\Utils\GrpcUtil;

class StrategyService
{
    private $client;

    /**
     * Constructor for StrategyService.
     *
     * @param string $playingFieldPort The port for the PlayingField service.
     * @param array $certSettings The certificate settings for secure gRPC communication.
     */
    public function __construct($playingFieldPort, $certSettings)
    {
        // Create a gRPC client using the provided port and certificate settings.
        $this->client = GrpcUtil::createClient($playingFieldPort, $certSettings);
    }

    /**
     * Fetches the list of subscribed strategies from the PlayingField service.
     *
     * @return array The list of subscribed strategies.
     */
    public function getSubscribedStrategies()
    {
        // Call the GetSubscribedStrategies RPC and get the response stream.
        $call = $this->client->GetSubscribedStrategies(new GPBEmpty());
        $strategies = [];

        // Iterate over the streamed responses and collect them in an array.
        foreach ($call->responses() as $response) {
            $strategies[] = $response;
        }

        return $strategies;
    }

    /**
     * Runs a match between two strategies for a specified number of rounds.
     *
     * @param string $strategyA The name of the first strategy.
     * @param string $strategyB The name of the second strategy.
     * @param int $rounds The number of rounds to run the match for.
     * @return array The results of each round.
     */
    public function runMatch($strategyA, $strategyB, $rounds)
    {
        // Create a RunMatchRequest with the provided strategies and number of rounds.
        $request = new RunMatchRequest();
        $request->setStrategyA($strategyA);
        $request->setStrategyB($strategyB);
        $request->setRounds($rounds);

        // Call the RunMatch RPC and get the response stream.
        $call = $this->client->RunMatch($request);
        $results = [];

        // Iterate over the streamed responses and collect them in an array.
        foreach ($call->responses() as $response) {
            $results[] = $response;
        }

        return $results;
    }
}
