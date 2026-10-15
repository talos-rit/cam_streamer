"""Synthetic encoder throughput/CPU probe. Does not open the robot or camera."""
import json
import resource
import subprocess
import time

for size in ("640x480", "1280x720", "1920x1080"):
    for encoder in ("libx264", "h264_v4l2m2m"):
        command = ["ffmpeg", "-hide_banner", "-loglevel", "error", "-f", "lavfi", "-i",
                   f"testsrc2=size={size}:rate=30", "-frames:v", "90", "-c:v", encoder,
                   "-b:v", "3000k", "-g", "30", "-bf", "0"]
        if encoder == "libx264":
            command += ["-preset", "ultrafast", "-tune", "zerolatency"]
        command += ["-f", "null", "-"]
        before = resource.getrusage(resource.RUSAGE_CHILDREN)
        start = time.monotonic()
        result = subprocess.run(command, capture_output=True, timeout=20)
        elapsed = time.monotonic() - start
        after = resource.getrusage(resource.RUSAGE_CHILDREN)
        cpu = after.ru_utime + after.ru_stime - before.ru_utime - before.ru_stime
        print(json.dumps({"size": size, "encoder": encoder, "exit": result.returncode,
                          "fps": round(90 / elapsed, 1), "cpu_s": round(cpu, 2),
                          "elapsed_s": round(elapsed, 2), "error": result.stderr.decode()[-300:]}), flush=True)
