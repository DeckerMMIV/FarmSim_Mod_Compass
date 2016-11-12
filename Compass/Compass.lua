--
-- Compass
--
-- @author  Decker_MMIV (DCK)
-- @contact fs-uk.com, modcentral.co.uk, forum.farming-simulator.com
-- @date    2016-11-xx
--

Compass = {};
--
local modItem = ModsUtil.findModItemByModName(g_currentModName);
Compass.version = (modItem and modItem.version) and modItem.version or "?";
--
Compass.initializeTimeout = 5;
Compass.drawFuncIdx = 1 -- 0=hidden
Compass.drawFuncs = {}


-- Support-function, that I would like to see be added to InputBinding class.
-- Maybe it is, I just do not know what its called.
local function getKeyIdOfModifier(binding)
    if InputBinding.actions[binding] == nil then
        return nil;  -- Unknown input-binding.
    end;
    if table.getn(InputBinding.actions[binding].keys1) <= 1 then
        return nil; -- Input-binding has only one or zero keys. (Well, in the keys1 - I'm not checking keys2)
    end;
    -- Check if first key in key-sequence is a modifier key (LSHIFT/RSHIFT/LCTRL/RCTRL/LALT/RALT)
    if Input.keyIdIsModifier[ InputBinding.actions[binding].keys1[1] ] then
        return InputBinding.actions[binding].keys1[1]; -- Return the keyId of the modifier key
    end;
    return nil;
end

local function toFloat3Decimals(e)
    return ("%.3f"):format(e)
end

local function vectorToString(v, formatFunc)
    local txt = ""
    local delim = ""
    if formatFunc == nil then
        formatFunc = tostring
    end
    for _,elem in pairs(v) do
        txt = txt .. delim .. formatFunc(elem)
        delim = " "
    end
    return txt
end

--

function Compass.addDrawFunc(func)
    table.insert(Compass.drawFuncs, func)
end

local function drawCompass3(compassAngle, props)
    local worldCornerNum = 1 + (math.floor((compassAngle + 22.5) / 45) % 8);

    if props.overlay ~= nil and props.overlay ~= 0 then
        setOverlayColor(props.overlay, props.boxColor[1], props.boxColor[2], props.boxColor[3], props.boxColor[4])
        renderOverlay(props.overlay, props.x,props.y, props.w,props.h);
    end

    setTextColor(props.fontColor[1],props.fontColor[2],props.fontColor[3],props.fontColor[4]);
    setTextBold(props.fontBold);

    setTextAlignment(RenderText.ALIGN_RIGHT);
    renderText(props.x + props.w - props.xTxtR, props.y + props.yTxt, props.fontSize, string.format("%5.1f", compassAngle));

    setTextAlignment(RenderText.ALIGN_LEFT);
    renderText(props.x + props.xTxtL,           props.y + props.yTxt, props.fontSize, Compass.worldCorners[worldCornerNum]);

    setTextColor(1,1,1,1);
    setTextBold(false);
end

local function addPreset(name, x,y, w,h, fontSize, fontBold, fontColor, boxColor, leftAlignOff, rightAlignOff, yTxtOff)
    table.insert(Compass.compassPresets,
        {
            name=name,
            overlay=Compass.hudBlack, boxColor=boxColor,
            x=x, y=y,
            w=w, h=h,
            fontSize=fontSize, fontBold=fontBold, fontColor=fontColor,
            xTxtL=leftAlignOff, xTxtR=rightAlignOff, yTxt=yTxtOff
        }
    )

    local presetNum = table.getn(Compass.compassPresets)

    Compass.addDrawFunc(
        function(compassAngle)
            drawCompass3(compassAngle, Compass.compassPresets[presetNum])
        end
    )
end

function Compass.saveCompassPresets()
-- TODO: Figure out if ModsSettings should/can be upgraded to FS17
--[[
    -- Make use of the 'ModsSettings'-mod for storing/retrieving the compass presets.
    if  ModsSettings ~= nil
    and ModsSettings.isVersion ~= nil
    and ModsSettings.isVersion("0.2.0", "Compass")
    then
        local modName = "Compass"
        local keyName

        local selectedPreset = nil
        local i=-1
        for _,cp in pairs(Compass.compassPresets) do
            i=i+1
            keyName = ("preset(%d)"):format(i)

            ModsSettings.getStringLocal(modName, keyName, "name", cp.name)
            ModsSettings.getStringLocal(modName, keyName, "xyPos", vectorToString( { cp.x, cp.y } , toFloat3Decimals ))
            ModsSettings.getStringLocal(modName, keyName, "boxWH", vectorToString( { cp.w, cp.h } , toFloat3Decimals ))
            ModsSettings.getStringLocal(modName, keyName, "leftAlignOffset" , toFloat3Decimals(cp.xTxtL))
            ModsSettings.getStringLocal(modName, keyName, "rightAlignOffset", toFloat3Decimals(cp.xTxtR))
            ModsSettings.getStringLocal(modName, keyName, "fontSize" , toFloat3Decimals(cp.fontSize))
            ModsSettings.getBoolLocal(  modName, keyName, "fontBold" , cp.fontBold)
            ModsSettings.getStringLocal(modName, keyName, "fontColor" , vectorToString( cp.fontColor , toFloat3Decimals ))
            ModsSettings.getStringLocal(modName, keyName, "boxColor"  , vectorToString( cp.boxColor  , toFloat3Decimals ))

            if i+1 == Compass.drawFuncIdx then
                selectedPreset = cp.name
            end
        end

        keyName = "config"

        ModsSettings.setStringLocal(modName, keyName, "lastScreenWH", ("%d %d"):format(g_screenWidth, g_screenHeight))
        ModsSettings.setStringLocal(modName, keyName, "selectedPreset", selectedPreset)
    end
--]]
end

function Compass.loadCompassPresets()
    Compass.compassPresets = {}

    local wasLoaded = false;

-- TODO: Figure out if ModsSettings should/can be upgraded to FS17
--[[
    -- Make use of the 'ModsSettings'-mod for storing/retrieving the compass presets.
    if  ModsSettings ~= nil
    and ModsSettings.isVersion ~= nil
    and ModsSettings.isVersion("0.2.0", "Compass")
    then
        local modName = "Compass"
        local keyName = "config"

        local selectedPreset = ModsSettings.getStringLocal(modName, keyName, "selectedPreset", "Default")
        local lastScreenWH   = ModsSettings.getStringLocal(modName, keyName, "lastScreenWH")
        if lastScreenWH ~= nil then
            lastScreenWH = { Utils.getVectorFromString(lastScreenWH) }
        end

        if  lastScreenWH ~= nil
        and lastScreenWH[1] == g_screenWidth
        and lastScreenWH[2] == g_screenHeight
        then
            local i=-1
            while true do
                i=i+1
                keyName = string.format("preset(%d)", i)
                if not ModsSettings.hasKeyLocal(modName, keyName) then
                    break
                end

                local name          = ModsSettings.getStringLocal(modName, keyName, "name", "NoPresetName")
                local xy            = { Utils.getVectorFromString(ModsSettings.getStringLocal(modName, keyName, "xyPos")) }
                local wh            = { Utils.getVectorFromString(ModsSettings.getStringLocal(modName, keyName, "boxWH")) }
                local leftAlignOff  = ModsSettings.getFloatLocal(modName, keyName, "leftAlignOffset")
                local rightAlignOff = ModsSettings.getFloatLocal(modName, keyName, "rightAlignOffset")
                local fontSize      = ModsSettings.getFloatLocal(modName, keyName, "fontSize")
                local fontBold      = ModsSettings.getBoolLocal( modName, keyName, "fontBold")
                local fontColor     = { Utils.getVectorFromString(ModsSettings.getStringLocal(modName, keyName, "fontColor")) }
                local boxColor      = { Utils.getVectorFromString(ModsSettings.getStringLocal(modName, keyName, "boxColor")) }

                if  table.getn(xy) == 2
                and table.getn(wh) == 2
                and table.getn(fontColor) == 4
                and table.getn(boxColor) == 4
                then
                    local x,y     = Utils.getNoNil(xy[1],0.826),Utils.getNoNil(xy[2],0.127)
                    local w,h     = Utils.getNoNil(wh[1],0.060),Utils.getNoNil(wh[2],0.020)
                    fontSize      = math.max(0.001, Utils.getNoNil(fontSize, 0.014))
                    fontBold      = fontBold==true
                    leftAlignOff  = math.max(0.001, Utils.getNoNil(leftAlignOff, 0.005))
                    rightAlignOff = math.max(0.001, Utils.getNoNil(rightAlignOff, 0.005))
                    --
                    local yTxtOff = (h/2 - fontSize/2) + (fontSize * 0.1)
                    --
                    addPreset(name, x,y, w,h, fontSize, fontBold, fontColor, boxColor, leftAlignOff, rightAlignOff, yTxtOff)
                    --
                    if selectedPreset == name
                    or selectedPreset == nil
                    then
                        selectedPreset = name
                        Compass.drawFuncIdx = table.getn(Compass.compassPresets);
                    end
                    --
                    wasLoaded = true
                end
            end
        end
    end
--]]

    if not wasLoaded then
        local function findMinimumWidth(fontSize, padding)
            local w = 0
            for _,txt in pairs(Compass.worldCorners) do
                w = math.max(w, padding + getTextWidth(fontSize, txt .. " 999.9"))
            end
            return w
        end

        local w,h,fontsize,padding

        -- Due to patch 1.3.0.0
        local uiScale = 1.0
        if g_gameSettings ~= nil and g_gameSettings.getValue ~= nil then
            uiScale = Utils.getNoNil(g_gameSettings:getValue("uiScale"), 1.0)
        end
       
        --
        fontsize = 0.014 * uiScale
        padding = 0.005
        w, h = findMinimumWidth(fontsize, padding*2), fontsize * 1.3
        addPreset(
            g_i18n:getText("Preset_TopCenter"),
            0.5 - (w / 2), 1.0 - (h),
            w, h,
            fontsize, false,
            {1,1,1,1}, {0,0,0,0.5},
            padding, padding, fontsize * 0.3
        )

        --
        fontsize = 0.014 * uiScale
        w, h = findMinimumWidth(fontsize, padding*2), fontsize * 1.3
        addPreset(
            g_i18n:getText("Preset_BottomCenter"),
            0.5 - (w / 2), 0.000,
            w, h,
            fontsize, false,
            {1,1,1,1}, {0,0,0,0.5},
            padding, padding, fontsize * 0.3
        )

        --
        Compass.saveCompassPresets()
    end
end

--

function Compass:loadMap(name)
    if g_client == nil then
        return;
    end

    if Compass.hudBlack == nil then
        Compass.keyModifier_COMPASS_TOGGLE = getKeyIdOfModifier(InputBinding.COMPASS_TOGGLE);

        -- Solid background
        Compass.hudBlack = createImageOverlay("dataS2/menu/blank.png");
        setOverlayColor(Compass.hudBlack, 0,0,0,0.5)
    end;

    Compass.worldCorners = {
         g_i18n:getText("north")
        ,g_i18n:getText("northeast")
        ,g_i18n:getText("east")
        ,g_i18n:getText("southeast")
        ,g_i18n:getText("south")
        ,g_i18n:getText("southwest")
        ,g_i18n:getText("west")
        ,g_i18n:getText("northwest")
    };
end;

function Compass:deleteMap()
    if g_client == nil then
        return;
    end

    Compass.saveCompassPresets()
end;

function Compass:mouseEvent(posX, posY, isDown, isUp, button)
end;

function Compass:keyEvent(unicode, sym, modifier, isDown)
end;

function Compass:update(dt)
    if g_client == nil then
        return;
    end

    if Compass.initializeTimeout > 0 then
        -- Give time for other mods to override Drivable's draw function.
        Compass.initializeTimeout = Compass.initializeTimeout - 1
        if Compass.initializeTimeout <= 0 then
            Compass:appendToDrivableDraw()
            --
            Compass.loadCompassPresets()
            --Compass.drawFuncIdx = math.min(math.max(Utils.getNoNil(Compass.drawFuncIdx, 1), 0), table.getn(Compass.drawFuncs))
            Compass.setDrawFuncIdx( Utils.getNoNil(Compass.drawFuncIdx, 1) )
        end
    else
        if InputBinding.hasEvent(InputBinding.COMPASS_TOGGLE) then
            --Compass.drawFuncIdx = (Compass.drawFuncIdx + 1) % (1 + table.getn(Compass.drawFuncs))
            Compass.setDrawFuncIdx( (Compass.drawFuncIdx + 1) % (1 + table.getn(Compass.drawFuncs)) )
            Compass.saveCompassPresets()
        end;
    end
end;

function Compass:draw()
end;

function Compass:appendToDrivableDraw()
    Drivable.draw = Utils.appendedFunction(Drivable.draw, Compass.DrawCompass);
end

Compass.drawFuncButtonText = ""
function Compass.setDrawFuncIdx(drawIdx)
    Compass.drawFuncIdx = math.min(math.max(drawIdx, 0), table.getn(Compass.drawFuncs))
    Compass.drawFuncButtonText = g_i18n:getText("COMPASS_TOGGLE") .. Compass.getDrawFuncName(Compass.drawFuncIdx)
end

function Compass.getDrawFuncName(idx)
    local name = "???";
    if idx > 0 and idx <= table.getn(Compass.compassPresets) then
        name = Utils.getNoNil(Compass.compassPresets[idx].name, idx);
    elseif idx == 0 then
        name = g_i18n:getText("Compass_Hidden")
    end
    return " ("..name..")";
end

--
Compass.DrawCompass = function(self)
    --if g_currentMission.missionInfo.showHelpMenu then
    --if g_gameSettings:getValue("showHelpMenu") then
        if Compass.keyModifier_COMPASS_TOGGLE ~= nil then
            -- Only show in helpbox, if correct key-modifier is pressed (SHIFT/CTRL/ALT)
            if Input.isKeyPressed(Compass.keyModifier_COMPASS_TOGGLE) then
                g_currentMission:addHelpButtonText(Compass.drawFuncButtonText, InputBinding.COMPASS_TOGGLE, nil, GS_PRIO_HIGH);
            end
        else
            -- If no modifier key, then show _with_very_low_priority_
            g_currentMission:addHelpButtonText(Compass.drawFuncButtonText, InputBinding.COMPASS_TOGGLE, nil, GS_PRIO_VERY_LOW);
        end;
    --end;

    if self.isEntered and Compass.drawFuncIdx > 0 and self:getIsActive() then
        local x,y,z = localDirectionToWorld(self.rootNode, 0, 0, 1);
        local length = Utils.vector2Length(x,z);
        if (length ~= 0.0) then -- Try to make sure we do not divide by zero.
            local direction = (math.deg(math.atan2(z/length,x/length)) + 90.0) % 360.0;   -- Rotate clockwise, so north=0, east=90, south=180, west=270.
            Compass.drawFuncs[Compass.drawFuncIdx](direction);
        end;
    end;
end;

--
addModEventListener(Compass);

print(string.format("Script loaded: Compass.LUA (v%s)", Compass.version));
