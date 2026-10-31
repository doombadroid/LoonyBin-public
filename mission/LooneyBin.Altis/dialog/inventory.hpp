/*
    inventory.hpp -- Y-menu / phone INVENTORY app (idd 361000), NEON AEGEAN deck skin.
    REBUILD 2026-07-20 (owner: "inventory is cooked, borrow the trunk styling"): trunk.hpp's split-panel
    vocabulary translated to the deck -- ITEM LIST panel left (with header row), ITEM OPS action rail right
    (USE / DROP primaries, then GIVE TO + QTY + GIVE), HOME bottom-right returns to the phone home screen.
    CONTRACT UNCHANGED: idc 361001 list / 361002 qty edit / 361003 near-players combo / 361004 Give /
    361005 Use / 361006 Drop / 1005 home -- fn_inventory + fn_useItem/fn_giveItem/fn_dropItem untouched.
    Content lives in the deck screen zone below the baked header: x[-18.5..16.5], y[-6.6..9.0].
*/
class Life_inventory_menu {idd = 361000;
    name = "life_inventory_menu";
    movingEnable = false;
    enableSimulation = true;
    class Life_PhoneButton: Life_RscButtonMenu {animTextureNormal = "#(argb,8,8,3)color(0,0,0,0)";
        animTextureDisabled = "#(argb,8,8,3)color(0,0,0,0)";
        animTextureOver = "#(argb,8,8,3)color(0,0,0,0)";
        animTextureFocused = "#(argb,8,8,3)color(0,0,0,0)";
        animTexturePressed = "#(argb,8,8,3)color(0,0,0,0)";
        animTextureDefault = "#(argb,8,8,3)color(0,0,0,0)";
        onLoad = "(_this select 0) ctrlShow false";};
    class controlsBackground {class PhoneWallpaper: Life_RscPictureKeepAspect {idc = 90300;
            onLoad = "(_this select 0) ctrlShow false";
            x = -28.96 * UI_GRID_W + UI_GRID_X;
            y = -16.44 * UI_GRID_H + UI_GRID_Y;
            w = 57.6002 * UI_GRID_W;
            h = 32.1625 * UI_GRID_H;
            colorBackground[] = { 0, 0, 0, 0 };};
        class PhoneFrame: Life_RscPicture {idc = -1;
            text = "images\phone_deck_blank.paa";
            x = -20 * UI_GRID_W + UI_GRID_X;
            y = -10 * UI_GRID_H + UI_GRID_Y;
            w = 40 * UI_GRID_W;
            h = 20 * UI_GRID_H;
            colorText[] = {1,1,1,1};};
        class StatusTextLeft: Life_RscStructuredText {idc = 90301;
            onLoad = "(_this select 0) ctrlShow false";
            x = 2.5 * UI_GRID_W + UI_GRID_X;
            y = -8.22 * UI_GRID_H + UI_GRID_Y;
            w = 13.7 * UI_GRID_W;
            h = 0.9 * UI_GRID_H;};
        class StatusTextCenter: Life_RscStructuredText {idc = 90302;
            onLoad = "(_this select 0) ctrlShow false";
            x = 2.5 * UI_GRID_W + UI_GRID_X;
            y = -8.22 * UI_GRID_H + UI_GRID_Y;
            w = 13.7 * UI_GRID_W;
            h = 0.9 * UI_GRID_H;};
        class StatusTextRight: Life_RscStructuredText {idc = 90303;
            onLoad = "(_this select 0) ctrlShow false";
            x = 2.5 * UI_GRID_W + UI_GRID_X;
            y = -8.22 * UI_GRID_H + UI_GRID_Y;
            w = 13.7 * UI_GRID_W;
            h = 0.9 * UI_GRID_H;};
        // ---- left: item list panel ----
        class ListPanel: Life_RscText {idc = -1;
            x = -18.5 * UI_GRID_W + UI_GRID_X;
            y = -6.6 * UI_GRID_H + UI_GRID_Y;
            w = 21.0 * UI_GRID_W;
            h = 15.6 * UI_GRID_H;
            colorBackground[] = { 0.02, 0.045, 0.035, 0.85 };};
        // ---- right: action rail panel ----
        class OpsPanel: Life_RscText {idc = -1;
            x = 3.3 * UI_GRID_W + UI_GRID_X;
            y = -6.6 * UI_GRID_H + UI_GRID_Y;
            w = 13.2 * UI_GRID_W;
            h = 15.6 * UI_GRID_H;
            colorBackground[] = { 0.02, 0.045, 0.035, 0.85 };};};
    class controls {class DeckSuffix: Life_RscStructuredText {idc = -1;
            x = -2.8 * UI_GRID_W + UI_GRID_X;
            y = -8.22 * UI_GRID_H + UI_GRID_Y;
            w = 5 * UI_GRID_W;
            h = 0.9 * UI_GRID_H;
            size = 0.55 * UI_GRID_H;
            text = "<t size='1' font='EtelkaMonospacePro' color='#4c5a55'>// INVENTORY</t>";};
        // list header row (trunk vocabulary: label left, nothing else -- carry weight already lives in the status strip)
        class ListHeader: Life_RscText {idc = -1;
            text = " ON YOU";
            sizeEx = 0.72 * UI_GRID_H;
            x = -18.5 * UI_GRID_W + UI_GRID_X;
            y = -6.6 * UI_GRID_H + UI_GRID_Y;
            w = 21.0 * UI_GRID_W;
            h = 1.15 * UI_GRID_H;
            colorText[] = { 0.788, 0.886, 0.10, 1 };
            colorBackground[] = { 0.047, 0.09, 0.07, 0.95 };};
        class ItemList: Life_RscListBox {idc = 361001;
            rowHeight = 0.05;
            x = -18.3 * UI_GRID_W + UI_GRID_X;
            y = -5.25 * UI_GRID_H + UI_GRID_Y;
            w = 20.6 * UI_GRID_W;
            h = 14.05 * UI_GRID_H;
            sizeEx = 0.68 * UI_GRID_H;
            colorText[] = { 0.86, 0.905, 0.878, 1 };
            colorBackground[] = { 0, 0, 0, 0 };
            colorSelect[] = { 0.788, 0.886, 0.10, 1 };
            colorSelect2[] = { 0.788, 0.886, 0.10, 1 };
            colorSelectBackground[] = { 0.788, 0.886, 0.10, 0.22 };
            colorSelectBackground2[] = { 0.788, 0.886, 0.10, 0.12 };};
        // ---- right rail ----
        class OpsHeader: Life_RscText {idc = -1;
            text = " ITEM OPS";
            sizeEx = 0.72 * UI_GRID_H;
            x = 3.3 * UI_GRID_W + UI_GRID_X;
            y = -6.6 * UI_GRID_H + UI_GRID_Y;
            w = 13.2 * UI_GRID_W;
            h = 1.15 * UI_GRID_H;
            colorText[] = { 0.2, 1, 0.73, 1 };
            colorBackground[] = { 0.047, 0.09, 0.07, 0.95 };};
        // USE -- acid primary (trunk's cyan TAKE slot)
        class UseButton: Life_RscButtonMenu {idc = 361005;
            text = "USE";
            x = 3.8 * UI_GRID_W + UI_GRID_X;
            y = -4.9 * UI_GRID_H + UI_GRID_Y;
            w = 12.2 * UI_GRID_W;
            h = 2.0 * UI_GRID_H;
            size = 0.78 * UI_GRID_H;
            sizeEx = 0.78 * UI_GRID_H;
            colorText[] = { 0.04, 0.09, 0.07, 1 };
            colorBackground[] = { 0.788, 0.886, 0.10, 1 };
            colorBackground2[] = { 0.788, 0.886, 0.10, 1 };
            colorBackgroundActive[] = { 0.86, 0.95, 0.2, 1 };
            colorFocused[] = { 0.86, 0.95, 0.2, 1 };
            class Attributes { font = "PuristaBold"; color = "#0c1712"; align = "center"; shadow = "false"; };
         colorDisabled[] = {0.78,0.82,0.62,0.8}; colorBackgroundDisabled[] = {0.10,0.13,0.08,0.92};};
        // DROP -- dim danger ghost
        class DropButton: Life_RscButtonMenu {idc = 361006;
            text = "DROP";
            x = 3.8 * UI_GRID_W + UI_GRID_X;
            y = -2.5 * UI_GRID_H + UI_GRID_Y;
            w = 12.2 * UI_GRID_W;
            h = 1.6 * UI_GRID_H;
            size = 0.7 * UI_GRID_H;
            sizeEx = 0.7 * UI_GRID_H;
            colorText[] = { 0.86, 0.66, 0.66, 1 };
            colorBackground[] = { 0.28, 0.08, 0.08, 0.95 };
            colorBackground2[] = { 0.28, 0.08, 0.08, 0.95 };
            colorBackgroundActive[] = { 0.4, 0.12, 0.12, 1 };
            colorFocused[] = { 0.4, 0.12, 0.12, 1 };
            class Attributes { font = "PuristaBold"; color = "#dba9a9"; align = "center"; shadow = "false"; };
         colorDisabled[] = {0.78,0.82,0.62,0.8}; colorBackgroundDisabled[] = {0.10,0.13,0.08,0.92};};
        // divider label
        class GiveLabel: Life_RscText {idc = -1;
            text = " GIVE TO";
            sizeEx = 0.62 * UI_GRID_H;
            x = 3.8 * UI_GRID_W + UI_GRID_X;
            y = 0.4 * UI_GRID_H + UI_GRID_Y;
            w = 12.2 * UI_GRID_W;
            h = 0.9 * UI_GRID_H;
            colorText[] = { 0.5, 0.62, 0.57, 1 };
            colorBackground[] = { 0, 0, 0, 0 };};
        class NearPlayers: Life_RscCombo {idc = 361003;
            x = 3.8 * UI_GRID_W + UI_GRID_X;
            y = 1.35 * UI_GRID_H + UI_GRID_Y;
            w = 12.2 * UI_GRID_W;
            h = 1.15 * UI_GRID_H;
            sizeEx = 0.62 * UI_GRID_H;
            colorBackground[] = { 0.02, 0.045, 0.035, 0.95 };};
        class QtyLabel: Life_RscText {idc = -1;
            text = " QTY";
            sizeEx = 0.62 * UI_GRID_H;
            x = 3.8 * UI_GRID_W + UI_GRID_X;
            y = 2.85 * UI_GRID_H + UI_GRID_Y;
            w = 3.6 * UI_GRID_W;
            h = 1.15 * UI_GRID_H;
            colorText[] = { 0.5, 0.62, 0.57, 1 };
            colorBackground[] = { 0, 0, 0, 0 };};
        class ItemSelectCount: Life_RscEdit {idc = 361002;
            text = "1";
            x = 7.6 * UI_GRID_W + UI_GRID_X;
            y = 2.85 * UI_GRID_H + UI_GRID_Y;
            w = 8.4 * UI_GRID_W;
            h = 1.15 * UI_GRID_H;
            sizeEx = 0.66 * UI_GRID_H;
            colorBackground[] = { 0.02, 0.045, 0.035, 0.95 };
            colorText[] = { 0.86, 0.905, 0.878, 1 };
            colorSelection[] = { 0.788, 0.886, 0.10, 0.5 };};
        // GIVE -- cyan secondary primary (trunk's STORE slot)
        class GiveButton: Life_RscButtonMenu {idc = 361004;
            text = "GIVE";
            x = 3.8 * UI_GRID_W + UI_GRID_X;
            y = 4.35 * UI_GRID_H + UI_GRID_Y;
            w = 12.2 * UI_GRID_W;
            h = 1.8 * UI_GRID_H;
            size = 0.74 * UI_GRID_H;
            sizeEx = 0.74 * UI_GRID_H;
            colorText[] = { 0.047, 0.09, 0.07, 1 };
            colorBackground[] = { 0.2, 1, 0.73, 1 };
            colorBackground2[] = { 0.2, 1, 0.73, 1 };
            colorBackgroundActive[] = { 0.4, 1, 0.82, 1 };
            colorFocused[] = { 0.4, 1, 0.82, 1 };
            class Attributes { font = "PuristaBold"; color = "#0c1712"; align = "center"; shadow = "false"; };
         colorDisabled[] = {0.78,0.82,0.62,0.8}; colorBackgroundDisabled[] = {0.10,0.13,0.08,0.92};};
        // HOME -- returns to the phone home screen (ESC still fully exits)
        class HomeButton: Life_PhoneButton { text = "CLOSE"; sizeEx = 0.62 * UI_GRID_H; animTextureNormal = "#(argb,8,8,3)color(1,1,1,1)"; animTextureOver = "#(argb,8,8,3)color(1,1,1,1)"; animTextureFocused = "#(argb,8,8,3)color(1,1,1,1)"; animTexturePressed = "#(argb,8,8,3)color(1,1,1,1)"; animTextureDefault = "#(argb,8,8,3)color(1,1,1,1)"; colorText[] = {0.86,0.66,0.66,1}; colorBackground[] = {0.28,0.08,0.08,0.95}; colorBackground2[] = {0.28,0.08,0.08,0.95}; colorBackgroundActive[] = {0.4,0.12,0.12,1}; colorFocused[] = {0.4,0.12,0.12,1};
            onButtonClick = "closeDialog 0; [] spawn { uiSleep 0.15; if (isNull findDisplay 90000 && {alive player}) then { [] call life_fnc_p_openMenu; }; };";
            onLoad = "(_this select 0) ctrlShow true";
            idc = 1005;
            
            x = 11.9 * UI_GRID_W + UI_GRID_X;
            y = 7.35 * UI_GRID_H + UI_GRID_Y;
            w = 4.6 * UI_GRID_W;
            h = 1.2 * UI_GRID_H;
            
            tooltip = "Back to home screen (Esc exits)";};};};
