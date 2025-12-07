from flask import Flask, request, jsonify
from flask_cors import CORS
import bcrypt
import uuid
import datetime
from db import get_connection  # <-- your db.py

app = Flask(__name__)
CORS(app, origins=["http://localhost:5173"])

# --- Endpoint to return building name list ---
@app.route("/buildings", methods=["GET"])
def get_buildings():
    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT BuildingName FROM Building;")
        rows = cursor.fetchall()
        
        buildingNames = [row['BuildingName'] for row in rows]
        response = {"success": True, "buildings":buildingNames}
    except Exception as e:
        response = {"success": False, "error": str(e)}
    finally:
        cursor.close()
        conn.close()
        
    return jsonify(response)



# --- Endpoint to create account ---
@app.route("/create_account", methods=["POST"])
def create_account():
    data = request.json
    email = data.get("email")
    password = data.get("password")
    fname = data.get("fname")
    lname = data.get("lname")
    user_type = data.get("type")
    extra1 = data.get("extra1")
    extra2 = data.get("extra2")
    has_graduated = data.get("hasGraduated", False)

    
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    hashed_password_str = hashed_password.decode('utf-8')

    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.callproc('AddAccount', [
            email, hashed_password_str, fname, lname,
            datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            user_type, extra1, extra2, has_graduated
        ])
        conn.commit()
        auth_token = str(uuid.uuid4())
        response = {"success": True, "auth_token": auth_token}
    except Exception as e:
        conn.rollback()
        response = {"success": False, "error": str(e)}
    finally:
        cursor.close()
        conn.close()

    return jsonify(response)

# --- Endpoint to log in a user ---
@app.route("/login", methods=["POST"])
def login():
    data = request.json
    user_email = data.get("email")
    user_password = data.get("password")
    conn = get_connection()
    cursor = conn.cursor()
    
    try:
        #query database for reviewerID and password
        cursor.execute("""
            SELECT ReviewerID, Password
            FROM Reviewer
            WHERE ReviewerID = %s
        """, (user_email,))
        
        row = cursor.fetchone()
        #if email isn't a match
        if not row:
            return jsonify({"success": False, "error": "Email not found"}), 400
        
        stored_hashed_password = row["Password"]

        # Compare the provided password with stored bcrypt hash
        if not bcrypt.checkpw(user_password.encode('utf-8'), stored_hashed_password.encode('utf-8')):
            return jsonify({"success": False, "error": "Incorrect password"}), 400

        # Authentication passed → generate auth token
        auth_token = str(uuid.uuid4())

        response = {
            "success": True,
            "auth_token": auth_token
        }
    except Exception as e:
        response = {"success": False, "error": str(e)}
    finally:
        cursor.close()
        conn.close()
    return jsonify(response)

# --- Endpoint to add a review ---
@app.route("/add_review", methods=["POST"])
def add_review():
    data = request.json
    review_id = data.get("review_id")
    num_stars = data.get("num_stars")
    description = data.get("description")
    reviewer_id = data.get("reviewer_id")
    building_name = data.get("building_name")

    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.callproc('AddReview', [
            review_id,
            datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            num_stars,
            description,
            reviewer_id,
            building_name
        ])
        conn.commit()
        response = {"success": True}
    except Exception as e:
        conn.rollback()
        response = {"success": False, "error": str(e)}
    finally:
        cursor.close()
        conn.close()

    return jsonify(response)

# --- Endpoint to rate a review ---
@app.route("/rate_review", methods=["POST"])
def rate_review():
    data = request.json
    reviewer_id = data.get("reviewer_id")
    review_id = data.get("review_id")
    rating = data.get("rating")

    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.callproc('RateReview', [
            reviewer_id, review_id, rating
        ])
        conn.commit()
        response = {"success": True}
    except Exception as e:
        conn.rollback()
        response = {"success": False, "error": str(e)}
    finally:
        cursor.close()
        conn.close()

    return jsonify(response)

# --- Endpoint to add a building ---
@app.route("/add_building", methods=["POST"])
def add_building():
    data = request.json
    building_name = data.get("building_name")
    address = data.get("address")
    year_built = data.get("year_built")

    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO Building (BuildingName, Address, YearBuilt) VALUES (%s, %s, %s)",
            (building_name, address, year_built)
        )
        conn.commit()
        response = {"success": True}
    except Exception as e:
        conn.rollback()
        response = {"success": False, "error": str(e)}
    finally:
        cursor.close()
        conn.close()

    return jsonify(response)

# --- Endpoint to add a special feature ---
@app.route("/add_special_feature", methods=["POST"])
def add_special_feature():
    data = request.json
    name = data.get("name")
    building_name = data.get("building_name")
    description = data.get("description")
    feature_type = data.get("type")
    hours = data.get("hours")

    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO SpecialFeature (Name, BuildingName, Description, Type, Hours) "
            "VALUES (%s, %s, %s, %s, %s)",
            (name, building_name, description, feature_type, hours)
        )
        conn.commit()
        response = {"success": True}
    except Exception as e:
        conn.rollback()
        response = {"success": False, "error": str(e)}
    finally:
        cursor.close()
        conn.close()

    return jsonify(response)




# --- Endpoint to find the top three rated buildings ---
@app.route("/top-buildings", methods=["GET"])
def top_buildings():
    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("""
            SELECT 
                b.BuildingName,
                AVG(r.NumStars) AS AvgRating
            FROM Building b
            LEFT JOIN WritesRevAbt w ON b.BuildingName = w.BuildingID
            LEFT JOIN Review r ON w.ReviewID = r.ReviewID
            GROUP BY b.BuildingName
            ORDER BY AvgRating DESC
            LIMIT 3;
        """)
        rows = cursor.fetchall()
        buildings = []

        for row in rows:
            # Construct an "image identifier" — frontend can combine with static folder
            image_name = f"{row['BuildingName']}.jpg"  # assume images are named exactly as building names
            buildings.append({
                "name": row['BuildingName'],
                "rating": float(row['AvgRating']) if row['AvgRating'] else 0,
                "image_name": image_name
            })

        response = {"success": True, "data": buildings}

    except Exception as e:
        response = {"success": False, "error": str(e)}
    finally:
        cursor.close()
        conn.close()

    return jsonify(response)



# --- Endpoint to get all info about a single building ---
@app.route("/buildings/<building_name>", methods=["GET"])
def get_building(building_name):
    conn = get_connection()
    cursor = conn.cursor()
    try:
        # Convert underscores to spaces for DB query
        building_name_db = building_name.replace("_", " ")

        # Get building info
        cursor.execute("SELECT * FROM Building WHERE BuildingName = %s", (building_name_db,))
        building = cursor.fetchone()
        if not building:
            return jsonify({"success": False, "error": "Building not found"}), 404

        # Get special features
        cursor.execute("SELECT * FROM SpecialFeature WHERE BuildingName = %s", (building_name_db,))
        features = cursor.fetchall()

        # Optionally, get reviews
        cursor.execute("""
            SELECT R.NumStars, R.Description, W.ReviewerID
            FROM Review R
            JOIN WritesRevAbt W ON R.ReviewID = W.ReviewID
            WHERE W.BuildingID = %s
        """, (building_name_db,))
        reviews = cursor.fetchall()

        response = {
            "success": True,
            "building": building,
            "features": features,
            "reviews": reviews
        }
    except Exception as e:
        response = {"success": False, "error": str(e)}
    finally:
        cursor.close()
        conn.close()

    return jsonify(response)



# --- Run the server ---
if __name__ == "__main__":
    app.run(debug=True, port=5000, host="0.0.0.0")
    CORS(app, origins=["http://localhost:5173"])