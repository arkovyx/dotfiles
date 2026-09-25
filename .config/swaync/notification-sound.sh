#!/bin/bash

if [ $(swaync-client -D) = "false" ]; then
	paplay ~/.config/swaync/notification.mp3
    # paplay ~/.config/swaync/que_miras_bobo_solo.mp3
fi
