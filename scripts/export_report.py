#!/usr/bin/env python3
"""把设计报告导出为 A4 PDF：封面、目录、页码，页边距 2.54 cm，小四、1.5 倍行距。"""
import re
from pathlib import Path

import markdown
from weasyprint import HTML

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "docs" / "网站设计报告.md"
OUT = ROOT / "docs" / "网站设计报告.pdf"

CSS = """
@page {
  size: A4;
  margin: 2.54cm;
  @bottom-center {
    content: counter(page);
    font-family: "WenQuanYi Micro Hei", sans-serif;
    font-size: 10.5pt;
  }
}
@page:first {
  @bottom-center { content: none; }
}
html, body {
  font-family: "WenQuanYi Micro Hei", sans-serif;
  font-size: 12pt;
  line-height: 1.5;
  color: #1c242a;
}
h1, h2, h3, h4 { font-weight: 700; line-height: 1.5; page-break-after: avoid; }
h1 { font-size: 18pt; }
h2 { font-size: 16pt; margin-top: 1.2em; }
h3 { font-size: 14pt; }
p, li { orphans: 2; widows: 2; }
img { width: 100%; height: auto; }
table { border-collapse: collapse; width: 100%; font-size: 10.5pt; margin: 0.6em 0 1em; }
th, td { border: 1px solid #333; padding: 3px 6px; vertical-align: top; }
code { font-size: 10pt; }
pre { white-space: pre-wrap; font-size: 10pt; line-height: 1.4; }
.cover { page-break-after: always; text-align: center; padding-top: 4.5cm; }
.cover h1 { font-size: 28pt; margin: 0.4em 0; }
.cover p { margin: 0.35em 0; }
.toc { page-break-after: always; }
.toc .toctitle { font-size: 16pt; font-weight: 700; margin: 0 0 0.6em; }
.toc ul { padding-left: 1.2em; }
"""


def slugify(value, separator):
    value = value.strip().lower()
    value = re.sub(r"[^\w\u4e00-\u9fff.]+", separator, value, flags=re.UNICODE)
    return value.strip(separator)


def main():
    source = SRC.read_text(encoding="utf-8")
    body = markdown.markdown(
        source,
        extensions=["extra", "tables", "sane_lists", "toc", "md_in_html"],
        extension_configs={"toc": {"slugify": slugify, "toc_depth": "2-3"}},
    )
    html = f"<!DOCTYPE html><html lang='zh-CN'><head><meta charset='utf-8'><style>{CSS}</style></head><body>{body}</body></html>"
    document = HTML(string=html, base_url=str(ROOT / "docs")).render()
    document.write_pdf(OUT)
    print(f"pages={len(document.pages)} bytes={OUT.stat().st_size} file={OUT}")


if __name__ == "__main__":
    main()
