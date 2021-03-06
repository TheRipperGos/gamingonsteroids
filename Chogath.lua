if myHero.charName ~= "Chogath" then return end
keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}


local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
function SetMovement(bool)
	if _G.EOWLoaded then
		EOW:SetMovements(bool)
		EOW:SetAttacks(bool)
	elseif _G.SDK then
		SDK.Orbwalker:SetMovement(bool)
		SDK.Orbwalker:SetAttack(bool)
	else
		GOS.BlockMovement = not bool
		GOS.BlockAttack = not bool
	end
	if bool then
		castSpell.state = 0
	end
end

class "Chogath"
local Scriptname,Version,Author,LVersion = "TRUSt in my Chogath","v1.0","TRUS","7.23"

if FileExist(COMMON_PATH .. "TPred.lua") then
	require 'TPred'
end

function Chogath:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	local orbwalkername = ""
	if _G.SDK then
		orbwalkername = "IC'S orbwalker"
	elseif _G.EOW then
		orbwalkername = "EOW"	
	elseif _G.GOS then
		orbwalkername = "Noddy orbwalker"
	else
		orbwalkername = "Orbwalker not found"
		
	end
	PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername .. (TPred and " TPred" or ""))
end

--[[Spells]]
function Chogath:LoadSpells()
	Q = {Range = 950, Width = 250, Delay = 1.2, Speed = math.huge}
	W = {Range = 650, Width = 60, Delay = 0.25, Speed = math.huge}
end
function Chogath:GetEnemyHeroes()
	self.EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(self.EnemyHeroes, Hero)
		end
	end
	return self.EnemyHeroes
end


function Chogath:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyChogath", name = Scriptname})
	
	--[[Combo]]
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "comboUseQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseE", name = "Use E", value = true})
	self.Menu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	
	--[[Harass]]
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "harassUseQ", name = "Use Q", value = true})
	self.Menu.Harass:MenuElement({id = "harassUseW", name = "Use W", value = true})
	self.Menu.Harass:MenuElement({id = "harassUseE", name = "Use E", value = true})
	self.Menu.Harass:MenuElement({id = "harassMana", name = "Minimal mana percent:", value = 30, min = 0, max = 101, identifier = "%"})
	self.Menu.Harass:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("C")})
	
	self.Menu:MenuElement({type = MENU, id = "RUse", name = "UseR Settings"})
	self.Menu.RUse:MenuElement({id = "forceR", name = "Force R on closest target", key = string.byte("T")})
	for i, hero in pairs(self:GetEnemyHeroes()) do
		self.Menu.RUse:MenuElement({id = "RU"..hero.charName, name = "Use AutoR on: "..hero.charName, value = true})
	end
	self.Menu.RUse:MenuElement({id = "JungleR", name = "Use in jungle", value = true})
	self.Menu.RUse:MenuElement({id = "Dragon", name = "Use AutoR on: Dragon", value = true})
	self.Menu.RUse:MenuElement({id = "Baron", name = "Use AutoR on: Baron", value = true})
	self.Menu.RUse:MenuElement({id = "Herald", name = "Use AutoR on: Herald", value = true})
	self.Menu:MenuElement({type = MENU, id = "DrawMenu", name = "Draw Settings"})
	self.Menu.DrawMenu:MenuElement({type = MENU, id = "RMenu", name = "R draw Settings"})
	self.Menu.DrawMenu.RMenu:MenuElement({id = "DrawOnEnemy", name = "Killable text on enemy", value = true})
	self.Menu.DrawMenu.RMenu:MenuElement({id = "DrawColor", name = "Color for drawing", color = Draw.Color(0xBF3F3FFF)})
	self.Menu.DrawMenu.RMenu:MenuElement({id = "TextOffset", name = "Z offset for text ", value = 0, min = -100, max = 100})
	self.Menu.DrawMenu.RMenu:MenuElement({id = "TextSize", name = "Font size ", value = 30, min = 2, max = 64})
	self.Menu.DrawMenu:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
	self.Menu.DrawMenu:MenuElement({id = "QRangeC", name = "Q Range color", color = Draw.Color(0xBF3F3FFF)})
	self.Menu.DrawMenu:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
	self.Menu.DrawMenu:MenuElement({id = "WRangeC", name = "W Range color", color = Draw.Color(0xBFBF3FFF)})
	self.Menu.DrawMenu:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
	self.Menu.DrawMenu:MenuElement({id = "RRangeC", name = "R Range color", color = Draw.Color(0xBF3FBFFF)})
	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. "" .. (TPred and " TPred" or "")})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function CurrentModes()
	local canmove, canattack
	if _G.SDK then -- ic orbwalker
		canmove = _G.SDK.Orbwalker:CanMove()
		canattack = _G.SDK.Orbwalker:CanAttack()
	elseif _G.EOW then -- eternal orbwalker
		canmove = _G.EOW:CanMove() 
		canattack = _G.EOW:CanAttack()
	else -- default orbwalker
		canmove = _G.GOS:CanMove()
		canattack = _G.GOS:CanAttack()
	end
	return canmove, canattack
end

function Chogath:Tick()
	if myHero.dead then return end
	local combomodeactive = self.Menu.Combo.comboActive:Value()
	local HarassMinMana = self.Menu.Harass.harassMana:Value()
	local harassactive = self.Menu.Harass.harassActive:Value()
	if combomodeactive then
		if self.Menu.Combo.comboUseQ:Value() and self:CanCast(_Q) then
			self:CastQ()
		end
		if self.Menu.Combo.comboUseW:Value() and self:CanCast(_W) then
			self:CastW()
		end
		if self.Menu.Combo.comboUseE:Value() and self:CanCast(_E) then
			self:CastE()
		end
	elseif (harassactive and myHero.maxMana * HarassMinMana * 0.01 < myHero.mana) then 
		if self.Menu.Harass.harassUseQ:Value() and self:CanCast(_Q) then
			self:CastQ()
		elseif self.Menu.Harass.harassUseW:Value() and self:CanCast(_W) then
			self:CastW()
		elseif self.Menu.Harass.harassUseE:Value() and self:CanCast(_E) then
			self:CastE()
		end
	end
	if self:CanCast(_R) then 
		if 	self.Menu.RUse.forceR:Value() then
			self:ForceR()
		end
		self:AutoR()
	end
end


function GetDistanceSqr(p1, p2)
	assert(p1, "GetDistance: invalid argument: cannot calculate distance to "..type(p1))
	return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function GetDistance(p1, p2)
	return math.sqrt(GetDistanceSqr(p1, p2))
end



function EnableMovement()
	SetMovement(true)
end

function ReturnCursor(pos)
	Control.SetCursorPos(pos)
	DelayAction(EnableMovement,0.1)
end

function LeftClick(pos)
	Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
	Control.mouse_event(MOUSEEVENTF_LEFTUP)
	DelayAction(ReturnCursor,0.05,{pos})
end

function Chogath:CastSpell(spell,pos)
	local customcast = self.Menu.CustomSpellCast:Value()
	if not customcast then
		Control.CastSpell(spell, pos)
		return
	else
		local delay = self.Menu.delay:Value()
		local ticker = GetTickCount()
		if castSpell.state == 0 and ticker > castSpell.casting then
			castSpell.state = 1
			castSpell.mouse = mousePos
			castSpell.tick = ticker
			if ticker - castSpell.tick < Game.Latency() then
				--block movement
				SetMovement(false)
				if (spell == HK_R) then
					Control.KeyDown(HK_TCO)
				end
				Control.SetCursorPos(pos)
				Control.KeyDown(spell)
				Control.KeyUp(spell)
				if (spell == HK_R) then
					Control.KeyUp(HK_TCO)
				end
				DelayAction(LeftClick,delay/1000,{castSpell.mouse})
				castSpell.casting = ticker + 500
			end
		end
	end
end

function Chogath:CastQ()
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AP"))
	if target and target.type == "AIHeroClient" and self:CanCast(_Q) then
		local castpos
		if (TPred) then
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay, Q.Width, Q.Range,Q.Speed,myHero.pos,false, "circular")
			if (HitChance > 0) then
				self:CastSpell(HK_Q, castpos)
			end
		else
			castPos = target:GetPrediction(Q.Speed,Q.Delay)
			self:CastSpell(HK_Q, castPos)
		end
	end
end

function Chogath:CastW()
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(W.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(W.Range,"AP"))
	if target and target.type == "AIHeroClient" and self:CanCast(_W) then
		local castpos
		if (TPred) then
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, W.Delay, W.Width, W.Range,W.Speed,myHero.pos,false)
			if (HitChance > 0) then
				local newpos = myHero.pos:Extended(castpos,math.random(100,300))
				self:CastSpell(HK_W, newpos)
			end
		else
			castPos = target:GetPrediction(W.Speed,W.Delay)
			local newpos = myHero.pos:Extended(castPos,math.random(100,300))
			self:CastSpell(HK_W, castPos)
		end
	end
end

function Chogath:CastE()
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(myHero.range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(myHero.range,"AP"))
	local canmove, canattack = CurrentModes()
	if canmove and not canattack and myHero:GetSpellData(_E).ammoCurrentCd == 0 then
		Control.CastSpell(HK_E)
	end
end
function Chogath:GetRDMG()
	local rdamage = 125 + myHero:GetSpellData(_R).level*175 + 0.5*myHero.ap + 0.1*(myHero.maxHealth - (574.4 + 80*(myHero.levelData.lvl-1)))
	return rdamage
end

function Chogath:GetRDMGPve()
	local rdamage = 1000 + 0.5*myHero.ap + 0.1*(myHero.maxHealth - (574.4 + 80*(myHero.levelData.lvl-1)))
	return rdamage
end

local FoodTable = {
	SRU_Baron = "",
	SRU_RiftHerald = "",
	SRU_Dragon_Water = "",
	SRU_Dragon_Fire = "",
	SRU_Dragon_Earth = "",
	SRU_Dragon_Air = "",
	SRU_Dragon_Elder = "",
}

function Chogath:AutoR()
	local rrange = 175 + myHero.boundingRadius + 60
	for i, target in pairs(self:GetEnemyHeroes()) do
		if GetDistance(myHero.pos, target.pos) <= rrange then
			local RDamage = self:GetRDMG()
			if self.Menu.RUse["RU"..target.charName] and self.Menu.RUse["RU"..target.charName]:Value() and RDamage > target.health and self:IsValidTarget(target) then
				self:CastSpell(HK_R, target.pos)
			end
		end
	end
	if self.Menu.RUse.JungleR:Value() then
		local RDamage = self:GetRDMGPve()
		local minionlist = {}
		if _G.SDK then
			minionlist = _G.SDK.ObjectManager:GetMonsters(Q.Range)
		elseif _G.GOS then
			for i = 1, Game.MinionCount() do
				local minion = Game.Minion(i)
				if minion.valid and minion.isEnemy and minion.pos:DistanceTo(myHero.pos) < Q.Range then
					table.insert(minionlist, minion)
				end
			end
		end
		for i, minion in pairs(minionlist) do
			if self.Menu.RUse.Dragon:Value() then
				if FoodTable[minion.charName] and RDamage > minion.health then
					Control.CastSpell(HK_R, minion.pos)
				end
			end
			if self.Menu.RUse.Herald:Value() then
				if minion.charName == "SRU_RiftHerald" and RDamage > minion.health then
					Control.CastSpell(HK_R, minion.pos)
				end
			end
			if self.Menu.RUse.Baron:Value() then
				if minion.charName == "SRU_Baron" and RDamage > minion.health then 
					Control.CastSpell(HK_R, minion.pos)
				end
			end
		end
	end
end
function Chogath:IsValidTarget(unit, range, checkTeam, from)
	local range = range == nil and math.huge or range
	if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or (checkTeam and unit.isAlly) then
		return false
	end
	if myHero.pos:DistanceTo(unit.pos)>range then return false end 
	return true 
end

function Chogath:ForceR()
	local rrange = 175 + myHero.boundingRadius + 60
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(rrange, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(rrange,"AP"))
	if target then 
		self:CastSpell(HK_R, target.pos)
	end
end


function Chogath:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Chogath:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Chogath:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function Chogath:Draw()
	if myHero.dead then return end 
	
	if self.Menu.DrawMenu.DrawQ:Value() then
		Draw.Circle(myHero.pos, Q.Range, 3, self.Menu.DrawMenu.QRangeC:Value())
	end
	if self.Menu.DrawMenu.DrawW:Value() then
		Draw.Circle(myHero.pos, W.Range, 3, self.Menu.DrawMenu.WRangeC:Value())
	end

	if self.Menu.DrawMenu.DrawR:Value() then
		local rrange = 175 + myHero.boundingRadius + 60
		Draw.Circle(myHero.pos, rrange, 3, self.Menu.DrawMenu.RRangeC:Value())
	end
	
	
	if self:CanCast(_R) then
		if self.Menu.DrawMenu.RMenu.DrawOnEnemy:Value() then
			local offset = self.Menu.DrawMenu.RMenu.TextOffset:Value()
			local fontsize = self.Menu.DrawMenu.RMenu.TextSize:Value()
			for i, target in ipairs(self:GetEnemyHeroes()) do
				local RDamage = self:GetRDMG()
				if self.Menu.DrawMenu.RMenu.DrawOnEnemy:Value() then
					if RDamage < target.health then
						Draw.Text(math.floor(target.health - RDamage), fontsize, target.pos2D.x, target.pos2D.y+offset,self.Menu.DrawMenu.RMenu.DrawColor:Value())
					end
				end
			end
		end
	end
end
function OnLoad()
	Chogath()
end