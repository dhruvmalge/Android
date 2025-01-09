import cv2
import numpy as np

# Load YOLO model
net = cv2.dnn.readNetFromDarknet("yolov3.cfg", "yolov3.weights")
layer_names = net.getLayerNames()
output_layers = [layer_names[i - 1] for i in net.getUnconnectedOutLayers()]

# Load class labels
with open("coco.names", "r") as f:
    classes = [line.strip() for line in f.readlines()]

# Classify plants based on simple color analysis (you can replace it with a more complex model)
def classify_plant_health(image):
    # Convert to grayscale for basic color analysis (you can improve this with AI models)
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # Simple threshold to classify plant health (this is a rudimentary approach)
    _, thresh = cv2.threshold(gray_image, 120, 255, cv2.THRESH_BINARY)

    # Count number of white pixels (potential healthy parts of the plant)
    white_pixels = np.sum(thresh == 255)

    if white_pixels > 50000:
        return "Healthy"
    elif white_pixels > 20000:
        return "Average"
    else:
        return "Poor"

# Function to detect objects like humans, cars, and birds
def detect_objects(frame):
    height, width, _ = frame.shape
    blob = cv2.dnn.blobFromImage(frame, 0.00392, (416, 416), (0, 0, 0), True, crop=False)
    net.setInput(blob)
    outputs = net.forward(output_layers)

    boxes = []
    confidences = []
    class_ids = []

    for output in outputs:
        for detection in output:
            scores = detection[5:]
            class_id = np.argmax(scores)
            confidence = scores[class_id]

            if confidence > 0.5:
                center_x = int(detection[0] * width)
                center_y = int(detection[1] * height)
                w = int(detection[2] * width)
                h = int(detection[3] * height)

                # Rectangle coordinates
                x = int(center_x - w / 2)
                y = int(center_y - h / 2)

                boxes.append([x, y, w, h])
                confidences.append(float(confidence))
                class_ids.append(class_id)

    # Apply Non-Maximum Suppression (NMS) to remove redundant boxes
    indexes = cv2.dnn.NMSBoxes(boxes, confidences, 0.5, 0.4)

    detected_objects = []

    if len(indexes) > 0:
        for i in indexes.flatten():
            x, y, w, h = boxes[i]
            label = classes[class_ids[i]]
            color = (0, 255, 0)  # Set color to green for simplicity

            # Draw the rectangle and label
            cv2.rectangle(frame, (x, y), (x + w, y + h), color, 2)
            cv2.putText(frame, label, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 1, color, 2)

            detected_objects.append(label)

    return detected_objects, frame

# Main function to capture video and process frame by frame
def monitor_farm():
    cap = cv2.VideoCapture(0)  # Use 0 for webcam or a file path for video

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        # Detect plants' health (this is just a placeholder)
        plant_health = classify_plant_health(frame)

        # Detect other objects like humans, cars, birds
        detected_objects, frame_with_objects = detect_objects(frame)

        # Display the results
        cv2.putText(frame_with_objects, f"Plant Health: {plant_health}", (10, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
        cv2.putText(frame_with_objects, f"Detected Objects: {', '.join(detected_objects)}", (10, 100), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)

        # Show the frame with detections
        cv2.imshow('Farm Monitor', frame_with_objects)

        # Break loop on 'q' key press
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    monitor_farm()
