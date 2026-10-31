/*
    life_fnc_applyRandomBillboardTexture  (LooneyBin)
    Restored billboard rotation -- deobf had gutted this to a single static placeholder image (no list/timer).
    Each rotating billboard registers itself + immediately gets a random ad; a SINGLE 5-minute loop (started
    once) re-rolls every registered billboard. Per-client (setObjectTexture is a local visual). Owner can add
    ads to PLB_billboardAds or change PLB_billboardInterval.
*/
params ["_obj_main", "_selectionNumber"];
PLB_billboardAds = ["images\billboard1.jpg", "images\billboard2.jpg"];
PLB_billboardInterval = 300;   // owner 2026-06-11: rotate every 5 minutes

if (isNil "PLB_billboardObjs") then { PLB_billboardObjs = []; };
PLB_billboardObjs pushBackUnique [_obj_main, _selectionNumber];
_obj_main setObjectTexture [_selectionNumber, selectRandom PLB_billboardAds];

if (isNil "PLB_billboardRotationStarted") then {PLB_billboardRotationStarted = true; [{{if !(isNull (_x select 0)) then {
                (_x select 0) setObjectTexture [(_x select 1), selectRandom PLB_billboardAds];};} forEach PLB_billboardObjs;
    }, createHashMap, PLB_billboardInterval] call life_fnc_addPerFrameHandler;};
