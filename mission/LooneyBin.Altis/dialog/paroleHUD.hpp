/*
    paroleHUD.hpp -- PLB_ParoleHud (RscTitles layer): the PAROLE PAPERS static objective card, pinned
    top-right in the notification area until the current contract completes. NC tokens (cyan step title,
    ink objective, gold progress counter). Driven by core\intake\fn_parole.sqf via its own rscLayer:
    painted on step start, counter live-updated per event, cleared at the finale. idc 515950.
*/
class PLB_ParoleHud {idd = -1;
    duration = 1e10;
    fadeIn = 0.4;
    fadeOut = 0.4;
    onLoad = "uiNamespace setVariable ['PLB_ParoleHud', _this select 0];";
    class controls {class ParoleText: Life_RscStructuredText {idc = 515950;
            text = "";
            size = 0.032;
            sizeEx = 0.032;
            x = safezoneX + safezoneW - 0.262 * safezoneW;
            y = safezoneY + 0.16 * safezoneH;
            w = 0.25 * safezoneW;
            h = 0.14 * safezoneH;
            colorBackground[] = { 0, 0, 0, 0 };
            class Attributes { font = "PuristaMedium"; color = "#ebeff4"; align = "right"; shadow = 1; };};};};
