<!DOCTYPE html>
<!--
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.

Author: Steffen70 <steffen@seventy.mx>
Creation Date: 2024-07-25

Contributors:
Contributor Name <contributor@example.com>
-->

<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Strategy Match</title>
</head>

<body>
    <h1>Strategy Match</h1>

    <form method="POST">
        <h2>Select Strategies</h2>
        <?php foreach ($subscribedStrategies as $strategy) : ?>
            <label>
                <input type="checkbox" name="strategies[]" value="<?= $strategy->getName() ?>">
                <?= $strategy->getName() ?>
            </label><br>
        <?php endforeach; ?>
        <input type="hidden" name="rounds" value="10">
        <button type="submit">Run Match</button>
    </form>

    <?php if (!empty($roundResults)) : ?>
        <h2>Round Results</h2>
        <ul>
            <?php foreach ($roundResults as $result) : ?>
                <li>Round <?= $result->getRoundNumber() ?>: <?= $result->getStrategyA() ?> (<?= $result->getAnswerA() ?>) vs <?= $result->getStrategyB() ?> (<?= $result->getAnswerB() ?>)</li>
            <?php endforeach; ?>
        </ul>
    <?php endif; ?>
</body>

</html>