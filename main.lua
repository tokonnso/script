--[[ 
    PANZZHACK UI V16 - PLAYER PROFILE & HISTORY
    - Feature: Added 'Player' Tab.
    - Content: User Profile (Avatar/Name), Session Info (Map/Time), Friend Connections.
    - Limitation: Real 6-hour history is blocked by Roblox, replaced with Current Session Log.
]]

-- SERVICES
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--=============================================================================
-- 1. BERSIHKAN UI LAMA
--=============================================================================
if CoreGui:FindFirstChild("PanzzHack_UI") then CoreGui.PanzzHack_UI:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild("PanzzHack_UI") then LocalPlayer.PlayerGui.PanzzHack_UI:Destroy() end

-- SETUP SCREEN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PanzzHack_UI"
if getgenv then 
    ScreenGui.Parent = CoreGui 
else 
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") 
end
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

--=============================================================================
-- 2. TEMA WARNA
--=============================================================================
local Theme = {
    Bg       = Color3.fromRGB(15, 15, 15),
    Sidebar  = Color3.fromRGB(20, 20, 20),
    Header   = Color3.fromRGB(20, 20, 20),
    Item     = Color3.fromRGB(28, 28, 28),
    ItemSel  = Color3.fromRGB(40, 40, 45),
    Accent   = Color3.fromRGB(0, 255, 255), -- Cyan
    Text     = Color3.fromRGB(255, 255, 255),
    TextDim  = Color3.fromRGB(150, 150, 150),
    On       = Color3.fromRGB(0, 255, 120),
    Off      = Color3.fromRGB(255, 60, 60)
}

--=============================================================================
-- 3. UTILS: DRAGGABLE
--=============================================================================
local function MakeDraggable(trigger, object)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        TweenService:Create(object, TweenInfo.new(0.05), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end
    trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    trigger.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
end

--=============================================================================
-- 4. LAYOUT UTAMA UI
--=============================================================================
local MainFrame = Instance.new("Frame"); MainFrame.Parent = ScreenGui; MainFrame.Name = "MainFrame"; MainFrame.BackgroundColor3 = Theme.Bg; MainFrame.Position = UDim2.new(0.5, -275, 0.5, -150); MainFrame.Size = UDim2.new(0, 550, 0, 300); MainFrame.ClipsDescendants = true; MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke"); Stroke.Parent = MainFrame; Stroke.Color = Theme.Accent; Stroke.Thickness = 1; Stroke.Transparency = 0.5

-- Header
local Header = Instance.new("Frame"); Header.Parent = MainFrame; Header.BackgroundColor3 = Theme.Header; Header.Size = UDim2.new(1, 0, 0, 45); Header.ZIndex = 5
local Title = Instance.new("TextLabel"); Title.Parent = Header; Title.Text = "PanzzHack"; Title.Font = Enum.Font.GothamBlack; Title.TextColor3 = Theme.Accent; Title.TextSize = 22; Title.Size = UDim2.new(0, 200, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0); Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = Header; CloseBtn.Text = "X"; CloseBtn.Font = Enum.Font.GothamBlack; CloseBtn.TextColor3 = Theme.Off; CloseBtn.BackgroundTransparency = 1; CloseBtn.Size = UDim2.new(0, 55, 1, 0); CloseBtn.Position = UDim2.new(1, -55, 0, 0); CloseBtn.TextSize = 24
local MiniBtn = Instance.new("TextButton"); MiniBtn.Parent = Header; MiniBtn.Text = "-"; MiniBtn.Font = Enum.Font.GothamBlack; MiniBtn.TextColor3 = Theme.Text; MiniBtn.BackgroundTransparency = 1; MiniBtn.Size = UDim2.new(0, 55, 1, 0); MiniBtn.Position = UDim2.new(1, -110, 0, 0); MiniBtn.TextSize = 32

MakeDraggable(Header, MainFrame)

-- Sidebar
local Sidebar = Instance.new("Frame"); Sidebar.Parent = MainFrame; Sidebar.BackgroundColor3 = Theme.Sidebar; Sidebar.Position = UDim2.new(0, 0, 0, 45); Sidebar.Size = UDim2.new(0, 140, 1, -45); Sidebar.ZIndex = 2
local SidebarLayout = Instance.new("UIListLayout"); SidebarLayout.Parent = Sidebar; SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder; SidebarLayout.Padding = UDim.new(0, 5)
local SidebarPad = Instance.new("UIPadding"); SidebarPad.Parent = Sidebar; SidebarPad.PaddingTop = UDim.new(0, 10); SidebarPad.PaddingLeft = UDim.new(0, 5)

-- Content Area
local Content = Instance.new("Frame"); Content.Parent = MainFrame; Content.BackgroundTransparency = 1; Content.Position = UDim2.new(0, 140, 0, 45); Content.Size = UDim2.new(1, -140, 1, -45); Content.ClipsDescendants = true
local PagesFolder = Instance.new("Folder"); PagesFolder.Parent = Content; PagesFolder.Name = "Pages"

--=============================================================================
-- 5. POPUP MODAL (INPUT NAMA)
--=============================================================================
local ModalOverlay = Instance.new("Frame"); ModalOverlay.Parent = MainFrame; ModalOverlay.BackgroundColor3 = Color3.new(0,0,0); ModalOverlay.BackgroundTransparency = 0.5; ModalOverlay.Size = UDim2.new(1, 0, 1, 0); ModalOverlay.Visible = false; ModalOverlay.ZIndex = 20
local ModalFrame = Instance.new("Frame"); ModalFrame.Parent = ModalOverlay; ModalFrame.BackgroundColor3 = Theme.Item; ModalFrame.Size = UDim2.new(0, 260, 0, 140); ModalFrame.Position = UDim2.new(0.5, -130, 0.5, -70); Instance.new("UICorner", ModalFrame).CornerRadius = UDim.new(0, 8); local MStroke = Instance.new("UIStroke"); MStroke.Parent = ModalFrame; MStroke.Color = Theme.Accent; MStroke.Thickness = 1
local MTitle = Instance.new("TextLabel"); MTitle.Parent = ModalFrame; MTitle.Text = "SAVE LOCATION"; MTitle.Font = Enum.Font.GothamBold; MTitle.TextColor3 = Theme.Accent; MTitle.Size = UDim2.new(1, 0, 0, 30); MTitle.BackgroundTransparency = 1; MTitle.TextSize = 14
local NameInput = Instance.new("TextBox"); NameInput.Parent = ModalFrame; NameInput.BackgroundColor3 = Theme.Bg; NameInput.Size = UDim2.new(0.8, 0, 0, 35); NameInput.Position = UDim2.new(0.1, 0, 0.3, 0); NameInput.Font = Enum.Font.Gotham; NameInput.PlaceholderText = "Location Name..."; NameInput.Text = ""; NameInput.TextColor3 = Theme.Text; NameInput.PlaceholderColor3 = Theme.TextDim; Instance.new("UICorner", NameInput).CornerRadius = UDim.new(0, 6)
local SaveConfirmBtn = Instance.new("TextButton"); SaveConfirmBtn.Parent = ModalFrame; SaveConfirmBtn.Text = "SAVE"; SaveConfirmBtn.BackgroundColor3 = Theme.Accent; SaveConfirmBtn.TextColor3 = Color3.new(0,0,0); SaveConfirmBtn.Font = Enum.Font.GothamBold; SaveConfirmBtn.Size = UDim2.new(0.35, 0, 0, 30); SaveConfirmBtn.Position = UDim2.new(0.1, 0, 0.7, 0); Instance.new("UICorner", SaveConfirmBtn).CornerRadius = UDim.new(0, 6)
local CancelBtn = Instance.new("TextButton"); CancelBtn.Parent = ModalFrame; CancelBtn.Text = "CANCEL"; CancelBtn.BackgroundColor3 = Theme.Off; CancelBtn.TextColor3 = Theme.Text; CancelBtn.Font = Enum.Font.GothamBold; CancelBtn.Size = UDim2.new(0.35, 0, 0, 30); CancelBtn.Position = UDim2.new(0.55, 0, 0.7, 0); Instance.new("UICorner", CancelBtn).CornerRadius = UDim.new(0, 6)

--=============================================================================
-- 6. SYSTEM TAB
--=============================================================================
local tabs = {}
local function CreateTab(name, order)
    local Page = Instance.new("Frame"); Page.Name = name.."Page"; Page.Parent = PagesFolder; Page.BackgroundTransparency = 1; Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false
    local Btn = Instance.new("TextButton"); Btn.Name = name.."Btn"; Btn.Parent = Sidebar; Btn.LayoutOrder = order; Btn.BackgroundColor3 = Theme.Sidebar; Btn.BackgroundTransparency = 1; Btn.Size = UDim2.new(1, -10, 0, 40); Btn.Font = Enum.Font.GothamMedium; Btn.Text = "  "..name; Btn.TextColor3 = Color3.fromRGB(150, 150, 150); Btn.TextSize = 14; Btn.TextXAlignment = Enum.TextXAlignment.Left; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    local Ind = Instance.new("Frame"); Ind.Parent = Btn; Ind.BackgroundColor3 = Theme.Accent; Ind.Size = UDim2.new(0, 3, 0.6, 0); Ind.Position = UDim2.new(0, 0, 0.2, 0); Ind.Visible = false
    Btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do t.Page.Visible = false; t.Btn.TextColor3 = Color3.fromRGB(150, 150, 150); t.Btn.BackgroundTransparency = 1; t.Ind.Visible = false end
        Page.Visible = true; Btn.TextColor3 = Theme.Text; Btn.BackgroundTransparency = 0.8; Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Ind.Visible = true
    end)
    table.insert(tabs, {Btn = Btn, Page = Page, Ind = Ind})
    return Page
end

--=============================================================================
-- 7. FITUR HACK (V10 LOGIC)
--=============================================================================
local function CreateHackScroll(page)
    local S = Instance.new("ScrollingFrame"); S.Parent = page; S.Size = UDim2.new(1,0,1,0); S.BackgroundTransparency = 1; S.ScrollBarThickness = 3; S.ScrollBarImageColor3 = Theme.Accent
    local L = Instance.new("UIListLayout"); L.Parent = S; L.Padding = UDim.new(0,8); local P = Instance.new("UIPadding"); P.Parent = S; P.PaddingTop = UDim.new(0,10); P.PaddingLeft = UDim.new(0,10); P.PaddingRight = UDim.new(0,10); P.PaddingBottom = UDim.new(0,20)
    return S
end
local function CreateControl(scroll, title, min, max, default, callback)
    local P = Instance.new("Frame"); P.Parent = scroll; P.BackgroundColor3 = Theme.Item; P.Size = UDim2.new(1,0,0,60); Instance.new("UICorner", P).CornerRadius = UDim.new(0,6)
    local L = Instance.new("TextLabel"); L.Parent = P; L.Text = title; L.Font = Enum.Font.GothamBold; L.TextColor3 = Theme.Text; L.TextSize = 14; L.Size = UDim2.new(0.6,0,0,30); L.Position = UDim2.new(0,12,0,0); L.BackgroundTransparency = 1; L.TextXAlignment = Enum.TextXAlignment.Left
    local T = Instance.new("TextButton"); T.Parent = P; T.Text = "OFF"; T.Font = Enum.Font.GothamBold; T.TextColor3 = Theme.Text; T.BackgroundColor3 = Theme.Off; T.Size = UDim2.new(0,50,0,24); T.Position = UDim2.new(1,-60,0,6); Instance.new("UICorner", T).CornerRadius = UDim.new(0,4)
    local V = Instance.new("TextLabel"); V.Parent = P; V.Text = tostring(default); V.Font = Enum.Font.Code; V.TextColor3 = Theme.Accent; V.TextSize = 12; V.Size = UDim2.new(0,30,0,20); V.Position = UDim2.new(1,-40,0,35); V.BackgroundTransparency = 1
    local S = Instance.new("TextButton"); S.Parent = P; S.Text = ""; S.AutoButtonColor = false; S.BackgroundColor3 = Color3.fromRGB(20,20,20); S.Size = UDim2.new(1,-70,0,4); S.Position = UDim2.new(0,12,0,45); Instance.new("UICorner", S).CornerRadius = UDim.new(1,0)
    local F = Instance.new("Frame"); F.Parent = S; F.BackgroundColor3 = Theme.Accent; F.Size = UDim2.new((default-min)/(max-min),0,1,0); F.BorderSizePixel = 0; Instance.new("UICorner", F).CornerRadius = UDim.new(1,0)
    local K = Instance.new("Frame"); K.Parent = S; K.BackgroundColor3 = Theme.Text; K.Size = UDim2.new(0,14,0,14); K.AnchorPoint = Vector2.new(0.5,0.5); K.Position = UDim2.new((default-min)/(max-min),0,0.5,0); Instance.new("UICorner", K).CornerRadius = UDim.new(1,0)
    local act, val, drag = false, default, false
    local function Up() callback(act, val) end
    T.MouseButton1Click:Connect(function() act = not act; T.Text = act and "ON" or "OFF"; T.BackgroundColor3 = act and Theme.On or Theme.Off; T.TextColor3 = act and Color3.new(0,0,0) or Theme.Text; Up() end)
    local function Set(i) local p = math.clamp((i.Position.X - S.AbsolutePosition.X) / S.AbsoluteSize.X, 0, 1); K.Position = UDim2.new(p, 0, 0.5, 0); F.Size = UDim2.new(p, 0, 1, 0); val = math.floor(min + (max - min) * p); V.Text = tostring(val); if act then Up() end end
    S.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; Set(i) end end)
    UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Set(i) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
end
local function CreateSimpleToggle(scroll, title, callback)
    local P = Instance.new("Frame"); P.Parent = scroll; P.BackgroundColor3 = Theme.Item; P.Size = UDim2.new(1,0,0,45); Instance.new("UICorner", P).CornerRadius = UDim.new(0,6)
    local L = Instance.new("TextLabel"); L.Parent = P; L.Text = title; L.Font = Enum.Font.GothamBold; L.TextColor3 = Theme.Text; L.TextSize = 14; L.Size = UDim2.new(0.6,0,1,0); L.Position = UDim2.new(0,12,0,0); L.BackgroundTransparency = 1; L.TextXAlignment = Enum.TextXAlignment.Left
    local T = Instance.new("TextButton"); T.Parent = P; T.Text = "OFF"; T.Font = Enum.Font.GothamBold; T.TextColor3 = Theme.Text; T.BackgroundColor3 = Theme.Off; T.Size = UDim2.new(0,50,0,24); T.Position = UDim2.new(1,-60,0.5,-12); Instance.new("UICorner", T).CornerRadius = UDim.new(0,4)
    local act = false; T.MouseButton1Click:Connect(function() act = not act; T.Text = act and "ON" or "OFF"; T.BackgroundColor3 = act and Theme.On or Theme.Off; T.TextColor3 = act and Color3.new(0,0,0) or Theme.Text; callback(act) end)
end

local HackPage = CreateTab("Hack", 1); local HackScroll = CreateHackScroll(HackPage)
local wsL; CreateControl(HackScroll, "Walk Speed", 16, 300, 16, function(a, v) if a then if not wsL then wsL = RunService.RenderStepped:Connect(function() if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = v end end) end else if wsL then wsL:Disconnect(); wsL = nil end; if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end end end)
local jpL; CreateControl(HackScroll, "Jump Power", 50, 500, 50, function(a, v) if a then if not jpL then jpL = RunService.RenderStepped:Connect(function() if LocalPlayer.Character then LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = v end end) end else if jpL then jpL:Disconnect(); jpL = nil end; if LocalPlayer.Character then LocalPlayer.Character.Humanoid.JumpPower = 50 end end end)
local flL, bg, bv; CreateControl(HackScroll, "Fly Mode (Joystick)", 10, 300, 50, function(a, v) local c=LocalPlayer.Character; local function cl() if bg then bg:Destroy();bg=nil end; if bv then bv:Destroy();bv=nil end; if flL then flL:Disconnect();flL=nil end; if c and c:FindFirstChild("Humanoid") then c.Humanoid.PlatformStand=false end end; if a and c then local h, hm = c:FindFirstChild("HumanoidRootPart"), c:FindFirstChild("Humanoid"); if h and hm then cl(); bg=Instance.new("BodyGyro",h); bg.P=9e4; bg.maxTorque=Vector3.new(9e9,9e9,9e9); bv=Instance.new("BodyVelocity",h); bv.velocity=Vector3.zero; bv.maxForce=Vector3.new(9e9,9e9,9e9); hm.PlatformStand=true; flL = RunService.RenderStepped:Connect(function() if not h or not bg or not bv then cl() return end; bg.CFrame=CFrame.lookAt(h.Position, h.Position+workspace.CurrentCamera.CFrame.LookVector*Vector3.new(1,0,1)); local ve = hm.MoveDirection*v; if UserInputService:IsKeyDown(Enum.KeyCode.Space) then ve=ve+Vector3.new(0,v/1.5,0) end; bv.Velocity=ve end) end else cl() end end)
local ij=false; UserInputService.JumpRequest:Connect(function() if ij and LocalPlayer.Character then LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping") end end); CreateSimpleToggle(HackScroll, "Infinity Jump", function(s) ij=s end)

--=============================================================================
-- 8. FITUR PAGE 2: PLAYER (NEW PROFILE, HISTORY, CONNECTIONS)
--=============================================================================
local PlayerPage = CreateTab("Player", 2)
local PlayerScroll = Instance.new("ScrollingFrame"); PlayerScroll.Parent = PlayerPage; PlayerScroll.Size = UDim2.new(1,0,1,0); PlayerScroll.BackgroundTransparency = 1; PlayerScroll.ScrollBarThickness = 3; PlayerScroll.ScrollBarImageColor3 = Theme.Accent
local PPL = Instance.new("UIListLayout"); PPL.Parent = PlayerScroll; PPL.SortOrder = Enum.SortOrder.LayoutOrder; PPL.Padding = UDim.new(0, 10); local PPP = Instance.new("UIPadding"); PPP.Parent = PlayerScroll; PPP.PaddingTop = UDim.new(0,10); PPP.PaddingLeft = UDim.new(0,10); PPP.PaddingRight = UDim.new(0,10)

-- PROFILE CARD
local ProfileCard = Instance.new("Frame"); ProfileCard.Parent = PlayerScroll; ProfileCard.BackgroundColor3 = Theme.Item; ProfileCard.Size = UDim2.new(1,0,0,80); Instance.new("UICorner", ProfileCard).CornerRadius = UDim.new(0,8)
local Avatar = Instance.new("ImageLabel"); Avatar.Parent = ProfileCard; Avatar.Size = UDim2.new(0,60,0,60); Avatar.Position = UDim2.new(0,10,0,10); Avatar.BackgroundColor3 = Theme.Bg; Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1,0)
local content, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420); Avatar.Image = content
local DispName = Instance.new("TextLabel"); DispName.Parent = ProfileCard; DispName.Text = LocalPlayer.DisplayName; DispName.Font = Enum.Font.GothamBold; DispName.TextColor3 = Theme.Text; DispName.TextSize = 16; DispName.Size = UDim2.new(0,200,0,20); DispName.Position = UDim2.new(0,80,0,15); DispName.TextXAlignment = Enum.TextXAlignment.Left; DispName.BackgroundTransparency = 1
local UserName = Instance.new("TextLabel"); UserName.Parent = ProfileCard; UserName.Text = "@" .. LocalPlayer.Name; UserName.Font = Enum.Font.Gotham; UserName.TextColor3 = Theme.TextDim; UserName.TextSize = 12; UserName.Size = UDim2.new(0,200,0,20); UserName.Position = UDim2.new(0,80,0,35); UserName.TextXAlignment = Enum.TextXAlignment.Left; UserName.BackgroundTransparency = 1
local UserID = Instance.new("TextLabel"); UserID.Parent = ProfileCard; UserID.Text = "ID: " .. LocalPlayer.UserId; UserID.Font = Enum.Font.Code; UserID.TextColor3 = Theme.Accent; UserID.TextSize = 10; UserID.Size = UDim2.new(0,200,0,20); UserID.Position = UDim2.new(0,80,0,55); UserID.TextXAlignment = Enum.TextXAlignment.Left; UserID.BackgroundTransparency = 1

-- HISTORY (SESSION) CARD
local HistLabel = Instance.new("TextLabel"); HistLabel.Parent = PlayerScroll; HistLabel.Text = "SESSION HISTORY"; HistLabel.Font = Enum.Font.GothamBold; HistLabel.TextColor3 = Theme.Accent; HistLabel.TextSize = 12; HistLabel.Size = UDim2.new(1,0,0,20); HistLabel.TextXAlignment = Enum.TextXAlignment.Left; HistLabel.BackgroundTransparency = 1
local HistCard = Instance.new("Frame"); HistCard.Parent = PlayerScroll; HistCard.BackgroundColor3 = Theme.Item; HistCard.Size = UDim2.new(1,0,0,60); Instance.new("UICorner", HistCard).CornerRadius = UDim.new(0,6)
local GameName = ""; pcall(function() GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)
local H1 = Instance.new("TextLabel"); H1.Parent = HistCard; H1.Text = "Current: " .. (GameName or "Unknown Game"); H1.Font = Enum.Font.GothamBold; H1.TextColor3 = Theme.Text; H1.TextSize = 12; H1.Size = UDim2.new(1,-20,0,20); H1.Position = UDim2.new(0,10,0,10); H1.TextXAlignment = Enum.TextXAlignment.Left; H1.BackgroundTransparency = 1
local H2 = Instance.new("TextLabel"); H2.Parent = HistCard; H2.Text = "Place ID: " .. game.PlaceId; H2.Font = Enum.Font.Code; H2.TextColor3 = Theme.TextDim; H2.TextSize = 10; H2.Size = UDim2.new(1,-20,0,15); H2.Position = UDim2.new(0,10,0,30); H2.TextXAlignment = Enum.TextXAlignment.Left; H2.BackgroundTransparency = 1

-- CONNECTIONS (FRIENDS) CARD
local ConnLabel = Instance.new("TextLabel"); ConnLabel.Parent = PlayerScroll; ConnLabel.Text = "CONNECTIONS (FRIENDS)"; ConnLabel.Font = Enum.Font.GothamBold; ConnLabel.TextColor3 = Theme.Accent; ConnLabel.TextSize = 12; ConnLabel.Size = UDim2.new(1,0,0,20); ConnLabel.TextXAlignment = Enum.TextXAlignment.Left; ConnLabel.BackgroundTransparency = 1
local ConnList = Instance.new("Frame"); ConnList.Parent = PlayerScroll; ConnList.BackgroundColor3 = Theme.Item; ConnList.Size = UDim2.new(1,0,0,100); Instance.new("UICorner", ConnList).CornerRadius = UDim.new(0,6)
local CScrol = Instance.new("ScrollingFrame"); CScrol.Parent = ConnList; CScrol.Size = UDim2.new(1,-10,1,-10); CScrol.Position = UDim2.new(0,5,0,5); CScrol.BackgroundTransparency = 1; CScrol.ScrollBarThickness=2
local CLL = Instance.new("UIListLayout"); CLL.Parent = CScrol; CLL.Padding = UDim.new(0,5)

local function RefreshFriends()
    for _,v in pairs(CScrol:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
    local count = 0
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and LocalPlayer:IsFriendsWith(player.UserId) then
            local F = Instance.new("TextLabel"); F.Parent = CScrol; F.Size = UDim2.new(1,0,0,20); F.BackgroundTransparency = 1; F.Text = "• " .. player.DisplayName .. " (@" .. player.Name .. ")"; F.TextColor3 = Theme.On; F.Font = Enum.Font.Gotham; F.TextSize = 11; F.TextXAlignment = Enum.TextXAlignment.Left
            count = count + 1
        end
    end
    if count == 0 then
        local F = Instance.new("TextLabel"); F.Parent = CScrol; F.Size = UDim2.new(1,0,0,20); F.BackgroundTransparency = 1; F.Text = "No friends in this server."; F.TextColor3 = Theme.TextDim; F.Font = Enum.Font.Gotham; F.TextSize = 11; F.TextXAlignment = Enum.TextXAlignment.Left
    end
end
RefreshFriends()

--=============================================================================
-- 9. FITUR PAGE 3: DATASET (DATA LIST & COPY LIST)
--=============================================================================
local DataPage = CreateTab("Dataset", 3)
local ControlMenu = Instance.new("Frame"); ControlMenu.Parent = DataPage; ControlMenu.BackgroundColor3 = Theme.Sidebar; ControlMenu.Size = UDim2.new(0.35, -5, 1, -20); ControlMenu.Position = UDim2.new(0, 5, 0, 10); Instance.new("UICorner", ControlMenu).CornerRadius = UDim.new(0, 8)
local CL = Instance.new("UIListLayout"); CL.Parent = ControlMenu; CL.Padding = UDim.new(0, 8); CL.SortOrder = Enum.SortOrder.LayoutOrder; local CP = Instance.new("UIPadding"); CP.Parent = ControlMenu; CP.PaddingTop = UDim.new(0, 10); CP.PaddingLeft = UDim.new(0, 10); CP.PaddingRight = UDim.new(0, 10)
local ListFrame = Instance.new("ScrollingFrame"); ListFrame.Parent = DataPage; ListFrame.BackgroundColor3 = Color3.fromRGB(18,18,18); ListFrame.Size = UDim2.new(0.65, -15, 1, -20); ListFrame.Position = UDim2.new(0.35, 10, 0, 10); ListFrame.ScrollBarThickness = 3; ListFrame.ScrollBarImageColor3 = Theme.Accent; Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 8); ListFrame.ClipsDescendants=true
local LL = Instance.new("UIListLayout"); LL.Parent = ListFrame; LL.Padding = UDim.new(0, 6); LL.SortOrder = Enum.SortOrder.LayoutOrder; local LP = Instance.new("UIPadding"); LP.Parent = ListFrame; LP.PaddingTop = UDim.new(0, 5); LP.PaddingLeft = UDim.new(0, 5); LP.PaddingRight = UDim.new(0, 5)

local SavedCoords = {}
local SelectedIndex = 0
local TempCFrame = nil

local function RefreshList()
    for _, v in pairs(ListFrame:GetChildren()) do if v:IsA("GuiObject") then v:Destroy() end end
    for i, data in ipairs(SavedCoords) do
        local Item = Instance.new("TextButton")
        Item.Parent = ListFrame
        Item.Size = UDim2.new(1, 0, 0, 42)
        Item.BackgroundColor3 = (i == SelectedIndex) and Theme.ItemSel or Theme.Item
        Item.AutoButtonColor = false
        Item.Text = ""
        Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 6)
        
        local Idx = Instance.new("TextLabel"); Idx.Parent = Item; Idx.Text = string.format("%02d", i); Idx.Font = Enum.Font.GothamBlack; Idx.TextColor3 = Theme.Accent; Idx.TextSize = 16; Idx.Size = UDim2.new(0, 30, 1, 0); Idx.BackgroundTransparency = 1; Idx.Position = UDim2.new(0, 5, 0, 0)
        local Name = Instance.new("TextLabel"); Name.Parent = Item; Name.Text = data.name; Name.Font = Enum.Font.GothamBold; Name.TextColor3 = Theme.Text; Name.TextSize = 13; Name.Size = UDim2.new(1, -40, 0.5, 0); Name.Position = UDim2.new(0, 35, 0, 2); Name.BackgroundTransparency = 1; Name.TextXAlignment = Enum.TextXAlignment.Left
        local Coords = Instance.new("TextLabel"); Coords.Parent = Item; Coords.Text = data.posStr; Coords.Font = Enum.Font.Code; Coords.TextColor3 = Theme.TextDim; Coords.TextSize = 10; Coords.Size = UDim2.new(1, -40, 0.5, 0); Coords.Position = UDim2.new(0, 35, 0.5, -2); Coords.BackgroundTransparency = 1; Coords.TextXAlignment = Enum.TextXAlignment.Left

        Item.MouseButton1Click:Connect(function()
            SelectedIndex = i
            RefreshList()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = data.cf
            end
        end)
    end
end

local function CreateMenuBtn(text, callback)
    local Btn = Instance.new("TextButton"); Btn.Parent = ControlMenu; Btn.Size = UDim2.new(1, 0, 0, 35); Btn.Text = text; Btn.Font = Enum.Font.GothamBold; Btn.TextColor3 = Theme.Text; Btn.BackgroundColor3 = Theme.Item; Btn.TextSize = 12; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(function() Btn.BackgroundColor3 = Theme.Accent; Btn.TextColor3 = Color3.new(0,0,0); wait(0.1); Btn.BackgroundColor3 = Theme.Item; Btn.TextColor3 = Theme.Text; callback() end)
end

CreateMenuBtn("SAVE POS", function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then TempCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame; NameInput.Text = ""; ModalOverlay.Visible = true end end)

CreateMenuBtn("COPY LIST", function()
    if #SavedCoords == 0 then return end
    local result = "-- DAFTAR KOORDINAT --\n"
    for i, v in ipairs(SavedCoords) do
        result = result .. i .. ". " .. v.name .. " (" .. v.posStr .. ")\n"
    end
    setclipboard(result)
end)

CreateMenuBtn("CLEAR LIST", function() SavedCoords = {}; SelectedIndex = 0; RefreshList() end)

-- LOGIC MODAL SAVE
SaveConfirmBtn.MouseButton1Click:Connect(function()
    local name = NameInput.Text; if name == "" then name = "Point " .. (#SavedCoords + 1) end
    if TempCFrame then
        local pos = TempCFrame.Position; local posStr = string.format("%d, %d, %d", math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
        table.insert(SavedCoords, {name = name, cf = TempCFrame, posStr = posStr})
        RefreshList()
    end
    ModalOverlay.Visible = false
end)
CancelBtn.MouseButton1Click:Connect(function() ModalOverlay.Visible = false end)

--=============================================================================
-- 10. FITUR PAGE 4: INFO (PANDUAN)
--=============================================================================
local InfoPage = CreateTab("Info", 4)
local InfoScroll = Instance.new("ScrollingFrame"); InfoScroll.Parent = InfoPage; InfoScroll.Size = UDim2.new(1,0,1,0); InfoScroll.BackgroundTransparency = 1; InfoScroll.ScrollBarThickness=3; InfoScroll.ScrollBarImageColor3=Theme.Accent
local IL = Instance.new("UIListLayout"); IL.Parent = InfoScroll; IL.SortOrder = Enum.SortOrder.LayoutOrder; IL.Padding = UDim.new(0, 10)
local IP = Instance.new("UIPadding"); IP.Parent = InfoScroll; IP.PaddingTop = UDim.new(0,10); IP.PaddingLeft = UDim.new(0,15); IP.PaddingRight = UDim.new(0,10)

local function AddInfoText(title, desc)
    local T = Instance.new("TextLabel"); T.Parent = InfoScroll; T.Text = title; T.Font = Enum.Font.GothamBold; T.TextColor3 = Theme.Accent; T.TextSize = 16; T.Size = UDim2.new(1,0,0,20); T.BackgroundTransparency = 1; T.TextXAlignment = Enum.TextXAlignment.Left
    local D = Instance.new("TextLabel"); D.Parent = InfoScroll; D.Text = desc; D.Font = Enum.Font.Gotham; D.TextColor3 = Theme.Text; D.TextSize = 12; D.Size = UDim2.new(1,0,0,0); D.AutomaticSize = Enum.AutomaticSize.Y; D.BackgroundTransparency = 1; D.TextXAlignment = Enum.TextXAlignment.Left; D.TextWrapped = true
end

AddInfoText("PLAYER MENU:", "Lihat profil akun kamu, info game saat ini, dan teman yang sedang bergabung.")
AddInfoText("DATASET:", "1. Tekan 'SAVE POS' untuk simpan lokasi.\n2. Beri nama lokasi (contoh: Base).\n3. KLIK nama di daftar untuk Teleport.\n4. 'COPY LIST' untuk menyalin semua data.")
AddInfoText("HACK:", "Fitur cheat standar: Terbang (Fly), Lari Cepat, dll.")

-- INIT UI
if tabs[1] then tabs[1].Page.Visible = true; tabs[1].Btn.TextColor3 = Theme.Text; tabs[1].Btn.BackgroundTransparency = 0.8; tabs[1].Ind.Visible = true end

-- FLOATING BUTTON
local FloatBtn = Instance.new("TextButton"); FloatBtn.Parent = ScreenGui; FloatBtn.BackgroundColor3 = Theme.Header; FloatBtn.Position = UDim2.new(0.1, 0, 0.1, 0); FloatBtn.Size = UDim2.new(0, 50, 0, 50); FloatBtn.Text = "PH"; FloatBtn.TextColor3 = Theme.Accent; FloatBtn.Font = Enum.Font.GothamBold; FloatBtn.TextSize = 20; FloatBtn.BackgroundTransparency = 0.2; Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1,0); local S = Instance.new("UIStroke", FloatBtn); S.Color = Theme.Accent; S.Thickness = 2; S.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; MakeDraggable(FloatBtn, FloatBtn)
FloatBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; FloatBtn.Visible = false; MainFrame.Size = UDim2.new(0,0,0,0); TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 550, 0, 300)}):Play() end)
MiniBtn.MouseButton1Click:Connect(function() local t = TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0,0,0,0)}); t:Play(); t.Completed:Wait(); MainFrame.Visible = false; FloatBtn.Visible = true end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
