--
-- Compass
--
-- @author  Decker_MMIV - fs-uk.com, forum.farming-simulator.com, modhoster.com
-- @date    2015-05-xx
--

Compass = {};
--
local modItem = ModsUtil.findModItemByModName(g_currentModName);
Compass.version = (modItem and modItem.version) and modItem.version or "?.?.?";
--
Compass.modDir = g_currentModDirectory;
Compass.initializeTimeout = 5;
Compass.drawFuncIdx = 1 -- 0=hidden
Compass.drawFuncs = {}

function Compass.addDrawFunc(func)
    table.insert(Compass.drawFuncs, func)
end

--
local function drawCompass(compassAngle, props)
    local worldCornerNum = 1 + (math.floor((compassAngle + 22.5) / 45) % 8);
    local txt = Compass.worldCorners[worldCornerNum] .. string.format(" %5.1f", compassAngle);

    if props.overlay ~= nil and props.overlay ~= 0 then
        renderOverlay(props.overlay, props.x,props.y, props.w,props.h);
    end
    
    setTextAlignment(RenderText.ALIGN_RIGHT);
    setTextBold(false);
    
    -- Background text
    setTextColor(0,0,0,1);
    renderText(props.x + props.xTxt + props.xShade, props.y + props.yTxt + props.yShade, props.fontSize, txt);
    -- Foreground text
    setTextColor(1,1,1,1);
    renderText(props.x + props.xTxt,                props.y + props.yTxt,                props.fontSize, txt);

    -- Normalise text-styling, because other mods expect it this way.
    setTextAlignment(RenderText.ALIGN_LEFT);
    setTextBold(false);
end

--Compass.addDrawFunc( function(compassAngle) drawCompass(compassAngle, { overlay=Compass.hudBlack, x=0.870, y=0.855, w=0.12, h=0.039, fontSize=0.022, xTxt=0.106, yTxt=0.0095, xShade=0.0000, yShade=-0.0010 } ) end );
--Compass.addDrawFunc( function(compassAngle) drawCompass(compassAngle, { overlay=Compass.hudBlack, x=0.790, y=0.820, w=0.12, h=0.039, fontSize=0.022, xTxt=0.106, yTxt=0.0095, xShade=0.0000, yShade=-0.0010 } ) end );

--
local function drawCompass2(compassAngle, props)
    local worldCornerNum = 1 + (math.floor((compassAngle + 22.5) / 45) % 8);
    --local txt = Compass.worldCorners[worldCornerNum] .. string.format(" %5.1f", compassAngle);

    if props.overlay ~= nil and props.overlay ~= 0 then
        renderOverlay(props.overlay, props.x,props.y, props.w,props.h);
    end
    
    setTextColor(1,1,1,1);
    setTextBold(false);
    
    setTextAlignment(RenderText.ALIGN_RIGHT);
    ---- Background text
    --setTextColor(0,0,0,1);
    --renderText(props.x + props.xTxt + props.xShade, props.y + props.yTxt + props.yShade, props.fontSize, txt);
    -- Foreground text
    renderText(props.x + props.xTxt,  props.y + props.yTxt, props.fontSize, string.format("%5.1f", compassAngle));

    -- Normalise text-styling, because other mods expect it this way.
    setTextAlignment(RenderText.ALIGN_LEFT);
    renderText(props.x + props.xTxtL, props.y + props.yTxt, props.fontSize, Compass.worldCorners[worldCornerNum]);
end

local function moveableDrawCompass(moveType, compassAngle)
    -- Moveable compass, for easier placement when developing
    if Compass.dynamicPosition == nil then
      Compass.dynamicPosition = {
        overlay=Compass.hudBlack, 
        x=0.826, 
        y=0.127, 
        w=0.060, 
        h=0.020, 
        fontSize=0.014, 
        xTxtL=0.005,
        xTxt=0.054, 
        yTxt=0.005, 
        --xShade=0.0000, 
        --yShade=-0.0010,
        overlayAlpha=0.5
      };
    end

    if moveType > 0 then
        local x,y = 0,0;
        if InputBinding.isPressed(InputBinding.RUN) then
            if     InputBinding.isPressed(InputBinding.MENU_UP)    then  y= 1;
            elseif InputBinding.isPressed(InputBinding.MENU_DOWN)  then  y=-1;
            end;                                                   
            if     InputBinding.isPressed(InputBinding.MENU_LEFT)  then  x=-1;
            elseif InputBinding.isPressed(InputBinding.MENU_RIGHT) then  x= 1;
            end;
        else
            if     InputBinding.hasEvent(InputBinding.MENU_UP)    then  y= 0.1;
            elseif InputBinding.hasEvent(InputBinding.MENU_DOWN)  then  y=-0.1;
            end;                                                   
            if     InputBinding.hasEvent(InputBinding.MENU_LEFT)  then  x=-0.1;
            elseif InputBinding.hasEvent(InputBinding.MENU_RIGHT) then  x= 0.1;
            end;
        end
        
        local txt = ""
        
        if (moveType == 1) then
            Compass.dynamicPosition.x = Compass.dynamicPosition.x + (x/100)
            Compass.dynamicPosition.y = Compass.dynamicPosition.y + (y/100)
            txt = ("Compass pos.\n%.3f,%.3f"):format(Compass.dynamicPosition.x, Compass.dynamicPosition.y)
        elseif (moveType == 2) then
            Compass.dynamicPosition.xTxtL = Compass.dynamicPosition.xTxtL + (x/100)
            Compass.dynamicPosition.fontSize = Compass.dynamicPosition.fontSize + (y/100)
            txt = ("Compass txtL-off,fontSize.\n%.3f,%.3f"):format(Compass.dynamicPosition.xTxtL,Compass.dynamicPosition.fontSize)
        elseif (moveType == 3) then
            Compass.dynamicPosition.xTxt = Compass.dynamicPosition.xTxt + (x/100)
            Compass.dynamicPosition.yTxt = Compass.dynamicPosition.yTxt + (y/100)
            txt = ("Compass txt-off.\n%.3f,%.3f"):format(Compass.dynamicPosition.xTxt, Compass.dynamicPosition.yTxt)
        elseif (moveType == 4) then
            Compass.dynamicPosition.w = Compass.dynamicPosition.w + (x/100)
            Compass.dynamicPosition.h = Compass.dynamicPosition.h + (y/100)
            txt = ("Compass w/h.\n%.3f,%.3f"):format(Compass.dynamicPosition.w, Compass.dynamicPosition.h)
        elseif (moveType == 5) then
            Compass.dynamicPosition.overlayAlpha = Utils.clamp(Compass.dynamicPosition.overlayAlpha + (x/100), 0, 1)
            setOverlayColor(Compass.dynamicPosition.overlay, 0,0,0,Compass.dynamicPosition.overlayAlpha) -- make it black
            txt = ("Compass alpha.\n%.3f"):format(Compass.dynamicPosition.overlayAlpha)
        end
        
        setTextColor(1,1,1,1)
        setTextBold(true)
        renderText(0.5, 0.5, 0.022, txt);
    end
    
    drawCompass2(compassAngle, Compass.dynamicPosition);
end
  
--Compass.addDrawFunc( function(compassAngle) moveableDrawCompass(1, compassAngle) end );
--Compass.addDrawFunc( function(compassAngle) moveableDrawCompass(2, compassAngle) end );
--Compass.addDrawFunc( function(compassAngle) moveableDrawCompass(3, compassAngle) end );
--Compass.addDrawFunc( function(compassAngle) moveableDrawCompass(4, compassAngle) end );
--Compass.addDrawFunc( function(compassAngle) moveableDrawCompass(5, compassAngle) end );
--Compass.addDrawFunc( function(compassAngle) moveableDrawCompass(0, compassAngle) end );

--
--
--


local function drawCompass3(compassAngle, props)
    local worldCornerNum = 1 + (math.floor((compassAngle + 22.5) / 45) % 8);
    --local txt = Compass.worldCorners[worldCornerNum] .. string.format(" %5.1f", compassAngle);

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

--

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

function Compass.saveCompassPresets()
    -- Make use of the 'ModsSettings'-mod for storing/retrieving the compass presets.
    if ModsSettings ~= nil and ModsSettings.isVersion("0.2.0", "Compass") then
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
    
--[[
    -- Inspired by ZZZ_GPS
    local function checkIsDedi()
        local pixelX, pixelY = getScreenModeInfo(getScreenMode());
        return pixelX*pixelY < 1;
    end;
    local isDediServer = checkIsDedi();
    --
    if g_dedicatedServerInfo ~= nil or isDediServer then
        print("** Compass seems to be running on a dedicated-server. So will not create 'Compass_config.xml' file.");
        return;
    end

    local fileName = g_modsDirectory .. "/" .. "Compass_config.XML";

    local tag = "compassConfig"
    local xmlFile = createXMLFile(tag, fileName, tag)
    
    setXMLString(xmlFile, tag.."#screenWidthHeight", ""..g_screenWidth.." "..g_screenHeight)
    
    local i = 0
    for _,cp in pairs(Compass.compassPresets) do
      local tag = ("compassConfig.preset(%d)"):format(i)
      i=i+1

      setXMLString( xmlFile, tag.."#name"             , cp.name)
      if Compass.drawFuncIdx == i then
        setXMLBool( xmlFile, tag.."#selected"         , true)
      end
      setXMLString( xmlFile, tag.."#xyPos"            , vectorToString( { cp.x, cp.y } , toFloat3Decimals ))
      setXMLString( xmlFile, tag.."#boxWH"            , vectorToString( { cp.w, cp.h } , toFloat3Decimals ))
      setXMLString( xmlFile, tag.."#fontSize"         , toFloat3Decimals(cp.fontSize))
      setXMLBool(   xmlFile, tag.."#fontBold"         , cp.fontBold)
      setXMLString( xmlFile, tag.."#fontColor"        , vectorToString( cp.fontColor , toFloat3Decimals ) )
      setXMLString( xmlFile, tag.."#boxColor"         , vectorToString( cp.boxColor  , toFloat3Decimals ) )
      setXMLString( xmlFile, tag.."#leftAlignOffset"  , toFloat3Decimals(cp.xTxtL))
      setXMLString( xmlFile, tag.."#rightAlignOffset" , toFloat3Decimals(cp.xTxtR))
    end
    
    saveXMLFile(xmlFile);
    delete(xmlFile);
--]]    
end    

local function addPreset(name, x,y, w,h, fontSize, fontBold, fontColor, boxColor, leftAlignOff, rightAlignOff, yTxtOff)
  table.insert(
    Compass.compassPresets,
    {
      name=name,
      overlay=Compass.hudBlack, boxColor=boxColor,
      x=x, y=y, 
      w=w, h=h, 
      fontSize=fontSize, fontBold=fontBold, fontColor=fontColor,
      xTxtL=leftAlignOff, xTxtR=rightAlignOff, yTxt=yTxtOff
    }
  );
  
  local presetNum = table.getn(Compass.compassPresets)
  
  Compass.addDrawFunc( 
    function(compassAngle) 
      drawCompass3(compassAngle, Compass.compassPresets[presetNum])
    end 
  );
end

function Compass.loadCompassPresets()
    Compass.compassPresets = {}

    local wasLoaded = false;

    -- Make use of the 'ModsSettings'-mod for storing/retrieving the compass presets.
    if ModsSettings ~= nil and ModsSettings.isVersion("0.2.0", "Compass") then
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
--[[
    local fileName = g_modsDirectory .. "/" .. "Compass_config.XML";
    if fileExists(fileName) then
      local tag = "compassConfig"
      local xmlFile = loadXMLFile(tag, fileName, tag)
      if xmlFile ~= nil then
        local tag = "compassConfig"
        local lastScreenWH = { Utils.getVectorFromString(getXMLString(xmlFile, tag.."#screenWidthHeight")) }

        if  lastScreenWH[1] == g_screenWidth 
        and lastScreenWH[2] == g_screenHeight 
        then
          local i = 0
          while true do
            tag = ("compassConfig.preset(%d)"):format(i)
            i=i+1
            if not hasXMLProperty(xmlFile, tag.."#name") then
              break
            end
          
            local selected      = getXMLBool(                               xmlFile, tag.."#selected")
            local name          = getXMLString(                             xmlFile, tag.."#name")
            local xy            = { Utils.getVectorFromString(getXMLString( xmlFile, tag.."#xyPos")) }
            local wh            = { Utils.getVectorFromString(getXMLString( xmlFile, tag.."#boxWH")) }
            local fontSize      = getXMLFloat(                              xmlFile, tag.."#fontSize")
            local fontBold      = getXMLBool(                               xmlFile, tag.."#fontBold")
            local fontColor     = { Utils.getVectorFromString(getXMLString( xmlFile, tag.."#fontColor")) }
            local boxColor      = { Utils.getVectorFromString(getXMLString( xmlFile, tag.."#boxColor"))  }
            local leftAlignOff  = getXMLFloat(                              xmlFile, tag.."#leftAlignOffset")
            local rightAlignOff = getXMLFloat(                              xmlFile, tag.."#rightAlignOffset")
            
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
              if selected then
                Compass.drawFuncIdx = table.getn(Compass.compassPresets);
              end
              --
              wasLoaded = true
            end
          end
        end
        
        delete(xmlFile)
      end
    end
--]]
    
    if not wasLoaded then
      -- Default presets
      addPreset("Default",
        g_currentMission.hudBackgroundOverlay.x,
        g_currentMission.hudBackgroundOverlay.y + g_currentMission.hudBackgroundOverlay.height,
        0.060,0.020, 0.014, false, {1,1,1,1}, {0,0,0,0.5}, 0.005, 0.005, 0.004
      )

      addPreset("BelowClock",   
        g_currentMission.weatherTimeBackgroundOverlay.x,
        g_currentMission.weatherTimeBackgroundOverlay.y - 0.020,
        0.060,0.020, 0.014, false, {1,1,1,1}, {0,0,0,0.5}, 0.005, 0.005, 0.004
      )

      addPreset("AboveClock",   
        g_currentMission.weatherTimeBackgroundOverlay.x,
        g_currentMission.weatherTimeBackgroundOverlay.y + g_currentMission.weatherTimeBackgroundOverlay.height,
        0.060,1.0 - (g_currentMission.weatherTimeBackgroundOverlay.y + g_currentMission.weatherTimeBackgroundOverlay.height), 0.014, false, {1,1,1,1}, {0,0,0,0.5}, 0.005, 0.005, 0.004
      )

      addPreset("TopCenter",    
        0.5 - (0.060 / 2),
        1.0 - (0.020), 
        0.060,0.020, 0.014, false, {1,1,1,1}, {0,0,0,0.5}, 0.005, 0.005, 0.004
      )

      addPreset("BelowMapRight",
        g_currentMission.ingameMap.mapPosX + g_currentMission.ingameMap.mapWidth - 0.060,
        0.0,
        0.060,g_currentMission.ingameMap.mapPosY, 0.014, false, {1,1,1,1}, {0,0,0,0.5}, 0.005, 0.005, 0.004
      )

      addPreset("BottomCenter", 
        0.5 - (0.060 / 2),
        0.000, 
        0.060,0.020, 0.014, false, {1,1,1,1}, {0,0,0,0.5}, 0.005, 0.005, 0.004
      )
      
      addPreset("BelowSchema",  
        g_currentMission.hudSelectionBackgroundOverlay.x,
        0.0,
        0.060,g_currentMission.hudSelectionBackgroundOverlay.y - 0, 0.014, false, {1,1,1,1}, {0,0,0,0.5}, 0.005, 0.005, 0.004
      )

      addPreset("LeftOfSchema", 
        g_currentMission.hudSelectionBackgroundOverlay.x - 0.064,
        g_currentMission.hudSelectionBackgroundOverlay.y,
        0.064,g_currentMission.hudSelectionBackgroundOverlay.height, 0.016, false, {1,1,1,1}, {0,0,0,0.5}, 0.005, 0.005, 0.008
      )
      
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

    --Compass.saveCompassPresets()
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
            Compass:overrideDrivableDraw()
            --
            Compass.loadCompassPresets()
            Compass.drawFuncIdx = math.min(math.max(Utils.getNoNil(Compass.drawFuncIdx, 1), 0), table.getn(Compass.drawFuncs))
        end
    else
        if InputBinding.hasEvent(InputBinding.COMPASS_TOGGLE) then
            Compass.drawFuncIdx = (Compass.drawFuncIdx + 1) % (1+table.getn(Compass.drawFuncs))
            Compass.saveCompassPresets()
        end;
    end
end;

function Compass:draw()
end;

function Compass:overrideDrivableDraw()
    Drivable.draw = Utils.appendedFunction(Drivable.draw, Compass.DrawCompass);
end

function Compass.getDrawFuncName(idx)
  local name = "unknown";
  if idx > 0 and idx <= table.getn(Compass.compassPresets) then
     name = Utils.getNoNil(Compass.compassPresets[idx].name, idx);
  else
     name = "hidden";
  end
  return " ("..name..")";
end

--
Compass.DrawCompass = function(self)
    if g_currentMission.showHelpText then
        -- Only show in helpbox, if correct key-modifier is pressed (SHIFT/CTRL/ALT), or there is no key-modifier assigned to the InputBinding.COMPASS_TOGGLE
        if (Compass.keyModifier_COMPASS_TOGGLE == nil) or (Input.isKeyPressed(Compass.keyModifier_COMPASS_TOGGLE)) then
            g_currentMission:addHelpButtonText(g_i18n:getText("COMPASS_TOGGLE") .. Compass.getDrawFuncName(Compass.drawFuncIdx), InputBinding.COMPASS_TOGGLE);
        end;
    end;

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
