FROM python:3.8-slim
WORKDIR /app

COPY . /app/

RUN apt-get update && apt-get install -y curl

RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# RUN mkdir /logs
# RUN chmod 777 /logs

ENV FLASK_APP=app.py

CMD ["flask", "run", "--host=0.0.0.0", "--port=8080"]
