#!/bin/bash

# Isaac Lab Training Automation Script
# This script runs Isaac Lab training with GPU acceleration and video recording

set -e

# Configuration - can be overridden via environment variables
CUDA_DEVICE="${CUDA_VISIBLE_DEVICES:-0}"
TASK="${TASK:-Isaac-Cartpole-v0}"
HEADLESS="${HEADLESS:---headless}"
VIDEO="${VIDEO:---video}"
VIDEO_LENGTH="${VIDEO_LENGTH:-200}"
VIDEO_INTERVAL="${VIDEO_INTERVAL:-2000}"
MAX_ITERATIONS="${MAX_ITERATIONS:-5}"
VIDEO_DIR="${VIDEO_DIR:-/results/videos/train}"
CONTAINER_IMAGE="${CONTAINER_IMAGE:-nvcr.io/nvidia/isaac-lab:2.3.0}"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --task)
            TASK="$2"
            shift 2
            ;;
        --headless)
            HEADLESS="--headless"
            shift
            ;;
        --no-headless)
            HEADLESS=""
            shift
            ;;
        --video)
            VIDEO="--video"
            shift
            ;;
        --no-video)
            VIDEO=""
            shift
            ;;
        --video-length)
            VIDEO_LENGTH="$2"
            shift 2
            ;;
        --video-interval)
            VIDEO_INTERVAL="$2"
            shift 2
            ;;
        --max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        --video-dir)
            VIDEO_DIR="$2"
            shift 2
            ;;
        --gpu)
            CUDA_DEVICE="$2"
            shift 2
            ;;
        --container-image)
            CONTAINER_IMAGE="$2"
            shift 2
            ;;
        --help)
            echo "Isaac Lab Training Script"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --task TASK               RL task to run (default: Isaac-Cartpole-v0)"
            echo "  --headless                Run in headless mode (default)"
            echo "  --no-headless             Run with display"
            echo "  --video                   Enable video recording (default)"
            echo "  --no-video                Disable video recording"
            echo "  --video-length LENGTH     Video length in frames (default: 200)"
            echo "  --video-interval INTERVAL Frames between videos (default: 2000)"
            echo "  --max-iterations NUM      Maximum training iterations (default: 500)"
            echo "  --video-dir DIR           Directory for video output (default: /results/videos/train)"
            echo "  --gpu GPU                 GPU device ID (default: 0)"
            echo "  --container-image IMAGE   Docker image to use (default: nvcr.io/nvidia/isaac-lab:2.3.0)"
            echo "  --help                    Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Validate environment
if ! command -v docker &> /dev/null; then
    echo "Error: docker is not installed"
    exit 1
fi

# Check for GPU access
if ! docker info &> /dev/null && ! docker info | grep -q nvidia; then
    echo "Warning: nvidia runtime not detected. GPU training may not work."
fi

# Create video directory locally if it doesn't exist
LOCAL_VIDEO_DIR="./results/videos/train"
mkdir -p "$LOCAL_VIDEO_DIR"

echo "Starting Isaac Lab training..."
echo "  Task: $TASK"
echo "  Image: $CONTAINER_IMAGE"
echo "  GPU: $CUDA_DEVICE"
echo "  Max iterations: $MAX_ITERATIONS"
echo "  Video: $VIDEO (length: $VIDEO_LENGTH, interval: $VIDEO_INTERVAL)"
echo ""

# Run Isaac Lab training container
# Note: ACCEPT_EULA is required for NVIDIA Isaac Lab container
# Note: Using explicit device mapping as --gpus flag has issues on 2-5880
docker run --rm \
    --runtime=nvidia \
    --device /dev/nvidia0:/dev/nvidia0 \
    --device /dev/nvidia1:/dev/nvidia1 \
    --device /dev/nvidiactl:/dev/nvidiactl \
    --device /dev/nvidia-modeset:/dev/nvidia-modeset \
    --device /dev/nvidia-uvm:/dev/nvidia-uvm \
    -e ACCEPT_EULA=Y \
    -e CUDA_VISIBLE_DEVICES="$CUDA_DEVICE" \
    -e OMNI_ENV_PRIVACY_CONSENT=1 \
    -v "$(pwd)/results:/results" \
    -w /workspace/isaaclab \
    "$CONTAINER_IMAGE" \
    python /workspace/isaaclab/scripts/reinforcement_learning/sb3/train.py \
        --task "$TASK" \
        $HEADLESS \
        --enable_cameras \
        $VIDEO \
        --video_length "$VIDEO_LENGTH" \
        --video_interval "$VIDEO_INTERVAL" \
        --max_iterations "$MAX_ITERATIONS" \
        --video_dir "$VIDEO_DIR"

echo ""
echo "Training completed successfully"
echo "Videos saved to: $LOCAL_VIDEO_DIR"
