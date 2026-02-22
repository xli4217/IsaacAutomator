# Task ID: 8

**Title:** Execute Full Training Run with Video Capture

**Status:** pending

**Dependencies:** 7

**Priority:** high

**Description:** Run the complete 500-iteration training process with video recording enabled, monitoring for successful completion and resource utilization.

**Details:**

Execute:
```bash
docker run --rm --gpus all \
  --name isaac_training \
  -v $(pwd)/results:/results \
  -e OMNI_KIT_ACCEPT_EULA=YES \
  isaac_automater:latest \
  /isaaclab/autorun.sh
```
Monitor with `docker logs -f isaac_training`. Watch for iteration counter (should reach 500/500), policy updates from SB3, and video encoding progress. Ensure container has sufficient shared memory (`--shm-size=16gb` if needed for video buffers).

**Test Strategy:**

VERIFIED 2026-02-22: NOT COMPLETE - Depends on Tasks 1-7. After Task 7 success with 50 iters: docker run --rm --gpus all --name isaac_training -v $(pwd)/results:/results -e OMNI_KIT_ACCEPT_EULA=YES isaac_automater /isaaclab/autorun.sh. Verify exit code 0, check 'Iteration 500/500' in logs, monitor nvidia-smi for memory (4-8GB typical).
