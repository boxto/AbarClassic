pont= 0.000
pofft= 0.000
ont = 0.000
offt= 0.000
ons = 0.000
offs= 0.000
offh = 0
onh  = 0
epont=0.000
epofft= 0.000
eont = 0.000
eofft= 0.000
eons = 0.000
eoffs= 0.000
eoffh = 0
eonh  = 0
testvar = 0

function Abar_chat(msg)
	msg = strlower(msg)
	if msg == "fix" then
		Abar_reset()
	elseif msg=="lock" then
		Abar_Frame:Hide()
		--ebar_Frame:Hide()
	elseif msg=="unlock" then
		Abar_Frame:Show()
		--ebar_Frame:Show()
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
	else
		print('use any of these to control Abar:');
		print('Lock- to lock and hide the anchor');
		print('unlock- to unlock and show the anchor');
		print('fix- to reset the values should they go awry, wait 5 sec after attacking to use this command');
		print('h2h- to turn on and off the melee bar(s)');
		print('range- to turn on and off the ranged bar');
		print('pvp- to turn on and off the enemy player bar(s)');
		print('mob- to turn on and off the enemy mob bar(s)');
	end
end

function Abar_loaded()
	SlashCmdList["ATKBAR"] = Abar_chat;
	SLASH_ATKBAR1 = "/abar";
	SLASH_ATKBAR2 = "/atkbar";
	if not(abar) then abar={} end
	if abar.range == nil then
		abar.range=true
	end
	if abar.h2h == nil then
		abar.h2h=true
	end
	if abar.timer == nil then
		abar.timer=true
	end


	Abar_Mhr:SetPoint("LEFT",Abar_Frame,"TOPLEFT",6,-13)
	Abar_Oh:SetPoint("LEFT",Abar_Frame,"TOPLEFT",6,-35)
	Abar_MhrText:SetJustifyH("Left")
	Abar_OhText:SetJustifyH("Left")
	--ebar_VL()
end

function Abar_OnEvent(event, ...)
	if (event == "COMBAT_LOG_EVENT") then
		local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...;
		if (string.find(subevent, "SWING.*") ~= nil) and abar.h2h == true then Abar_selfhit() end
	end
  if event=="PLAYER_LEAVE_COMBAT" then Abar_reset() end
  if event == "VARIABLES_LOADED" then Abar_loaded() end
  --if event == "CHAT_MSG_SPELL_SELF_DAMAGE" then Abar_spellhit(arg1) end
  if event == "VARIABLES_LOADED" then Abar_loaded() end
end

function Abar_selfhit()
ons,offs=UnitAttackSpeed("player");
hd,ld,ohd,old = UnitDamage("player")
hd,ld= hd-math.fmod(hd,1),ld-math.fmod(ld,1)
if old then
	ohd,old = ohd-math.fmod(ohd,1),old-math.fmod(old,1)
end	
if offs then
	ont,offt=GetTime(),GetTime()
	if ((math.abs((ont-pont)-ons) <= math.abs((offt-pofft)-offs))and not(onh <= offs/ons)) or offh >= ons/offs then
		if pofft == 0 then pofft=offt end
		pont = ont
		tons = ons
		offh = 0
		onh = onh +1
		ons = ons - math.fmod(ons,0.01)
		Abar_Mhrs(tons,"Main["..ons.."s]("..hd.."-"..ld..")",0,0,1)
	else
		pofft = offt
		offh = offh+1
		onh = 0
		ohd,old = ohd-math.fmod(ohd,1),old-math.fmod(old,1)
		offs = offs - math.fmod(offs,0.01)
		Abar_Ohs(offs,"Off["..offs.."s]("..ohd.."-"..old..")",0,0,1)
	end
else
	ont=GetTime()
	tons = ons
	ons = ons - math.fmod(ons,0.01)
	Abar_Mhrs(tons,"Main["..ons.."s]("..hd.."-"..ld..")",0,0,1)
end
end

function Abar_reset()
	pont=0.000
	pofft= 0.000
	ont=0.000
	offt= 0.000
	onid=0
	offid=0
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