import bcrypt
import uuid
import datetime
from db import get_connection  # <-- your db.py

def insertAuthToken(reviewerID, auth_token):
    conn = get_connection()
    cursor = conn.cursor()
    response = ""
    try:
        #if the auth token exists, update, if not store
        cursor.execute("REPLACE INTO AuthToken (ReviewerID, Token) VALUES (%s %s)", (reviewerID, auth_token))
        conn.commit()
        response = "success"
    except Exception as e:
        conn.rollback()
        response = "error"
    finally:
        cursor.close()
        conn.close()
        
    return response