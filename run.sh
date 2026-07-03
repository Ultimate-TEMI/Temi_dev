#!/bin/bash

SESSION="temi_ros2"

# Kill existing session if already running
tmux kill-session -t $SESSION 2>/dev/null

# Create new session (detached) with Zenoh router first
tmux new-session -d -s $SESSION -n "zenoh"

# Tab 0: Zenoh router
tmux send-keys -t $SESSION:0 "ros2 run rmw_zenoh_cpp rmw_zenohd --config /home/temi/rmw_configs/fleetmanager.json5" C-m

# Give Zenoh a moment to start
sleep 2

# Pane/window 1: ros2 bringup
tmux new-window -t $SESSION -n "bringup"
tmux send-keys -t $SESSION:1 "ros2 launch temi_bringup bringup.launch.py namespace:=temi" C-m

# Create new window for each process instead of splitting

# This is the application to add images to the new locations
tmux new-window -t $SESSION -n "gallery"
tmux send-keys -t $SESSION:2 "python3 /home/temi/temi_addimgloc/gallery_dir/app.py" C-m

# This is the application to visualize the arrivals and departures of trains in the Minden train station
tmux new-window -t $SESSION -n "db_info"
tmux send-keys -t $SESSION:3 "python3 /home/temi/Temi_DBInfo/DB_App/app.py" C-m

# The following two ROS2 launches are the person detection and tracking pipelines
tmux new-window -t $SESSION -n "detection"
tmux send-keys -t $SESSION:4 "ros2 launch person_detection_ros detect.launch.py use_sim_time:=false use_rviz:=false namespace:=temi" C-m

tmux new-window -t $SESSION -n "tracker"
tmux send-keys -t $SESSION:5 "ros2 launch pdaf_tracker track.launch.py namespace:=temi use_sim_time:=false" C-m

tmux new-window -t $SESSION -n "closest_person_node"
tmux send-keys -t $SESSION:6 "ros2 run detections_utils_pkg closest_pose_selector_node --ros-args -r __ns:=/temi -p input_topic:=cartesian_detections_local -p output_topic:=closest_person" C-m

# A local Instance of the rosbridge suite to translate web messages into ROS2 topics, actions, servies, etc.
# tmux new-window -t $SESSION -n "temi_rosbridge_suite"
# tmux send-keys -t $SESSION:7 "ros2 launch rosbridge_server rosbridge_websocket_launch.xml namespace:=temi" C-m

tmux new-window -t $SESSION -n "tf_aggregator"
tmux send-keys -t $SESSION:7 "ros2 run tf_aggregator tf_aggregator_node --ros-args -p input_topic:=/temi/tf -p output_topic:=/tf -p static_input_topic:=/temi/tf_static -p publish_rate:=30.0 -p max_age:=5.0 -p keep_original_stamp:=true -p include_static_in_tf:=true -r __ns:=/temi" C-m

tmux new-window -t $SESSION -n "temi_vizanti_rosbridge"
tmux send-keys -t $SESSION:8 "ros2 launch vizanti_server vizanti_server.launch.py namespace:=temi" C-m

tmux new-window -t $SESSION -n "placement"
tmux send-keys -t $SESSION:9 "ros2 launch robot_placement_ros start.launch.py use_sim_time:=false" C-m

# Attach directly to the Zenoh tab/window
tmux select-window -t $SESSION:0

# Attach to session
tmux attach-session -t $SESSION
