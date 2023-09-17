local author = 'lemoncloudtree'
local addonName = 'shopgoddess'
-- version 1.0.1

_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}

function SHOPGODDESS_ON_INIT(addon, frame)
    local acutil = require("acutil");
    acutil.slashCommand("/증표", SHOPGODDESS_COMMAND);

end

function SHOPGODDESS_COMMAND(command)
  local cmd = "";

  if #command > 0 then
    cmd = table.remove(command, 1);
  else
    local msg = '';
    msg = msg.. '/증표  : 안내문{nl}';
    msg = msg.. '/증표 가비야  : 가비야 상점{nl}';
    msg = msg.. '/증표 바카리네  : 바카리네 상점{nl}';
    msg = msg.. '/증표 라다  : 라다 상점{nl}';
    msg = msg.. '/증표 바이보라  : 바이보라의 날개 상점{nl}';
    msg = msg.. '/증표 용병단  : 용병단 상점{nl}';
    return ui.MsgBox(msg,"","Nope")
  end

  if cmd == "가비야" then
    ui.CloseFrame('earthtowershop');
    REQ_GabijaCertificate_SHOP_OPEN();
    return;
  elseif cmd == "바카리네" then
    ui.CloseFrame('earthtowershop');
    REQ_VakarineCertificate_SHOP_OPEN();
    return;
  elseif cmd == "라다" then
    ui.CloseFrame('earthtowershop');
    REQ_RadaCertificate_SHOP_OPEN();
    return;
  elseif cmd == "바이보라" then
    ui.CloseFrame('earthtowershop');
    REQ_DAILY_REWARD_SHOP_1_OPEN();
    return;
  elseif cmd == "용병단" then
    ui.CloseFrame('earthtowershop');
    REQ_PVP_MINE_SHOP_OPEN();
    return;
  end
  
end

