from flask import Flask, request, jsonify
import bcrypt
import uuid
import datetime
from db import get_connection  # <-- your db.py

app = Flask(__name__)

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

    hashed_email = bcrypt.hashpw(email.encode('utf-8'), bcrypt.gensalt())
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    hashed_email_str = hashed_email.decode('utf-8')
    hashed_password_str = hashed_password.decode('utf-8')

    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.callproc('AddAccount', [
            hashed_email_str, hashed_password_str, fname, lname,
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

# --- Run the server ---
if __name__ == "__main__":
    app.run(debug=True, port=5000)