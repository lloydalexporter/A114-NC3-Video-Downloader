

microsoftStreamUsername="lap170@student.aru.ac.uk"


# Download the Microsoft Stream Video
function_videoIsMSStream () {

    # Check if Destreamer is installed.
    [[ -f ~/destreamer/destreamer.sh ]] || { printf "Destreamer is not installed\nVisit: https://github.com/snobu/destreamer\n" ; exit 1 ; }

    # Remove End of the Line
    editedLine=$(echo $Line | rev | cut -d? -f2 | rev)

    # Run Destreamer
    cd ~/destreamer
    ./destreamer.sh -u $microsoftStreamUsername -i $editedLine --format mp4 -cc true -o "$destinationDirectory"

    echo
    echo Download in progress...

    # Back to Current Directory
    cd "$destinationDirectory"
}





# Download the YouTube Video
function_videoIsYoutube () {

    # Get video title and format it.
    videoTitle=$(/opt/homebrew/bin/youtube-dl -f bestvideo+bestaudio "$videoURL" -o "%(title)s.%(ext)s" --get-title)
    videoTitle=$(echo $videoTitle | sed 's/["/]//g')

    # Set videoDownload Directory.
    downloadsFolder="/Users/$(whoami)/Downloads"
    videoDirectory="$downloadsFolder/$videoTitle"

    # Download the youtube video.
    $('/opt/homebrew/bin/youtube-dl' -k -f bestvideo+bestaudio "$videoURL" -o "$videoDirectory/$videoTitle.%(ext)s") & wait

    # Get the videos full title.
    videoFullTitle=$(ls "$videoDirectory" | grep -e "$videoTitle")

    # Check if the video is already an MP4 file, if not then convert it to one.
    if test $(ls "$videoDirectory" | grep -E "$videoTitle" | wc -l) -eq 2; then
        echo "Two files need combining: $(ls "$videoDirectory" | head -1) and $(ls "$videoDirectory" | tail -1)"
        '/opt/homebrew/bin/ffmpeg' -i "$videoDirectory/$(ls "$videoDirectory" | head -1)" -i "$videoDirectory/$(ls "$videoDirectory" | tail -1)" "$videoDirectory/$videoTitle.mp4" & wait
    elif [[ -f "$videoDirectory/$videoTitle.mp4" ]]; then
        var=''
    else
        '/opt/homebrew/bin/ffmpeg' -i "$videoDirectory/$videoFullTitle" "$videoDirectory/$videoTitle.mp4" & wait
    fi

    # Move the MP4 video file to the Downloads folder.
    /bin/mv "$videoDirectory/$videoTitle.mp4" "$downloadsFolder/$videoTitle.mp4" & wait

    # Remove the directory with any undeleted files.
    # /bin/rm -dr "$videoDirectory" & wait

    echo Done
    exit 0
}






# Check if we have any parameter supplied.
if [ $# -eq 0 ]; then
    # We don't have any parameters supplied: Ask until we do.
    videoURL=
	while [[ $videoURL == "" ]]
	do
		echo
        echo Enter the Video URL below:
		videoURL=
		read -p "" videoURL
        # If the input is a YouTube link, then continue, else we loop again.
        if [[ "$videoURL" != *"youtu.be"* ]] | [[ "$videoURL" != *"youtube.com"* ]] | [[ "$videoURL" != *"web.microsoftstream.com"* ]]; then
            echo
            echo Not a compatible video link, try again with a YouTube or Microsoft Stream link.
            videoURL=
        fi
	done
else
    # We do have a parameter supplied:
    videoURL="$1"
    # If the input is a YouTube link, then continue, else exit.
    if [[ "$videoURL" != *"youtu.be"* ]] | [[ "$videoURL" != *"youtube.com"* ]] | [[ "$videoURL" != *"web.microsoftstream.com"* ]]; then
        echo
        echo Not a compatible video link, try again with a YouTube or Microsoft Stream link.
        exit 1
    fi
fi


# IF contains a Microsoft Stream Domain, then run MS Function
if [[ "$videoURL" == *"web.microsoftstream.com"* ]]; then
    function_videoIsMSStream
# IF contains a YouTube Domain, then run YT-DL Function
elif [[ "$videoURL" == *"youtu.be"* ]] | [[ "$videoURL" == *"youtube.com"* ]]; then
    function_videoIsYoutube
fi




