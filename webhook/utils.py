from slack_sdk.webhook import WebhookClient
from abc import ABC, abstractmethod
import os


class Metadata(ABC):
    @abstractmethod
    def generate_slack_text(self) -> dict:
        pass

    def slack_text_to_block(self, text) -> dict:
        return (
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": text,
                },
            },
        )


class KubernetesMetadata(Metadata):
    def __init__(self, data=None) -> None:
        self.username = data["user"]["username"]
        self.error_msg = data["responseStatus"]["message"]
        self.method = data["requestURI"]
        self.caller_ip = data["sourceIPs"]
        self.agent = data.get("userAgent")


    def generate_slack_text(self) -> dict:
        SLACK_REPORT = os.environ.get("SLACK_REPORT", "")

        if SLACK_REPORT:
            return SLACK_REPORT.format(
                agent=self.agent,
                error_msg=self.error_msg,
                caller_ip=self.caller_ip,
                method=self.method,
            )

        return f"""K8S token "*{self.username}*" triggered\n*Metadata*:\n- IP: {self.caller_ip} \n- Method: {self.method}\n"""


class SlackRequest:
    def __init__(self, webhook_url: str) -> None:
        self.webhook_url = webhook_url
        self.client = WebhookClient(self.webhook_url)

    def send(self, metadata: Metadata):
        print(f"Sedning to: {self.webhook_url}")
        text = metadata.generate_slack_text()
        print(f"Sending blocks: {text}")
        response = self.client.send(
            text=f'Token triggered',
            blocks=metadata.slack_text_to_block(text),
        )
        print(f"Status: {response.status_code}")
        print(f"Body: {response.body}")
        return response
