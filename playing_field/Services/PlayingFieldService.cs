using System.Collections.Concurrent;
using System.Security.Cryptography.X509Certificates;
using Google.Protobuf.WellKnownTypes;
using Grpc.Core;
using Grpc.Net.Client;
using Seventy.GameTheory.PlayingField.Extensions;
using Seventy.GameTheory.PlayingField.Model;
using Seventy.GameTheory.Strategy;
using static Seventy.GameTheory.Strategy.Strategy;

namespace Seventy.GameTheory.PlayingField.Services;

public class PlayingFieldService : PlayingField.PlayingFieldBase
{
    private static readonly ConcurrentDictionary<string, StrategyInfo> _strategies = new();
    private readonly ILogger<PlayingFieldService> _logger;
    private readonly HttpClient _httpClient;

    public PlayingFieldService(ILogger<PlayingFieldService> logger, IHttpClientFactory httpClientFactory)
    {
        _logger = logger;
        _httpClient = httpClientFactory.CreateClient("customHttpClient");
    }

    public override Task<Empty> Subscribe(StrategyInfo info, ServerCallContext context)
    {
        // Add the strategy info object to the dictionary
        _strategies[info.Name] = info;

        // Log the subscription
        _logger.LogInformation($"Strategy {info.Name} subscribed.");

        // Return an empty response
        return Task.FromResult(new Empty());
    }

    public async override Task GetSubscribedStrategies(Empty _, IServerStreamWriter<StrategyInfo> responseStream, ServerCallContext context)
    {
        // Return all the strategy info objects
        foreach (var info in _strategies)
            await responseStream.WriteAsync(info.Value);
    }

    public async override Task RunMatch(RunMatchRequest request, IServerStreamWriter<RoundResult> responseStream, ServerCallContext context)
    {
        // Check if the strategies exist
        // - else throw an exception
        if (!_strategies.TryGetValue(request.StrategyA, out var strategyA) || !_strategies.TryGetValue(request.StrategyB, out var strategyB))
            throw new RpcException(new Status(StatusCode.NotFound, "One or both strategies not found."));


        var channelA = GrpcChannel.ForAddress(strategyA.Address, new GrpcChannelOptions { HttpClient = _httpClient });
        var channelB = GrpcChannel.ForAddress(strategyB.Address, new GrpcChannelOptions { HttpClient = _httpClient });

        var clientA = new StrategyClient(channelA);
        var clientB = new StrategyClient(channelB);

        // Create a RoundResult object to store the results of each round
        // - set it outside the loop to store the previous round's results
        RoundResult? result = null;

        // Run the match for the specified number of rounds
        for (int round = 1; round <= request.Rounds; round++)
        {
            try
            {
                // Invoke the strategies and pass the opponent's action from the previous round
                var responseA = await clientA.HandleRequestAsync(new HandleRequestRequest { OpponentAction = (result?.AnswerB).ToOpponentAction() });
                var responseB = await clientB.HandleRequestAsync(new HandleRequestRequest { OpponentAction = (result?.AnswerA).ToOpponentAction() });

                // Create a RoundResult object to store the results of the current round
                result = new RoundResult
                {
                    StrategyA = request.StrategyA,
                    StrategyB = request.StrategyB,
                    AnswerA = responseA.PlayerAction,
                    AnswerB = responseB.PlayerAction,
                    RoundNumber = round
                };

                // Send the results to the client
                await responseStream.WriteAsync(result);
            }
            catch (Exception e)
            {
                _logger.LogError(e.Message);
                throw new RpcException(new Status(StatusCode.Internal, "Error running the match."));
            }
        }
    }

}