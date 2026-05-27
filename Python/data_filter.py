
from openpyxl import load_workbook
input_file = "C:\\Users\\Om_42\\Documents\\Billboard_Top_ThaiSongs.xlsx"
wb = load_workbook(input_file)
sheet = wb.active
output_file = "C:\\Users\\Om_42\\Documents\\ent\\media-player\\Thai\\Billboard_Top_ThaiSongs.txt"
with open(output_file, 'w', encoding='utf-8') as f:
    for row in sheet.iter_rows(values_only=True):
        last_element = row[-1] # เลือกตัวสุดท้ายของแถว
        if last_element is not None:
            f.write(f"{last_element}\n")