local SendModRPCToAllShards = function(id_table, ...)
    local sender_list = {}
    for i, v in pairs(Shard_GetConnectedShards()) do
        sender_list[#sender_list + 1] = i
    end

    SendModRPCToShard(id_table, sender_list, ...)
end

return {
    SendModRPCToAllShards = SendModRPCToAllShards,
}
