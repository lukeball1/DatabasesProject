from flask import Flask, jsonify, request 

app = Flask(__name__)   

#route is wrong, determine new route to return list of all builidng names
@app.route("/buildings", methods=["GET"])
def getAllBuildings():
    #return json list of all building names
    print("return list of all building names")

#Make new route to return specific building information from database depending on what the building name is




if __name__ == "__main__":
    app.run(debug=True)