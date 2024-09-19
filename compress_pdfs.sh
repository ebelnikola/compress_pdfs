#!/bin/bash

# Default threshold (in KB)
threshold=200

# Function to display usage
usage() {
    echo "Usage: $0 [-t threshold_in_KB]"
    echo "  -t: Specify the size threshold in KB (default: 200KB)"
    exit 1
}

# Parse command line options
while getopts ":t:" opt; do
    case $opt in
        t) threshold=$OPTARG ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
        :) echo "Option -$OPTARG requires an argument." >&2; usage ;;
    esac
done

echo "Compressing PDFs larger than ${threshold}KB"

for pdf in *.pdf; do
    if [ -f "$pdf" ]; then
        size=$(du -k "$pdf" | cut -f1)
        if [ $size -gt $threshold ]; then
            echo "Processing: $pdf (Original size: ${size}KB)"
            temp_file="${pdf%.pdf}_temp.pdf"
            if gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$temp_file" "$pdf"; then
                new_size=$(du -k "$temp_file" | cut -f1)
                if [ $new_size -lt $size ]; then
                    mv "$temp_file" "$pdf"
                    echo "Compressed: $pdf (New size: ${new_size}KB)"
                else
                    echo "No size reduction for $pdf. Original file kept."
                    rm "$temp_file"
                fi
            else
                echo "Error compressing $pdf"
                [ -f "$temp_file" ] && rm "$temp_file"
            fi
        else
            echo "Skipping $pdf (Size: ${size}KB, below threshold)"
        fi
    fi
done