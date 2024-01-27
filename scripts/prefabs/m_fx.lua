local assets = {
    Asset("ANIM", "anim/thunderbird_fx.zip"),
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("thunderbird_fx")
    inst.AnimState:SetBuild("thunderbird_fx")
    inst.AnimState:SetSortOrder(2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("mthunderbird_fx", fn, assets)