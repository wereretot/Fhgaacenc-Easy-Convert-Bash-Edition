#!/bin/bash

# Check if fhgaacenc is installed
if ! command -v wine &> /dev/null; then
    echo "Error: Wine is not installed. Please install Wine to use fhgaacenc."
    exit 1
fi

fhgaacenc_path="$HOME/.wine/drive_c/fhgaacenc/fhgaacenc.exe"

# Check if fhgaacenc executable exists
if [ ! -f "$fhgaacenc_path" ]; then
    echo "Error: fhgaacenc is not installed at $fhgaacenc_path. Please install fhgaacenc."
    exit 1
fi

# Create required folders if they don't exist
output_folder="output"
temp_folder="temp"
log_file="conversion_log.txt"

mkdir -p "$output_folder" "$temp_folder"

# Function to compress a WAV file using fhgaacenc
compress_with_fhgaacenc() {
    wav_file="$1"
    output_file="$2"

    wine "$fhgaacenc_path" --vbr 2 "$wav_file" "$output_file"
    echo "Compressed: $wav_file to $output_file" | tee -a "$log_file"
}

# Experimental toggle for parallel conversion (set to 1 to enable)
experimental_parallel_conversion=1

# Clear the log file if it exists
> "$log_file"

# Iterate over input files in the current directory
for input_file in *; do
    # Skip folders and non-audio files
    if [ -d "$input_file" ] || ! file -i "$input_file" | grep -q "audio/"; then
        continue
    fi

    # Check if the input file is not in WAV format
    if ! file -i "$input_file" | grep -q "audio/wav"; then
        # Convert non-WAV files to WAV format
        wav_file="${temp_folder}/${input_file%.*}.wav"

        # Skip conversion if the output file already exists
        if [ -f "$wav_file" ]; then
            echo "Skipping conversion for $input_file" | tee -a "$log_file"
        else
            ffmpeg -i "$input_file" -acodec pcm_s16le -ar 44100 "$wav_file" >/dev/null 2>&1
            echo "Converted: $input_file to $wav_file" | tee -a "$log_file"
        fi
    else
        # Move the input WAV file to the temporary folder if it doesn't exist there
        wav_file="${temp_folder}/${input_file}"
        if [ ! -f "$wav_file" ]; then
            mv "$input_file" "$wav_file"
            echo "Moved: $input_file to $wav_file" | tee -a "$log_file"
        fi
    fi

    # Compress the WAV file using fhgaacenc
    output_file="${output_folder}/${input_file%.*}.m4a"

    # Skip compression if the output file already exists
    if [ -f "$output_file" ]; then
        echo "Skipping compression for $wav_file" | tee -a "$log_file"
        continue
    fi

    if [ "$experimental_parallel_conversion" -eq 1 ]; then
        compress_with_fhgaacenc "$wav_file" "$output_file" &  # Run the compression process in the background
    else
        compress_with_fhgaacenc "$wav_file" "$output_file"
    fi
done

# Wait for background processes to finish if experimental parallel conversion is enabled
if [ "$experimental_parallel_conversion" -eq 1 ]; then
    wait
fi
