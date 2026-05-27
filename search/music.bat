set /p "song_name= Song or Artist to you want listen: "

if "%song_name%"=="" goto search_loop
mpv "ytdl://https://music.youtube.com/search?q=%song_name%"