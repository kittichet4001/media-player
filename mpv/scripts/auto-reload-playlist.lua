-- สร้างตัวแปรเก็บ Path ไว้ตายตัว ป้องกัน mpv ลืม Path หลังจากเคลียร์ลิสต์
local saved_path = nil

function reload_playlist()
    -- ดึง Path แค่ครั้งแรกตอนที่เริ่มรันสำเร็จ
    if not saved_path then
        local p = mp.get_property("playlist-path")
        if p and string.match(p, "%.txt$") then
            saved_path = p
        end
    end

    -- ถ้าได้ Path ชัวร์ๆ แล้ว ลุยเลย
    if saved_path then
        local current_pos = mp.get_property_number("playlist-pos", 0)
        local current_time = mp.get_property_number("time-pos", 0)
        
        -- ใช้ low-level command บังคับรีโมตเปิดเพลย์ลิสต์ทับตัวเก่าตรงๆ
        mp.commandv("loadlist", saved_path, "replace")
        
        -- ล็อกเป้ากลับมาเล่นคลิปเดิม วินาทีเดิม
        mp.set_property_number("playlist-pos", current_pos)
        
        -- ดึงเวลากลับมาเมื่อไฟล์โหลดพร้อม
        mp.register_event("file-loaded", function()
            mp.set_property_number("time-pos", current_time)
            mp.unregister_event("file-loaded")
        end)
        
        mp.osd_message("Syncing .txt Playlist...", 1)
    end
end

-- ตั้งเวลาให้ทำงานทุกๆ 15 วินาที (ปรับให้เร็วขึ้นเพื่อเช็กผลลัพธ์)
mp.add_periodic_timer(300, reload_playlist)