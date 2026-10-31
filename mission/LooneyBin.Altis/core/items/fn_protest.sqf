if (life_protesting) exitWith {};
if !(isNull life_object_inhand) exitWith {["You're already holding an object.", "basic"] spawn life_fnc_handleMessage};
private _started = time;
life_protesting = true;
if !("_salute" in (animationState player)) then {player playAction "Salute"};
waitUntil {"_salute" in (animationState player) || time - _started > 5};
if (time - _started > 5) exitWith {life_protesting = false};
closeDialog 0;
titleText["Rabble rabble rabble!", "PLAIN"];
life_object_inhand = "Land_Poster_04_F"
createVehicle[0, 0, 0];
life_object_inhand attachTo[player, [0, 0, 0.6], "righthand"];
life_object_inhand setVectorUp[0, 90, -1];
life_object_inhand setMass 0;
waitUntil {!("_salute" in (animationState player))};
deleteVehicle life_object_inhand;
life_protesting = false;