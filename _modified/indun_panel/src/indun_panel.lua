local addonName = "indun_panel"
local addonNameLower = string.lower(addonName)
local author = "norisan"
-- version 1.0.0_favorite
-- spoon: lemoncloudtree
-- idea: moonsplit

--#차이점
-- : 인던창 즐겨찾기에 추가된 인던을 애드온에 표출(입력되어있는 것만)
-- : 인던창 즐겨찾기 추가/제거 또는 "/패널" 명령어로 애드온창 호출 가능(사라질경우)

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
local acutil = require("acutil")

g.settings = {
    ischecked = 0,
    isopened = 0
}

function indun_panel_save_settings()
    acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function indun_panel_load_settings()
    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        CHAT_SYSTEM(string.format("[%s] 세팅값 로딩 실패. 기본세팅 사용", addonNameLower))
    end
    if not settings then
        settings = g.settings
    end

    g.settings = settings
end


function INDUN_PANEL_ON_INIT(addon, frame)
    g.addon = addon;
    g.frame = frame;
    g.framename = addonName;
    g.able_indun_list =  INDUN_PANEL_GET_OPENED_INDUN_LIST();
    g.INDUN_PANEL_BTN_INFO = INDUN_PANEL_MY_BTN_INFO();
    addon:RegisterMsg("FAVORITE_CHANGE","INDUN_PANEL_UPDATE_FAVORITE");
    indun_panel_load_settings();

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc);
    local mapCls = GetClass("Map", curMap);
    if mapCls.MapType == "City" then
        indun_panel_frame_init();
    end

    acutil.slashCommand("/패널", INDUN_PANEL_COMMAND);
end

function INDUN_PANEL_GET_OPENED_INDUN_LIST()
    local opened_list = {};
    local locked_list = {"Moringponia","Glacier","Vasilissa"};
    local indunClsList, cnt = GetClassList('Indun');
    local missionIndunCnt = 0;
    
    for i = 0, cnt - 1 do
      local indunCls = GetClassByIndexFromList(indunClsList, i);
      local add_flag = false;
      
      if indunCls.Category ~= 'None' then
        local dungeonType = TryGetProp(indunCls, 'DungeonType')
        if dungeonType == 'MissionIndun' then
          local sysTime = geTime.GetServerSystemTime();
          if missionIndunCnt == sysTime.wDayOfWeek then
              add_flag = true;
          end
          missionIndunCnt = missionIndunCnt + 1;
        elseif string.find(indunCls.DungeonType,"MythicDungeon") == 1 then
          local pattern_info = mythic_dungeon.GetPattern(mythic_dungeon.GetCurrentSeason())
          local mapCls = GetClassByType("Map",pattern_info.mapID)
          if TryGetProp(mapCls,"ClassName") == indunCls.MapName then
            add_flag = true;
          end
        elseif string.find(indunCls.DungeonType,"TOSHero") == 1 then
          local dungeonType = session.rank.GetCurrentDungeon(1)
          if dungeonType == indunCls.MapName then
            add_flag = true;
          end
        else
          add_flag = true;
        end
      else
        if string.find(indunCls.ClassName,"Ancient_Solo_dungeon") == 1 then
          add_flag = true;
        end
      end
  
      for j = 1, #locked_list do
        if string.find(indunCls.ClassName, locked_list[j]) ~=nil then
          add_flag = false;
        end
      end
  
      if add_flag == true then
        table.insert(opened_list, indunCls);
      end
    end
  
    return opened_list;
end


function INDUN_PANEL_UPDATE_FAVORITE(frame, msg, groupID)
    indun_panel_frame_init()
    local ipframe = ui.GetFrame(g.framename)
    indun_panel_init(ipframe)
end


function INDUN_PANEL_COMMAND(command)
    local ipframe = ui.GetFrame(g.framename)
    indun_panel_load_settings()

    if g.settings.isopened == 1 then
        indun_panel_frame_init()
        g.settings.isopened = 0
    elseif g.settings.isopened == 0 then
        indun_panel_init(ipframe)
        g.settings.isopened = 1
    end

    indun_panel_save_settings()
end

function INDUN_PANEL_INVENTORY_ON_MSG(frame, msg)
    local ipframe = ui.GetFrame(g.framename)
    indun_panel_init(ipframe)
end

function indun_panel_frame_init()
    local ipframe = ui.GetFrame(g.framename)

    ipframe:SetSkinName('None')
    ipframe:SetLayerLevel(30)
    ipframe:Resize(90, 35)
    ipframe:SetPos(665, 30)
    ipframe:SetTitleBarSkin("None")
    ipframe:EnableHittestFrame(1)
    ipframe:EnableHide(0)
    ipframe:EnableHitTest(1)
    ipframe:SetAlpha(70)
    ipframe:RemoveAllChild()
    local button = ipframe:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("패널")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_init")
    ipframe:ShowWindow(1)

    indun_panel_judge(ipframe)
end

function indun_panel_judge(ipframe)
    local button = GET_CHILD_RECURSIVELY(ipframe, "indun_panel_open")

    if g.settings.ischecked == 0 then
        ipframe:SetSkinName('None')
        ipframe:SetLayerLevel(30)
        ipframe:Resize(90, 35)
        ipframe:SetPos(665, 30)
        ipframe:SetTitleBarSkin("None")
        ipframe:EnableHittestFrame(1)
        ipframe:EnableHide(0)
        ipframe:EnableHitTest(1)
        ipframe:SetAlpha(70)
    elseif g.settings.ischecked == 1 then
        indun_panel_init(ipframe)
    else
        return;
    end
end

function indun_panel_checkbox_toggle()
    local ipframe = ui.GetFrame(g.framename)
    local checkbox = GET_CHILD_RECURSIVELY(ipframe, "checkbox")
    tolua.cast(checkbox, 'ui::CCheckBox')
    local ischeck = checkbox:IsChecked();

    if ischeck == 1 then
        g.settings.ischecked = 1
        indun_panel_save_settings()
    elseif ischeck == 0 then
        g.settings.ischecked = 0
        indun_panel_save_settings()
    end
end


function indun_panel_sweep_count(buffid)
    local handle = session.GetMyHandle()
    local buffframe = ui.GetFrame("buff")
    local buffslotset = GET_CHILD_RECURSIVELY(buffframe, "buffslot")
    local buffslotcount = buffslotset:GetChildCount()
    local iconcount = 0
    for i = 0, buffslotcount - 1 do
        local achild = buffslotset:GetChildByIndex(i)
        local aicon = achild:GetIcon()
        local aiconinfo = aicon:GetInfo()
        local abuff = info.GetBuff(handle, aiconinfo.type)
        if abuff ~= nil then
            iconcount = iconcount + 1
        end
    end

    local sweepcount = 0

    for i = 0, iconcount - 1 do
        local child = buffslotset:GetChildByIndex(i)
        local icon = child:GetIcon()
        local iconinfo = icon:GetInfo()
        local buff = info.GetBuff(handle, iconinfo.type)

        if tostring(buff.buffID) == tostring(buffid) then
            sweepcount = buff.over
        end
    end

    return sweepcount
end


function indun_panel_x(arg)
    local table_x = {10, 140, 230, 320, 410, 500, 590};
    return table_x[arg];
end

function indun_panel_y(arg)
    local table_y = { 50,  90, 130, 170, 210,
                     250, 290, 330, 370, 410,
                     450, 490, 530, 570, 610,
                     650, 690, 730, 770, 810,
                     850, 890, 930, 970, 1010};
    return table_y[arg];
end

function INDUN_PANEL_MY_BTN_INFO()
    local indun_id = 61
    for i = 1, #g.able_indun_list do
        local myObj = g.able_indun_list[i]

        if myObj.GroupID == "Indun" and myObj.Level >= 400 then
            indun_id = myObj.ClassID
            break
        end
    end

    local mythic_id = {659, 637, 649, 641}
    for i = 1, #g.able_indun_list do
        local myObj = g.able_indun_list[i]

        if myObj.GroupID == "Mythic" and myObj.ClassID >= 658 then
            if myObj.ClassID == 658 then
                mythic_id = {658, 636, 648, 640}
            elseif myObj.ClassID == 659 then
                mythic_id = {659, 637, 649, 641}
            elseif myObj.ClassID == 690 then
                mythic_id = {660, 639, 650, 643}
            end
            break
        end
    end

    local INDUN_PANEL_BTN_INFO = {
        {
            groupID   = "AbyssalObserver",
            label     = "심연의 관찰자",
            row_count = 2,
            {id = 689, x = 2, y = 0, autosweep = false, category = "raid_solo",  caption = "1인"},
            {id = 688, x = 3, y = 0, autosweep = true,  category = "raid_auto",  caption = "자동매칭"},
            {id = 688, x = 4, y = 0, autosweep = true,  category = "count",      caption = "slash"},
            {id = 690, x = 5, y = 0, autosweep = false, category = "raid_party", caption = "파티"},
            {id = 690, x = 6, y = 0, autosweep = false, category = "count",      caption = "slash"},
            {id = 688, x = 3, y = 1, autosweep = true,  category = "sweep_buff", caption = "소탕"},
            {id = 80031, x = 4, y = 1, autosweep = true,  category = "count",    caption = "buff"}
        },
        {
            groupID   = "Challenge",
            label     = "챌린지",
            row_count = 2,
            {id = 644, x = 2, y = 0, autosweep = false, category = "challenge_solo", caption = "1인 480"},
            {id = 647, x = 5, y = 0, autosweep = false, category = "challenge_auto", caption = "분열"},
            {id = 647, x = 6, y = 0, autosweep = false, category = "count",          caption = ""},
            {id = 645, x = 2, y = 1, autosweep = false, category = "challenge_solo", caption = "1인 500"},
            {id = 646, x = 3, y = 1, autosweep = false, category = "challenge_auto", caption = "자동매칭"},
            {id = 646, x = 4, y = 1, autosweep = false, category = "count",          caption = "slash"},
            {id = 691, x = 5, y = 1, autosweep = false, category = "challenge_auto", caption = "분열EX"},
            {id = 691, x = 6, y = 1, autosweep = false, category = "count",          caption = ""}
        },
        {
            groupID   = "DreamyForest",
            label     = "몽환의 숲",
            row_count = 2,
            {id = 686, x = 2, y = 0, autosweep = false, category = "raid_solo",  caption = "1인"},
            {id = 685, x = 3, y = 0, autosweep = true,  category = "raid_auto",  caption = "자동매칭"},
            {id = 685, x = 4, y = 0, autosweep = true,  category = "count",      caption = "slash"},
            {id = 687, x = 5, y = 0, autosweep = false, category = "raid_party", caption = "파티"},
            {id = 687, x = 6, y = 0, autosweep = false, category = "count",      caption = "slash"},
            {id = 685, x = 3, y = 1, autosweep = true,  category = "sweep_buff", caption = "소탕"},
            {id = 80030, x = 4, y = 1, autosweep = true,  category = "count",    caption = "buff"}
        },
        {
            groupID   = "Roze",
            label     = "로제",
            row_count = 2,
            {id = 680, x = 2, y = 0, autosweep = false, category = "raid_solo",  caption = "1인"},
            {id = 679, x = 3, y = 0, autosweep = true,  category = "raid_auto",  caption = "자동매칭"},
            {id = 679, x = 4, y = 0, autosweep = true,  category = "count",      caption = "slash"},
            {id = 681, x = 5, y = 0, autosweep = false, category = "raid_party", caption = "파티"},
            {id = 681, x = 6, y = 0, autosweep = false, category = "count",      caption = "slash"},
            {id = 679, x = 3, y = 1, autosweep = true,  category = "sweep_buff", caption = "소탕"},
            {id = 80015, x = 4, y = 1, autosweep = true,  category = "count",    caption = "buff"}
        },
        {
            groupID   = "TurbulentCore",
            label     = "변질의 전파자",
            row_count = 4,
            {id = 674, x = 2, y = 0, autosweep = false, category = "raid_solo",  caption = "1인"},
            {id = 673, x = 3, y = 0, autosweep = true,  category = "raid_auto",  caption = "자동매칭"},
            {id = 673, x = 4, y = 0, autosweep = true,  category = "count",      caption = "slash"},
            {id = 675, x = 5, y = 0, autosweep = false, category = "raid_party", caption = "파티"},
            {id = 675, x = 6, y = 0, autosweep = false, category = "count",      caption = "slash"},
            {id = 673, x = 3, y = 1, autosweep = true,  category = "sweep_buff", caption = "소탕"},
            {id = 80016, x = 4, y = 1, autosweep = true,  category = "count",    caption = "buff"},
            {id = 677, x = 2, y = 2, autosweep = false, category = "raid_solo",  caption = "1인"},
            {id = 676, x = 3, y = 2, autosweep = true,  category = "raid_auto",  caption = "자동매칭"},
            {id = 678, x = 5, y = 2, autosweep = false, category = "raid_party", caption = "파티"},
            {id = 676, x = 3, y = 3, autosweep = true,  category = "sweep_buff", caption = "소탕"},
            {id = 80017, x = 4, y = 3, autosweep = true,  category = "count",    caption = "buff"}
            
        },
        {
            groupID   = "Delmore",
            label     = "델무어",
            row_count = 1,
            {id = 667, x = 2, y = 0, autosweep = false, category = "raid_solo",  caption = "1인"},
            {id = 666, x = 3, y = 0, autosweep = false, category = "raid_auto",  caption = "자동매칭"},
            {id = 666, x = 4, y = 0, autosweep = false, category = "count",      caption = "slash"},
            {id = 665, x = 5, y = 0, autosweep = false, category = "raid_party", caption = "파티"},
            {id = 665, x = 6, y = 0, autosweep = false, category = "count",      caption = "slash"}
        },
        {
            groupID   = "Jellyzele",
            label     = "나포선",
            row_count = 1,
            {id = 672, x = 2, y = 0, autosweep = false, category = "raid_solo",  caption = "1인"},
            {id = 671, x = 3, y = 0, autosweep = false, category = "raid_auto",  caption = "자동매칭"},
            {id = 671, x = 4, y = 0, autosweep = false, category = "count",      caption = "slash"},
            {id = 670, x = 5, y = 0, autosweep = false, category = "raid_party", caption = "파티"},
            {id = 670, x = 6, y = 0, autosweep = false, category = "count",      caption = "slash"}
        },
        {
            groupID   = "Earring",
            label     = "귀걸이",
            row_count = 1,
            {id = 661, x = 2, y = 0, autosweep = false, category = "raid_solo",  caption = "1인"},
            {id = 662, x = 3, y = 0, autosweep = false, category = "raid_party", caption = "파티(노말)"},
            {id = 663, x = 4, y = 0, autosweep = false, category = "raid_party", caption = "파티(하드)"},
            {id = 663, x = 5, y = 0, autosweep = false, category = "count",      caption = ""}
        },
        {
            groupID   = "Giltine",
            label     = "마신의성소",
            row_count = 1,
            {id = 669, x = 2, y = 0, autosweep = false, category = "raid_solo",  caption = "1인"},
            {id = 635, x = 3, y = 0, autosweep = false, category = "raid_auto",  caption = "자동매칭"},
            {id = 635, x = 4, y = 0, autosweep = false, category = "count",      caption = "slash"},
            {id = 628, x = 5, y = 0, autosweep = false, category = "raid_party", caption = "파티"},
            {id = 628, x = 6, y = 0, autosweep = false, category = "count",      caption = ""}
        },
        {
            groupID   = "Mythic",
            label     = "성물",
            row_count = 2,
            {id = mythic_id[1], x = 2, y = 0, autosweep = true, category = "raid_solo",  caption = "1인(노말)"},
            {id = mythic_id[2], x = 3, y = 0, autosweep = true, category = "raid_auto",  caption = "자매(노말)"},
            {id = mythic_id[2], x = 4, y = 0, autosweep = true, category = "count",      caption = "slash"},
            {id = mythic_id[2], x = 5, y = 0, autosweep = true, category = "sweep_buff", caption = "소탕"},
            {id = 80023, x = 6, y = 0, autosweep = true,  category = "count",    caption = "buff"},
            {id = mythic_id[3], x = 2, y = 1, autosweep = true, category = "raid_solo",  caption = "1인(하드)"},
            {id = mythic_id[4], x = 3, y = 1, autosweep = true, category = "raid_auto",  caption = "자매(하드)"},
            {id = mythic_id[4], x = 4, y = 1, autosweep = true, category = "count",      caption = ""},
            {id = mythic_id[4], x = 5, y = 1, autosweep = true, category = "raid_sweep", caption = "소탕"},
            {id = 80022, x = 6, y = 1, autosweep = true,  category = "count",    caption = "buff"}
        },
        {
            groupID   = "Indun",
            label     = "인던",
            row_count = 1,
            {id =  16, x = 2, y = 0, autosweep = false, category = "raid_auto", caption = "80비석로"},
            {id =  45, x = 3, y = 0, autosweep = false, category = "raid_auto", caption = "200란코"},
            {id =  indun_id, x = 4, y = 0, autosweep = false, category = "raid_auto", caption = "400인던"},
            {id =  16, x = 5, y = 0, autosweep = false, category = "count",     caption = "slash"}
        },
        {
            groupID   = "Ancient",
            label     = "어시스터 던전",
            row_count = 1,
            {id = 202, x = 2, y = 0, autosweep = false, category = "dungeon_ancient", caption = "입장"}
        },
        {
            groupID   = "Solo_dungeon",
            label     = "베르니케",
            row_count = 1,
            {id = 201, x = 2, y = 0, autosweep = false, category = "dungeon_solo", caption = "입장"}
        },
        {
            groupID   = "Raid_Solo",
            label     = "텔하르샤",
            row_count = 1,
            {id = 623, x = 2, y = 0, autosweep = false, category = "raid_solo", caption = "1인"}
        },
        {
            groupID   = "BridgeWailing",
            label     = "통곡의 묘지",
            row_count = 1,
            {id = 684, x = 2, y = 0, autosweep = false, category = "raid_party", caption = "파티"},
            {id = 684, x = 3, y = 0, autosweep = false, category = "count",      caption = ""}
        }
    }

    return INDUN_PANEL_BTN_INFO
end


function indun_panel_init(ipframe)
    local checkbox = ipframe:CreateOrGetControl('checkbox', 'checkbox', 520, 5, 30, 30)
    tolua.cast(checkbox, 'ui::CCheckBox')
    checkbox:SetCheck(g.settings.ischecked)
    checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_checkbox_toggle")

    local entext = ipframe:CreateOrGetControl("richtext", "entext", 380, 10)
    entext:SetText("{#000000}{s20}항상 열기")

    local title = ipframe:CreateOrGetControl("richtext", "indun_panel_title", 100, 10)
    title:SetText("{#000000}{s20}/패널")
    local button = GET_CHILD_RECURSIVELY(ipframe, "indun_panel_open")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")
    
    local favorite_list = INDUNINFO_GET_FAVORITE_INDUN_LIST();
    local INDUN_PANEL_BTN_INFO = g.INDUN_PANEL_BTN_INFO
    local row_count = 1;
    for i = 1, #INDUN_PANEL_BTN_INFO do
        local btnInfo = INDUN_PANEL_BTN_INFO[i]

        if table.find(favorite_list, btnInfo.groupID) > 0 then
            INDUN_PANEL_ADD_BTN(ipframe, btnInfo, row_count)
            row_count = row_count + btnInfo.row_count
        end
    end
    
    ipframe:SetLayerLevel(93)
    ipframe:Resize(560, indun_panel_y(row_count))
    ipframe:SetSkinName("test_frame_low")
end


function INDUN_PANEL_ADD_BTN(ipframe, btnInfo, yy)
    local btnLabel = ipframe:CreateOrGetControl("richtext", btnInfo.groupID, indun_panel_x(1), indun_panel_y(yy))
    btnLabel:SetText("{#000000}{s20}"..btnInfo.label)
    if btnInfo.groupID == "TurbulentCore" then
        local btnLabel2 = ipframe:CreateOrGetControl("richtext", btnInfo.groupID..2, indun_panel_x(1), indun_panel_y(yy+2))
        btnLabel2:SetText("{#000000}{s20}".."팔로우로스")
    end

    for i = 1, #btnInfo do
        if btnInfo[i].category == "count" then
            local txtctrl = ipframe:CreateOrGetControl("richtext", btnInfo.groupID.."_"..i,
                                                        indun_panel_x(btnInfo[i].x)-5,
                                                        indun_panel_y(btnInfo[i].y+yy)+5, 40, 30)
            if btnInfo[i].caption == "buff" then
                txtctrl:SetText("{#000000}{s16}(" .. indun_panel_sweep_count(btnInfo[i].id) .. ")")
            else
                local txtcount = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", btnInfo[i].id).PlayPerResetType)
                local txtcountmax = ""
                if btnInfo[i].caption == "slash" then
                    txtcountmax = "/" .. GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", btnInfo[i].id).PlayPerResetType)
                end
                txtctrl:SetText("{#000000}{s16}(" .. txtcount .. txtcountmax .. ")")
            end
        else
            local btnctrl = ipframe:CreateOrGetControl('button', btnInfo.groupID.."_"..i,
                                                        indun_panel_x(btnInfo[i].x),
                                                        indun_panel_y(btnInfo[i].y+yy), 80, 30)
            btnctrl:SetText(btnInfo[i].caption)
            btnctrl:SetEventScript(ui.LBUTTONUP, "INDUN_PANEL_BTN_L_CLICK")
            btnctrl:SetEventScriptArgNumber(ui.LBUTTONUP, btnInfo[i].id)
            btnctrl:SetEventScriptArgString(ui.LBUTTONUP, btnInfo[i].category)
        end
    end
end

function INDUN_PANEL_BTN_L_CLICK(frame, ctrl, argStr, argNum)
    local category = StringSplit(argStr, "_")

    if category[1] == "challenge" then
        ReqChallengeAutoUIOpen(argNum)
        if category[2] == "solo" then
            ReqMoveToIndun(1, 0)
        end
    elseif category[1] == "raid" then
        if category[2] == "solo" then
            ReqRaidSoloUIOpen(argNum)
            ReqMoveToIndun(1, 0)
        elseif category[2] == "party" then
            control.CustomCommand('MOVE_TO_ENTER_HARD', argNum, 0, 0);
        else
            ReqRaidAutoUIOpen(argNum)
        end
    elseif category[1] == "sweep" then
        ReqUseRaidAutoSweep(argNum)
        local ipframe = ui.GetFrame(g.framename)
    elseif category[1] == "dungeon" then
        if category[2] == "solo" then
            local account_obj = GetMyAccountObj();
            if account_obj ~= nil then
                local stage = TryGetProp(account_obj, "SOLO_DUNGEON_MINI_CLEAR_STAGE", 0);
                local yesScp = "INDUNINFO_MOVE_TO_SOLO_DUNGEON_PRECHECK";
                local title = ScpArgMsg("Select_Stage_SoloDungeon", "Stage", stage + 5); 
                INDUN_EDITMSGBOX_FRAME_OPEN(argNum, title, "", yesScp, "", 1, stage + 5, 1);
            end
        elseif category[2] == "ancient" then
            local yesScp = string.format("_INDUNINFO_MOVE_TO_DUNGEON(%d,%d)", argNum, 1)
            ui.MsgBox(ClMsg('EnterRightNow'), yesScp, 'None');
        end
    end
end
