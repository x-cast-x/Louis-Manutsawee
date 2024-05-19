local FOODTYPE = GLOBAL.FOODTYPE
local ENV = env
GLOBAL.setfenv(1, GLOBAL)

-- when MiM enabled, add it
if ENV.is_mim_enabled then
    local video_urls = {
        "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        "https://github.com/Manutsawee/Louis-Manutsawee",
        "https://www.nicovideo.jp/watch/sm2057168",
        "https://www.bilibili.com/video/BV1xx411c7mu",
        "https://www.bilibili.com/video/BV1SG4y1274y",
        "https://www.youtube.com/watch?v=zXglsI9oH18",
        "https://www.youtube.com/watch?v=IOXoAvF6r_A",
        "https://www.youtube.com/watch?v=W84JUTLVedg",
        "https://www.youtube.com/watch?v=MNLxpgtnHTE",
    }
    -- No animation video
    CHARACTER_VIDEOS["manutsawee"] = {video_urls[math.random(1, #video_urls)]}
end

FOODTYPE.MFRUIT = "MFRUIT"

ALL_KATANA = {}

M_SKILLS = {
    "ichimonji",
    "flip",
    "thrust",
    "isshin",
    "heavenlystrike",
    "ryusen",
    "susanoo",
    "soryuha",
}

M_SKIN_NAMES = {
    "sailor",
    "yukata",
    "yukatalong",
    "miko",
    "qipao",
    "fuka",
    "maid",
    "jinbei",
    "shinsengumi",
    "taohuu",
    "uniform_black",
    "bocchi",
    "lycoris",
    "maid_m",
    "souji",
}
