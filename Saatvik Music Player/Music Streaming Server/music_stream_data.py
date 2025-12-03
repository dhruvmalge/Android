from flask import Flask, jsonify, send_file, request
import os
from werkzeug.utils import secure_filename
from datetime import datetime, timedelta
import time 

app = Flask(__name__)
PORT = 5000
SERVER_IP = "0.0.0.0" 

MUSIC_DIRECTORY = "D:/MySongs/Music" #change your music directory
UPLOAD_FOLDER = "D:/My songs/Music/uploads"#Change your Upload folder 
ALLOWED_EXTENSIONS = ["mp3"]
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

songs_db = []
SONG_EXTENSIONS = ('.mp3', '.wav', '.ogg', '.flac') 
current_id = 1

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

def sanitize_folder_name(name):
    return name.lower().replace(' ', '').replace('-', '').replace('_', '')

KNOWN_CATEGORIES = ['uploads', 'artists', 'bhajans', 'party', 'gym', 'marathons', 'cooking']
RECENT_DAYS = 7 

def build_song_database():
    global songs_db, current_id
    songs_db.clear() 
    current_id = 1

    seven_days_ago = datetime.now() - timedelta(days=RECENT_DAYS)

    for dirpath, dirnames, filenames in os.walk(MUSIC_DIRECTORY):
        parent_folder = os.path.basename(dirpath)
        base_dir_name = os.path.basename(MUSIC_DIRECTORY)
        folder_tag = sanitize_folder_name(parent_folder)

        for filename in filenames:
            if filename.lower().endswith(SONG_EXTENSIONS):
                full_path = os.path.join(dirpath, filename)
                title = filename.rsplit('.', 1)[0]
                
                tags = []
                
                if folder_tag in KNOWN_CATEGORIES:
                    tags.append(folder_tag)
                
                artist_name = parent_folder
                if parent_folder == base_dir_name:
                    artist_name = "Various Artists"
                    tags.append('artists') 

                try:
                    file_mod_time = datetime.fromtimestamp(os.path.getmtime(full_path))
                    if file_mod_time > seven_days_ago:
                        tags.append('uploads')
                except OSError:
                    pass

                unique_tags = list(set(tags))
                
                songs_db.append({
                    "id": current_id,
                    "title": title,
                    "artist": artist_name,
                    "path": full_path,
                    "tags": unique_tags 
                })
                current_id += 1

    print(f"Loaded {len(songs_db)} songs. Last ID: {current_id - 1}")


@app.route('/songs', methods=['GET'])
def list_songs():
    
    category_id = request.args.get('category')
    filtered_list = songs_db

    if category_id and category_id.lower() != 'all':
        # Filter the global songs_db list based on the requested tag
        filtered_list = [s for s in songs_db if category_id.lower() in s.get('tags', [])]
        print(f"Filtering by category: {category_id}. Returning {len(filtered_list)} songs.")

    metadata_list = [
        {"id": s['id'], "title": s['title'], "artist": s['artist'], "tags": s['tags']} 
        for s in filtered_list
    ]
    return jsonify(metadata_list)


@app.route('/stream/<int:song_id>', methods=['GET'])
def stream_song(song_id):    
    quality = request.args.get('quality', '320kbps')
    song = next((s for s in songs_db if s['id'] == song_id), None)
    if song is None:
        return jsonify({"error": f"Song with ID {song_id} not found"}), 404
    try:
        return send_file(
            song['path'],
            mimetype='audio/mpeg', 
            as_attachment=False 
        )
    except FileNotFoundError:
        return jsonify({"error": f"Audio file not found at path: {song['path']}"}), 500
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route("/upload", methods=['POST'])
def upload_songs():
    if 'file' not in request.files:
        return jsonify({'message': 'No file part in the request'}), 400
    file = request.files['file']

    if file.filename == '':
        return jsonify({'message': 'No file selected for upload'}), 400
    
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        try:
            save_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            file.save(save_path)
            build_song_database() 
            return jsonify({
                'message': 'File uploaded successfully', 
                'filename': filename
            }), 200
        except Exception as e:
            return jsonify({'message': f'File save failed: {str(e)}'}), 500
            
    return jsonify({'message': 'File type not allowed or invalid file format'}), 400

if __name__ == '__main__':
    build_song_database()
    app.run(host=SERVER_IP, port=PORT, debug=True, threaded=True)
