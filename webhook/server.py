from flask import Flask, json, request
from utils import *
import logging

api = Flask(__name__)
logging.basicConfig(level=logging.DEBUG)


SLACK_WEBHOOK_URL = os.environ["SLACK_WEBHOOK_URL"]

@api.route("/", methods=["POST"])
def post_webhook():
    data = json.loads(request.data)
    api.logger.info(data)
    for item in data["items"]:
        metadata = KubernetesMetadata(item)
        slack = SlackRequest(SLACK_WEBHOOK_URL)
        slack.send(metadata)
    return "OK", 200


if __name__ == "__main__":
    api.run(host="0.0.0.0")
