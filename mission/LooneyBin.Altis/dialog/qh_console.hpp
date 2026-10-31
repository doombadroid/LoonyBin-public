// QUICKHACK CONSOLE (idd 941500) -- ICEBREAKER OS (civ) + TAL OS (cop), no-goggles quickhack firing.
// 1:1 with the approved deck render (scratchpad/deck_apps.html): the whole deck CHROME is a baked backdrop
// (images\cyberdeck\deck_ice|tal.paa, rendered headless at 1088x675 = the render's real aspect), and every
// live value is an overlay control pixel-aligned to the render's measured element boxes (scratchpad/deck_bake).
// Coords are in the render's own grid: deck spans 32.237 cells wide x 20 tall, centred. UI_GRID coords BARE.
#define QS 1.2   // whole-console scale (owner 2026-07-22: 20% larger); centred on UI_GRID_X/Y
class qh_console {idd = 941500; name = "qh_console"; movingEnable = 0; enableSimulation = 1;
    onLoad = "uiNamespace setVariable ['qh_console', _this select 0]; [] call life_fnc_qhConsole;";
    onUnload = "PLB_qhConsoleOpen = false;";

    class OvTxt : Life_RscStructuredText { idc=-1; };
    class OvPic : CBPicBase { idc=-1; text=""; colorText[]={1,1,1,1}; };
    // Life_RscButton has no `type` in this build (warns + dead); Life_RscButtonMenu (type 16) is what the whole
    // codebase uses. Transparent textures -> invisible hit / label-only button over the baked chrome.
    class OvHit : Life_RscButtonMenu { idc=-1; text=""; sizeEx=0.405*QS*UI_GRID_H; colorText[]={0,0,0,0}; colorBackground[]={0,0,0,0}; colorBackground2[]={0,0,0,0}; colorFocused[]={1,1,1,0.05}; colorBackgroundActive[]={1,1,1,0.06}; animTextureNormal="#(argb,8,8,3)color(1,1,1,0)"; animTextureOver="#(argb,8,8,3)color(1,1,1,0.05)"; animTextureFocused="#(argb,8,8,3)color(1,1,1,0)"; animTexturePressed="#(argb,8,8,3)color(1,1,1,0.10)"; animTextureDefault="#(argb,8,8,3)color(1,1,1,0)"; };
    class SwBtn : Life_RscButtonMenu { idc=-1; text=""; sizeEx=0.405*QS*UI_GRID_H; colorText[]={0.7,0.78,0.73,1}; colorBackground[]={0,0,0,0}; colorBackground2[]={0,0,0,0}; colorFocused[]={1,1,1,0.06}; colorBackgroundActive[]={1,1,1,0.06}; animTextureNormal="#(argb,8,8,3)color(1,1,1,0)"; animTextureOver="#(argb,8,8,3)color(1,1,1,0.06)"; animTextureFocused="#(argb,8,8,3)color(1,1,1,0)"; animTexturePressed="#(argb,8,8,3)color(1,1,1,0.10)"; animTextureDefault="#(argb,8,8,3)color(1,1,1,0)"; };

    class controlsBackground {
        class Frame : CBPicBase { idc=941504; text="images\cyberdeck\deck_ice.paa"; colorText[]={1,1,1,1}; x=-16.119*QS*UI_GRID_W + UI_GRID_X; y=-10.0*QS*UI_GRID_H + UI_GRID_Y; w=32.237*QS*UI_GRID_W; h=20.0*QS*UI_GRID_H; };
    };

    class controls {
        // ---- STATUS (right side: cash / clock / count) ----
        class StatusR : OvTxt { idc=941502; size=0.52*QS*UI_GRID_H; x=6.92*QS*UI_GRID_W + UI_GRID_X; y=-9.052*QS*UI_GRID_H + UI_GRID_Y; w=6.858*QS*UI_GRID_W; h=0.578*QS*UI_GRID_H; };

        // ---- TARGET SCOPE ----
        class TgtIcon : OvPic { idc=941506; x=-11.467*QS*UI_GRID_W + UI_GRID_X; y=-5.037*QS*UI_GRID_H + UI_GRID_Y; w=1.541*QS*UI_GRID_W; h=1.541*QS*UI_GRID_H; };
        class TgtName : OvTxt { idc=941511; size=0.64*QS*UI_GRID_H; x=-14.696*QS*UI_GRID_W + UI_GRID_X; y=-1.674*QS*UI_GRID_H + UI_GRID_Y; w=8.0*QS*UI_GRID_W; h=0.711*QS*UI_GRID_H; };
        // v2: kind+dist merged into ONE meta line under the name (941512); 941513 is parked (driver clears it)
        class TgtKind : OvTxt { idc=941512; size=0.42*QS*UI_GRID_H; x=-14.696*QS*UI_GRID_W + UI_GRID_X; y=-0.844*QS*UI_GRID_H + UI_GRID_Y; w=8.0*QS*UI_GRID_W; h=0.6*QS*UI_GRID_H; };
        class TgtDist : OvTxt { idc=941513; size=0.459*QS*UI_GRID_H; x=-10.0*QS*UI_GRID_W + UI_GRID_X; y=-0.696*QS*UI_GRID_H + UI_GRID_Y; w=0; h=0; };
        class TgtL2 : OvTxt { idc=941514; size=0.459*QS*UI_GRID_H; x=-14.696*QS*UI_GRID_W + UI_GRID_X; y=0.081*QS*UI_GRID_H + UI_GRID_Y; w=3.0*QS*UI_GRID_W; h=0.511*QS*UI_GRID_H; };
        class TgtDriver : OvTxt { idc=941515; size=0.459*QS*UI_GRID_H; x=-10.7*QS*UI_GRID_W + UI_GRID_X; y=0.081*QS*UI_GRID_H + UI_GRID_Y; w=4.0*QS*UI_GRID_W; h=0.511*QS*UI_GRID_H; };
        class TgtFlags : OvTxt { idc=941516; size=0.4*QS*UI_GRID_H; x=-14.696*QS*UI_GRID_W + UI_GRID_X; y=0.919*QS*UI_GRID_H + UI_GRID_Y; w=8.0*QS*UI_GRID_W; h=0.681*QS*UI_GRID_H; };

        // ---- v2 NEARBY list (baked row plates; these are the live overlays) ----
        // rows measured from the bake: x=-14.756 w=8.119 h=1.244, y = 2.230 / 3.681 / 5.133 / 6.585
        class NearSel : Life_RscText { idc=941529; colorBackground[]={0.784,0.961,0.227,0.10}; x=UI_GRID_X; y=UI_GRID_Y; w=0; h=0; };  // selection wash, driver positions+tints
        class NearG0 : OvPic { idc=941536; x=-14.46*QS*UI_GRID_W + UI_GRID_X; y=2.467*QS*UI_GRID_H + UI_GRID_Y; w=0.77*QS*UI_GRID_W; h=0.77*QS*UI_GRID_H; };
        class NearG1 : OvPic { idc=941537; x=-14.46*QS*UI_GRID_W + UI_GRID_X; y=3.918*QS*UI_GRID_H + UI_GRID_Y; w=0.77*QS*UI_GRID_W; h=0.77*QS*UI_GRID_H; };
        class NearG2 : OvPic { idc=941538; x=-14.46*QS*UI_GRID_W + UI_GRID_X; y=5.370*QS*UI_GRID_H + UI_GRID_Y; w=0.77*QS*UI_GRID_W; h=0.77*QS*UI_GRID_H; };
        class NearG3 : OvPic { idc=941539; x=-14.46*QS*UI_GRID_W + UI_GRID_X; y=6.822*QS*UI_GRID_H + UI_GRID_Y; w=0.77*QS*UI_GRID_W; h=0.77*QS*UI_GRID_H; };
        class NearN0 : OvTxt { idc=941524; size=0.42*QS*UI_GRID_H; x=-13.452*QS*UI_GRID_W + UI_GRID_X; y=2.51*QS*UI_GRID_H + UI_GRID_Y; w=5.6*QS*UI_GRID_W; h=0.72*QS*UI_GRID_H; };
        class NearN1 : OvTxt { idc=941525; size=0.42*QS*UI_GRID_H; x=-13.452*QS*UI_GRID_W + UI_GRID_X; y=3.961*QS*UI_GRID_H + UI_GRID_Y; w=5.6*QS*UI_GRID_W; h=0.72*QS*UI_GRID_H; };
        class NearN2 : OvTxt { idc=941526; size=0.42*QS*UI_GRID_H; x=-13.452*QS*UI_GRID_W + UI_GRID_X; y=5.413*QS*UI_GRID_H + UI_GRID_Y; w=5.6*QS*UI_GRID_W; h=0.72*QS*UI_GRID_H; };
        class NearN3 : OvTxt { idc=941527; size=0.42*QS*UI_GRID_H; x=-13.452*QS*UI_GRID_W + UI_GRID_X; y=6.865*QS*UI_GRID_H + UI_GRID_Y; w=5.6*QS*UI_GRID_W; h=0.72*QS*UI_GRID_H; };
        class NearD0 : OvTxt { idc=941532; size=0.38*QS*UI_GRID_H; x=-9.1*QS*UI_GRID_W + UI_GRID_X; y=2.55*QS*UI_GRID_H + UI_GRID_Y; w=2.167*QS*UI_GRID_W; h=0.65*QS*UI_GRID_H; };
        class NearD1 : OvTxt { idc=941533; size=0.38*QS*UI_GRID_H; x=-9.1*QS*UI_GRID_W + UI_GRID_X; y=4.001*QS*UI_GRID_H + UI_GRID_Y; w=2.167*QS*UI_GRID_W; h=0.65*QS*UI_GRID_H; };
        class NearD2 : OvTxt { idc=941534; size=0.38*QS*UI_GRID_H; x=-9.1*QS*UI_GRID_W + UI_GRID_X; y=5.453*QS*UI_GRID_H + UI_GRID_Y; w=2.167*QS*UI_GRID_W; h=0.65*QS*UI_GRID_H; };
        class NearD3 : OvTxt { idc=941535; size=0.38*QS*UI_GRID_H; x=-9.1*QS*UI_GRID_W + UI_GRID_X; y=6.905*QS*UI_GRID_H + UI_GRID_Y; w=2.167*QS*UI_GRID_W; h=0.65*QS*UI_GRID_H; };
        // footer strip (rule is baked)
        class NearFootL : OvTxt { idc=941530; size=0.38*QS*UI_GRID_H; x=-14.696*QS*UI_GRID_W + UI_GRID_X; y=8.09*QS*UI_GRID_H + UI_GRID_Y; w=4.5*QS*UI_GRID_W; h=0.65*QS*UI_GRID_H; };
        class NearFootR : OvTxt { idc=941531; size=0.38*QS*UI_GRID_H; x=-11.3*QS*UI_GRID_W + UI_GRID_X; y=8.09*QS*UI_GRID_H + UI_GRID_Y; w=4.37*QS*UI_GRID_W; h=0.65*QS*UI_GRID_H; };
        // whole-row hit buttons ON TOP of the row overlays (structured text would eat the click)
        class Sw0 : SwBtn { idc=941520; onButtonClick="[0] call life_fnc_qhConsolePick;"; x=-14.756*QS*UI_GRID_W + UI_GRID_X; y=2.230*QS*UI_GRID_H + UI_GRID_Y; w=8.119*QS*UI_GRID_W; h=1.244*QS*UI_GRID_H; };
        class Sw1 : SwBtn { idc=941521; onButtonClick="[1] call life_fnc_qhConsolePick;"; x=-14.756*QS*UI_GRID_W + UI_GRID_X; y=3.681*QS*UI_GRID_H + UI_GRID_Y; w=8.119*QS*UI_GRID_W; h=1.244*QS*UI_GRID_H; };
        class Sw2 : SwBtn { idc=941522; onButtonClick="[2] call life_fnc_qhConsolePick;"; x=-14.756*QS*UI_GRID_W + UI_GRID_X; y=5.133*QS*UI_GRID_H + UI_GRID_Y; w=8.119*QS*UI_GRID_W; h=1.244*QS*UI_GRID_H; };
        class Sw3 : SwBtn { idc=941523; onButtonClick="[3] call life_fnc_qhConsolePick;"; x=-14.756*QS*UI_GRID_W + UI_GRID_X; y=6.585*QS*UI_GRID_H + UI_GRID_Y; w=8.119*QS*UI_GRID_W; h=1.244*QS*UI_GRID_H; };

        // ---- LOADOUT TILES (6) : icon + name + blurb + foot stats + FIRE + full-card hit button ----
        class TI0 : OvPic { idc=941540; x=-5.067*QS*UI_GRID_W + UI_GRID_X; y=-6.119*QS*UI_GRID_H + UI_GRID_Y; w=0.889*QS*UI_GRID_W; h=0.889*QS*UI_GRID_H; };
        class TN0 : OvTxt { idc=941550; size=0.54*QS*UI_GRID_H; x=-3.911*QS*UI_GRID_W + UI_GRID_X; y=-6.119*QS*UI_GRID_H + UI_GRID_Y; w=4.237*QS*UI_GRID_W; h=0.652*QS*UI_GRID_H; };
        class TB0 : OvTxt { idc=941560; size=0.44*QS*UI_GRID_H; x=-5.067*QS*UI_GRID_W + UI_GRID_X; y=-5.052*QS*UI_GRID_H + UI_GRID_Y; w=5.393*QS*UI_GRID_W; h=1.244*QS*UI_GRID_H; };
        class TF0 : OvTxt { idc=941570; size=0.4*QS*UI_GRID_H; x=-5.067*QS*UI_GRID_W + UI_GRID_X; y=-3.481*QS*UI_GRID_H + UI_GRID_Y; w=4.03*QS*UI_GRID_W; h=0.474*QS*UI_GRID_H; };
        class TR0 : OvTxt { idc=941580; size=0.4*QS*UI_GRID_H; x=-1.037*QS*UI_GRID_W + UI_GRID_X; y=-3.541*QS*UI_GRID_H + UI_GRID_Y; w=1.363*QS*UI_GRID_W; h=0.563*QS*UI_GRID_H; };
        class TH0 : OvHit { idc=941590; onButtonClick="[0] call life_fnc_qhConsoleFire;"; x=-5.422*QS*UI_GRID_W + UI_GRID_X; y=-6.474*QS*UI_GRID_H + UI_GRID_Y; w=6.104*QS*UI_GRID_W; h=3.763*QS*UI_GRID_H; };

        class TI1 : OvPic { idc=941541; x=1.333*QS*UI_GRID_W + UI_GRID_X; y=-6.119*QS*UI_GRID_H + UI_GRID_Y; w=0.889*QS*UI_GRID_W; h=0.889*QS*UI_GRID_H; };
        class TN1 : OvTxt { idc=941551; size=0.54*QS*UI_GRID_H; x=2.489*QS*UI_GRID_W + UI_GRID_X; y=-6.119*QS*UI_GRID_H + UI_GRID_Y; w=4.237*QS*UI_GRID_W; h=0.652*QS*UI_GRID_H; };
        class TB1 : OvTxt { idc=941561; size=0.44*QS*UI_GRID_H; x=1.333*QS*UI_GRID_W + UI_GRID_X; y=-5.052*QS*UI_GRID_H + UI_GRID_Y; w=5.393*QS*UI_GRID_W; h=1.244*QS*UI_GRID_H; };
        class TF1 : OvTxt { idc=941571; size=0.4*QS*UI_GRID_H; x=1.333*QS*UI_GRID_W + UI_GRID_X; y=-3.481*QS*UI_GRID_H + UI_GRID_Y; w=4.03*QS*UI_GRID_W; h=0.474*QS*UI_GRID_H; };
        class TR1 : OvTxt { idc=941581; size=0.4*QS*UI_GRID_H; x=5.363*QS*UI_GRID_W + UI_GRID_X; y=-3.541*QS*UI_GRID_H + UI_GRID_Y; w=1.363*QS*UI_GRID_W; h=0.563*QS*UI_GRID_H; };
        class TH1 : OvHit { idc=941591; onButtonClick="[1] call life_fnc_qhConsoleFire;"; x=0.978*QS*UI_GRID_W + UI_GRID_X; y=-6.474*QS*UI_GRID_H + UI_GRID_Y; w=6.104*QS*UI_GRID_W; h=3.763*QS*UI_GRID_H; };

        class TI2 : OvPic { idc=941542; x=7.733*QS*UI_GRID_W + UI_GRID_X; y=-6.119*QS*UI_GRID_H + UI_GRID_Y; w=0.889*QS*UI_GRID_W; h=0.889*QS*UI_GRID_H; };
        class TN2 : OvTxt { idc=941552; size=0.54*QS*UI_GRID_H; x=8.889*QS*UI_GRID_W + UI_GRID_X; y=-6.119*QS*UI_GRID_H + UI_GRID_Y; w=4.237*QS*UI_GRID_W; h=0.652*QS*UI_GRID_H; };
        class TB2 : OvTxt { idc=941562; size=0.44*QS*UI_GRID_H; x=7.733*QS*UI_GRID_W + UI_GRID_X; y=-5.052*QS*UI_GRID_H + UI_GRID_Y; w=5.393*QS*UI_GRID_W; h=1.244*QS*UI_GRID_H; };
        class TF2 : OvTxt { idc=941572; size=0.4*QS*UI_GRID_H; x=7.733*QS*UI_GRID_W + UI_GRID_X; y=-3.481*QS*UI_GRID_H + UI_GRID_Y; w=4.03*QS*UI_GRID_W; h=0.474*QS*UI_GRID_H; };
        class TR2 : OvTxt { idc=941582; size=0.4*QS*UI_GRID_H; x=11.763*QS*UI_GRID_W + UI_GRID_X; y=-3.541*QS*UI_GRID_H + UI_GRID_Y; w=1.363*QS*UI_GRID_W; h=0.563*QS*UI_GRID_H; };
        class TH2 : OvHit { idc=941592; onButtonClick="[2] call life_fnc_qhConsoleFire;"; x=7.378*QS*UI_GRID_W + UI_GRID_X; y=-6.474*QS*UI_GRID_H + UI_GRID_Y; w=6.104*QS*UI_GRID_W; h=3.763*QS*UI_GRID_H; };

        class TI3 : OvPic { idc=941543; x=-5.067*QS*UI_GRID_W + UI_GRID_X; y=-2.059*QS*UI_GRID_H + UI_GRID_Y; w=0.889*QS*UI_GRID_W; h=0.889*QS*UI_GRID_H; };
        class TN3 : OvTxt { idc=941553; size=0.54*QS*UI_GRID_H; x=-3.911*QS*UI_GRID_W + UI_GRID_X; y=-2.059*QS*UI_GRID_H + UI_GRID_Y; w=4.237*QS*UI_GRID_W; h=0.652*QS*UI_GRID_H; };
        class TB3 : OvTxt { idc=941563; size=0.44*QS*UI_GRID_H; x=-5.067*QS*UI_GRID_W + UI_GRID_X; y=-0.993*QS*UI_GRID_H + UI_GRID_Y; w=5.393*QS*UI_GRID_W; h=1.244*QS*UI_GRID_H; };
        class TF3 : OvTxt { idc=941573; size=0.4*QS*UI_GRID_H; x=-5.067*QS*UI_GRID_W + UI_GRID_X; y=0.578*QS*UI_GRID_H + UI_GRID_Y; w=4.03*QS*UI_GRID_W; h=0.474*QS*UI_GRID_H; };
        class TR3 : OvTxt { idc=941583; size=0.4*QS*UI_GRID_H; x=-1.037*QS*UI_GRID_W + UI_GRID_X; y=0.519*QS*UI_GRID_H + UI_GRID_Y; w=1.363*QS*UI_GRID_W; h=0.563*QS*UI_GRID_H; };
        class TH3 : OvHit { idc=941593; onButtonClick="[3] call life_fnc_qhConsoleFire;"; x=-5.422*QS*UI_GRID_W + UI_GRID_X; y=-2.415*QS*UI_GRID_H + UI_GRID_Y; w=6.104*QS*UI_GRID_W; h=3.763*QS*UI_GRID_H; };

        class TI4 : OvPic { idc=941544; x=1.333*QS*UI_GRID_W + UI_GRID_X; y=-2.059*QS*UI_GRID_H + UI_GRID_Y; w=0.889*QS*UI_GRID_W; h=0.889*QS*UI_GRID_H; };
        class TN4 : OvTxt { idc=941554; size=0.54*QS*UI_GRID_H; x=2.489*QS*UI_GRID_W + UI_GRID_X; y=-2.059*QS*UI_GRID_H + UI_GRID_Y; w=4.237*QS*UI_GRID_W; h=0.652*QS*UI_GRID_H; };
        class TB4 : OvTxt { idc=941564; size=0.44*QS*UI_GRID_H; x=1.333*QS*UI_GRID_W + UI_GRID_X; y=-0.993*QS*UI_GRID_H + UI_GRID_Y; w=5.393*QS*UI_GRID_W; h=1.244*QS*UI_GRID_H; };
        class TF4 : OvTxt { idc=941574; size=0.4*QS*UI_GRID_H; x=1.333*QS*UI_GRID_W + UI_GRID_X; y=0.578*QS*UI_GRID_H + UI_GRID_Y; w=4.03*QS*UI_GRID_W; h=0.474*QS*UI_GRID_H; };
        class TR4 : OvTxt { idc=941584; size=0.4*QS*UI_GRID_H; x=5.363*QS*UI_GRID_W + UI_GRID_X; y=0.519*QS*UI_GRID_H + UI_GRID_Y; w=1.363*QS*UI_GRID_W; h=0.563*QS*UI_GRID_H; };
        class TH4 : OvHit { idc=941594; onButtonClick="[4] call life_fnc_qhConsoleFire;"; x=0.978*QS*UI_GRID_W + UI_GRID_X; y=-2.415*QS*UI_GRID_H + UI_GRID_Y; w=6.104*QS*UI_GRID_W; h=3.763*QS*UI_GRID_H; };

        class TI5 : OvPic { idc=941545; x=7.733*QS*UI_GRID_W + UI_GRID_X; y=-2.059*QS*UI_GRID_H + UI_GRID_Y; w=0.889*QS*UI_GRID_W; h=0.889*QS*UI_GRID_H; };
        class TN5 : OvTxt { idc=941555; size=0.54*QS*UI_GRID_H; x=8.889*QS*UI_GRID_W + UI_GRID_X; y=-2.059*QS*UI_GRID_H + UI_GRID_Y; w=4.237*QS*UI_GRID_W; h=0.652*QS*UI_GRID_H; };
        class TB5 : OvTxt { idc=941565; size=0.44*QS*UI_GRID_H; x=7.733*QS*UI_GRID_W + UI_GRID_X; y=-0.993*QS*UI_GRID_H + UI_GRID_Y; w=5.393*QS*UI_GRID_W; h=1.244*QS*UI_GRID_H; };
        class TF5 : OvTxt { idc=941575; size=0.4*QS*UI_GRID_H; x=7.733*QS*UI_GRID_W + UI_GRID_X; y=0.578*QS*UI_GRID_H + UI_GRID_Y; w=4.03*QS*UI_GRID_W; h=0.474*QS*UI_GRID_H; };
        class TR5 : OvTxt { idc=941585; size=0.4*QS*UI_GRID_H; x=11.763*QS*UI_GRID_W + UI_GRID_X; y=0.519*QS*UI_GRID_H + UI_GRID_Y; w=1.363*QS*UI_GRID_W; h=0.563*QS*UI_GRID_H; };
        class TH5 : OvHit { idc=941595; onButtonClick="[5] call life_fnc_qhConsoleFire;"; x=7.378*QS*UI_GRID_W + UI_GRID_X; y=-2.415*QS*UI_GRID_H + UI_GRID_Y; w=6.104*QS*UI_GRID_W; h=3.763*QS*UI_GRID_H; };

        // ---- rail buttons (baked): power(bottom) = close, F(top) = deck tools ----
        // rail "+" = FIREWALL chip editor (moved here when the standalone Quickhacks app was removed)
        class RailFirewall : OvHit { idc=941598; onButtonClick="[] spawn life_fnc_ringLoadout;"; x=14.72*QS*UI_GRID_W + UI_GRID_X; y=-4.78*QS*UI_GRID_H + UI_GRID_Y; w=0.95*QS*UI_GRID_W; h=0.95*QS*UI_GRID_H; };
        class RailClose : OvHit { idc=1005; onButtonClick="closeDialog 0; [] spawn { uiSleep 0.15; if (isNull findDisplay 90000 && {alive player}) then { [] call life_fnc_p_openMenu; }; };"; x=14.72*QS*UI_GRID_W + UI_GRID_X; y=-2.05*QS*UI_GRID_H + UI_GRID_Y; w=0.95*QS*UI_GRID_W; h=0.95*QS*UI_GRID_H; };
        class RailTools : OvHit { idc=941599; onButtonClick="closeDialog 0; [] spawn { uiSleep 0.12; if (playerSide isEqualTo west) then { [] spawn life_fnc_talHome } else { PLB_cdTarget = cursorObject; [] spawn life_fnc_cyberdeckHome }; };"; x=14.72*QS*UI_GRID_W + UI_GRID_X; y=-7.7*QS*UI_GRID_H + UI_GRID_Y; w=0.95*QS*UI_GRID_W; h=0.95*QS*UI_GRID_H; };
    };};
#undef QS
