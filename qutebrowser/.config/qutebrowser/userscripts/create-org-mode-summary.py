#!/home/iocanel/.config/qutebrowser/userscripts/.venv/bin/python3

import os
import sys
import json
import openai
import subprocess
import logging

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
PAGE_CONTENT_FILE = os.getenv('QUTE_TEXT')
LOG_FILE = "/home/iocanel/.local/share/qutebrowser/log/create-summary.log"
SUMMARY_FILE="/home/iocanel/.local/share/qutebrowser/summary.org"

os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

os.makedirs(os.path.dirname(SUMMARY_FILE), exist_ok=True)

def get_page_content():
    """Read the page content from a file."""
    with open(PAGE_CONTENT_FILE, "r") as f:
        return f.read()

def save_summary(answer):
    """Append the answer to the summary file and save the summary to a file."""
    with open(SUMMARY_FILE, "a") as f:
        f.write(answer)
        f.write("\n\n")

def send_notification(message):
    """Send a desktop notification with wrapped text."""
    try:
        subprocess.run(["notify-send", "Qutebrowser Assistant", f"{message}"], text=True)
    except Exception as e:
        logging.error(f"Failed to send notification: {str(e)}")


def detect_summary(content):
    """Use OpenAI to provide a summary."""
    prompt = f"""

You are an org-mode assistant that creates, maintains, updates and migratees to org-mode documents.

Your job is to ensure that input text is converted to org-mode (if not already) and uses a consistent formatting.

Headings should have a reasonable size and should avoid wrapping text in quotes, stars etc.
Headings should avoid using ':'. Instead they split the heading at ':' and move the right side of the ':' to the body.

Regular text should not exceed maximum line width: ```%s```

Use all the content in thee triple backticks to generate the summary:
    {content}
    """
    response = openai.chat.completions.create(
        messages=[
            {
                "role": "user",
                "content": prompt,
            }
        ],
        model="gpt-4o",
    )
    # Extract and print only the assistant's response
    answer = response.choices[0].message.content
    return answer

send_notification("Creating summary...")
page_content = get_page_content()
if not page_content:
    send_notification("No content to analyze!")

logging.info(f'Page content: {page_content}.')
summary = detect_summary(page_content)

logging.info(f"Summary: {summary}")
save_summary(summary)
send_notification(f"Summary: {summary}")
