-- autoQualityCircles v1.1 | by Elbard

require "Inspired"
class "autoQualityCircles"

function autoQualityCircles:__init()
  self.cfg = MenuConfig("Auto Quality Circles", "autoQualityCircles")
  self.myHeroPos = GetOrigin(myHero) -- myHero position
  self.savedMessages = {}
  self.second = 1000
  self.gTimeDelay = 0
  self.dTimeDelay = 0
  self.circleAssigned = false
  _G.oldDrawCircle = rawget(_G, 'DrawCircle')

  self.cfg:Boolean("debug", "Show Debug Info", false)
  self.cfg:Boolean("qual", "Adjust global circle quality", true)
  self.cfg:Slider("gQual", "Global quality multiplier", 1, 1, 10)
  self.cfg:Menu("range", "Test Circle")
  self.cfg.range:Boolean("drawRange", "Draw", false)
  self.cfg.range:Slider("circleRange", "Range", 500, 1, 1400)
  self.cfg.range:ColorPick("circleCol", "Color", {255, 0, 204, 102})
  self.cfg.range:Slider("circleQual", "Test multiplier x1", 1, 0, 10)
  self.cfg.range:Slider("qualMultiTen", "Test multiplier x10", 1, 1, 10)
  self.cfg.range:Slider("qualMultiHun", "Test multiplier x100", 1, 1, 10)
  self.cfg.range:Slider("circleWidth", "Width", 2, 1, 20)
  OnTick(function() self:Tick() end)
  OnDraw(function() self:Draw() end)
  self:Msg("Loaded!", "autoQualityCircles")
end

function autoQualityCircles:getGoodQuality(range)
  local multi = 1 + ((self.cfg.gQual:Value() - 1) / 10)
  self:printLimitedDebugMsg("multi value = "..tostring(multi))
  if range < 11 then
    return 100 / multi
  elseif range > 10 and range < 21 then
    return 14 / multi
  elseif range > 20 and range < 31 then
    return 16 / multi
  elseif range > 30 and range < 41 then
    return 20 / multi
  elseif range > 40 and range < 51 then
    return 25 / multi
  elseif range > 50 and range < 71 then
    return 33 / multi
  elseif range > 70 and range < 91 then
    return 50 / multi
  elseif range > 90 and range < 141 then
    return 62 / multi
  elseif range > 140 and range < 241 then
    return 83 / multi
  elseif range > 240 and range < 301 then
    return 100 / multi
  elseif range > 300 and range < 401 then
    return 125 / multi
  elseif range > 400 and range < 601 then
    return 142 / multi
  elseif range > 600 and range < 901 then
    return 166 / multi
  elseif range > 900 and range < 1401 then
    return 200 / multi
  end
end

 -- If someone can teach me, how to make this class function, I will appreciate *)
function myDrawCircle(x, y , z, radius, width, quality, colorARGB)
  if not quality then
    origin, radius, width, quality, colorARGB = x, y , z, radius, width
    if  radius > 1400 then
      oldDrawCircle(origin, 1400, width, AQC_Instance:getGoodQuality(1400), colorARGB)
      AQC_Instance:printLimitedDebugMsg(" !! warning !! circle radius limited to 1400") -- else bad things will happen
    else
      oldDrawCircle(origin, radius, width, AQC_Instance:getGoodQuality(radius), colorARGB)
    end
  else
    if radius > 1400 then
      oldDrawCircle(x, y , z, 1400, width, AQC_Instance:getGoodQuality(1400), colorARGB)
      AQC_Instance:printLimitedDebugMsg(" !! warning !! circle radius limited to 1400") -- else bad things will happen
    else
      oldDrawCircle(x, y , z, radius, width, AQC_Instance:getGoodQuality(radius), colorARGB)
    end
  end
end

function autoQualityCircles:Tick()
  if GetTickCount() > self.gTimeDelay then -- loop (2)
    if self.cfg.qual:Value() then
      if not self.circleAssigned then
        _G.DrawCircle = myDrawCircle
        self.circleAssigned = true
        self:printDebugMsg("circle SET")
      end
    else
      if self.circleAssigned then
        _G.DrawCircle = _G.oldDrawCircle
        self:printDebugMsg("circle BACK")
        self.circleAssigned = false
      end
    end
    self:printDebugMsg("in g loop")
    self.gTimeDelay = GetTickCount() + 1 * self.second
  end
  self:printLimitedDebugMsg("test")
  if self.cfg.range.drawRange:Value() then
    self.myHeroPos = GetOrigin(myHero)
  end
end

function autoQualityCircles:calculateQuality()
  local qual = 1000/(self.cfg.range.circleQual:Value()*self.cfg.range.qualMultiTen:Value()*self.cfg.range.qualMultiHun:Value())
  self:printLimitedDebugMsg("quality = "..qual)
  return qual
end

function autoQualityCircles:Draw()
  if self.cfg.range.drawRange:Value() then
    self:printLimitedDebugMsg("myHeroPos{x="..math.floor(self.myHeroPos.x)..", y="..math.floor(self.myHeroPos.y)..
      ", z="..math.floor(self.myHeroPos.z).."}")
    self:printLimitedDebugMsg("range="..self.cfg.range.circleRange:Value()..
      ", width="..self.cfg.range.circleWidth:Value()..", col{A="..self.cfg.range.circleCol.color[1]:Value()..
        ", R="..self.cfg.range.circleCol.color[2]:Value()..", G="..self.cfg.range.circleCol.color[3]:Value()..
          ",B="..self.cfg.range.circleCol.color[4]:Value().."}")
    DrawCircle(self.myHeroPos, self.cfg.range.circleRange:Value(), self.cfg.range.circleWidth:Value(), self:calculateQuality(), 
        self.cfg.range.circleCol:Value());
          -- (params: x, y , z, radius, width, quality, colorARGB)
  end
end

function autoQualityCircles:printDebugMsg(msg)
  if self.cfg.debug:Value() then PrintChat(self:color("debug", "FFB266")..": "..msg) end
end

function autoQualityCircles:printLimitedDebugMsg(msg)
  if self.cfg.debug:Value() and GetTickCount() > self.dTimeDelay then
    self.savedMessages[msg] = 1
    for cMsg, _ in pairs(self.savedMessages) do
      PrintChat(self:color("limited", "FFFFFF")..": "..cMsg)
    end
    for k in pairs (self.savedMessages) do self.savedMessages[k] = nil end
    self.dTimeDelay = GetTickCount() + 1 * self.second
  else
    self.savedMessages[msg] = 1
  end
end

function autoQualityCircles:color(msg, hexColorCode) -- color text
  return "<font color=\"#"..hexColorCode.."\">"..msg.."</font>"
end

function autoQualityCircles:Msg(msg, script)
  PrintChat("<font color=\"#00FFFF\">["..script.."]:</font> <font color=\"#FFFFFF\">"..msg.."</font>")
end

_G.AQC_Instance = autoQualityCircles() -- init
