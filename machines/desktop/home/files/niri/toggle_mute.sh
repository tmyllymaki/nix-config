#!/bin/bash

# Toggle the mute state for your default microphone
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# Check the new state and play a corresponding sound
if wpctl get-mute @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED"; then
    # Sound cue for Muted (feel free to swap with your own .wav or .oga paths)
    pw-play /usr/share/sounds/freedesktop/stereo/message.oga &
else
    # Sound cue for Unmuted
    pw-play /usr/share/sounds/freedesktop/stereo/complete.oga &
fi
