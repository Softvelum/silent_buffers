rates=(7350 8000 11025 12000 16000 22050 24000 32000 44100 48000 64000 88200 96000)
cls=("mono" "stereo" "2.1" "3.1" "4.1" "5.1" "7.1")
: > silence_frames.aac.js
for i in "${cls[@]}"; do
  for j in "${rates[@]}"; do
    filename="$i"_silence_"$j".aac
    ffmpeg -y -f lavfi -i anullsrc=r=$j:cl=$i -t 1 $filename
    perl get_last_frame.pl -t aac -f $filename --outfilename silence_frames.aac.js --arrayname silence_"$i"_"$j" --adts
  done
done

rates=(32000 44100 48000)
cls=("mono" "stereo")
: > silence_frames.mp3.js
for i in "${cls[@]}"; do
  for j in "${rates[@]}"; do
    filename="$i"_silence_"$j".mp3
    ffmpeg -y -f lavfi -i anullsrc=r=$j:cl=$i -acodec libmp3lame -t 1 $filename
    perl get_last_frame.pl -t mp3 -f $filename --outfilename silence_frames.mp3.js --arrayname silence_"$i"_"$j"
  done
done