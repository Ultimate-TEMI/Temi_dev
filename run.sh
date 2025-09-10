#!/bin/bash

SESSION="temi_ros2"


# Kill existing session if already running
tmux kill-session -t $SESSION 2>/dev/null

# Create new session (detached)
tmux new-session -d -s $SESSION -n "bringup"

# Pane 1: ros2 bringup
tmux send-keys -t $SESSION "ros2 launch temi_bringup bringup.launch.py namespace:=temi" C-m

# Create new window for each process instead of splitting
tmux new-window -t $SESSION -n "gallery"
tmux send-keys -t $SESSION:1 "python3 /home/temi/gallery_dir/app.py" C-m

tmux new-window -t $SESSION -n "detection"
tmux send-keys -t $SESSION:2 "ros2 launch person_detection_ros detect.launch.py use_sim_time:=false use_rviz:=false namespace:=temi" C-m

tmux new-window -t $SESSION -n "tracker"
tmux send-keys -t $SESSION:3 "ros2 launch pdaf_tracker track.launch.py namespace:=temi use_sim_time:=false" C-m

# Attach to session
tmux attach-session -t $SESSION
