"""
Daily Planner Generator

Generates a daily planner PDF from a JSON data file or by gathering data from CLI tools.
Designed for Supernote (Letter size, large fonts, readable on e-ink).
"""

import argparse
import json
import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

# Template path - check environment variable first, then default locations
def get_template_path():
    if "DAILY_PLANNER_TEMPLATE" in os.environ:
        return Path(os.environ["DAILY_PLANNER_TEMPLATE"])
    # Check nix store path
    share_dir = Path(__file__).parent.parent / "share" / "morning-routine"
    if share_dir.exists():
        return share_dir / "daily-planner.html"
    # Fallback to relative path
    return Path(__file__).parent.parent / "templates" / "daily-planner.html"

TEMPLATE_PATH = get_template_path()

PDF_OPTIONS = [
    "--page-size", "Letter",
    "--margin-top", "10mm",
    "--margin-bottom", "10mm",
    "--margin-left", "10mm",
    "--margin-right", "10mm",
    "--encoding", "UTF-8",
    "--enable-local-file-access",
    "--load-error-handling", "ignore",
    "--load-media-error-handling", "ignore",
    "--quiet",
]

TIMEZONE = ZoneInfo("Europe/Athens")


def run_cmd(cmd: list, silent: bool = False) -> str:
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
        return result.stdout
    except subprocess.TimeoutExpired:
        if not silent:
            print(f"Warning: Command timed out: {' '.join(cmd)}", file=sys.stderr)
        return ""
    except FileNotFoundError:
        if not silent:
            print(f"Warning: Command not found: {cmd[0]}", file=sys.stderr)
        return ""


def fetch_org_agenda() -> list:
    output = run_cmd(["org-cli", "agenda", "today"])
    if not output:
        return []
    try:
        data = json.loads(output)
        tasks = []
        for task in data.get("tasks", []):
            title = task.get("title", "")
            if title and title != "%?":
                tasks.append({"title": title})
        return tasks
    except json.JSONDecodeError:
        return []


def fetch_org_habits() -> list:
    output = run_cmd(["org-cli", "habits", "today"])
    if not output:
        return []
    try:
        data = json.loads(output)
        return [{"title": h.get("title", "")} for h in data if h.get("title")]
    except json.JSONDecodeError:
        return []


def fetch_outlook_calendar() -> list:
    output = run_cmd(["outlook", "calendar", "--today", "--format", "json"])
    if not output:
        return []
    try:
        # Extract JSON from output (outlook prints log messages before JSON)
        json_start = output.find('[')
        if json_start == -1:
            json_start = output.find('{')
        if json_start == -1:
            return []
        json_str = output[json_start:]
        data = json.loads(json_str)
        # Handle both flat array and nested {"events": [...]} format
        events = data if isinstance(data, list) else data.get("events", [])
        meetings = []
        for event in events:
            start = event.get("start", "")
            title = event.get("subject", event.get("title", ""))
            end = event.get("end", "")

            # Parse time and convert to local timezone
            time_str = ""
            duration_str = ""
            if start:
                try:
                    start_dt = datetime.fromisoformat(start.replace("Z", "+00:00"))
                    local_start = start_dt.astimezone(TIMEZONE)
                    time_str = local_start.strftime("%H:%M")

                    if end:
                        end_dt = datetime.fromisoformat(end.replace("Z", "+00:00"))
                        duration_mins = int((end_dt - start_dt).total_seconds() / 60)
                        duration_str = f"{duration_mins} min"
                except (ValueError, TypeError):
                    pass

            if title:
                meetings.append({
                    "time": time_str,
                    "title": title,
                    "duration": duration_str
                })
        # Sort by time
        meetings.sort(key=lambda m: m.get("time", ""))
        return meetings
    except json.JSONDecodeError:
        return []


def fetch_glab_mrs() -> list:
    output = run_cmd(["glab-mr-tracker", "list", "--format", "detailed"])
    if not output:
        return []

    mrs = []
    current_mr = {}

    for line in output.split("\n"):
        line = line.strip()

        # Match MR header: ## !123: Title
        match = re.match(r"^## !(\d+): (.+)$", line)
        if match:
            if current_mr and current_mr.get("requires_attention", True):
                mrs.append(current_mr)
            current_mr = {"iid": match.group(1), "title": match.group(2).strip()}
            continue

        if line.startswith("- **Author:**"):
            current_mr["author"] = line.replace("- **Author:**", "").strip()
        elif line.startswith("- **Reason:**"):
            current_mr["reason"] = line.replace("- **Reason:**", "").strip()
        elif line.startswith("- **Status:**"):
            status = line.replace("- **Status:**", "").strip()
            current_mr["requires_attention"] = status == "NEEDS ATTENTION"

    if current_mr and current_mr.get("requires_attention", True):
        mrs.append(current_mr)

    return mrs[:6]


def fetch_asana_tasks() -> list:
    output = run_cmd(["asana", "tasks", "list", "-a", "me", "--completed=false"])
    if not output:
        return []

    tasks = []
    for line in output.split("\n"):
        line = line.strip()
        if line and not line.startswith("GID"):
            parts = line.split(None, 1)
            if len(parts) >= 2:
                title = parts[1].strip()
                if title:
                    tasks.append({"title": title})
    return tasks[:6]


def gather_data() -> dict:
    today = datetime.now().strftime("%Y-%m-%d")

    print("Gathering org-mode agenda...", file=sys.stderr)
    org_tasks = fetch_org_agenda()

    print("Gathering org-mode habits...", file=sys.stderr)
    habits = fetch_org_habits()

    print("Gathering Outlook calendar...", file=sys.stderr)
    meetings = fetch_outlook_calendar()

    print("Gathering GitLab MRs...", file=sys.stderr)
    mrs = fetch_glab_mrs()

    print("Gathering Asana tasks...", file=sys.stderr)
    asana_tasks = fetch_asana_tasks()

    # Limit total tasks to 10 (org tasks first, then asana)
    all_tasks = (org_tasks + asana_tasks)[:10]

    return {
        "date": today,
        "meetings": meetings,
        "merge_requests": mrs,
        "tasks": all_tasks,
        "habits": habits
    }


def render_meetings(meetings: list) -> str:
    if not meetings:
        return '<div class="meeting-item" style="color:#888;">No meetings today</div>'

    html_parts = []
    for m in meetings:
        time = m.get("time", "")
        title = m.get("title", "")
        duration = m.get("duration", "")
        duration_str = f" ({duration})" if duration else ""

        html_parts.append(f'<div class="meeting-item"><span class="time-tag">{time}</span>{title}{duration_str}</div>')

    return "\n".join(html_parts)


def render_merge_requests(mrs: list) -> str:
    if not mrs:
        return '<div class="card"><div class="card-title" style="color:#888;">No MRs pending</div></div>'

    html_parts = []
    for mr in mrs:
        title = mr.get("title", "")
        author = mr.get("author", "")
        reason = mr.get("reason", "")
        meta_parts = []
        if author:
            meta_parts.append(f"Author: {author}")
        if reason:
            meta_parts.append(reason)
        meta = " | ".join(meta_parts)

        html_parts.append(f'''<div class="card">
        <div class="card-title"><span class="checkbox"></span>{title}</div>
        {f'<div class="card-meta">{meta}</div>' if meta else ''}
      </div>''')

    return "\n".join(html_parts)


def render_tasks(tasks: list) -> str:
    if not tasks:
        return '<div class="task-item" style="color:#888;">No tasks scheduled</div>'

    html_parts = []
    for task in tasks:
        title = task if isinstance(task, str) else task.get("title", "")
        html_parts.append(f'<div class="task-item"><span class="checkbox"></span>{title}</div>')

    return "\n".join(html_parts)


def render_habits(habits: list) -> str:
    if not habits:
        return '<span style="color:#888;">No habits due</span>'

    html_parts = []
    for i, habit in enumerate(habits):
        title = habit if isinstance(habit, str) else habit.get("title", "")
        if i == 0:
            html_parts.append(f'<span class="checkbox"></span>{title}')
        elif i % 3 == 0:
            html_parts.append(f'<br>\n      <span class="checkbox"></span>{title}')
        else:
            html_parts.append(f'\n      <span class="checkbox"></span>{title}')

    return "\n".join(html_parts)


def format_date_display(date_str: str) -> str:
    try:
        dt = datetime.strptime(date_str, "%Y-%m-%d")
        return dt.strftime("%A, %B %d, %Y")
    except ValueError:
        return date_str


def generate_html(data: dict) -> str:
    with open(TEMPLATE_PATH, "r", encoding="utf-8") as f:
        template = f.read()

    date_str = data.get("date", datetime.now().strftime("%Y-%m-%d"))
    date_display = format_date_display(date_str)

    replacements = {
        "{{DATE_DISPLAY}}": date_display,
        "{{MEETINGS}}": render_meetings(data.get("meetings", [])),
        "{{MERGE_REQUESTS}}": render_merge_requests(data.get("merge_requests", [])),
        "{{TASKS}}": render_tasks(data.get("tasks", [])),
        "{{HABITS}}": render_habits(data.get("habits", [])),
    }

    html = template
    for placeholder, content in replacements.items():
        html = html.replace(placeholder, content)

    return html


def generate_pdf(html: str, output_path: str) -> None:
    import tempfile

    with tempfile.NamedTemporaryFile(mode="w", suffix=".html", delete=False, encoding="utf-8") as f:
        f.write(html)
        temp_html = f.name

    try:
        cmd = ["wkhtmltopdf"] + PDF_OPTIONS + [temp_html, output_path]
        subprocess.run(cmd, check=True, capture_output=True)
    finally:
        os.unlink(temp_html)


def main():
    parser = argparse.ArgumentParser(description="Generate daily planner PDF")
    subparsers = parser.add_subparsers(dest="command", help="Commands")

    # generate command
    gen_parser = subparsers.add_parser("generate", help="Generate planner from JSON data")
    gen_parser.add_argument("--input", "-i", required=True, help="JSON data file path")
    gen_parser.add_argument("--output", "-o", required=True, help="Output PDF path")

    # run command - gather data and generate
    run_parser = subparsers.add_parser("run", help="Gather data from all sources and generate PDF")
    run_parser.add_argument("--output", "-o", help="Output PDF path (default: /tmp/daily-YYYY-MM-DD.pdf)")
    run_parser.add_argument("--save-json", help="Also save JSON data to this path")

    # template command
    subparsers.add_parser("template", help="Show template path")

    args = parser.parse_args()

    if args.command == "generate":
        with open(args.input, "r", encoding="utf-8") as f:
            data = json.load(f)

        html = generate_html(data)
        generate_pdf(html, args.output)
        print(f"Generated: {args.output}")

    elif args.command == "run":
        data = gather_data()

        if args.save_json:
            with open(args.save_json, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2)
            print(f"Saved JSON: {args.save_json}", file=sys.stderr)

        output_path = args.output
        if not output_path:
            today = datetime.now().strftime("%Y-%m-%d")
            output_path = f"/tmp/daily-{today}.pdf"

        html = generate_html(data)
        generate_pdf(html, output_path)
        print(f"Generated: {output_path}")

    elif args.command == "template":
        print(TEMPLATE_PATH)

    else:
        parser.print_help()


if __name__ == "__main__":
    main()
