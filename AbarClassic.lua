prev_mh_time= 0.000
prev_off_time= 0.000
mh_time = 0.000
off_time= 0.000
mh_speed = 0.000
off_speed = 0.000
eons = 0.000
eoffs= 0.000

shoot_start = 0
shoot_end = 0
shoot_event_delay = 1.5

reset_spells =
	{
		["Heroic Strike"] = true,
		["Cleave"] = true,
		["Raptor Strike"] = true,
		["Maul"] = true,
		["Slam"] = true,
		["Escape Artist"] = true,
		--Potions
		-- Healing Potions
		["Major Healing Potion"] = true,
		["Superior Healing Potion"] = true,
		["Greater Healing Potion"] = true,
		["Healing Potion"] = true,
		["Lesser Healing Potion"] = true,
		["Minor Healing Potion"] = true,
		["Combat Healing Potion"] = true,
		["Discolored Healing Potion"] = true,
		-- Other pots reset?
	}

function Abar_chat(msg)
	msg = strlower(msg)
	if msg == "fix" then
		Abar_reset()
	elseif msg=="lock" then
		Abar_Frame:Hide()
		ebar_Frame:Hide()
	elseif msg=="unlock" then
		Abar_Frame:Show()
		ebar_Frame:Show()
	elseif msg=="range" then
		abar.range= not(abar.range)
		print('range is'.. Abar_Boo(abar.range));
	elseif msg=="h2h" then
		abar.h2h = not(abar.h2h)
		print('H2H is'.. Abar_Boo(abar.h2h));
	elseif msg=="timer" then
		abar.timer = not(abar.timer)
		print('timer is'.. Abar_Boo(abar.timer));
	elseif msg=="pvp" then
		abar.pvp = not(abar.pvp)
		print('pvp is'.. Abar_Boo(abar.pvp));
	elseif msg=="mob" then
		abar.mob = not(abar.mob)
		print('mobs are'.. Abar_Boo(abar.mob));
	elseif msg=="enemy" then
		abar.enemy = not(abar.enemy)
	else
		print('use any of these to control Abar:');
		print('Lock- to lock and hide the anchor');
		print('unlock- to unlock and show the anchor');
		print('fix- to reset the values should they go awry, wait 5 sec after attacking to use this command');
		print('h2h- to turn on and off the melee bar(s)');
		print('range- to turn on and off the ranged bar');
		print('pvp- to turn on and off the enemy player bar(s)');
		print('mob- to turn on and off the enemy mob bar(s)');
		print('enemy- to turn on and off always showing target swing (default only shows if the player is target of target)')
	end
end

function Abar_loaded()
	SlashCmdList["ATKBAR"] = Abar_chat;
	SLASH_ATKBAR1 = "/abar";
	SLASH_ATKBAR2 = "/atkbar";
	if abar == nil then abar={} end
	if abar.enemy_swing == nil then
		abar.enemy_swing = true
	end
	if abar.range == nil then
		abar.range = true
	end
	if abar.h2h == nil then
		abar.h2h = true
	end
	if abar.timer == nil then
		abar.timer = true
	end
	if abar.pvp == nil then abar.pvp = true end
	if abar.mob == nil then abar.mob = true end
	if abar.shoot_event_delay ~= nil then
		shoot_event_delay = abar.shoot_event_delay
	end


	Abar_Mhr:SetPoint("LEFT",Abar_Frame,"TOPLEFT",6,-13)
	Abar_Oh:SetPoint("LEFT",Abar_Frame,"TOPLEFT",6,-35)
	Abar_MhrText:SetJustifyH("Left")
	Abar_OhText:SetJustifyH("Left")
	ebar_VL()
end

function player_cleu(subevent)
	if (string.find(subevent, "SWING.*") ~= nil) and abar.h2h then
		is_oh = select(21,CombatLogGetCurrentEventInfo())
		if subevent == "SWING_MISSED" then
			is_oh = select(13,CombatLogGetCurrentEventInfo())
		end
		Abar_selfhit(is_oh)
	elseif ((subevent == "SPELL_CAST_SUCCESS") or (subevent == "SPELL_MISSED")) and abar.h2h then
		spell = select(13, CombatLogGetCurrentEventInfo())
		Abar_spellhit(spell, true)
		if ((spell == "Shoot Gun") or (spell == "Shoot Bow") or (spell == "Shoot Crossbow")) then
			shoot_end = GetTime()
			shoot_event_delay = shoot_end - shoot_start
			abar.shoot_event_delay = shoot_event_delay
		end
	elseif (subevent == ("SPELL_CAST_START")) and abar.h2h then
		spell = select(13, CombatLogGetCurrentEventInfo())
		if ((spell == "Shoot Gun") or (spell == "Shoot Bow") or (spell == "Shoot Crossbow")) then
			shoot_start = GetTime()
			Abar_rangehit(spell)
		end
	end
end

function target_cleu(subevent)
	if (UnitIsPlayer("target")) then
		if (abar.pvp) then
			if (string.find(subevent, "SWING.*") ~= nil) and abar.h2h then
				ebar_set()
			elseif ((subevent == "SPELL_CAST_SUCCESS") or (subevent == "SPELL_MISSED")) and abar.h2h then
				spell = select(13, CombatLogGetCurrentEventInfo())
				Abar_spellhit(spell, false)
			end
		end
	else
		if (abar.mob) then
				if (string.find(subevent, "SWING.*") ~= nil) and abar.h2h then
					ebar_set()
				end
		end
	end
end
		
function player_equip_changed(inventorySlotId)
	if inventorySlotId == 17 then
		Abar_selfhit(true)
	elseif inventorySlotId == 16 then
		Abar_selfhit(false)
	end
end

function unit_spellcast_succeeded(spellid)
	if spellid == 2366 or spellid == 10248 then
		Abar_selfhit(false)
		if C_PaperDollInfo.OffhandHasWeapon() then
			Abar_selfhit(true)
		end
	end
end


function Abar_OnEvent(self, event, arg1, ...)
	if (event == "COMBAT_LOG_EVENT_UNFILTERED" and abar ~= nil) then
		local subevent = select(2, CombatLogGetCurrentEventInfo())
		local sourceGUID = select(4, CombatLogGetCurrentEventInfo())
		local destGUID = select(8, CombatLogGetCurrentEventInfo())
		if (sourceGUID == UnitGUID("player")) then
			player_cleu(subevent)
		elseif (destGUID == UnitGUID("player") or abar.enemy) and sourceGUID == UnitGUID("target") then
			target_cleu(subevent)
		end
	end
	if event == "PLAYER_EQUIPMENT_CHANGED" then player_equip_changed(arg1) end
	if event == "PLAYER_LEAVE_COMBAT" then Abar_reset() end
	if (event == "ADDON_LOADED" and arg1 == "AbarClassic") then Abar_loaded() end
	if event == "UNIT_SPELLCAST_SUCCEEDED" then unit_spellcast_succeeded()
		if arg1 == "player" then
			unit_spellcast_succeeded(select(2,...))
		end
	end
end

function Abar_rangehit(spell)
	rs,rld,rhd = UnitRangedDamage("player")
	rhd,rld= rhd-math.fmod(rhd,1),rld-math.fmod(rld,1)
	trs=rs
	rs = rs-math.fmod(rs,0.01)
	Abar_Mhrs(shoot_event_delay, "Shoot["..(rs).."s]("..rhd.."-"..rld..")",1,.5,0)
end
	

function Abar_spellhit(spell, player)
	if reset_spells[spell] and abar.h2h then
		mh_low_dmg,mh_high_dmg,off_low_dmg,off_high_dmg = UnitDamage("player")
		mh_high_dmg = mh_high_dmg-math.fmod(mh_high_dmg,1)
		mh_low_dmg = mh_low_dmg-math.fmod(mh_low_dmg,1)
		if prev_off_time == 0 then prev_off_time=off_time end
		prev_mh_time = mh_time
		total_mh_speed = mh_speed
		mh_speed = mh_speed - math.fmod(mh_speed,0.01)
		if (player) then
			Abar_Mhrs(total_mh_speed,"Main["..mh_speed.."s]("..mh_low_dmg.."-"..mh_high_dmg..")",0,0,1)
		else
			ebar_set()
		end
	end
end

function Abar_selfhit(oh)
mh_speed,off_speed = UnitAttackSpeed("player");
mh_low_dmg,mh_high_dmg,off_low_dmg,off_high_dmg = UnitDamage("player")
mh_high_dmg = mh_high_dmg-math.fmod(mh_high_dmg,1)
mh_low_dmg = mh_low_dmg-math.fmod(mh_low_dmg,1)

mh_time,off_time=GetTime(),GetTime()
if (oh == false) then
	if prev_off_time == 0 then prev_off_time=off_time end
	prev_mh_time = mh_time
	total_mh_speed = mh_speed
	mh_speed = mh_speed - math.fmod(mh_speed,0.01)
	Abar_Mhrs(total_mh_speed,"Main["..mh_speed.."s]("..mh_low_dmg.."-"..mh_high_dmg..")",0,0,1)
else
	prev_off_time = off_time
	off_high_dmg = off_high_dmg-math.fmod(off_high_dmg,1)
	off_low_dmg = off_low_dmg-math.fmod(off_low_dmg,1)
	off_speed = off_speed - math.fmod(off_speed,0.01)
	Abar_Ohs(off_speed,"Off["..off_speed.."s]("..off_low_dmg.."-"..off_high_dmg..")",0,0,1)
end
end

function Abar_reset()
	prev_mh_time = 0.000
	prev_off_time = 0.000
	mh_time = 0.000
	off_time = 0.000
end

function Abar_Update(self)
	local ttime = GetTime()
	local left = 0.00
	tSpark=getglobal(self:GetName().. "Spark")
	tText=getglobal(self:GetName().. "Tmr")
	if abar.timer==true then
		left = (self.et-GetTime()) - (math.fmod((self.et-GetTime()),.01))
	--	tText:SetText(this.txt.. "{"..left.."}")
		tText:SetText("{"..left.."}")
		tText:Show()
	else
	        tText:Hide()
	end
	self:SetValue(ttime)
	tSpark:SetPoint("CENTER", self, "LEFT", (ttime-self.st)/(self.et-self.st)*195, 2);
	if ttime>=self.et then 
		self:Hide() 
		tSpark:SetPoint("CENTER", self, "LEFT",195, 2);
	end
end

function Abar_Mhrs(bartime,text,r,g,b)
	Abar_Mhr:Hide()
	Abar_Mhr.txt = text
	Abar_Mhr.st = GetTime()
	Abar_Mhr.et = GetTime() + bartime
	Abar_Mhr:SetStatusBarColor(r,g,b)
	Abar_MhrText:SetText(text)
	Abar_Mhr:SetMinMaxValues(Abar_Mhr.st,Abar_Mhr.et)
	Abar_Mhr:SetValue(Abar_Mhr.st)
	Abar_Mhr:Show()
end

function Abar_Ohs(bartime,text,r,g,b)
	Abar_Oh:Hide()
	Abar_Oh.txt = text
	Abar_Oh.st = GetTime()
	Abar_Oh.et = GetTime() + bartime
	Abar_Oh:SetStatusBarColor(r,g,b)
	Abar_OhText:SetText(text)
	Abar_Oh:SetMinMaxValues(Abar_Oh.st,Abar_Oh.et)
	Abar_Oh:SetValue(Abar_Oh.st)
	Abar_Oh:Show()
end

function Abar_Boo(inpt)
	if inpt == true then return " ON" else return " OFF" end
end

-----------------------------------------------------------------------------------------------------------------------
-- ENEMY BAR CODE --
-----------------------------------------------------------------------------------------------------------------------

function ebar_VL()
	ebar_mh:SetPoint("LEFT",ebar_Frame,"TOPLEFT",6,-13)
	ebar_oh:SetPoint("LEFT",ebar_Frame,"TOPLEFT",6,-35)
	ebar_mhText:SetJustifyH("Left")
	ebar_ohText:SetJustifyH("Left")
end

function ebar_set()
	eons,eoffs = UnitAttackSpeed("target")
	eons = eons - math.fmod(eons,0.01)
	ebar_mhs(eons,"Target".."["..eons.."s]",1,.1,.1)
end

function ebar_mhs(bartime,text,r,g,b)
	ebar_mh:Hide()
	ebar_mh.txt = text
	ebar_mh.st = GetTime()
	ebar_mh.et = GetTime() + bartime
	ebar_mh:SetStatusBarColor(r,g,b)
	ebar_mhText:SetText(text)
	ebar_mh:SetMinMaxValues(ebar_mh.st,ebar_mh.et)
	ebar_mh:SetValue(ebar_mh.st)
	ebar_mh:Show()
end