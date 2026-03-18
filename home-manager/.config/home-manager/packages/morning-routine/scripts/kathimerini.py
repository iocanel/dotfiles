"""
Kathimerini News Fetcher

Fetches latest news from Kathimerini.gr and outputs as markdown or PDF.
"""

import argparse
import os
import shutil
import sys
import tempfile
from datetime import datetime

import pdfkit
import requests
from bs4 import BeautifulSoup
from pypdf import PdfReader, PdfWriter

URL = "https://www.kathimerini.gr/epikairothta/"

# Configure wkhtmltopdf path from environment or search PATH
WKHTMLTOPDF_PATH = os.environ.get("WKHTMLTOPDF_PATH") or shutil.which("wkhtmltopdf")
PDFKIT_CONFIG = pdfkit.configuration(wkhtmltopdf=WKHTMLTOPDF_PATH) if WKHTMLTOPDF_PATH else None

PDF_OPTIONS = {
    'page-size': 'Letter',
    'encoding': 'UTF-8',
    'no-outline': None,
    'quiet': '',
    'enable-local-file-access': '',
    'load-error-handling': 'ignore',
    'load-media-error-handling': 'ignore',
}

ARTICLE_CSS = """
body {
    font-family: 'DejaVu Sans', 'Liberation Sans', Arial, sans-serif;
    font-size: 20px;
    line-height: 1.6;
    color: #333;
    max-width: 100%;
    margin: 0;
    padding: 20px;
}
h1 {
    font-size: 29px;
    font-weight: bold;
    margin-bottom: 10px;
    color: #1a1a1a;
}
.meta {
    font-size: 14px;
    color: #666;
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 1px solid #ddd;
}
.featured-image {
    width: 100%;
    margin-bottom: 20px;
}
.featured-image img {
    width: 100%;
    height: auto;
}
.featured-image figcaption {
    font-size: 13px;
    color: #666;
    font-style: italic;
    margin-top: 5px;
}
.content {
    text-align: justify;
}
.content p {
    margin-bottom: 15px;
}
.content img {
    max-width: 100%;
    height: auto;
    margin: 15px 0;
}
"""


def fetch_articles(limit=10):
    response = requests.get(URL, timeout=30)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "html.parser")

    articles = []
    for title_elem in soup.find_all(class_="card-title"):
        parent_link = title_elem.find_parent("a")
        if parent_link and parent_link.get("href"):
            articles.append({
                "title": title_elem.get_text(strip=True),
                "url": parent_link.get("href")
            })

    if limit > 0:
        articles = articles[:limit]

    return articles


def extract_article_content(url):
    response = requests.get(url, timeout=30)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "html.parser")

    article = soup.find('article')
    if not article:
        return None

    title_elem = article.find(class_='entry-title') or article.find('h1')
    title = title_elem.get_text(strip=True) if title_elem else "Untitled"

    meta_parts = []
    author_elem = article.find(class_='author') or article.find(class_='vcard')
    if author_elem:
        author_name = author_elem.find(class_='fn') or author_elem
        meta_parts.append(author_name.get_text(strip=True))

    date_elem = article.find(class_='published') or article.find('time')
    if date_elem:
        meta_parts.append(date_elem.get_text(strip=True))

    featured_html = ""
    featured = article.find(class_='featured-image') or article.find('figure')
    if featured:
        img = featured.find('img')
        if img:
            img_src = img.get('src', '') or img.get('data-src', '')
            if img_src:
                if img_src.startswith('/'):
                    img_src = 'https://www.kathimerini.gr' + img_src
                caption = ""
                figcaption = featured.find('figcaption')
                if figcaption:
                    caption = f"<figcaption>{figcaption.get_text(strip=True)}</figcaption>"
                featured_html = f'<figure class="featured-image"><img src="{img_src}" alt="">{caption}</figure>'

    content_html = ""
    content = article.find(class_='entry-content')
    if content:
        for unwanted in content.find_all(['script', 'style', 'iframe', 'aside', 'svg']):
            unwanted.decompose()

        unwanted_classes = [
            'social-share-wrapper', 'share-holder', 'share-tool', 'social-tool',
            'socials-holder', 'socials-container', 'share-link',
            'comments-icon-wrapper', 'comments-icon', 'comments-text', 'comment-cnt',
            'bookmark-add', 'copy-link', 'svg-social-icon', 'svg-share-icons',
            'text-to-speech-wrap', 'shimmer',
            'author', 'vcard', 'subscribe-author', 'author-select',
        ]
        for cls in unwanted_classes:
            for elem in content.find_all(class_=cls):
                elem.decompose()

        for img in content.find_all('img'):
            src = img.get('src', '') or img.get('data-src', '')
            if src and src.startswith('/'):
                img['src'] = 'https://www.kathimerini.gr' + src
            elif img.get('data-src'):
                img['src'] = img['data-src']

        content_html = str(content)

    html = f"""<!DOCTYPE html>
<html lang="el">
<head>
    <meta charset="UTF-8">
    <style>{ARTICLE_CSS}</style>
</head>
<body>
    <h1>{title}</h1>
    <div class="meta">{' | '.join(meta_parts)}</div>
    {featured_html}
    <div class="content">{content_html}</div>
</body>
</html>"""

    return html


def format_markdown(articles):
    lines = [
        "# Kathimerini News",
        f"*Fetched: {datetime.now().strftime('%Y-%m-%d %H:%M')}*",
        "",
    ]
    for i, article in enumerate(articles, 1):
        lines.append(f"{i}. [{article['title']}]({article['url']})")

    return "\n".join(lines)


def generate_pdf(articles, output_path):
    temp_dir = tempfile.mkdtemp()
    temp_pdfs = []

    try:
        for i, article in enumerate(articles):
            temp_html = os.path.join(temp_dir, f"article_{i}.html")
            temp_pdf = os.path.join(temp_dir, f"article_{i}.pdf")
            try:
                clean_html = extract_article_content(article['url'])
                if not clean_html:
                    print(f"  Warning: Could not extract content from {article['url']}", file=sys.stderr)
                    continue

                with open(temp_html, 'w', encoding='utf-8') as f:
                    f.write(clean_html)

                pdfkit.from_file(temp_html, temp_pdf, options=PDF_OPTIONS, configuration=PDFKIT_CONFIG)
                temp_pdfs.append(temp_pdf)
                print(f"  [{i+1}/{len(articles)}] {article['title'][:50]}...")
            except Exception as e:
                print(f"  Warning: Failed to convert {article['url']}: {e}", file=sys.stderr)

        if not temp_pdfs:
            print("Error: No articles could be converted to PDF", file=sys.stderr)
            sys.exit(1)

        writer = PdfWriter()
        for pdf in temp_pdfs:
            reader = PdfReader(pdf)
            for page in reader.pages:
                writer.add_page(page)
        with open(output_path, 'wb') as f:
            writer.write(f)

    finally:
        shutil.rmtree(temp_dir, ignore_errors=True)


def main():
    parser = argparse.ArgumentParser(description="Fetch news from Kathimerini")
    subparsers = parser.add_subparsers(dest="command", help="Commands")

    fetch_parser = subparsers.add_parser("fetch", help="Fetch latest news")
    fetch_parser.add_argument(
        "--format", "-f",
        choices=["markdown", "pdf"],
        default="markdown",
        help="Output format (default: markdown)"
    )
    fetch_parser.add_argument(
        "--output", "-o",
        help="Output file path (required for PDF)"
    )
    fetch_parser.add_argument(
        "--limit", "-l",
        type=int,
        default=10,
        help="Number of articles to fetch (default: 10, use 0 for all)"
    )

    args = parser.parse_args()

    if args.command == "fetch":
        articles = fetch_articles(args.limit)

        if args.format == "markdown":
            print(format_markdown(articles))
        elif args.format == "pdf":
            if not args.output:
                print("Error: --output is required for PDF format", file=sys.stderr)
                sys.exit(1)
            print(f"Generating PDF with {len(articles)} articles...")
            generate_pdf(articles, args.output)
            print(f"PDF saved to: {args.output}")
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
