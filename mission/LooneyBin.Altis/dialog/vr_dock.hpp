// ICEBREAKER / TAL OS VISOR DOCK (idd 941300) -- replaces the SHIFT+Y radial with a bottom macOS-style
// magnifying dock, 1:1 with the approved mockup (scratchpad/vr_dock.html). This is a HUD over the live world:
// the chrome bar + lock card are baked TRANSLUCENT (vrdock_bar/card_*.paa) so the world shows through; the
// icons, HUD text and lock readout are live overlays; a full-screen catcher takes mouse-move (magnify) and
// click (fire nearest). Coords are safezone fractions measured from the mockup, so it fits any aspect.
class vr_dock {idd = 941300; name = "vr_dock"; movingEnable = 0; enableSimulation = 1;
    onLoad = "uiNamespace setVariable ['vr_dock', _this select 0]; [] call life_fnc_qhDockFill;";
    onUnload = "PLB_vrDockOpen = false;";

    class Bracket : Life_RscText { idc=-1; colorBackground[]={0.784,0.961,0.227,0.42}; };

    class controlsBackground {
        // full-screen visor overlay: scanlines + edge vignette (the "looking through goggles" layer), over the
        // world but under the dock/card/HUD. Black-on-transparent, so it serves both palettes.
        class Visor : CBPicBase { idc=941300; text="images\cyberdeck\vr_visor.paa"; colorText[]={1,1,1,1}; x=safezoneX; y=safezoneY; w=safezoneW; h=safezoneH; };
        // full-screen transparent catcher -- MUST be a button (Life_RscText is a static and receives no
        // MouseMoving; the radial ring uses exactly this). Static icons on top don't block it.
        class Catcher : Life_RscButtonMenu { idc=941301; text=""; x=safezoneX; y=safezoneY; w=safezoneW; h=safezoneH; colorText[]={0,0,0,0}; colorBackground[]={0,0,0,0}; colorBackground2[]={0,0,0,0}; colorFocused[]={0,0,0,0}; colorBackgroundFocused[]={0,0,0,0}; animTextureNormal="#(argb,8,8,3)color(0,0,0,0)"; animTextureOver="#(argb,8,8,3)color(0,0,0,0)"; animTextureFocused="#(argb,8,8,3)color(0,0,0,0)"; animTexturePressed="#(argb,8,8,3)color(0,0,0,0)"; animTextureDefault="#(argb,8,8,3)color(0,0,0,0)"; };
        // soft floor glow under the bar (positioned + tinted by the driver)
        class GlowBg : CBPicBase { idc=941298; text="images\cyberdeck\vrglow.paa"; colorText[]={0.784,0.961,0.227,1}; x=safezoneX; y=safezoneY; w=0; h=0; };
        // baked translucent chrome -- positioned ENTIRELY by fn_qhDockFill (bar stretches with the
        // magnify displacement; both arts carry halo margins the driver compensates for)
        class BarBg : CBPicBase { idc=941302; text="images\cyberdeck\vrdock_bar_ice.paa"; colorText[]={1,1,1,1}; x=safezoneX; y=safezoneY; w=0; h=0; };
        class CardBg : CBPicBase { idc=941303; text="images\cyberdeck\vrdock_card_ice.paa"; colorText[]={1,1,1,1}; x=safezoneX; y=safezoneY; w=0; h=0; };
    };

    class controls {
        // ---- HUD strip ----
        class Brand : Life_RscStructuredText { idc=941304; x=safezoneX + 0.012*safezoneW; y=safezoneY + 0.011*safezoneH; w=0.4*safezoneW; h=0.028*safezoneH; size=0.022*safezoneH; };
        class StatusR : Life_RscStructuredText { idc=941305; x=safezoneX + 0.6*safezoneW; y=safezoneY + 0.011*safezoneH; w=0.388*safezoneW; h=0.028*safezoneH; size=0.02*safezoneH; };

        // ---- reticle (gaze) ----
        class RetV : Life_RscText { idc=-1; colorBackground[]={0.784,0.961,0.227,0.55}; x=safezoneX + 0.49985*safezoneW; y=safezoneY + 0.386*safezoneH; w=0.0006*safezoneW; h=0.048*safezoneH; };
        class RetH : Life_RscText { idc=-1; colorBackground[]={0.784,0.961,0.227,0.55}; x=safezoneX + 0.4865*safezoneW; y=safezoneY + 0.4095*safezoneH; w=0.0271*safezoneW; h=0.001*safezoneH; };

        // ---- corner brackets ----
        class TLh : Bracket { x=safezoneX + 0.0083*safezoneW; y=safezoneY + 0.0148*safezoneH; w=0.0177*safezoneW; h=0.0018*safezoneH; };
        class TLv : Bracket { x=safezoneX + 0.0083*safezoneW; y=safezoneY + 0.0148*safezoneH; w=0.001*safezoneW;  h=0.0315*safezoneH; };
        class TRh : Bracket { x=safezoneX + 0.974*safezoneW;  y=safezoneY + 0.0148*safezoneH; w=0.0177*safezoneW; h=0.0018*safezoneH; };
        class TRv : Bracket { x=safezoneX + 0.9907*safezoneW; y=safezoneY + 0.0148*safezoneH; w=0.001*safezoneW;  h=0.0315*safezoneH; };
        class BLh : Bracket { x=safezoneX + 0.0083*safezoneW; y=safezoneY + 0.9834*safezoneH; w=0.0177*safezoneW; h=0.0018*safezoneH; };
        class BLv : Bracket { x=safezoneX + 0.0083*safezoneW; y=safezoneY + 0.9537*safezoneH; w=0.001*safezoneW;  h=0.0315*safezoneH; };
        class BRh : Bracket { x=safezoneX + 0.974*safezoneW;  y=safezoneY + 0.9834*safezoneH; w=0.0177*safezoneW; h=0.0018*safezoneH; };
        class BRv : Bracket { x=safezoneX + 0.9907*safezoneW; y=safezoneY + 0.9537*safezoneH; w=0.001*safezoneW;  h=0.0315*safezoneH; };

        // ---- lock card overlays ----
        class LockK : Life_RscStructuredText { idc=941320; x=safezoneX; y=safezoneY; w=0; h=0; size=0.019*safezoneH; };
        class LockIcon : CBPicBase { idc=941321; text=""; colorText[]={0.784,0.961,0.227,1}; x=safezoneX; y=safezoneY; w=0; h=0; };
        class LockName : Life_RscStructuredText { idc=941322; x=safezoneX; y=safezoneY; w=0; h=0; size=0.023*safezoneH; };
        class LockRows : Life_RscStructuredText { idc=941323; x=safezoneX; y=safezoneY; w=0; h=0; size=0.019*safezoneH; };
        class LockFlags : Life_RscStructuredText { idc=941324; x=safezoneX; y=safezoneY; w=0; h=0; size=0.017*safezoneH; };

        // ---- dock label + tooltip + upload bar ----
        class Caption : Life_RscStructuredText { idc=941331; x=safezoneX + 0.3*safezoneW; y=safezoneY + 0.892*safezoneH; w=0.4*safezoneW; h=0.016*safezoneH; size=0.013*safezoneH; };
        class Tip : Life_RscStructuredText { idc=941330; x=safezoneX + 0.3*safezoneW; y=safezoneY + 0.858*safezoneH; w=0.4*safezoneW; h=0.05*safezoneH; size=0.02*safezoneH; };
        class UpName : Life_RscStructuredText { idc=941332; x=safezoneX + 0.395*safezoneW; y=safezoneY + 0.828*safezoneH; w=0.21*safezoneW; h=0.02*safezoneH; size=0.014*safezoneH; };
        class UpBar : Life_RscText { idc=941333; colorBackground[]={0.2,1,0.733,1}; x=safezoneX + 0.5*safezoneW; y=safezoneY + 0.85*safezoneH; w=0*safezoneW; h=0.004*safezoneH; };
        class UpTrack : Life_RscText { idc=941334; colorBackground[]={1,1,1,0.08}; x=safezoneX + 0.395*safezoneW; y=safezoneY + 0.85*safezoneH; w=0.11*safezoneW; h=0.004*safezoneH; };
    };};
