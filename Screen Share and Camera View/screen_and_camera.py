import cv2
import random
import numpy as np
import pyautogui
import time
import mediapipe as mp
from flask import Flask, Response, render_template_string
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

cap = cv2.VideoCapture(0)  # Use the default camera (0)
cap.set(3, 520)  # Width
cap.set(4, 520)  # Height

# Initialize YOLO for object detection
yolo_net = cv2.dnn.readNet("yolov3.weights", "yolov3.cfg")
yolo_net.setPreferableBackend(cv2.dnn.DNN_BACKEND_CUDA)
yolo_net.setPreferableTarget(cv2.dnn.DNN_TARGET_CUDA)

layer_names = yolo_net.getLayerNames()
output_layers = [layer_names[i - 1] for i in yolo_net.getUnconnectedOutLayers()]

with open("coco.names", "r") as f:
    classes = [line.strip() for line in f.readlines()]

# Initialize MediaPipe Hand Tracking
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(min_detection_confidence=0.7, min_tracking_confidence=0.5)
mp_drawing = mp.solutions.drawing_utils

# Initialize MediaPipe Face Mesh
mp_face_mesh = mp.solutions.face_mesh
face_mesh = mp_face_mesh.FaceMesh(min_detection_confidence=0.7, min_tracking_confidence=0.5)

# Initialize MediaPipe Pose Estimation
mp_pose = mp.solutions.pose
pose = mp_pose.Pose(min_detection_confidence=0.7, min_tracking_confidence=0.5)

streaming = True 

def capture_screen():
    screenshot = pyautogui.screenshot()
    img = np.array(screenshot)
    img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)
    ret, jpeg = cv2.imencode('.jpg', img)
    return jpeg.tobytes()

def generate_frames_camera():
    while True:
        success, frame = cap.read()
        if not success:
            break
        
        frame = cv2.flip(frame, 1)

        # Convert the frame to RGB for MediaPipe processing
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

        # Hand tracking
        result_hands = hands.process(rgb_frame)
        if result_hands.multi_hand_landmarks:
            for hand_landmarks in result_hands.multi_hand_landmarks:
                mp_drawing.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)

        # Face Mesh tracking
        result_face = face_mesh.process(rgb_frame)
        if result_face.multi_face_landmarks:
            for face_landmarks in result_face.multi_face_landmarks:
                mp_drawing.draw_landmarks(frame, face_landmarks, mp_face_mesh.FACEMESH_TESSELATION)

        # Pose Estimation
        result_pose = pose.process(rgb_frame)
        if result_pose.pose_landmarks:
            mp_drawing.draw_landmarks(frame, result_pose.pose_landmarks, mp_pose.POSE_CONNECTIONS)

        # YOLO object detection
        blob = cv2.dnn.blobFromImage(frame, 0.00392, (416, 416), (0, 0, 0), True, crop=False)
        yolo_net.setInput(blob)
        outputs = yolo_net.forward(output_layers)
        
        class_ids = []
        confidences = []
        boxes = []
        height, width, channels = frame.shape

        for out in outputs:
            for detection in out:
                scores = detection[5:]
                class_id = np.argmax(scores)
                confidence = scores[class_id]
                if confidence > 0.2:                      
                    center_x = int(detection[0] * width)
                    center_y = int(detection[1] * height)
                    w = int(detection[2] * width)
                    h = int(detection[3] * height)

                    x = int(center_x - w / 2)
                    y = int(center_y - h / 2)

                    boxes.append([x, y, w, h])
                    confidences.append(float(confidence))
                    class_ids.append(class_id)
        
        indices = cv2.dnn.NMSBoxes(boxes, confidences, 0.2, 0.2)         
        if len(indices) > 0:
            for i in indices.flatten():
                x, y, w, h = boxes[i]
                randColor = (random.randint(0, 255), random.randint(0, 255), random.randint(0, 255))
                
                x, y, w, h = int(x), int(y), int(w), int(h)

                frame = cv2.rectangle(frame, (x, y), (x + w, y + h), color=randColor, thickness=3)

                label = classes[class_ids[i]]
                frame = cv2.putText(frame, label, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, randColor, 2)

        # Convert frame to bytes for Flask
        ret, buffer = cv2.imencode('.jpg', frame)
        if not ret:
            continue
    
        frame = buffer.tobytes()

        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n\r\n')

def generate_frames_screen():
    global streaming
    while streaming:
        frame = capture_screen()
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n\r\n')
        time.sleep(0.1)

@app.route('/video_feed.mp4')
def video_feed_camera():
    return Response(generate_frames_camera(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/screen_feed.mp4')
def video_feed_screen():
    return Response(generate_frames_screen(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/')
def index():
    return render_template_string('''
        <html>
            <body>
                <h1>Choose Stream</h1>
                <h2>Camera Stream</h2>
                <img src="/video_feed.mp4" width="640" height="480"/>
                <h2>Screen Share Stream</h2>
                <img src="/screen_feed.mp4" width="100%"/>
                <br>
                <form action="/stop_stream" method="post">
                    <button type="submit">Stop Screen Share</button>
                </form>
            </body>
        </html>
    ''')

@app.route('/stop_stream', methods=['POST', 'GET'])
def stop_stream():
    global streaming
    streaming = False
    return '''
        <h1>Screen Share Stopped</h1>
        <p><a href="/">Go back</a></p>
    '''

@app.route('/stop_camera', methods=['POST', 'GET'])
def stop_camera():
    global streaming
    streaming = False
    cap.release()
    return '''
        <h1>Camera Stream Stopped</h1>
        <p><a href="/">Go back</a></p>
   '''

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000, threaded=True)

cap.release()
cv2.destroyAllWindows()
