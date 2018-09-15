PlotDialogue ={
    body,
    leftRole,
    rightRole,
    leftName,
    rightName,
    wordWid, 
    arrow,
    btnContinue,
    btnCancel,
    words,
    isContinue = false,
    isShowBtn = false,
    onDispose,
    wait=true,
}

local function Init(go)
    PlotDialogue.body=go.gameObject
    PlotDialogue.leftRole=go.transform:ChildWidget("role_left"):GetCmp(typeof(UITexture))
    PlotDialogue.rightRole=go.transform:ChildWidget("role_right"):GetCmp(typeof(UITexture))
    PlotDialogue.leftName=PlotDialogue.leftRole:ChildWidget("left_name")
    PlotDialogue.rightName=PlotDialogue.rightRole:ChildWidget("right_name")
    PlotDialogue.wordWid=go.transform:ChildWidget("Word")  
    PlotDialogue.arrow=go.transform:ChildWidget("arrow"):GetCmp(typeof(TweenPosition))
    PlotDialogue.btnContinue=go.transform:ChildWidget("btn_continue")  
    PlotDialogue.btnCancel=go.transform:ChildWidget("btn_cancel")  
    return PlotDialogue
end

local function Dispose(b)
    b.leftRole:UnLoadTex()
    b.rightRole:UnLoadTex()
    b.body.gameObject:SetActive(false)
    b.words = nil
    b.body.gameObject:Destroy()
    if b.onDispose~=nil then  
        if not b.isContinue then b.onDispose() 
        else
            user.TutorialSN=1
            user.TutorialStep=61
            b.onDispose()
            MapLevel.AttackNextCity()--继续攻城
            if b.isShowBtn then 
               --  if SceneGame.body then TweenAlpha.Begin(SceneGame.body.gameObject, 0.3, 1) end
            end
        end
    end
end

local function SetRole(role1,role2,nmObj,nm,img)
    nmObj.text = nm
    print("print: ",role1.name)
    role1:LoadTexAsync(img)
    role1:GetCmp(typeof(TweenAlpha)):Play(true)
    role1:GetCmp(typeof(TweenPosition)):Play(true)
    role2:GetCmp(typeof(TweenAlpha)):Play(false)
    role2:GetCmp(typeof(TweenPosition)):Play(false)
end

local function OnShowLevelPlot(d,lv)
    if d.words == nil then Dispose(d); return end
    d.body.gameObject:SetActive(true)
    d.body:GetCmp(typeof(TweenAlpha)):Play(true)
--    if SceneGame.body then TweenAlpha.Begin(SceneGame.body.gameObject, 0.3, 0) end
    local asset= lv<DB.maxGmLv and AM.LoadPrefab(ResName.MapLevel(lv + 1), true) or nil
    for i=1,#d.words do
        local dlg= d.words[i]
        local Ndx= string.find("N:")
        local Pdx= string.find("P:")
        local bool= Ndx<Pdx
        d.leftRole:GetCmp(typeof(TweenAlpha)):Play(bool)
        d.leftRole:GetCmp(typeof(TweenPosition)):Play(bool)
        d.rightRol:GetCmp(typeof(TweenAlpha)):Play(not bool)
        d.rightRol:GetCmp(typeof(TweenPosition)):Play(not boo)
        EF.TypeText(d.wordWid, string.sub(dlg,3))
        coroutine.wait(0.3)
        d.wait=true
        local time=#dlg / d.wordWid.charsPerSecond+0.5
        print(time,Time.deltaTime)
        while time>0 and b.wait do
            time = time- Time.deltaTime
            coroutine.step()
            if time<=0 then break end
        end
        d.leftRole:GetCmp(typeof(TweenAlpha)):Play(false)
        d.leftRole:GetCmp(typeof(TweenPosition)):Play(false)
        d.rightRol:GetCmp(typeof(TweenAlpha)):Play(false)
        d.rightRol:GetCmp(typeof(TweenPosition)):Play(false)
        coroutine.wait(0.2)
        d.body:GetCmp(typeof(TweenAlpha)):Play(false)
--        if SceneGame.body then TweenAlpha.Begin(SceneGame.body.gameObject, 0.3, 1) end
        coroutine.wait(0.2)
        if asset~=nil and not tolua.isnull(asset) then 
            StatusBar.ShowR(asset) 
            while tolua.isnull(asset)  do
                coroutine.step()
            end    
        end
        Dispose(d)
        if user.gmMaxCity == 8 then --升级主城
            user.TutorialSN=1
            user.TutorialStep=46
            Tutorial.Active =true
            if user.gmLv==2 then
                MapLevel.CheckTutorial()
            else 
                Win.Open("MapLevel")
            end
        end 
    end
end

local function OnShowTutorialPlot(d,isShowBtn)
    if d.words==nil then Dispose(d) return end 
    local leftRole,rightRole=d.leftRole,d.rightRole
    local leftName,rightName=d.leftName,d.rightName
    local word=d.wordWid:GetCmp(typeof(TypeWriterEffect))
    local sp=d.body:AddWidget(typeof(UISprite),"mask")
    sp.atlas = AM.mainAtlas
    sp.spriteName = "mask"
    sp.color = Color.black
    sp.depth = 0
    sp.alpha = 0.6
    sp.width = 1200 
    sp.height = 960
    sp.type = UIBasicSprite.Type.Sliced
    d.body:SetActive(true)
    d.body:GetCmp(typeof(TweenAlpha)):Play(true)
--    TweenAlpha.Begin(SceneGame.body.gameObject, 0.3, 0)

    local words = d.words 
    for i = 1, #words do
       local dlg = words[i]
       local colon = string.find(dlg ,':')
       if colon and colon > 0 then
            local prefix= string.sub(dlg,1,colon-1)
            dlg = string.sub(dlg,colon+1)
            local roleName,imgName="",""
            if prefix == "P" then 
                roleName = user.nick
                imgName = ResName.PlayerRole(user.role)
            else
                local prefixs = string.split(prefix,',')
                local img = -1
                if #prefixs > 0 then roleName = prefixs[1] end
                if #prefixs > 1 then img=prefixs[2] or -1 end
                imgName = ResName.HeroImage(img)
            end
            local bool=i%2==1
            SetRole(bool and leftRole or rightRole,bool and rightRole or leftRole,bool and leftName or rightName,roleName,imgName)
            EF.TypeText(d.wordWid,dlg)
            local time= Time.realtimeSinceStartup+0.3
            while time > Time.realtimeSinceStartup do coroutine.step() end
            d.wait=true
            time=Time.realtimeSinceStartup + math.min( string.len(dlg) / (word.charsPerSecond + 0.5), 5)  
            while (time > Time.realtimeSinceStartup and d.wait) do coroutine.step() end
       end
    end

    if not isShowBtn then 
        leftRole:GetCmp(typeof(TweenPosition)):Play(false)
        leftRole:GetCmp(typeof(TweenAlpha)):Play(false)
        rightRole:GetCmp(typeof(TweenAlpha)):Play(false)
        rightRole:GetCmp(typeof(TweenPosition)):Play(false)
        local t = Time.realtimeSinceStartup + 0.3
        while t > Time.realtimeSinceStartup do coroutine.step() end
        d.body:GetCmp(typeof(TweenAlpha)):Play(false)
        if (user.TutorialSN~=1  or user.TutorialStep~=2) and SceneGame.body then 
            print("user.TutorialSN",user.TutorialSN)
--            TweenAlpha.Begin(SceneGame.body.gameObject, 0.3, 1)
        end
        t = Time.realtimeSinceStartup + 0.2
        while t > Time.realtimeSinceStartup do coroutine.step() end
        Dispose(d)
    end
    PlotDialogue.isShowBtn=isShowBtn
end

function PlotDialogue.ShowTutorialPlot(d,content, isShowBtn)
    if isShowBtn==nil then isShowBtn=false end
    if string.isEmpty(content) then Dispose(d)
    else
        d.leftRole.alpha = 0
        d.rightRole.alpha = 0
        d.words =  string.split(content,'|') 
        if #d.words then 
            coroutine.start(OnShowTutorialPlot,d,isShowBtn)
        else Dispose(d)
        end
    end
end

function PlotDialogue.ShowLevelPlot(d,lv)
    local data=DB.GetGmLv(lv)
    if data.sn > 0 then 
        local hd=DB.GetHero(data.dbsn)
        d.leftRole:LoadTexAsync(ResName.HeroImage(hd.img))
        d.leftName.text = hd.nm
        d.rightRole:LoadTexAsync(ResName.PlayerRole(user.role))
        d.rightName.text = user.nick
        d.leftRole.alpha = 0
        d.rightRole.alpha = 0

        local dialogue = DB.Get("dlg_lv1")
        if dialogue and dialogue[lv] then 
            d.words= string.split(dialogue[lv],'|')
            if #d.words>0 then coroutine.start(OnShowLevelPlot,d,lv) 
            else Dispose(d)
            end
        else Dispose(d)
        end
    else Dispose(d)
    end
end


function PlotDialogue.TutorialPlot(content,onDispose,isShowBtn) 
     if SceneGame then 
         local plot= Init(SceneGame.body:AddChild(AM.LoadPrefab("PlotDialogue"),"PlotDialogue")) 
         plot.isShowBtn = isShowBtn;
         plot.arrow.from = isShowBtn and Vector3(180, -245, 0) or Vector3(251, -245, 0)
         plot.arrow.to = isShowBtn and Vector3(180, -252, 0) or Vector3(251, -252, 0)
         plot.wordWid.width = isShowBtn and 460 or 532
         plot.btnContinue.gameObject:SetActive(isShowBtn)
         plot.btnCancel.gameObject:SetActive(isShowBtn)
         plot:ShowTutorialPlot(content, isShowBtn)
         plot.onDispose = onDispose
     end
end

function PlotDialogue.LevelPlot(level)
    if SceneGame.body then 
        local plot= Init(SceneGame.body:AddChild(AM.LoadPrefab("PlotDialogue"),"PlotDialogue"))
        plot:ShowLevelPlot(level)
    end
end

objext(PlotDialogue)