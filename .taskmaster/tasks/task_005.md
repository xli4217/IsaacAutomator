# Task ID: 5

**Title:** Update Dockerfile with Video Encoding Dependencies

**Status:** pending

**Dependencies:** 4

**Priority:** high

**Description:** Modify the isaac_automater Dockerfile to include ffmpeg and video codec libraries required for MP4 generation in Isaac Lab 2.3.1.

**Details:**

Update Dockerfile:
```dockerfile
FROM nvcr.io/nvidia/isaac-lab:2.3.1

# Install video encoding dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libx264-dev \
    libx265-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy automation script
COPY autorun.sh /isaaclab/autorun.sh
RUN chmod +x /isaaclab/autorun.sh

# Create results directory
RUN mkdir -p /results/videos/train

WORKDIR /isaaclab
ENTRYPOINT ["/bin/bash"]
```
Build with tag `isaac_automater:latest`. Ensure compatibility with Isaac Lab's Omniverse dependencies.

**Test Strategy:**

VERIFIED 2026-02-22: COMPLETE in Dockerfile.isaaclab lines 5-8: RUN apt-get update && apt-get install -y ffmpeg libx264-dev libx265-dev. Image was NEVER BUILT. After Task 1: docker build -f Dockerfile.isaaclab -t isaac_automater:latest . then docker run --rm isaac_automater ffmpeg -version
