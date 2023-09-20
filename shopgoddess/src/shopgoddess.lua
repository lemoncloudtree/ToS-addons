local author = 'lemoncloudtree'
local addonName = 'shopgoddess'
-- version 1.0.3
-- reference: Charbon

_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}

local Shopgoddess = _G['ADDONS'][author][addonName]
local acutil = require('acutil')

Shopgoddess.SettingsFileLoc = string.format('../addons/%s/settings.json', addonName)
Shopgoddess.DefaultSettings = {}
Shopgoddess.DefaultSettings.Fixed = false
Shopgoddess.DefaultSettings.Position = {X = 300, Y = 300}
Shopgoddess.cmd_table = {
  ["가비야"] = 1, ["바카리네"] = 2, ["라다"] = 3, ["바이보라"] = 4, ["용병단"] = 5, ["max"] = 5
}

function Shopgoddess.LoadSettings(self)
  local settings, err = acutil.loadJSON(self.SettingsFileLoc, self.DefaultSettings)

  if not settings then
    settings = self.DefaultSettings
  end

  self.Settings = settings
end

function Shopgoddess.SaveSettings(self)
  return acutil.saveJSON(self.SettingsFileLoc, self.Settings)
end

function Shopgoddess.SetFramePositionFixed(self)
  local hittest = self.Settings.Fixed and 1 or 0
  local moveable = self.Settings.Fixed and 0 or 1
  local markButton = GET_CHILD_RECURSIVELY(self.Frame, 'markButton', 'ui::CButton')
  self.Frame:EnableMove(moveable)
  markButton:EnableHitTest(hittest)

  local lockImage = self.Settings.Fixed and 'chat_lock_btn2' or 'chat_lock_btn'
  local lockButton = GET_CHILD_RECURSIVELY(self.Frame, 'lockButton', 'ui::CButton')
  lockButton:SetImage(lockImage)
end

function Shopgoddess.SaveFramePositionFixed(self, flag)
  if flag ~= nil and flag ~= true and flag ~= false then
    return false
  end

  if flag == nil then
    flag = not self.Settings.Fixed
  end

  if self.Settings.Fixed ~= flag then
    self.Settings.Fixed = flag
    self:SaveSettings()
  end
  self:SetFramePositionFixed()
end

function Shopgoddess.SetFramePosition(self)
  self.Frame:SetPos(self.Settings.Position.X, self.Settings.Position.Y)
end

function Shopgoddess.SaveFramePosition(self, X, Y)
  self.Settings.Position.X = X
  self.Settings.Position.Y = Y
  self:SaveSettings()
end

function Shopgoddess.GetShopListMenu(self)
  local context = ui.CreateContextMenu('SHOPGODDESS_SHOP_LIST', '', 0, 0, 170, 100)
  local text, callback

  text = GET_ITEM_IMG_BY_CLS(GetClassByType("Item", 11030201), 30) .. ' 가비야'
  callback = string.format('SHOPGODDESS_CLICK_CONTEXT_MENU(%d)', 1)
  ui.AddContextMenuItem(context, text, callback)

  text = GET_ITEM_IMG_BY_CLS(GetClassByType("Item", 11200161), 30) .. ' 바카리네'
  callback = string.format('SHOPGODDESS_CLICK_CONTEXT_MENU(%d)', 2)
  ui.AddContextMenuItem(context, text, callback)

  text = GET_ITEM_IMG_BY_CLS(GetClassByType("Item", 11200303), 30) .. ' 라다'
  callback = string.format('SHOPGODDESS_CLICK_CONTEXT_MENU(%d)', 3)
  ui.AddContextMenuItem(context, text, callback)

  text = GET_ITEM_IMG_BY_CLS(GetClassByType("Item", 647016), 30) .. ' 바이보라의 날개'
  callback = string.format('SHOPGODDESS_CLICK_CONTEXT_MENU(%d)', 4)
  ui.AddContextMenuItem(context, text, callback)

  text = GET_ITEM_IMG_BY_CLS(GetClassByType("Item", 646076), 30) .. ' 용병단'
  callback = string.format('SHOPGODDESS_CLICK_CONTEXT_MENU(%d)', 5)
  ui.AddContextMenuItem(context, text, callback)
  return context
end

function SHOPGODDESS_CLICK_CONTEXT_MENU(shopnum)
  ui.CloseFrame('earthtowershop')

  if shopnum == 1 then
    REQ_GabijaCertificate_SHOP_OPEN()
  elseif shopnum == 2 then
    REQ_VakarineCertificate_SHOP_OPEN()
  elseif shopnum == 3 then
    REQ_RadaCertificate_SHOP_OPEN()
  elseif shopnum == 4 then
    REQ_DAILY_REWARD_SHOP_1_OPEN()
  elseif shopnum == 5 then
    REQ_PVP_MINE_SHOP_OPEN()
  end
end

function SHOPGODDESS_CLICK_MARK_BUTTON()
  ui.OpenContextMenu(Shopgoddess:GetShopListMenu())
end

function SHOPGODDESS_CLICK_LOCK_BUTTON()
  Shopgoddess:SaveFramePositionFixed()
end

function SHOPGODDESS_END_DRAG()
  local X = Shopgoddess.Frame:GetX()
  local Y = Shopgoddess.Frame:GetY()
  Shopgoddess:SaveFramePosition(X, Y)
end

function SHOPGODDESS_ON_INIT(addon, frame)
  Shopgoddess.Addon = addon
  Shopgoddess.Frame = frame

  if not Shopgoddess.Loaded then
    Shopgoddess:LoadSettings()
    Shopgoddess:SaveSettings()
    Shopgoddess.Loaded = true
  end

  Shopgoddess:SetFramePositionFixed()
  Shopgoddess:SetFramePosition()
  acutil.slashCommand("/증표", SHOPGODDESS_COMMAND)
end

function SHOPGODDESS_COMMAND(command)
  if #command > 0 then
    local cmd = table.remove(command, 1)
    local cmdnum = Shopgoddess.cmd_table[cmd]

    if 1 <= cmdnum and cmdnum <= Shopgoddess.cmd_table.max then
      SHOPGODDESS_CLICK_CONTEXT_MENU(cmdnum)
    end
  else
    local msg = ''
    msg = msg.. '/증표  : 안내문{nl}'
    msg = msg.. '/증표 가비야  : 가비야 상점{nl}'
    msg = msg.. '/증표 바카리네  : 바카리네 상점{nl}'
    msg = msg.. '/증표 라다  : 라다 상점{nl}'
    msg = msg.. '/증표 바이보라  : 바이보라의 날개 상점{nl}'
    msg = msg.. '/증표 용병단  : 용병단 상점{nl}'
    return ui.MsgBox(msg,"","Nope")
  end
  
  return
end
