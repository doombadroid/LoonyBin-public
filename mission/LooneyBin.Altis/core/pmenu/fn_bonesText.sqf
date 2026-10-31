/*
    life_fnc_bonesText  (client) -- an incoming text from Ben Bones Official. Server pushes the reply here.
    Styled notification + drops into the phone inbox (life_messages) like any other text.
*/
params [["_msg", "", [""]]];
if (_msg isEqualTo "") exitWith {};
life_messages pushBack ["Ben Bones Official", format [">>>MESSAGE FROM Ben Bones Official: %1", _msg], time];
[format ["<t size='1.25' color='#e8b23a'>Ben Bones Official</t><br/><t size='1.05'>%1</t>", _msg], "bones"] spawn life_fnc_handleMessage;
