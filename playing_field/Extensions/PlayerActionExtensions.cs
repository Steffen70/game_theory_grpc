
using Seventy.GameTheory.Model;

namespace Seventy.GameTheory.PlayingField.Extensions;

public static class PlayerActionExtensions
{
    /// <summary>
    /// Converts a <see cref="PlayerAction"/> to an <see cref="OpponentAction"/>.
    /// If the action is null, returns <see cref="OpponentAction.None"/>.
    /// </summary>
    public static OpponentAction ToOpponentAction(this PlayerAction? action) =>
        action switch
        {
            PlayerAction.Cooperate => OpponentAction.Cooperated,
            PlayerAction.Defect => OpponentAction.Defected,
            // Return None if the action is null
            _ => OpponentAction.None
        };
}