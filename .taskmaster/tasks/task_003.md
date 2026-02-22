# Task ID: 3

**Title:** Create autorun.sh Training Automation Script

**Status:** in-progress

**Dependencies:** 2 ✓

**Priority:** high

**Description:** Develop the automation script that executes Isaac Lab training with specified parameters for headless operation and video recording.

**Details:**

Create script at `/workspace/isaaclab/autorun.sh` inside container context:
```bash
#!/bin/bash
set -e

# Run Isaac Lab training with GPU and video recording
# Use explicit device mapping (--gpus fails on 2-5880)
docker run --rm --runtime=nvidia \
  --device /dev/nvidia0:/dev/nvidia0 \
  --device /dev/nvidia1:/dev/nvidia1 \
  --device /dev/nvidiactl:/dev/nvidiactl \
  --device /dev/nvidia-modeset:/dev/nvidia-modeset \
  --device /dev/nvidia-uvm:/dev/nvidia-uvm \
  -e ACCEPT_EULA=Y \
  -e OMNI_ENV_PRIVACY_CONSENT=1 \
  -v /home/xli4217/IsaacAutomator/results:/results \
  -w /workspace/isaaclab \
  nvcr.io/nvidia/isaac-lab:2.3.0 \
  /workspace/isaaclab/isaaclab.sh -p \
  /workspace/isaaclab/scripts/reinforcement_learning/sb3/train.py \
  --task Isaac-Cartpole-v0 \
  --headless \
  --enable_cameras \
  --video \
  --video_length 200 \
  --video_interval 2000 \
  --max_iterations 5 \
  --num_envs 64

# Videos saved to: logs/sb3/Isaac-Cartpole-v0/videos (default)
# NOT /results/videos/train (--video_dir flag not working)
```
Make executable: `chmod +x /workspace/isaaclab/autorun.sh`.

**Test Strategy:**

VERIFIED 2026-02-22: IN PROGRESS - Multiple issues found and fixed. 

FINDINGS:
1. Path fixed: Scripts at /workspace/isaaclab/scripts/reinforcement_learning/sb3/train.py (NOT /isaaclab/)
2. Must use wrapper: /workspace/isaaclab/isaaclab.sh -p <script> (not direct python)
3. GPU access: Use explicit device mapping (--device /dev/nvidia0:/dev/nvidia0 etc) instead of --gpus
4. Video dir: Default is logs/sb3/<task>/videos, NOT /results/videos/train (--video_dir may not work)
5. Default num_envs is very high (4096) - may need --num_envs 64 for faster testing

UPDATES MADE:
- scripts/autorun.sh: Changed to /workspace/isaaclab paths
- Changed default MAX_ITERATIONS to 5
- Added explicit GPU device mapping for 2-5880
- Changed working dir to /workspace/isaaclab

NEXT: Run with correct video output path or mount logs directory
