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
