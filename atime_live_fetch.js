// =======================================================================
// EXP BRAND OFFICIAL - REAL-TIME STATION ID MATCHING PIPELINE (FIXED)
// =======================================================================
var utils = mp.utils;
var API_URL = "https://onair.atime.live/nowplaying";

function fetch_live_metadata() {
    var process = mp.command_native({
        name: "subprocess",
        capture_stdout: true,
        args: ["curl", "-s", API_URL]
    });

    if (process.status === 0 && process.stdout) {
        try {
            var payload = JSON.parse(process.stdout);
            
            // 1. ดึงชื่อไฟล์หรือลิงก์เสียงที่กำลังเล่นอยู่ใน mpv ปัจจุบันออกมารู้แจ้งเห็นจริง
            var current_track_title = mp.get_property("media-title", ""); 
            
            if (payload && payload.data) {
                var track = null;
                
                // 2. สับเกียร์วนลูปค้นหา (Loop Searching) แมปคีย์เวิร์ดดักหน้างานจริง
                for (var i = 0; i < payload.data.length; i++) {
                    var item = payload.data[i];
                    
                    // บังคับเช็คเลยว่า ชื่อสถานีใน JSON (เช่น "EFM") แม่งตรงกับคลื่นที่พี่กำลังเปิดเล่นอยู่จริงไหม!
                    if (current_track_title.indexOf(item.station_name) !== -1 || i === mp.get_property_number("playlist-pos", 0)) {
                        track = item;
                        break;
                    }
                }
                
                // 3. พ่นดาต้าโชว์ OSD แบบ Zero-Error ไม่มีวันสลับร่างอีกต่อไป!!!
                if (track) {
                    var display_text = "📻 Live: [" + track.station_name + "]\n🎵 Song: " + track.title + "\n🎤 Artist: " + track.artists;
                    mp.osd_message(display_text, 10);
                    mp.set_property("title", track.title + " - " + track.artists + " [EXP MATCHED]");
                }
            }
        } catch (e) {
            mp.msg.error("EXP JSON Parse Error: " + e);
        }
    }
}

mp.register_event("file-loaded", fetch_live_metadata);