# Python runtime parent image
FROM python:3.9-slim

# Working directory
WORKDIR /app

# Copy current directory content into container
COPY . .

# Install required Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Make port 80 available to the world outside this container
EXPOSE 80

# Define the command to run the application
CMD ["python", "app.py"]