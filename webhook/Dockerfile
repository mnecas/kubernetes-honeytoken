FROM python:3

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV SLACK_WEBHOOK_URL ${SLACK_WEBHOOK_URL}

CMD [ "python3", "./server.py" ]
