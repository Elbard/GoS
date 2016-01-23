-- autoQualityCircles v1.2 | by Elbard

require "Inspired" -- MenuConfig / DrawCircle3D / Updater
class "autoQualityCircles"

function autoQualityCircles:__init()
  self.scriptName = "autoQualityCircles"
  self.gitVersionPath = "/Elbard/GoS/master/Scripts/"..self.scriptName..".version"
  self.gitScriptPath = "/Elbard/GoS/master/Scripts/"..self.scriptName..".lua"
  self.localVersion = 1.2
  self.cfg = MenuConfig("Auto Quality Circles", "autoQualityCircles")
  self.myHeroPos = GetOrigin(myHero)
  self.savedMessages = {}
  self.second = 1000
  self.gTimeDelay = 0
  self.dTimeDelay = 0
  self.circleAssigned = false
  _G.oldDrawCircle = rawget(_G, 'DrawCircle')
  _G.oldDrawCircle3D = DrawCircle3D

  self.cfg:Boolean("debug", "Show debug info (dev)", false)
  self.cfg:Boolean("checkUpdates", "Check Updates on Load", true)
  self.cfg:Boolean("adjust", "Adjust global circle quality", true)
  self.cfg:Slider("gQual", "Global quality multiplier", 5, 1, 10)
  self.cfg:Menu("testC", "Test Circle (dev)")
  self.cfg.testC:Boolean("drawRange", "Draw", false)
  self.cfg.testC:Slider("circleRange", "Range", 1, 1, 3000)
  self.cfg.testC:ColorPick("circleCol", "Color", {255, 0, 204, 102})
  self.cfg.testC:Slider("circleQual", "Local quality multiplier x1", 1, 0, 10)
  self.cfg.testC:Slider("qualMultiTen", "Local quality multiplier x10", 1, 1, 10)
  self.cfg.testC:Slider("qualMultiHun", "Local quality multiplier x100", 1, 1, 10)
  self.cfg.testC:Slider("circleWidth", "Width", 2, 1, 20)
  OnTick(function() self:Tick() end)
  OnDraw(function() self:Draw() end)
  if self.cfg.checkUpdates:Value() then
    AutoUpdater(self.localVersion, true, "raw.githubusercontent.com", self.gitVersionPath, self.gitScriptPath, self.scriptName..".lua", 
      function() self:update() end, function() self:noUpdate() end, function() self:newVersion() end, function() self:updateError() end)
  end
  self:msg("Loaded!", "autoQualityCircles")
end

function autoQualityCircles:update()
  self:msg("Successfully updated! Please reload.", "autoQualityCircles", "49C14F")
end

function autoQualityCircles:noUpdate()
  self:msg("Update is not required.", "autoQualityCircles", "709BE0")
end

function autoQualityCircles:newVersion()
  self:msg("New version found! Updating...", "autoQualityCircles", "E2C416")
end

function autoQualityCircles:updateError()
  self:msg("Error: Script was not updated!", "autoQualityCircles", "E54242")
end

 -- If someone can teach me, how to make this class function, I will appreciate *)
function myDrawCircle(x, y , z, radius, width, quality, colorARGB)
  if not colorARGB then
    origin, radius, width, quality, colorARGB = x, y , z, radius, width
    if width == 0 then width = 1 end
    myDrawCircle3D(origin.x, origin.y , origin.z, radius, width, colorARGB, 0)
  else
    if width == 0 then width = 1 end
    myDrawCircle3D(x, y , z, radius, width, colorARGB, 0)
  end
end

 -- created by Inspired | edited by Elbard
function myDrawCircle3D(x, y, z, radius, width, color, quality)
  local multi = 1 + ((AQC_Instance.cfg.gQual:Value() / 10) - 0.5)
  local points = {}
  local numOfEdges = 0

  radius = radius or 300
  numOfEdges = (math.ceil(math.pow(radius,1/(2.1/multi)))+2) -- the formula 8-)
  quality = 2 * math.pi / numOfEdges
  AQC_Instance:printLimitedDebugMsg("number of edges = "..numOfEdges)
  
  for theta = 0, 2 * math.pi + quality, quality do
    local c = WorldToScreen(1,Vector(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
    points[#points + 1] = Vector(c.x, c.y)
  end
  DrawLines2(points, width or 1, color or 4294967295)
end

function autoQualityCircles:Tick()
  if GetTickCount() > self.gTimeDelay then -- loop (2)
    if self.cfg.adjust:Value() then
      if not self.circleAssigned then
        _G.DrawCircle = myDrawCircle
        _G.DrawCircle3D = myDrawCircle3D
        self:printDebugMsg("circle SET")
        self.circleAssigned = true
      end
    else
      if self.circleAssigned then
        _G.DrawCircle = _G.oldDrawCircle
        DrawCircle3D = _G.oldDrawCircle3D
        self:printDebugMsg("circle BACK")
        self.circleAssigned = false
      end
    end
    self.gTimeDelay = GetTickCount() + 1 * self.second
  end
  if self.cfg.testC.drawRange:Value() then
    self.myHeroPos = GetOrigin(myHero)
  end
end

function autoQualityCircles:calculateDefaultQuality()
  local quality = 1000/(self.cfg.testC.circleQual:Value()*self.cfg.testC.qualMultiTen:Value()*self.cfg.testC.qualMultiHun:Value())
  if not self.cfg.adjust:Value() then self:printLimitedDebugMsg("local gos quality = "..quality) end
  return quality
end

function autoQualityCircles:calculateInspiredQuality()
  local quality = (self.cfg.testC.circleQual:Value()*self.cfg.testC.qualMultiTen:Value()*self.cfg.testC.qualMultiHun:Value())
  if not self.cfg.adjust:Value() then self:printLimitedDebugMsg("local inspired quality = "..quality) end
  return quality
end

function autoQualityCircles:Draw()
  if self.cfg.testC.drawRange:Value() then
    -- DrawCircle(self.myHeroPos,30,0,0,ARGB(0xff,0,0xff,0)); -- GREEN
    -- DrawCircle(self.myHeroPos,100,0,0,0xffffffff); -- WHITE
    -- DrawCircle(self.myHeroPos.x,self.myHeroPos.y,self.myHeroPos.z,200,0,0,0xffff0000); -- RED
    -- DrawCircle(self.myHeroPos.x,self.myHeroPos.y,self.myHeroPos.z,450,0,0,ARGB(0xff,0,0,0xff)); -- BLUE
    -- DrawCircle(self.myHeroPos.x,self.myHeroPos.y,self.myHeroPos.z,900,2,400,0xffff5500); -- ORANGE
    
    -- self:printLimitedDebugMsg("myHeroPos{x="..math.floor(self.myHeroPos.x)..", y="..math.floor(self.myHeroPos.y)..
    --   ", z="..math.floor(self.myHeroPos.z).."}") -- hero pos

    -- self:printLimitedDebugMsg("range="..self.cfg.testC.circleRange:Value()..
    --   ", width="..self.cfg.testC.circleWidth:Value()..", col{A="..self.cfg.testC.circleCol.color[1]:Value()..
    --     ", R="..self.cfg.testC.circleCol.color[2]:Value()..", G="..self.cfg.testC.circleCol.color[3]:Value()..
    --       ",B="..self.cfg.testC.circleCol.color[4]:Value().."}") -- random debug info

    DrawCircle(self.myHeroPos, self.cfg.testC.circleRange:Value(), self.cfg.testC.circleWidth:Value(), self:calculateDefaultQuality(), 
        self.cfg.testC.circleCol:Value()); -- (params: x, y , z, radius, width, quality, colorARGB)

    -- DrawCircle3D(self.myHeroPos.x, self.myHeroPos.y, self.myHeroPos.z, self.cfg.testC.circleRange:Value(),
    --   self.cfg.testC.circleWidth:Value(), self.cfg.testC.circleCol:Value(), 
    --     self:calculateInspiredQuality()) -- (params: x, y, z, radius, width, color, quality)
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

function autoQualityCircles:msg(msg, script, color)
  color = color or "FFFFFF"
  PrintChat("<font color=\"#00FFFF\">["..script.."]:</font> "..self:color(msg, color))
end

_G.AQC_Instance = autoQualityCircles() -- init
