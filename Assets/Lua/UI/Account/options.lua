module("options", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText


local function CloseClickCallback(go)
    Hide()
end

local function LoadUI()
    local option = Global.GGameSetting.instance.option
    local sound = option.mSoundSetting
    local music = option.mMusicSetting
    local quality = option.mQualityLevel

    local bg_music =transform:Find("options/bg_frane/Scroll View/bf_music/bg_music/bg_icon")
    local bg_music_cha = transform:Find("options/bg_frane/Scroll View/bf_music/bg_music/bg_icon/icon_cha")
    bg_music_cha.gameObject:SetActive(not music)
    SetClickCallback(bg_music.gameObject,function() 
        music = not music
        bg_music_cha.gameObject:SetActive(not music)
    end)

    local bg_sound =transform:Find("options/bg_frane/Scroll View/bf_music/bg_sound/bg_icon")
    local bg_sound_cha = transform:Find("options/bg_frane/Scroll View/bf_music/bg_sound/bg_icon/icon_cha")
    bg_sound_cha.gameObject:SetActive(not sound)
    SetClickCallback(bg_sound.gameObject,function() 
        sound = not sound
        bg_sound_cha.gameObject:SetActive(not sound)
    end)   
    
    local saveandclose = function()
    	option.mSoundSetting = sound
        option.mMusicSetting = music
        option.mQualityLevel = quality     
        Global.GAudioMgr.MusicSwith =option.mMusicSetting
        Global.GAudioMgr.SfxSwith = option.mSoundSetting
        if option.mMusicSetting then
            Global.GAudioMgr.Instance:PlayMusic("MUSIC_maincity_background", 0.2, true, 1)
        else
            Global.GAudioMgr.Instance:StopMusic();
        end         
		Global.GGameSetting.instance.option = option
        Global.GGameSetting.instance:SaveOption()  
        Hide()
    end 

    SetClickCallback(transform:Find("options/bg_frane/bg_top/btn_close").gameObject, saveandclose)
	SetClickCallback(transform:Find("options").gameObject, saveandclose)
    
    local qlowToggle =transform:Find("options/bg_frane/Scroll View/bf_quality/bg_quality_low/checkbox").gameObject:GetComponent("UIToggle")
    qlowToggle.value = quality == 0
    SetClickCallback(qlowToggle.gameObject,function() 
        if quality == 0 then
            return
        else
           quality = 0
           qlowToggle.value = quality == 0

        end        
    end)

    local qmidToggle =transform:Find("options/bg_frane/Scroll View/bf_quality/bg_quality_mid/checkbox").gameObject:GetComponent("UIToggle")
    qmidToggle.value = quality == 1
    SetClickCallback(qmidToggle.gameObject,function() 
        if quality == 1 then
            return
        else
           quality = 1
           qmidToggle.value = quality == 1
        end        
    end)


    local qheightToggle =transform:Find("options/bg_frane/Scroll View/bf_quality/bg_quality_height/checkbox").gameObject:GetComponent("UIToggle")
    qheightToggle.value = quality == 2
    SetClickCallback(qheightToggle.gameObject,function() 
        if quality == 2 then
            return
        else
           quality = 2
           qheightToggle.value = quality == 2
        end        
    end) 

    SetClickCallback(transform:Find("options/bg_frane/btn_relate").gameObject,function()
        saveandclose()
        setting.Hide()
    end)
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end


function Awake()

end


function Show()
    --heroUid = uid
    Global.OpenUI(_M)
    LoadUI()
end
