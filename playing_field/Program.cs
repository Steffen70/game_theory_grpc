using System.Security.Cryptography.X509Certificates;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using System.Text.Json;

using Seventy.GameTheory.PlayingField.Model;
using Seventy.GameTheory.PlayingField.Extensions;

const string CertificateSettingsEnvironmentVariable = "CERTIFICATE_SETTINGS";
const string ApiPortEnvironmentVariable = "PLAYING_FIELD_PORT";

const string CorsPolicyName = "ClientPolicy";

var builder = WebApplication.CreateBuilder(args);

// Get the certificate settings from the environment variable
var certSettings = JsonSerializer.Deserialize<CertificateSettings>(
    Environment.GetEnvironmentVariable(CertificateSettingsEnvironmentVariable) ?? throw new InvalidOperationException($"{CertificateSettingsEnvironmentVariable} environment variable not set"),
    new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase }
)!;

// Get the API port from the environment variable
var apiPort = int.Parse(Environment.GetEnvironmentVariable(ApiPortEnvironmentVariable) ?? throw new InvalidOperationException($"{ApiPortEnvironmentVariable} environment variable not set"));

// Configure the Kestrel server with the certificate and the API port
builder.WebHost.ConfigureKestrel(options => options.ListenLocalhost(apiPort, listenOptions =>
{
    listenOptions.UseHttps(new X509Certificate2(certSettings.Path, certSettings.Password));
    // Enable HTTP/2 and HTTP/1.1 for gRPC-Web compatibility
    listenOptions.Protocols = HttpProtocols.Http1AndHttp2;
}));

// Allow all origins
builder.Services.AddCors(o => o.AddPolicy(CorsPolicyName, policyBuilder =>
{
    policyBuilder
        // Allow all ports on localhost
        .SetIsOriginAllowed(origin => new Uri(origin).Host == "localhost")
        // Allow all methods and headers
        .AllowAnyMethod()
        .AllowAnyHeader()
        // Expose the gRPC-Web headers
        .WithExposedHeaders("Grpc-Status", "Grpc-Message", "Grpc-Encoding", "Grpc-Accept-Encoding");
}));

builder.Services.AddGrpc();

var app = builder.Build();

// Configure the HTTP request pipeline.

// Enable the HTTPS redirection - only use HTTPS
app.UseHttpsRedirection();

// Enable CORS - allow all origins and add gRPC-Web headers
app.UseCors(CorsPolicyName);

// Enable gRPC-Web for all services
app.UseGrpcWeb(new() { DefaultEnabled = true });

// Add all services in the Services namespace
app.MapGrpcServices();

app.Run();