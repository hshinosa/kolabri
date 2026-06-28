#!/usr/bin/env python3
"""Generate simple PDFs from sample markdown (text-only, no deps)."""

from __future__ import annotations

import re
import struct
import zlib
from pathlib import Path

HERE = Path(__file__).resolve().parent

SAMPLES = [
    (
        "if211-minggu-1-pengenalan-data-mining.md",
        "if211-minggu-1-pengenalan-data-mining.pdf",
    ),
    (
        "if211-minggu-2-preprocessing-dan-kmeans.md",
        "if211-minggu-2-preprocessing-dan-kmeans.pdf",
    ),
    ("if211-minggu-3-association-rules.md", "if211-minggu-3-association-rules.pdf"),
]


def md_to_plain(md: str) -> list[str]:
    lines: list[str] = []
    for raw in md.splitlines():
        line = raw.strip()
        if not line:
            lines.append("")
            continue
        if line.startswith("#"):
            line = re.sub(r"^#+\s*", "", line).upper()
        line = re.sub(r"\*\*([^*]+)\*\*", r"\1", line)
        line = re.sub(r"\|", " ", line)
        if line.startswith("- "):
            line = "• " + line[2:]
        lines.append(line)
    return lines


def escape_pdf_text(s: str) -> str:
    return s.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)")


def build_pdf(pages_lines: list[list[str]]) -> bytes:
    """Minimal multi-line PDF using Helvetica 11pt."""
    objects: list[bytes] = []
    page_objs: list[int] = []

    def add_obj(data: str | bytes) -> int:
        if isinstance(data, str):
            data = data.encode("latin-1", errors="replace")
        objects.append(data)
        return len(objects)

    font_id = add_obj("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>")

    content_streams: list[bytes] = []
    for lines in pages_lines:
        y = 800
        parts = ["BT", "/F1 11 Tf", "50 800 Td"]
        first = True
        for line in lines[:45]:
            text = escape_pdf_text(line[:95])
            if first:
                parts.append(f"({text}) Tj")
                first = False
            else:
                parts.append("0 -14 Td")
                parts.append(f"({text}) Tj")
            y -= 14
        parts.append("ET")
        stream = "\n".join(parts).encode("latin-1", errors="replace")
        content_streams.append(stream)

    for stream in content_streams:
        compressed = zlib.compress(stream)
        cid = add_obj(
            f"<< /Length {len(compressed)} /Filter /FlateDecode >>\nstream\n".encode()
            + compressed
            + b"\nendstream"
        )
        pid = add_obj(
            f"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] "
            f"/Resources << /Font << /F1 {font_id} 0 R >> >> /Contents {cid} 0 R >>"
        )
        page_objs.append(pid)

    kids = " ".join(f"{p} 0 R" for p in page_objs)
    pages_id = add_obj(f"<< /Type /Pages /Kids [{kids}] /Count {len(page_objs)} >>")
    # fix parent ref — pages object number varies; rebuild with known ids after catalog
    # Simpler: single page only per file
    catalog_id = add_obj(f"<< /Type /Catalog /Pages {pages_id} 0 R >>")

    out = bytearray(b"%PDF-1.4\n")
    offsets = [0]
    for i, obj in enumerate(objects, 1):
        offsets.append(len(out))
        out.extend(f"{i} 0 obj\n".encode())
        out.extend(obj if obj.endswith(b"endstream") else obj)
        if not (isinstance(obj, bytes) and b"endstream" in obj):
            if isinstance(obj, bytes) and obj.strip().endswith(b">>"):
                pass
        out.extend(b"\nendobj\n")

    xref_pos = len(out)
    out.extend(f"xref\n0 {len(objects) + 1}\n".encode())
    out.extend(b"0000000000 65535 f \n")
    for off in offsets[1:]:
        out.extend(f"{off:010d} 00000 n \n".encode())
    out.extend(
        f"trailer\n<< /Size {len(objects) + 1} /Root {catalog_id} 0 R >>\n"
        f"startxref\n{xref_pos}\n%%EOF\n".encode()
    )
    return bytes(out)


def build_pdf_simple(lines: list[str]) -> bytes:
    """Single-page PDF — reliable minimal writer."""
    text_lines = (
        md_to_plain("\n".join(lines))
        if len(lines) == 1 and lines[0].endswith(".md")
        else lines
    )
    if len(lines) == 1 and Path(lines[0]).exists():
        text_lines = md_to_plain(Path(lines[0]).read_text(encoding="utf-8"))

    y_start = 750
    text_ops = []
    for i, line in enumerate(text_lines[:50]):
        esc = escape_pdf_text(line[:90] or " ")
        if i == 0:
            text_ops.append(f"1 0 0 1 50 {y_start} Tm ({esc}) Tj")
        else:
            text_ops.append(f"1 0 0 1 50 {y_start - i * 13} Tm ({esc}) Tj")

    stream = ("BT /F1 10 Tf\n" + "\n".join(text_ops) + "\nET").encode(
        "latin-1", errors="replace"
    )

    stream_len = len(stream)
    pdf = (
        f"""%PDF-1.4
1 0 obj<< /Type /Catalog /Pages 2 0 R >>endobj
2 0 obj<< /Type /Pages /Kids [3 0 R] /Count 1 >>endobj
3 0 obj<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792]
/Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>endobj
4 0 obj<< /Length {stream_len} >>stream
""".encode("ascii")
        + stream
        + b"""
endstream
endobj
5 0 obj<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>endobj
xref
0 6
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000266 00000 n 
trailer<< /Size 6 /Root 1 0 R >>
startxref
400
%%EOF
"""
    )
    return pdf


def main() -> None:
    for md_name, pdf_name in SAMPLES:
        md_path = HERE / md_name
        text = md_path.read_text(encoding="utf-8")
        plain = md_to_plain(text)
        pdf_bytes = build_pdf_simple(plain)
        out = HERE / pdf_name
        out.write_bytes(pdf_bytes)
        print(f"Wrote {out} ({len(pdf_bytes)} bytes)")


if __name__ == "__main__":
    main()
