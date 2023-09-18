local author = 'lemoncloudtree'
local addonName = 'shopgoddess'
-- version 1.0.2

_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}

function SHOPGODDESS_ON_INIT(addon, frame)
    local acutil = require("acutil");
    acutil.slashCommand("/증표", SHOPGODDESS_COMMAND);
end

function SHOPGODDESS_COMMAND(command)
  if #command > 0 then
    local cmd_table = {
        ["가비야"] = "REQ_GabijaCertificate_SHOP_OPEN()",
        ["바카리네"] = "REQ_VakarineCertificate_SHOP_OPEN()",
        ["라다"] = "REQ_RadaCertificate_SHOP_OPEN()",
        ["바이보라"] = "REQ_DAILY_REWARD_SHOP_1_OPEN()",
        ["용병단"] = "REQ_PVP_MINE_SHOP_OPEN()"
    };

    local cmd = cmd_table[tostring(table.remove(command, 1))];
    if cmd ~= nil then
      ui.CloseFrame('earthtowershop');
      ReserveScript(cmd, 0.1);
    end
    
  else
    local msg = '';
    msg = msg.. '/증표  : 안내문{nl}';
    msg = msg.. '/증표 가비야  : 가비야 상점{nl}';
    msg = msg.. '/증표 바카리네  : 바카리네 상점{nl}';
    msg = msg.. '/증표 라다  : 라다 상점{nl}';
    msg = msg.. '/증표 바이보라  : 바이보라의 날개 상점{nl}';
    msg = msg.. '/증표 용병단  : 용병단 상점{nl}';
    return ui.MsgBox(msg,"","Nope");
  end
  
  return;
end
