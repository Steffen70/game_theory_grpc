namespace Seventy.GameTheory.PlayingField.Model;

public class CertificateSettings
{
    // The path to the certificate file (without file extension)
    public string Path { get; init; } = null!;

    // The password for the certificate file
    public string Password { get; init; } = null!;
}