# Task ID: 2

**Title:** Configure GPU-enabled Docker Runtime on Remote Machine

**Status:** done

**Dependencies:** 1 ✓

**Priority:** high

**Description:** Verify and configure nvidia-docker2 runtime on 2-5880 to enable GPU access within containers, ensuring CUDA drivers are accessible to Isaac Lab.

**Details:**

Verify nvidia-docker2 installation: `docker info | grep nvidia`. Test GPU access: `docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi`. If missing, install nvidia-container-toolkit and restart docker daemon. Configure default runtime in /etc/docker/daemon.json if necessary. Ensure user xli4217 is in docker group.

**Test Strategy:**

VERIFIED 2026-02-22: COMPLETE with workaround. Host has 2x RTX 5880 with Driver 570.181. `docker info` shows 'nvidia runc'. Original --gpus all failed with NVML error. FIX FOUND: Use explicit device mapping instead of --gpus: `--device /dev/nvidia0:/dev/nvidia0 --device /dev/nvidia1:/dev/nvidia1 --device /dev/nvidiactl:/dev/nvidiactl --device /dev/nvidia-modeset:/dev/nvidia-modeset --device /dev/nvidia-uvm:/dev/nvidia-uvm`. Or use --runtime=nvidia with these devices.
