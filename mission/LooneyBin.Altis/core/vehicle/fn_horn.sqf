params[["_vehicle", objNull, [objNull]], ["_hornType", "", [""]]];
if (isNull _vehicle || _hornType isEqualTo "") exitWith {};
if (!isNil "life_streamerMode" && {life_streamerMode} && {_hornType in PLB_offensiveHorns}) exitWith {};
_vehicle say3D[_hornType, 650];