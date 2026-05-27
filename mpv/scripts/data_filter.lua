-- ฟังก์ชันแกะฟอร์แมต Name|Link สำหรับสร้างชาร์ตเพลง
function parse_music_chart(file_path)
    local items = {}
    local file = io.open(file_path, "r")
    if not file then return items end
    
    for line in file:lines() do
        line = line:match("^%s*(.-)%s*$") -- ตัดช่องว่างหัวท้ายบรรทัด
        -- ข้ามบรรทัดว่าง หรือบรรทัดที่เป็น Comment (#)
        if line ~= "" and not string.match(line, "^#") then
            -- แยกข้อความด้วยเครื่องหมาย |
            local name, source = string.match(line, "([^|]+)%s*|%s*(.+)")
            if name and source then
                table.insert(items, {title = name, url = source})
            else
                -- ถ้าไม่มีเครื่องหมาย | ให้ใช้ลิงก์เพียวๆ
                table.insert(items, {title = line, url = line})
            end
        end
    end
    file:close()
    return items
end

-- ฟังก์ชันรันครั้งเดียวตอนเริ่มเปิดไฟล์ .txt ชาร์ตเพลง
function load_custom_chart()
    local path = mp.get_property("playlist-path")
    if path and string.match(path, "%.txt$") then
        local items = parse_music_chart(path)
        if #items == 0 then return end

        -- ล้างคิวจำลองที่ mpv อ่านพลาดตอนแรกออก
        mp.command("playlist-clear")

        -- ยัดชาร์ตเพลงเข้าสู่ระบบประมวลผล
        for i, item in ipairs(items) do
            if i == 1 then
                mp.commandv("loadfile", item.url, "replace")
            else
                mp.commandv("loadfile", item.url, "append")
            end
            -- เซตชื่อเพลงให้ขึ้นโชว์บนหน้าจอและหน้าลิสต์ (F8) แทน URL รกๆ
            mp.commandv("playlist-set-title", tostring(i-1), item.title)
        end
        
        mp.osd_message("Music Chart Loaded! 🎵", 3)
    end
end

-- สั่งให้สคริปต์ทำงานทันทีที่เริ่มเปิดไฟล์เสร็จ (รันรอบเดียวจบ)
mp.register_event("start-file", load_custom_chart)