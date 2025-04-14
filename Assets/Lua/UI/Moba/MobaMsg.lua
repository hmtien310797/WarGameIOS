module("MobaMsg", package.seeall)

function GetCategoryId()
    return Global.GetMobaMode() == 2 and Category_pb.GuildMoba or Category_pb.Moba
end

function GetReqMsg(msg)
    return Global.GetMobaMode() == 2 and GuildMobaMsg_pb["Guild" .. msg]() or MobaMsg_pb["Msg" .. msg]()
end

function GetTypeId(typeId)
    return Global.GetMobaMode() == 2 and GuildMobaMsg_pb.GuildMobaTypeId["Guild" .. typeId] or MobaMsg_pb.MobaTypeId["Msg" .. typeId]
end

function GetRepMsgPb(msg)
    return Global.GetMobaMode() == 2 and GuildMobaMsg_pb["Guild" .. msg] or MobaMsg_pb["Msg" .. msg]
end
