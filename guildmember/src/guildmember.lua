local author = "lemoncloudtree";
local addonName = "guildmember";

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}

local g = _G["ADDONS"][author][addonName]

function GUILDMEMBER_ON_INIT(addon, frame)
    local acutil = require("acutil");
    acutil.slashCommand("/guildmember", GUILDMEMBER_MSG);
    acutil.slashCommand("/길드원", GUILDMEMBER_MSG);
end

function GUILDMEMBER_MSG(msg)
  local list = session.party.GetPartyMemberList(PARTY_GUILD);
  local count = list:Count();
  local myFamilyName = info.GetFamilyName(session.GetMyHandle());
  local s = "";
  local sep = " ";
  local cnt = 0;
  msg = table.concat(msg, " ").."　";

  if count > 1 then
    for i = 0 , count - 1 do
      local partyMemberInfo = list:Element(i);
      if partyMemberInfo:GetMapID() > 0 then
        if myFamilyName ~= tostring(partyMemberInfo:GetName()) then
          s = s..tostring(partyMemberInfo:GetName())..sep;
          cnt = cnt + 1;
        end
      end
    end

    UI_CHAT("/g "..s..msg)
    CHAT_SYSTEM("[GUILDMEMBER] "..cnt.."명 언급");
  end
end
