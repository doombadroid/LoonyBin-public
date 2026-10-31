private _side =
switch (playerSide) do {case west: {"cop"};
    case civilian: {"civ"};
    case independent: {"med"};
    default {""};}; _side