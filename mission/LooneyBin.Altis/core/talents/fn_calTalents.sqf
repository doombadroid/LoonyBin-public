life_currentTalents =
switch (true) do {case (life_side_exp >= 14200): {28};
    case (life_side_exp >= 13000): {27};
    case (life_side_exp >= 12000): {26};
    case (life_side_exp >= 11000): {25};
    case (life_side_exp >= 10400): {24};
    case (life_side_exp >= 9500): {23};
    case (life_side_exp >= 8700): {22};
    case (life_side_exp >= 8000): {21};
    case (life_side_exp >= 7200): {20};
    case (life_side_exp >= 6500): {19};
    case (life_side_exp >= 5900): {18};
    case (life_side_exp >= 5200): {17};
    case (life_side_exp >= 4600): {16};
    case (life_side_exp >= 4100): {15};
    case (life_side_exp >= 3500): {14};
    case (life_side_exp >= 3100): {13};
    case (life_side_exp >= 2600): {12};
    case (life_side_exp >= 2200): {11};
    case (life_side_exp >= 1800): {10};
    case (life_side_exp >= 1500): {9};
    case (life_side_exp >= 1200): {8};
    case (life_side_exp >= 920): {7};
    case (life_side_exp >= 690): {6};
    case (life_side_exp >= 490): {5};
    case (life_side_exp >= 320): {4};
    case (life_side_exp >= 190): {3};
    case (life_side_exp >= 97): {2};
    case (life_side_exp >= 36): {1};
    default {0};};
// owner 2026-06-24: MAX TALENT POINTS baked in PERMANENTLY -- grant the FULL per-side cap regardless of XP (no grind)
// and independent of beta god-stats (PLB_betaMaxStats), so it survives public launch. The XP switch above is now
// vestigial (overridden). To restore XP-earned points later, change these back to selectMin[life_currentTalents, CAP].
if (playerSide isEqualTo west) then {life_currentTalents = life_maxTalents};
if (playerSide isEqualTo independent) then {life_currentTalents = 16};
if (playerSide isEqualTo civilian) then {life_currentTalents = 20};
// LooneyBin 2026-07-16: BUYABLE TALENT POINTS -- purchased extras (talent_points table, loaded at login via
// TON_fnc_talentPointsSRV -> life_fnc_talentPointsRecv) stack on top of the free cap. The menu's Points cap
// display tracks up with it.
private _boughtPts = missionNamespace getVariable ["life_boughtTalents", 0];
life_currentTalents = life_currentTalents + _boughtPts;
if (!isNil "life_maxTalents") then { life_maxTalents = life_maxTalents max life_currentTalents; };
life_currentTalents;