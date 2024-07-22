namespace Seventy.GameTheory.PlayingField.Model;

public class CertificateSettings
{
    // The path to the certificate file (.pfx)
    private string? _path = null;
    public string Path
    {
        get => $"{_path ?? throw new Exception("CertificateSettings.Path not set")}.pfx";
        init => _path = value;
    }

    // The password for the certificate file
    public string Password { get; init; } = null!;
}