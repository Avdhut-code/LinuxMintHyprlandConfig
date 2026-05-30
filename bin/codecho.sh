#!/bin/bash

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -v, --version       Show the script version"
    echo "  --play [FILE]       Play the specified video file using Celluloid"
    echo ""
    echo "Examples:"
    echo "  $0 --play  /path/to/video.mp4"
    echo "  $0 --play, -p           Play the default video"
    echo "  $0 --version , -v"
}

play_video() {
    FILE="$1"
    if [ -z "$FILE" ]; then
        echo "No file provided. Falling back to the default video: $DEFAULT_FILE"
        FILE="$DEFAULT_FILE"
    fi

    if [ -f "$FILE" ]; then
        echo "Playing video: $FILE"
	    nohup mpv "$FILE" > /dev/null 2>&1 &
        echo "Video is playing in the background. You can close the terminal."
    else
        echo "Error: File '$FILE' does not exist. Please check the path or update the default file."
        exit 1
    fi
}

if [ "$#" -eq 0 ]; then
    echo "Error: No arguments provided."
    show_help
    exit 1
fi

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            echo "$0 version 0.0.1"
            exit 0
            ;;
        --play | -p )
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                play_video "$2"
                shift
            else
                play_video
            fi
            ;;
        *)
            echo "Error: Unknown option '$1'"
            show_help
            exit 1
            ;;
    esac
    shift
done

