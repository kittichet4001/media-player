import pandas as pd
from ytmusicapi import YTMusic

ytm = YTMusic()
file_path = ".\\Thai\\Youtube_Chart.xlsx"
df = pd.read_excel(file_path)

# สร้างคอลัมน์ Link มารองรับไว้ล่วงหน้าถ้ายังไม่มี
if 'Link' not in df.columns:
    df['Link'] = ""

print("กำลังเริ่มค้นหาแบบระบุ ศิลปิน + ชื่อเพลง...")

for index, row in df.iterrows():
    artist = row['Artist']
    song = row['Song']
    
    # ----------------------------------------------------
    # Nested If ชั้นที่ 1: เช็กว่ามีข้อมูลทั้งศิลปินและชื่อเพลงไหม
    # ----------------------------------------------------
    if pd.notna(artist) and pd.notna(song):
        
        # ปรับ Format คำค้นหาให้แม่นยำที่สุด เช่น "PURPEECH - กลัวว่าฉันจะไม่เสียใจ"
        search_query = f"{str(artist).strip()} - {str(song).strip()}"
        
        # คัดกรองเฉพาะแถวที่ยังไม่มี Link (ป้องกันการรันซ้ำข้อความเดิม)
        if pd.isna(row['Link']) or row['Link'] == "":
            try:
                # ค้นหาในหมวดเพลง (Songs)
                search_results = ytm.search(query=search_query, filter="songs")
                
                # ----------------------------------------------------
                # Nested If ชั้นที่ 2: เช็กว่า API มีผลลัพธ์ส่งกลับมาไหม
                # ----------------------------------------------------
                if search_results and len(search_results) > 0:
                    video_id = search_results[0]['videoId']
                    yt_music_link = f"https://music.youtube.com/watch?v={video_id}"
                    
                    # บันทึกลิงก์ลงล็อกที่ถูกต้อง
                    df.at[index, 'Link'] = yt_music_link
                    print(f"เจอแล้ว! -> {search_query}")
                else:
                    print(f"❌ ค้นหาไม่พบผลลัพธ์: {search_query}")
                    
            except Exception as e:
                print(f"⚠️ เกิดข้อผิดพลาดกับเพลง {search_query}: {e}")

# เซฟไฟล์กลับ
df.to_excel(file_path, index=False)
print("\n✨ ตรวจสอบและเพิ่มลิงก์เสร็จสิ้นเรียบร้อยแล้ว!")