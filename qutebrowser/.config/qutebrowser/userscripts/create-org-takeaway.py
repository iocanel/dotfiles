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
LOG_FILE = "/home/iocanel/.local/share/qutebrowser/log/create-takeaway.log"
TAKEAWAY_FILE="/home/iocanel/Documents/org/learning/takeaway.org"
ORIGINAL_CONTENT_DIR="/home/iocanel/.local/share/qutebrowser/original-content/takeaways"

os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

os.makedirs(os.path.dirname(TAKEAWAY_FILE), exist_ok=True)
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

def save_takeaway(answer):
    """Append the answer to the takeaway file and save the takeaway to a file."""
    with open(TAKEAWAY_FILE, "a") as f:
        f.write(answer)
        f.write("\n\n")

def replace_takeaway(answer, original_file=None): 
    """Replace the takeaway file with the new answer."""
    with open(TAKEAWAY_FILE, "w") as f:
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


def isolate_ai_coaching_info(content):
    """Isolate the AI coaching information from the content."""
    start = content.find("AI Coach Info")
    end = content.find("This is powered by AI and may make mistakes.")
    if start != -1 and end != -1:
        return content[start:end].strip()
    return content

def detect_takeaway(content):
    """Use OpenAI to provide a takeaway."""
    prompt = f"""

You are an org-mode assistant that helps me maintain my notes.

Your job is to detect the key usage, summary points and takeaways from the input text and convert it to org-mode format.
When the source content contains software usage examples, commands, code snippets, or technical details, ensure these are preserved accurately in the org-mode output:
- Use #+begin_src sh :results output for shell commands and scripts
- Use #+begin_src <language> for code snippets in specific languages
- Use #+begin_example for general examples or output

Headings should have a reasonable size and should avoid wrapping text in quotes, stars etc.
Headings should avoid using ':'. Instead they split the heading at ':' and move the right side of the ':' to the body.
Avoid prefixing headings with things like: 'Key takeaways for this video', just use the video title as a heading instead.
Only use numbering for things that are enumerated without explanation or details, use org-mode headings otherwise.
Be consistent for each video: Video headings should always be prefixed with '***' and its takeaways with '****' or more for nested subheadings.

Examples:

User:
2025-04-17 10:00:32,622 - INFO - Page content: 0 notifications total
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
Coaching and Developing Employees
Busting myths and finding time
2,758
2,758 likes
Save
43,298
43,298 bookmarks
Add to my content
Share Coaching and Developing Employees
966 active
Loaded: 23.04%
Play
Skip back 10 seconds
Skip ahead 10 seconds
Previous
Next
Current time 
0:03/
Duration 
4:16
2x
Playback speed
Open Captions Menu
Settings
Mute
Turn fullscreen on
about coaching so you can become a great manager and coach.
Overview
Q&A
Notebook
Transcript
Instructor
Lisa Gates
Leadership Coach, Career Story Sleuth
Follow on LinkedIn
Related to this course
Exercise Files 
Show all
Certificates 
Show all
Certifying Organizations 
Show more
Course details
1h 25m
Advanced
Updated: 12/19/2024
4.8
(4,237)

Harness the power of coaching in the workplace. Learn how to shift from a command-and-control style of management to a manager-as-coach style of leadership to transform employee engagement and bottom-line results. Join leadership coach Lisa Gates, as she explains how to establish a coaching relationship with your reports. Lisa shows how skills like open-ended question asking, listening, challenging for growth, and accountability can increase your employees' autonomy and problem-solving capacities. Learn how to overcome bias and coach inclusively, how to coach remotely, and how to implement simple, repeatable coaching frameworks. The course includes assessments, exercises, and tools to help your team capture goals, map a career trajectory, and accelerate growth, along with sample coaching conversations to help you see these tips in practice and understand their potential impact on your people, productivity, and results.

This course is part of a Professional Certificate from LinkedIn Learning.

Skills covered
Employee Coaching
People Development
Learners
2,758 members like this content
113,320 people started learning
Professional Certifications and Continuing Education Units (CEUs)
Project Management Institute (PMI)®
PDUs/ContactHours: 1

LinkedIn Learning has been reviewed and approved by the PMI® Authorized Training Partner Program. This course qualifies for professional development units (PDUs).

The PMI Authorized Training Partner logo is a registered mark of the Project Management Institute, Inc.

To view the activity and PDU details for this course, click here.

Show more
Learner reviews
4.8 out of 5
4,237 ratings
Ratings calculation
5 star
80%
4 star
16%
3 star
3%
2 star
<1%
1 star
<1%
Filter by:
All stars
Sort by: Most recent
Andrea Del Tinto 3rd
Contact Center Manager

Reviewer rating 4 out of 5

April 14, 2025

...

Helpful
Report
Stephen Fichera
Senior Mechanical Design Engineer

Reviewer rating 5 out of 5

April 14, 2025

I have really enjoyed this course. I wish I had done it earlier!

Helpful
Report
Azra Fathima 3rd
QA Analyst

Reviewer rating 4 out of 5

April 10, 2025

Good guidance to begin coaching employees

Helpful
Report
Show more reviews
Related courses
Coaching in Action for Leaders and Managers
Course
22,371 learners
Save
34m
Coaching Your Team to Think and Act Strategically
Course
48,114 learners
Save
55m
Coaching Your Team in a Dynamic Workplace
Course
72,433 learners
Save
39m
Coaching for Results
Course
248,039 learners
Save
59m
Peer Coaching for Leaders, Managers and Teams
Course
15,252 learners
Save
39m
English (English)
Change language. Current language is English.
  About  Become an Instructor  
Buy for my team
  Help  
Privacy & Terms
  Accessibility  
Apps

LinkedIn Corporation © 2025

AI Coach Info
Close AI Coach
Video
Busting myths and finding time
Ioannis Canellos:
Key takeaways for this video
Learning AI:
Here are the key takeaways from the video "Busting myths and finding time":


Coaching is not handholding: It's about setting clear expectations and goals, guiding, questioning, and prompting employees to take ownership of their work and careers.
Time management: Coaching can save time in the long run by making teams more autonomous and efficient, reducing the need for backtracking and firefighting.
Employee retention: Growing your people doesn't mean you'll lose them. Providing growth opportunities can actually increase engagement and reduce turnover.
Shared responsibility: While employees are responsible for driving their careers, managers play a crucial role in unlocking their strengths and helping them grow.

The video also suggests practical steps like letting go of myths, identifying people to coach, and scheduling regular coaching sessions.

Send positive feedback
Send negative feedback
Send message

This is powered by AI and may make mistakes. Learn more.

Assistant:
*** Busting myths and finding time

**** Coaching is not handholding
 It's about setting clear expectations and goals, guiding, questioning, and prompting employees to take ownership of their work and careers.
**** Time management
 Coaching can save time in the long run by making teams more autonomous and efficient, reducing the need for backtracking and firefighting.
**** Employee retention
 Growing your people doesn't mean you'll lose them. Providing growth opportunities can actually increase engagement and reduce turnover.
**** Shared responsibility
 While employees are responsible for driving their careers, managers play a crucial role in unlocking their strengths and helping them grow.


Use all the content in thee triple backticks to generate the takeaway:
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

def merge_takeaways(existing, takeaway):
    """Merge the existing takeaway with the new one."""
    prompt = f"""
    Merge the an org-mode tree into an existing org-mode document, eliminating duplicates and ensuring that the new content is properly formatted and integrated.
    The existing content is: {existing}
    The new content is: {takeaway}
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

def read_takeaways():
    """Read the existing takeaways from the file."""
    try:
        with open(TAKEAWAY_FILE, "r") as f:
            return f.read()
    except FileNotFoundError:
        return ""

send_notification("Creating takeaway...")
page_content = get_page_content()
if not page_content:
    send_notification("No content to analyze!")

# Save original content with metadata
content_hash = hashlib.sha256(page_content.encode()).hexdigest()
original_file = save_original_content(page_content, content_hash)
logging.info(f"Original content saved to: {original_file}")

input = isolate_ai_coaching_info(page_content)
takeaway = detect_takeaway(input)
existing_takeaway = read_takeaways()
new_takeaway = merge_takeaways(existing_takeaway, takeaway)
logging.info(f"takeaway: {takeaway}")
replace_takeaway(takeaway, original_file)
send_notification(f"takeaway: {takeaway}")
