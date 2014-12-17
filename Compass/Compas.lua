--
-- Compas for Steerable
--
-- @author  Decker    (ls-uk.info, Decker_MMIV)
-- @date    2011-12-18
--
-- @history v0.9(beta)  Public release
--          v1.0        Changed to overload 'Steerable', particular needed for the Lexion 770 combine.
--                      Detect if old-version is still loaded, then display a text on screen.
--          v1.2        Use of Utils.appendedFunction(), instead of "overtaking" the Steerable.draw function,
--                       so the compas will still be drawn when using the 'D+M Monopol Map' in multiplayer.
--                      Added InputBinding for compas show/hide, instead of the hardcoded ALT+C,
--                       and made use of only showing in helpbox when key-modifier is pressed (if any).
--                      Removal of really-old-version detection.
--

Compas = {};
Compas.showOnHud = true;
Compas.hudX = 0.870;
Compas.hudY = 0.855;
Compas.hudOverlay = Overlay:new("hudOverlay", Utils.getFilename("Compas_hud.dds", g_currentModDirectory), Compas.hudX, Compas.hudY, 0.12, 0.039);

addModEventListener(Compas);

--
function Compas:loadMap(name)
    Compas.keyBindingModifier = getKeyModifier(InputBinding.CompasHUD);
end;

--http://stackoverflow.com/questions/656199/search-for-an-item-in-a-lua-list
function Set(list)
    local set = {};
    for _,l in ipairs(list) do
        set[l]=true;
    end;
    return set;
end;

function getKeyModifier(binding)
    local allowedModifiers = Set({
        Input.KEY_lshift,
        Input.KEY_rshift,
        Input.KEY_shift,
        Input.KEY_lctrl, 
        Input.KEY_rctrl, 
        Input.KEY_lalt,  
        Input.KEY_ralt  
    });
    for _,k in pairs(InputBinding.digitalActions[binding].key1Modifiers) do
        if allowedModifiers[k] then
            return k;
        end;
    end;
    return nil;
end;

function Compas:deleteMap()
end;

function Compas:mouseEvent(posX, posY, isDown, isUp, button)
end;

function Compas:keyEvent(unicode, sym, modifier, isDown)
end;

function Compas:update(dt)
    if InputBinding.hasEvent(InputBinding.CompasHUD) then
        Compas.showOnHud = not Compas.showOnHud;
    end;
end;

function Compas:draw()
    if g_currentMission.showHelpText then
        -- Only show in helpbox, if correct key-modifier is pressed (SHIFT/CTRL/ALT), or there is no key-modifier assigned to the InputBinding.CompasHUD
        if (Compas.keyBindingModifier == nil) or (Input.isKeyPressed(Compas.keyBindingModifier)) then
            g_currentMission:addHelpButtonText(g_i18n:getText("CompasHUD"), InputBinding.CompasHUD);
        end;
    end;
end;



--
--
--
Compas.drawCompas = function(self)
  if Compas.showOnHud then
    if self:getIsActiveForInput() then
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

            local dirText = "";

            if     (direction >= 337.5    or  direction <  22.5   ) then  dirText = g_i18n:getText("north");       --"N";
            elseif (direction >=  22.5    and direction <  67.5   ) then  dirText = g_i18n:getText("northeast");   --"NE";
            elseif (direction >=  67.5    and direction < 112.5   ) then  dirText = g_i18n:getText("east");        --"E";
            elseif (direction >= 112.5    and direction < 157.5   ) then  dirText = g_i18n:getText("southeast");   --"SE";
            elseif (direction >= 157.5    and direction < 202.5   ) then  dirText = g_i18n:getText("south");       --"S";
            elseif (direction >= 202.5    and direction < 247.5   ) then  dirText = g_i18n:getText("southwest");   --"SW";
            elseif (direction >= 247.5    and direction < 292.5   ) then  dirText = g_i18n:getText("west");        --"W";
            elseif (direction >= 292.5    and direction < 337.5   ) then  dirText = g_i18n:getText("northwest");   --"NW";
            end;

            dirText = dirText .. string.format(" %6.2f", direction);
            Compas.hudOverlay:render();
            setTextAlignment(RenderText.ALIGN_RIGHT);
            setTextBold(true);
            setTextColor(0,0,0,1); renderText(Compas.hudX+0.105, Compas.hudY+0.007, 0.022, dirText);  -- Black shadow-text
            setTextColor(1,1,1,1); renderText(Compas.hudX+0.105, Compas.hudY+0.009, 0.022, dirText);  -- White text

            -- Normalise text-styling, because other mods expect it this way.
            setTextAlignment(RenderText.ALIGN_LEFT);
            setTextBold(false);
        end;
    end;
  end;  
end;

-- A better way of adding extra functionality to existing functions, by using Utils.prependedFunction(), Utils.appendedFunction() or Utils.overwrittenFunction()
-- However a function definition like this will not work for reasons unknown; "function Compas:drawCompas()"
-- This is apparently how the function definition must be;                    "Compas.drawCompas = function(self)"
Steerable.draw = Utils.appendedFunction(Steerable.draw, Compas.drawCompas);

print("Script loaded: Compas.LUA (v1.2)");
