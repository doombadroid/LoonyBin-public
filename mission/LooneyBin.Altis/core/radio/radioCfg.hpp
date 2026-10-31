/*
    LooneyBin car radio -- station config. Read server-side by TON_fnc_radioSRV (broadcasts the current track per
    station) + client-side by the HUD, via  missionConfigFile >> "PLB_Radio_Cfg" >> "AutoRadio" >> ...

    2026-07-06: ALL MUSIC WIPED + stations SEGREGATED. Each station now has its OWN song list (before, Origin+KHR
    shared one list and Pulse+Classico+Anarchy shared another -- that was the cross-station "bleed"). Starting fresh,
    genre by genre. To add a song to a station: (1) drop <file>.ogg in sounds\radio\, (2) add a CfgSounds class in
    CfgSounds.hpp, (3) add its class name to that station's AUTORADIO_RadioNN[] + a display title to ...NNName[] +
    the length in whole seconds to ...NNLengh[] (the three arrays stay parallel / index-aligned).
    An empty station simply broadcasts nothing (silent) until it has songs.

    Stations: 01 Origin / 02 KHR / 03 Pulse / 04 Classico (classical) / 05 Anarchy.
*/
class PLB_Radio_Cfg {class AutoRadio {
        AUTORADIO_Radio[]      = { "AUTORADIO_Radio01", "AUTORADIO_Radio02", "AUTORADIO_Radio03", "AUTORADIO_Radio04", "AUTORADIO_Radio05" };
        AUTORADIO_RadioName[]  = { "AUTORADIO_Radio01Name", "AUTORADIO_Radio02Name", "AUTORADIO_Radio03Name", "AUTORADIO_Radio04Name", "AUTORADIO_Radio05Name" };
        AUTORADIO_RadioLengh[] = { "AUTORADIO_Radio01Lengh", "AUTORADIO_Radio02Lengh", "AUTORADIO_Radio03Lengh", "AUTORADIO_Radio04Lengh", "AUTORADIO_Radio05Lengh" };
        AUTORADIO_RadioColor[] = { "[0.988, 0.816, 0.062, 1]", "[0.203, 0.484, 0.203, 1]", "[0.683, 0.195, 0.511, 1]", "[0.121, 0.398, 0.660, 1]", "[0.796, 0, 0, 1]" };
        AUTORADIO_RadioLogo[]  = { "images\radio\OriginLogo.paa", "images\radio\KHRLogo.paa", "images\radio\PulseLogo.paa", "images\radio\ClassicoLogo.paa", "images\radio\AnarchyLogo.paa" };

        // 01 Origin
        AUTORADIO_Radio01[]      = {};
        AUTORADIO_Radio01Name[]  = {};
        AUTORADIO_Radio01Lengh[] = {};

        // 02 KHR
        AUTORADIO_Radio02[]      = {};
        AUTORADIO_Radio02Name[]  = {};
        AUTORADIO_Radio02Lengh[] = {};

        // 03 Pulse
        AUTORADIO_Radio03[]      = { "radio_pe_cinema", "radio_pe_vondutch", "radio_pe_onemoretime", "radio_pe_ghosts", "radio_pe_oneminute", "radio_pe_stereolove", "radio_pe_scientist", "radio_pe_stayhouse", "radio_pe_rayofsolar", "radio_pe_losangeles", "radio_ad_malden" };
        AUTORADIO_Radio03Name[]  = { "<t shadow='0' font='PuristaBold' color='#191919'>CINEMA (SKRILLEX RMX)<br/><t font='PuristaLight' size='0.8'>BENNY BENASSI</t>", "<t shadow='0' font='PuristaBold' color='#191919'>VON DUTCH<br/><t font='PuristaLight' size='0.8'>CHARLI XCX</t>", "<t shadow='0' font='PuristaBold' color='#191919'>ONE MORE TIME<br/><t font='PuristaLight' size='0.8'>DAFT PUNK</t>", "<t shadow='0' font='PuristaBold' color='#191919'>GHOSTS 'N' STUFF<br/><t font='PuristaLight' size='0.8'>DEADMAU5</t>", "<t shadow='0' font='PuristaBold' color='#191919'>ONE MINUTE (DOTEXE RMX)<br/><t font='PuristaLight' size='0.8'>KREWELLA</t>", "<t shadow='0' font='PuristaBold' color='#191919'>STEREO LOVE<br/><t font='PuristaLight' size='0.8'>EDWARD MAYA</t>", "<t shadow='0' font='PuristaBold' color='#191919'>THE SCIENTIST<br/><t font='PuristaLight' size='0.8'>FLUX PAVILION</t>", "<t shadow='0' font='PuristaBold' color='#191919'>STAY AT YOUR HOUSE<br/><t font='PuristaLight' size='0.8'>ROSA WALTON</t>", "<t shadow='0' font='PuristaBold' color='#191919'>RAY OF SOLAR<br/><t font='PuristaLight' size='0.8'>SWEDISH HOUSE MAFIA</t>", "<t shadow='0' font='PuristaBold' color='#191919'>LOS ANGELES<br/><t font='PuristaLight' size='0.8'>THE MIDNIGHT</t>", "<t shadow='0' font='PuristaBold' color='#191919'>MOVING TO MALDEN<br/><t font='PuristaLight' size='0.8'>LOONYBIN ANNOUNCEMENT</t>" };
        AUTORADIO_Radio03Lengh[] = { 308, 164, 320, 188, 287, 184, 293, 247, 188, 389, 145 };

        // 04 Classico (classical)
        AUTORADIO_Radio04[]      = { "radio_cl_vivaldi_spring", "radio_cl_beethoven_5th", "radio_cl_clair_de_lune", "radio_cl_nachtmusik", "radio_cl_moonlight", "radio_cl_canon_d", "radio_cl_valkyries", "radio_cl_swan_lake", "radio_cl_bach_cello", "radio_cl_erika", "radio_ad_malden" };
        AUTORADIO_Radio04Name[]  = { "<t shadow='0' font='PuristaBold' color='#191919'>SPRING (ALLEGRO)<br/><t font='PuristaLight' size='0.8'>VIVALDI</t>", "<t shadow='0' font='PuristaBold' color='#191919'>SYMPHONY NO. 5<br/><t font='PuristaLight' size='0.8'>BEETHOVEN</t>", "<t shadow='0' font='PuristaBold' color='#191919'>CLAIR DE LUNE<br/><t font='PuristaLight' size='0.8'>DEBUSSY</t>", "<t shadow='0' font='PuristaBold' color='#191919'>EINE KLEINE NACHTMUSIK<br/><t font='PuristaLight' size='0.8'>MOZART</t>", "<t shadow='0' font='PuristaBold' color='#191919'>MOONLIGHT SONATA<br/><t font='PuristaLight' size='0.8'>BEETHOVEN</t>", "<t shadow='0' font='PuristaBold' color='#191919'>CANON IN D<br/><t font='PuristaLight' size='0.8'>PACHELBEL</t>", "<t shadow='0' font='PuristaBold' color='#191919'>RIDE OF THE VALKYRIES<br/><t font='PuristaLight' size='0.8'>WAGNER</t>", "<t shadow='0' font='PuristaBold' color='#191919'>SWAN LAKE (SCENE I)<br/><t font='PuristaLight' size='0.8'>TCHAIKOVSKY</t>", "<t shadow='0' font='PuristaBold' color='#191919'>CELLO SUITE NO.1 - PRELUDE<br/><t font='PuristaLight' size='0.8'>BACH</t>", "<t shadow='0' font='PuristaBold' color='#191919'>ERIKA<br/><t font='PuristaLight' size='0.8'>MARCH</t>", "<t shadow='0' font='PuristaBold' color='#191919'>MOVING TO MALDEN<br/><t font='PuristaLight' size='0.8'>LOONYBIN ANNOUNCEMENT</t>" };
        AUTORADIO_Radio04Lengh[] = { 195, 406, 313, 347, 392, 376, 300, 174, 195, 182, 145 };

        // 05 Anarchy
        AUTORADIO_Radio05[]      = { "radio_ar_thunderstruck", "radio_ar_schoolsout", "radio_ar_reaper", "radio_ar_fortunateson", "radio_ar_derkommissar", "radio_ar_madeforlovin", "radio_ar_sweethome", "radio_ar_drfeelgood", "radio_ar_crazytrain", "radio_ar_tomsawyer", "radio_ad_malden" };
        AUTORADIO_Radio05Name[]  = { "<t shadow='0' font='PuristaBold' color='#191919'>THUNDERSTRUCK<br/><t font='PuristaLight' size='0.8'>AC/DC</t>", "<t shadow='0' font='PuristaBold' color='#191919'>SCHOOL'S OUT<br/><t font='PuristaLight' size='0.8'>ALICE COOPER</t>", "<t shadow='0' font='PuristaBold' color='#191919'>(DON'T FEAR) THE REAPER<br/><t font='PuristaLight' size='0.8'>BLUE OYSTER CULT</t>", "<t shadow='0' font='PuristaBold' color='#191919'>FORTUNATE SON<br/><t font='PuristaLight' size='0.8'>CREEDENCE CLEARWATER REVIVAL</t>", "<t shadow='0' font='PuristaBold' color='#191919'>DER KOMMISSAR<br/><t font='PuristaLight' size='0.8'>AFTER THE FIRE</t>", "<t shadow='0' font='PuristaBold' color='#191919'>I WAS MADE FOR LOVIN' YOU<br/><t font='PuristaLight' size='0.8'>KISS</t>", "<t shadow='0' font='PuristaBold' color='#191919'>SWEET HOME ALABAMA<br/><t font='PuristaLight' size='0.8'>LYNYRD SKYNYRD</t>", "<t shadow='0' font='PuristaBold' color='#191919'>DR. FEELGOOD<br/><t font='PuristaLight' size='0.8'>MOTLEY CRUE</t>", "<t shadow='0' font='PuristaBold' color='#191919'>CRAZY TRAIN<br/><t font='PuristaLight' size='0.8'>OZZY OSBOURNE</t>", "<t shadow='0' font='PuristaBold' color='#191919'>TOM SAWYER<br/><t font='PuristaLight' size='0.8'>RUSH</t>", "<t shadow='0' font='PuristaBold' color='#191919'>MOVING TO MALDEN<br/><t font='PuristaLight' size='0.8'>LOONYBIN ANNOUNCEMENT</t>" };
        AUTORADIO_Radio05Lengh[] = { 293, 209, 309, 137, 341, 238, 285, 285, 226, 275, 145 };};};
