#define __SETCONST__(var1,var2) var1 = compileFinal(if (var2 isEqualType "") then {var2} else {str(var2)})
#define fileName (__FILE__ select [29, count __FILE__ - 33])
#define scriptAvailable(cooldownTime) (cooldownTime call { \
    _zindex = life_scriptCooldowns find fileName; \
    _zret = false; \
    if !(_zindex isEqualTo -1) then { \
        if ((life_scriptCooldowns select (_zindex + 1)) > (time - _this)) then { \
            _zret = true; \
        } else { \
            life_scriptCooldowns set [_zindex + 1, time]; \
        }; \
    } else { \
        if !(fileName isEqualTo "") then { \
            life_scriptCooldowns pushBack fileName; \
            life_scriptCooldowns pushBack time; \
        }; \
    }; \
    _zret; \
})
#define getControl(disp,ctrl) ((findDisplay ##disp) displayCtrl ##ctrl)
#define getSelData(ctrl) (lbData [##ctrl, (lbCurSel ##ctrl)])
