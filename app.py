from flask import Flask, jsonify
from datetime import datetime
import timezone as full_timezonelist
import pytz

currenttime_app = Flask(__name__)

@currenttime_app.route("/", methods=["GET"])
def home():
    return jsonify({
        "message": "Automate All The Things",
        "current_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    })

@currenttime_app.route("/<region>", methods=["GET"])
def get_time(region):
    timezone_name = full_timezonelist.timezones.get(region.lower(), "UTC")  # Fallback to UTC if region is not found
    timezone = pytz.timezone(timezone_name)
    current_time = datetime.now(timezone).strftime("%Y-%m-%d %H:%M:%S")
    return jsonify({
        "message": f"Automate All The Things: Current time in {region.capitalize()}",
        "current_time": current_time
    })

@currenttime_app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    })

if __name__ == "__main__":
    currenttime_app.run(host="0.0.0.0", port=8080)