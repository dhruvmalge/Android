import cv2
import numpy as np
import tensorflow as tf
from flask import Flask, Response, jsonify
from flask_cors import CORS
import datetime
import time

app = Flask(__name__)
CORS(app)

cap = cv2.VideoCapture(0)
cap.set(3, 520)  # Width
cap.set(4, 520)  # Height

# Load Plant Disease Model
plant_disease_model = tf.keras.models.load_model('plant_disease_model.h5')

# Load YOLOv3 Model
yolo_net = cv2.dnn.readNet("yolov3.weights", "yolov3.cfg")
yolo_net.setPreferableBackend(cv2.dnn.DNN_BACKEND_CUDA)
yolo_net.setPreferableTarget(cv2.dnn.DNN_TARGET_CUDA)

layer_names = yolo_net.getLayerNames()
output_layers = [layer_names[i - 1] for i in yolo_net.getUnconnectedOutLayers()]

with open("coco.names", "r") as f:
    classes = [line.strip() for line in f.readlines()]

streaming = True

latest_data = {
    "confidence": 0,
    "predicted_disease": "None",
    "actual_disease": "None",  # Placeholder for actual disease if available
    "disease_severity": "Healthy",
    "detected_objects": [],
    "datetime": str(datetime.datetime.now()),
    "fps": 0  # To store FPS
}

DISEASE_THRESHOLD = 0.75
USE_DEEP_LEARNING = True  # Set this to False to bypass deep learning

# Expanded plant disease labels list
disease_labels = [
    'Healthy', 'Rust', 'Grey Mold', 'Yellow Leaf Spot', 'Bacterial Blight',
    'Fungal Infection', 'Worm Damage', 'Powdery Mildew', 'Downy Mildew', 'Anthracnose',
    'Leaf Spot', 'Blight', 'Wilt', 'Leaf Curl', 'Mosaic Virus'
]

def preprocess_plant_image(frame):
    # Preprocess the image for the plant disease model
    frame_resized = cv2.resize(frame, (256, 256))
    frame_rgb = cv2.cvtColor(frame_resized, cv2.COLOR_BGR2RGB)
    frame_normalized = frame_rgb / 255.0
    return np.expand_dims(frame_normalized, axis=0)

def detect_plant_disease(frame):
    if USE_DEEP_LEARNING:
        # Detect plant disease from the frame using deep learning model
        preprocessed_frame = preprocess_plant_image(frame)
        predictions = plant_disease_model.predict(preprocessed_frame)
        
        predicted_class = np.argmax(predictions, axis=1)
        predicted_disease = disease_labels[predicted_class[0]]
        confidence = np.max(predictions)

        # Set severity level based on confidence
        disease_severity = "Healthy"
        if confidence >= DISEASE_THRESHOLD:
            disease_severity = "Severe"
        elif confidence >= 0.5:
            disease_severity = "Moderate"
        else:
            disease_severity = "Mild"

        return predicted_disease, confidence, disease_severity
    else:
        return "Healthy", 0, "Healthy"  # Default return when deep learning is not used

def detect_objects_yolo(frame):
    if frame is None or frame.size == 0:
        raise ValueError("Invalid frame for YOLO detection")

    height, width, channels = frame.shape
    blob = cv2.dnn.blobFromImage(frame, 0.00392, (416, 416), (0, 0, 0), True, crop=False)
    yolo_net.setInput(blob)
    outs = yolo_net.forward(output_layers)

    class_ids = []
    confidences = []
    boxes = []

    for out in outs:
        for detection in out:
            scores = detection[5:]
            class_id = np.argmax(scores)
            confidence = scores[class_id]
            if confidence > 0.5:
                center_x = int(detection[0] * width)
                center_y = int(detection[1] * height)
                w = int(detection[2] * width)
                h = int(detection[3] * height)

                x = int(center_x - w / 2)
                y = int(center_y - h / 2)

                boxes.append([x, y, w, h])
                confidences.append(float(confidence))
                class_ids.append(class_id)

    indices = cv2.dnn.NMSBoxes(boxes, confidences, score_threshold=0.5, nms_threshold=0.4)

    final_boxes = []
    final_class_ids = []
    final_confidences = []
    if len(indices) > 0:
        for i in indices.flatten():
            final_boxes.append(boxes[i])
            final_class_ids.append(class_ids[i])
            final_confidences.append(confidences[i])

    return final_class_ids, final_confidences, final_boxes

def generate_frames_camera():
    global latest_data
    fps_target = 1 / 30  # Target 30 FPS
    colors = [(0, 255, 0), (255, 0, 0), (0, 0, 255), (0, 255, 255)]

    while True:
        start_time = time.time()

        success, frame = cap.read()
        if not success:
            print("Failed to capture frame from camera")
            break

        frame = cv2.flip(frame, 1)

        # Object Detection (YOLO)
        class_ids, confidences, boxes = detect_objects_yolo(frame)

        detected_objects = []
        for i in range(len(class_ids)):
            label = str(classes[class_ids[i]])
            confidence = confidences[i]
            x, y, w, h = boxes[i]
            color = colors[class_ids[i] % len(colors)]
            cv2.rectangle(frame, (x, y), (x + w, y + h), color, 2)
            cv2.putText(frame, f"{label} {confidence:.2f}", (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
            detected_objects.append(f"{label}: {confidence:.2f}")

        latest_data["detected_objects"] = detected_objects
        latest_data["datetime"] = str(datetime.datetime.now())

        # After object detection, process plant disease detection
        predicted_disease, disease_confidence, disease_severity = detect_plant_disease(frame)
        latest_data["confidence"] = float(disease_confidence)
        latest_data["predicted_disease"] = predicted_disease
        latest_data["actual_disease"] = "Rust"  # Placeholder for actual disease (can be updated)
        latest_data["disease_severity"] = disease_severity

        # Calculate FPS
        elapsed_time = time.time() - start_time
        fps = 1 / elapsed_time
        latest_data["fps"] = round(fps, 2)

        # Encode Frame
        ret, buffer = cv2.imencode('.jpg', frame)
        if not ret:
            print("Failed to encode frame")
            continue

        frame = buffer.tobytes()

        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n\r\n')

        sleep_time = max(0, fps_target - elapsed_time)
        time.sleep(sleep_time)

@app.route('/video_feed.mp4')
def video_feed():
    return Response(generate_frames_camera(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/data')
def get_latest_data():
    return jsonify(latest_data)

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, threaded=True, debug=True)
