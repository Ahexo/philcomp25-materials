import os
import cv2
import mediapipe as mp
import numpy as np
from pathlib import Path

mp_face = mp.solutions.face_detection


def crop_face_with_shoulders(
    img, out_size=512, shoulder_scale=2, face_y_offset=0.5, min_confidence=0.4
):
    h, w = img.shape[:2]
    rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    with mp_face.FaceDetection(
        model_selection=1, min_detection_confidence=min_confidence
    ) as detector:
        results = detector.process(rgb)
    if not results.detections:
        return None
    det = results.detections[0].location_data.relative_bounding_box
    x = det.xmin * w
    y = det.ymin * h
    bw = det.width * w
    bh = det.height * h
    cx = x + bw / 2
    cy = y + bh / 2

    square = int(max(bw, bh * shoulder_scale))
    top = int(cy - square * face_y_offset)
    left = int(cx - square / 2)
    bottom = top + square
    right = left + square

    pad_top = max(0, -top)
    pad_left = max(0, -left)
    pad_bottom = max(0, bottom - h)
    pad_right = max(0, right - w)

    if any((pad_top, pad_left, pad_bottom, pad_right)):
        img = cv2.copyMakeBorder(
            img, pad_top, pad_bottom, pad_left, pad_right, borderType=cv2.BORDER_REFLECT
        )
        top += pad_top
        left += pad_left
        bottom += pad_top
        right += pad_left

    crop = img[top:bottom, left:right]
    if crop.size == 0:
        return None
    crop_resized = cv2.resize(crop, (out_size, out_size), interpolation=cv2.INTER_AREA)
    return crop_resized


def batch_process_photos(
    input_dir=".",
    output_dir="output",
    out_size=512,
    shoulder_scale=2,
    face_y_offset=0.5,
    min_confidence=0.4,
    recursive=False,
):
    input_path = Path(input_dir)
    out_path = input_path / output_dir
    out_path.mkdir(parents=True, exist_ok=True)

    exts = ("*.jpg", "*.jpeg", "*.png")
    files = []
    for ext in exts:
        if recursive:
            files.extend(input_path.rglob(ext))
        else:
            files.extend(input_path.glob(ext))

    files = [p for p in files if p.is_file() and out_path not in p.parents]

    for p in files:
        try:
            img = cv2.imread(str(p))
            if img is None:
                print(f"skipping unreadable: {p.name}")
                continue
            cropped = crop_face_with_shoulders(
                img,
                out_size=out_size,
                shoulder_scale=shoulder_scale,
                face_y_offset=face_y_offset,
                min_confidence=min_confidence,
            )
            if cropped is None:
                print(f"no face detected: {p.name}")
                continue
            out_file = out_path / (p.stem + ".jpg")
            # Save as JPEG with quality 95
            cv2.imwrite(str(out_file), cropped, [int(cv2.IMWRITE_JPEG_QUALITY), 95])
            print(f"saved: {out_file.name}")
        except Exception as e:
            print(f"error processing {p.name}: {e}")


if __name__ == "__main__":
    # When run from photos/ folder, this will read images and write to photos/output
    batch_process_photos(input_dir=".", output_dir="output", out_size=512)
