--
-- Compass
--
-- @author  Decker_MMIV - fs-uk.com, forum.farming-simulator.com, modhoster.com
-- @date    2011-12-18
--
-- @history
--      v0.9(beta)- Public release
--      v1.0      - Changed to overload 'Steerable', particular needed for the Lexion 770 combine.
--                - Detect if old-version is still loaded, then display a text on screen.
--      v1.2      - Use of Utils.appendedFunction(), instead of "overtaking" the Steerable.draw function,
--                   so the Compass will still be drawn when using the 'D+M Monopol Map' in multiplayer.
--                - Added InputBinding for Compass show/hide, instead of the hardcoded ALT+C,
--                   and made use of only showing in helpbox when key-modifier is pressed (if any).
--                - Removal of really-old-version detection.
--  2012-November
--      v1.3      - Upgraded to FS2013.
--                - Renamed to 'Compass'.
--                - Altered a bit with regards to the key-modifier detection.
--      v1.4      - Updated graphics to FS2013 style.
--  2013-February
--      v1.41     - Added support for CustomVehicleHUD (modCVH)
--

Compass = {};
--
local modItem = ModsUtil.findModItemByModName(g_currentModName);
Compass.version = (modItem and modItem.version) and modItem.version or "?.?.?";
--
Compass.modDir = g_currentModDirectory;


-- Support-function, that I would like to see be added to InputBinding class.
-- Maybe it is, I just do not know what its called.
function getKeyIdOfModifier(binding)
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
function Compass:loadMap(name)
  if Compass.hudOverlay == nil then
    Compass.keyModifier_COMPASS_TOGGLE = getKeyIdOfModifier(InputBinding.COMPASS_TOGGLE);
    Compass.showOnHud = true;
    Compass.hudPosSize = {x=0.870, y=0.855, w=0.12, h=0.039}; -- X,Y,Width,Height        -- TODO: Make position customizable from within the game.
    Compass.hudOverlay = createImageOverlay(Utils.getFilename("Compass_hud.dds", g_currentModDirectory));
  end;
end;

function Compass:deleteMap()
end;

function Compass:mouseEvent(posX, posY, isDown, isUp, button)
end;

function Compass:keyEvent(unicode, sym, modifier, isDown)
end;

function Compass:update(dt)
    if InputBinding.hasEvent(InputBinding.COMPASS_TOGGLE) then
        Compass.showOnHud = not Compass.showOnHud;
    end;
end;

function Compass:draw()
end;


--
Compass.drawCompass = function(self)
    if g_currentMission.showHelpText then
        -- Only show in helpbox, if correct key-modifier is pressed (SHIFT/CTRL/ALT), or there is no key-modifier assigned to the InputBinding.COMPASS_TOGGLE
        if (Compass.keyModifier_COMPASS_TOGGLE == nil) or (Input.isKeyPressed(Compass.keyModifier_COMPASS_TOGGLE)) then
            g_currentMission:addHelpButtonText(g_i18n:getText("COMPASS_TOGGLE"), InputBinding.COMPASS_TOGGLE);
        end;
    end;

  if Compass.showOnHud then
    if self:getIsActive() and self.isEntered then
        local x,y,z = localDirectionToWorld(self.rootNode, 0, 0, 1);
        local length = Utils.vector2Length(x,z);
        if (length ~= 0.0) then -- Try to make sure we do not divide by zero.
            local direction = math.deg(math.atan2(z/length,x/length)) + 90.0;   -- Rotate clockwise, so north=0, east=90, south=180, west=270.
            while (direction > 359.999999) do
                direction = direction - 360.0;
            end;
            while (direction < 0.0) do
                direction = direction + 360.0;
            end;

            --local dirText = "";
            --
            --if     (direction >= 337.5 or  direction <  22.5) then  dirText = g_i18n:getText("north");       --"N";
            --elseif (direction >=  22.5 and direction <  67.5) then  dirText = g_i18n:getText("northeast");   --"NE";
            --elseif (direction >=  67.5 and direction < 112.5) then  dirText = g_i18n:getText("east");        --"E";
            --elseif (direction >= 112.5 and direction < 157.5) then  dirText = g_i18n:getText("southeast");   --"SE";
            --elseif (direction >= 157.5 and direction < 202.5) then  dirText = g_i18n:getText("south");       --"S";
            --elseif (direction >= 202.5 and direction < 247.5) then  dirText = g_i18n:getText("southwest");   --"SW";
            --elseif (direction >= 247.5 and direction < 292.5) then  dirText = g_i18n:getText("west");        --"W";
            --elseif (direction >= 292.5 and direction < 337.5) then  dirText = g_i18n:getText("northwest");   --"NW";
            --end;
            --
            --dirText = dirText .. string.format(" %6.2f", direction);
            
            if Compass.worldCorners == nil then
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
            local wCrnr = 1+(math.floor((direction + 22.5) / 45) % 8);
            local dirText =  Compass.worldCorners[wCrnr] .. string.format(" %6.2f", direction);
            
            renderOverlay(Compass.hudOverlay, Compass.hudPosSize.x,Compass.hudPosSize.y, Compass.hudPosSize.w,Compass.hudPosSize.h);
            setTextAlignment(RenderText.ALIGN_RIGHT);
            setTextBold(true);
            setTextColor(0,0,0,1); renderText(Compass.hudPosSize.x+0.106, Compass.hudPosSize.y+0.0075, 0.022, dirText);  -- Black shadow-text
            setTextColor(1,1,1,1); renderText(Compass.hudPosSize.x+0.106, Compass.hudPosSize.y+0.0095, 0.022, dirText);  -- White text

            -- Normalise text-styling, because other mods expect it this way.
            setTextAlignment(RenderText.ALIGN_LEFT);
            setTextBold(false);
            -- color already white.
        end;
    end;
  end;  
end;


--
-- CustomVehicleHUD functionality.
--
function Compass.drawPanel(self, hudX,hudY, hudW,hudH)
  --
  if Compass.gfxBackground == nil then
    Compass.gfxBackground = createImageOverlay(Utils.getFilename("HalfPanel.dds", Compass.modDir));
    setOverlayUVs(Compass.gfxBackground, 0,0, 0,1, 1,0, 1,1);
  end;
  renderOverlay(Compass.gfxBackground, hudX,hudY, hudW,hudH);
  --
  local vx,vy,vz = localDirectionToWorld(self.rootNode, 0, 0, 1);
  local length = Utils.vector2Length(vx,vz);
  if (length ~= 0.0) then -- Try to make sure we do not divide by zero.
    local direction = math.deg(math.atan2(vz/length,vx/length)) + 90.0;   -- Rotate clockwise, so north=0, east=90, south=180, west=270.
    while (direction > 359.999999) do
      direction = direction - 360.0;
    end;
    while (direction < 0.0) do
      direction = direction + 360.0;
    end;

    if Compass.worldCorners == nil then
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
    local wCrnr = 1+(math.floor((direction + 22.5) / 45) % 8);
    
    setTextBold(true);
    setTextAlignment(RenderText.ALIGN_CENTER);
    modCVH.drawTextShaded(hudX + (hudW/32)*18, hudY, 0.023, Compass.worldCorners[wCrnr] .. string.format(" %6.2f", direction));
  end;
end;

--
if modCVH ~= nil then
  -- Use CustomVehicleHUD to draw the compass.
  modCVH.registerDrawCallback("compass", Compass.drawPanel);
else
  -- If CustomVehicleHUD not available, revert back to "normal"
  Steerable.draw = Utils.appendedFunction(Steerable.draw, Compass.drawCompass);
  addModEventListener(Compass);
end;

print(string.format("Script loaded: Compass.LUA (v%s)", Compass.version));
