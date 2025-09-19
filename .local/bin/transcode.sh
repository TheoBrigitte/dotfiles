#!/bin/bash
#
# Author: Théo Brigitte
# Date: 2025-09-16
#
# Usage: transcode.sh input_file output_file
#
# Options:
#  --help                  Show this help message and exit
#  --[no-]audio     [lang]
#  --[no-]video     [lang]
#  --[no-]subtitles [lang] Exclude or include (default) the stream in the output
#                          file with optional optional language filter (e.g. "eng")
#                          see https://trac.ffmpeg.org/wiki/Map#Specificlanguage
#
#  --crf <value>           Set the Constant Rate Factor (CRF) for video quality
#                          (default: 23, lower is better quality, range 0-51)
#                          see https://trac.ffmpeg.org/wiki/Encode/H.264#crf
#
#  --tune <preset>         Set the tune preset for x264 encoder
#
#
# FFmpeg script to convert video files to h264 + aac format using Docker
# for better compatibility with streaming service like Jellyfin, Plex, etc.
#
# This is useful to avoid transcoding on the fly, especially on low-end boxes.
# Less CPU power required, less heat, less noise, less electricity ... better for the planet!
#
# Convert video file to h264 + aac (widely compatible format)
# - h264 video codec (libx264)
# - aac audio codec (libfdk_aac)
# - 2 channels (stereo) 192k bitrate audio
# - optimized for streaming (faststart)
# - force keyframes every 3 seconds
# - mp4 container

# Documentation:
# - x264: https://trac.ffmpeg.org/wiki/Encode/H.264
# - aac: https://trac.ffmpeg.org/wiki/Encode/AAC
# - ffmpeg + libfdk_acc: https://aur.archlinux.org/packages/ffmpeg-libfdk_aac
# - client codec support: https://jellyfin.org/docs/general/clients/codec-support

set -euo pipefail

exit_error() {
  echo "[ERROR] $1"
  exit 1
}

print_help() {
  # Extract usage from the script comments
  # Print from Usage to the first empty line, then remove leading "# "
  sed -ne '/Usage/,/^$/ s/#\s\?//p' "$0"
}

# Default options
video="0:v"     # keep all video
audio="0:a"     # keep all audio
subtitles="0:s" # keep all subtitles
crf=23          # default CRF value
tune=""         # no tune by default

# Parse command line arguments
shopt -s extglob
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      print_help
      exit;;
    --?(no-)@(audio|video|subtitles))
      # Handle options --audio, --video, --subtitles and their negated forms --no-audio, --no-video, --no-subtitles
      option="${1##*-}" # Remove leading -- or --no-
      test ! "${!option+set}" && exit_error "Invalid option $option"
      if [[ "$1" == --no-* ]]; then
        # If the option is prefixed with "--no", exclude the stream type
        # e.g. --no-subtitles
        # set the variable named in $option to "-0:<first letter of option>"
        eval "${option}=-0:${option:0:1}"
      else
        # Include the stream type, optionally with a language filter
        # e.g. --subtitles or --subtitles fre
        filter=""
        if [[ -n "${2-}" && ! "$2" =~ ^- ]]; then
          # If the next argument is not empty and does not start with a dash,
          # consider it as a language filter (3 letters ISO 639 code)
          # e.g. --subtitles fre
          filter=":m:language:${2}"; shift
        fi
        eval "${option}=0:${option:0:1}${filter}"
      fi;;
    --crf)
      test -z "${2-}" && exit_error "$1 requires an argument"
      crf="$2"; shift;;
    --tune)
      test -z "${2-}" && exit_error "$1 requires an argument"
      tune="-tune $2"; shift;;
    *)
      exit_error "Unknown option $1";;
  esac
  shift
done

# Print help if wrong number of arguments
if [ "$#" -ne 2 ]; then
  print_help
  exit 1
fi

# Check arguments
input_file="$(readlink -e "$1")" || exit_error "File $1 does not exist"
input_dir="$(dirname "$input_file")" || exit_error "Directory for $input_file does not exist"
input_filename="$(basename "$input_file")" || exit_error "File $input_file does not exist"
output_file="$(readlink -f "$2")" || exit_error "File $2 does not exist"
# Force output to be .mp4
output_file="${output_file%.*}.mp4"
output_dir="$(dirname "$output_file")" || exit_error "Directory for $output_file does not exist"
output_filename="$(basename "$output_file")" || exit_error "File $output_file does not exist"

# Create log directory
mkdir -p "$output_dir/log"
# Log file with timestamp
timestamp=$(date +%Y%m%d-%H%M%S)
log_file="log/ffmpeg-$timestamp-${output_filename%.*}.log"

echo "[INFO] Converting $input_filename" | tee -a "$output_dir/$log_file"

# Run ffmpeg in Docker
# https://docs.linuxserver.io/images/docker-ffmpeg/
#
# Parameters explained:
# -xerror - exit on error
# -map 0:v - map all video streams
# -map 0:a:m:language:fre - map only french audio streams
# -map -0:s - exclude all subtitle streams
# -movflags +faststart - move moov atom to the beginning of the file for faster playback start
# -preset slow - slower encoding for better compression
# -crf 23 - constant rate factor, lower is better quality (default 23)
# -profile:v high - h264 profile
# -x264opts - additional x264 options for better quality
# -force_key_frames "expr:gte(t,n_forced*3)" - force keyframes every 3 seconds
# -sc_threshold:v 0 - disable scene change detection for keyframes
# -vf format=yuv420p - ensure compatibility with most players
# -codec:a libfdk_aac - use libfdk_aac for better quality
# -ac 2 - stereo audio
# -b:a 192k - audio bitrate
# -f mp4 - output format
# -y - overwrite output file if exists
# -e FFREPORT="file=/output/${log_file}:level=32" - log ffmpeg output to file
docker run --rm -it \
  -v "$input_dir:/input" \
  -v "$output_dir:/output" \
  -e FFREPORT="file=/output/${log_file}:level=32" \
  linuxserver/ffmpeg \
  -xerror \
  -i "/input/$input_filename" \
  -map "$video" \
  -map "$audio" \
  -map "$subtitles" \
  -movflags +faststart \
  -preset slow \
  -codec:v libx264 \
  -crf "$crf" \
  -maxrate 8259125 \
  -bufsize 16518250 \
  -profile:v high \
  -x264opts subme=0:me_range=16:rc_lookahead=10:me=hex:open_gop=0 \
  -force_key_frames "expr:gte(t,n_forced*3)" \
  -sc_threshold:v 0 \
  $tune \
  -vf format=yuv420p \
  -codec:a libfdk_aac \
  -ac 2 \
  -b:a 192k \
  -f mp4 \
  -y \
  "/output/$output_filename"

echo "[SUCCESS] Converted to $output_file" | tee -a "$output_dir/$log_file"
