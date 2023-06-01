# Any common format to compressed M4A Audio Converter Script

This script is a bash script that automates the process of converting audio files to the WAV format and compressing them using fhgaacenc. It ensures that the input files are in the WAV format before compressing them with multiple threads with high speed.

## Requirements

- Wine: The script requires Wine to run fhgaacenc. Install the latest at https://wiki.winehq.org/Download.
- fhgaacenc: The fhgaacenc executable should be installed at ~/.wine/drive_c/fhgaacenc/fhgaacenc.exe.
Use https://www.andrews-corner.org/fhgaacenc.html for instructions.

## Usage

1. Place the script in the same folder as the audio files you want to convert.
2. Make the script executable by running the following command in the terminal:
   ```bash
   chmod +x fhgaacenc.sh

    Run the script by executing the following command:

    bash

    ./fhgaacenc.sh

The script will create the necessary output and temporary folders if they don't exist. It will then iterate over the audio files in the current folder, converting any non-WAV files to WAV format using FFmpeg. Finally, it will compress the WAV files using fhgaacenc and save the compressed files in the output folder.

Note: The script assumes that the input files have unique names. If an output file with the same name already exists, it will be overwritten. Also this program tries to use all of your threads to maximize conversion speed, to disable change the 'experimental_parallel_conversion' to 0 before runtime.
##License

This script is licensed under the MIT License.
