#!/home/iocanel/.config/qutebrowser/userscripts/.venv/bin/python3

import os
import sys
import json
import openai
import subprocess
import logging

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
PAGE_CONTENT_FILE = os.getenv('QUTE_TEXT')
LOG_FILE = "/home/iocanel/.local/share/qutebrowser/log/answer-question.log"
FLASHCARDS_FILE="/home/iocanel/Documents/org/learning/flashcards.org"

os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

os.makedirs(os.path.dirname(FLASHCARDS_FILE), exist_ok=True)

def get_page_content():
    """Read the page content from a file."""
    with open(PAGE_CONTENT_FILE, "r") as f:
        return f.read()

def save_flashcard(answer):
    """Append the answer to the flashcards file and save the flashcard to a file."""
    with open(FLASHCARDS_FILE, "a") as f:
        f.write(answer)
        f.write("\n\n")

def send_notification(message):
    """Send a desktop notification with wrapped text."""
    try:
        subprocess.run(["notify-send", "Qutebrowser Assistant", f"{message}"], text=True)
    except Exception as e:
        logging.error(f"Failed to send notification: {str(e)}")


def detect_question_and_answer(content):
    """Use OpenAI to detect the question and provide an answer."""
    prompt = f"""
You are an org-mode assistant that create org-drill flashcards based on the provided content.
The flashcard should be an org heading with the :drill: tag that contains no properties. 
The content of the heading should be never be empty. 
If there is nothing to included in the body (e.g. multiple choices, clarifications) then repeat the full question. 
The answer should be provided under an answer sub-heading. The answer itself may not contain additional sub-headings. 
Be carefull, to discern when the question is followed by the response or multiple choices. 
Also make sure you filter out content irrelevant to the question.
Examples: 

User: 
What's the capital of Greece ?
Assistant: 
** What's the capital of Greece ? :drill:
What's the capital of Greece ?
*** Answer 
Athens

User: 
What's the capital of Greece ?
Athens
Assistant:
** What's the capital of Greece ? :drill:
What's the capital of Greece ?
*** Answer 
Athens

User:
What's the capital of Greece ?
Athens
Rome 
Paris
Assistant:
** What's the capital of Greece ? :drill:
- Athens
- Rome 
- Paris
*** Answer 
Athens

User: 
The capital of Greece is Athens
Assistant:
** What's the capital of Greece ? :drill:
What's the capital of Greece ?
*** Answer 
Athens

User:
Important LinkedIn Alerts

There are no alerts at the moment.

Skip to section
Skip to search
Accessibility feedback
Contact LinkedIn’s Disability Answer Desk with accessibility feedback or issues
Close jump menu
Expand site navigation
Me
EN
Change language. Current language is English.
Home
My Career Journey
My Library
Content
AI Coaching
Coding Practice
Certifications
Help
LinkedIn Learning
Contents
Machine Learning Foundations: Linear Algebra
Chapter Quiz
946
946 likes
Save
19,710
19,710 bookmarks
Add to my content
Share Machine Learning Foundations: Linear Algebra
Up next
Dot product of vectors
3m 10s
Dismiss
Question 1 of 3

What is the difference between a scalar and a vector?

a vector is a number and a scalar is an ordered list of numbers that has both dimensionality and orientation
a scalar is a number and a vector is an ordered list of numbers that has both dimensionality and orientation
a scalar is a number and a vector is an ordered list of numbers
they are the same
Submit.
Assistant:
** What is the difference between a scalar and a vector? :drill:
What is the difference between a scalar and a vector?

- a vector is a number and a scalar is an ordered list of numbers that has both dimensionality and orientation
- a scalar is a number and a vector is an ordered list of numbers that has both dimensionality and orientation
- a scalar is a number and a vector is an ordered list of numbers
*** Answer
a vector is a number and a scalar is an ordered list of numbers that has both dimensionality and orientation

Use all the content in thee triple backticks to generate the flashcoard:
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

send_notification("Creating flashcard...")
page_content = get_page_content()
if not page_content:
    send_notification("No content to analyze!")

logging.info(f'Page content: {page_content}.')
answer = detect_question_and_answer(page_content)

logging.info(f"Answer: {answer}")
save_flashcard(answer)
send_notification(f"Answer: {answer}")
