#!/home/iocanel/.config/qutebrowser/userscripts/.venv/bin/python3

import os
import sys
import json
import openai
import subprocess
import logging
import datetime
import hashlib

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
PAGE_CONTENT_FILE = os.getenv('QUTE_TEXT')
LOG_FILE = "/home/iocanel/.local/share/qutebrowser/log/create-summary.log"
SUMMARY_FILE="/home/iocanel/.local/share/qutebrowser/summary.org"
ORIGINAL_CONTENT_DIR="/home/iocanel/.local/share/qutebrowser/original-content/summaries"

os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

os.makedirs(os.path.dirname(SUMMARY_FILE), exist_ok=True)
os.makedirs(ORIGINAL_CONTENT_DIR, exist_ok=True)

def get_page_content():
    """Read the page content from a file."""
    with open(PAGE_CONTENT_FILE, "r") as f:
        return f.read()

def save_original_content(content, content_hash):
    """Save the original content with timestamp, URL, title and hash."""
    timestamp = datetime.datetime.now().isoformat()
    filename = f"{timestamp}_{content_hash[:8]}.txt"
    filepath = os.path.join(ORIGINAL_CONTENT_DIR, filename)
    
    with open(filepath, "w") as f:
        f.write(f"Timestamp: {timestamp}\n")
        f.write(f"URL: {os.getenv('QUTE_URL', 'unknown')}\n")
        f.write(f"Title: {os.getenv('QUTE_TITLE', 'unknown')}\n")
        f.write(f"Hash: {content_hash}\n")
        f.write("=" * 80 + "\n")
        f.write(content)
    
    return filepath

def save_summary(answer, original_file=None):
    """Append the answer to the summary file and save the summary to a file."""
    with open(SUMMARY_FILE, "a") as f:
        if original_file:
            f.write(f"#+source: {original_file}\n\n")
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

When the content contains shell commands, scripts, or code snippets, ensure these are preserved accurately:
- Use #+begin_src sh :results output for shell commands and scripts
- Use #+begin_src <language> for code snippets in specific languages
- Use #+begin_example for general examples or output

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
        model="gpt-5.2",
    )
    # Extract and print only the assistant's response
    answer = response.choices[0].message.content
    return answer

send_notification("Creating summary...")
page_content = get_page_content()
if not page_content:
    send_notification("No content to analyze!")

# Save original content with metadata
content_hash = hashlib.sha256(page_content.encode()).hexdigest()
original_file = save_original_content(page_content, content_hash)
logging.info(f"Original content saved to: {original_file}")

logging.info(f'Page content: {page_content}.')
summary = detect_summary(page_content)

logging.info(f"Summary: {summary}")
save_summary(summary, original_file)
send_notification(f"Summary: {summary}")
