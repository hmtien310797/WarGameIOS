module("UnionAuthority", package.seeall)

local authorityList =
{
    0, 1, 2, 3, 4, 5, 7, 8, 10, 11, 12, 13, 14,
}

local TextMgr = Global.GTextMgr
local SetClickCallback = UIUtil.SetClickCallback

function Hide()
    Global.CloseUI(_M)
end

function Awake()
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/close btn")

    SetClickCallback(mask.gameObject, Hide)
    SetClickCallback(closeButton.gameObject, Hide)

    local authorityGrid = transform:Find("bg/Scroll View/Grid"):GetComponent("UIGrid")
    local authorityPrefab = authorityGrid.transform:GetChild(0).gameObject  
    for i, v in ipairs(authorityList) do
        local authorityTransform
        if i > authorityGrid.transform.childCount then
            authorityTransform = NGUITools.AddChild(authorityGrid.gameObject, authorityPrefab).transform
        else
            authorityTransform = authorityGrid.transform:GetChild(i - 1)
        end
        authorityTransform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("union_authority" .. (v + 1))
        authorityTransform:Find("bg").gameObject:SetActive(i % 2 ~= 0)
        for j = 1, 6 do
            authorityTransform:Find("R" .. j).gameObject:SetActive(bit.band(tableData_tUnionPrivilege.data[j == 6 and 11 or j].powerNum, bit.lshift(1, v)) ~= 0)
        end
    end
	authorityGrid:Reposition()
end

function Show()
    Global.OpenUI(_M)
end
