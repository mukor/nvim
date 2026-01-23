# Notes Ingestion Strategy for Local LLM

This document outlines a complete strategy for authoring, storing, and ingesting Telekasten notes into a local LLM-powered RAG (Retrieval-Augmented Generation) system.

## Table of Contents

1. [Ingestion Strategy](#ingestion-strategy)
2. [Frontmatter Schema](#frontmatter-schema)
3. [Tooling Strategy](#tooling-strategy)
4. [Architecture](#architecture)
5. [Code Implementation](#code-implementation)
6. [CLI Interface](#cli-interface)
7. [Neovim Integration](#neovim-integration)

---

## Ingestion Strategy

### Overview

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Markdown   │────▶│   Parser    │────▶│  Chunker    │────▶│  Embeddings │
│    Notes    │     │ (frontmatter│     │ (semantic)  │     │  (local)    │
└─────────────┘     │  + content) │     └─────────────┘     └─────────────┘
                    └─────────────┘                                │
                                                                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Response  │◀────│  Local LLM  │◀────│  Retriever  │◀────│  Vector DB  │
│             │     │ (Ollama)    │     │  (top-k)    │     │ (ChromaDB)  │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

### Pipeline Steps

1. **Watch** - Monitor `~/notes` for changes (new, modified, deleted)
2. **Parse** - Extract frontmatter metadata and markdown content
3. **Chunk** - Split content into semantic chunks (respecting headers)
4. **Embed** - Generate embeddings using local model (nomic-embed-text)
5. **Store** - Save vectors + metadata in ChromaDB
6. **Index** - Maintain searchable metadata index
7. **Query** - Retrieve relevant chunks via similarity search
8. **Generate** - Pass context to local LLM for response

### Incremental Updates

- Use file modification timestamps to detect changes
- Hash content to avoid re-embedding unchanged notes
- Support soft deletes (archived status) vs hard deletes

---

## Frontmatter Schema

### Required Fields

```yaml
---
title: "Descriptive Note Title"
date: 2026-01-22
tags: [tag1, tag2, tag3]
type: concept | reference | project | daily | meeting | snippet
---
```

### Optional Fields (Recommended)

```yaml
---
title: "Descriptive Note Title"
date: 2026-01-22
updated: 2026-01-23
tags: [python, async, programming]
type: concept
topic: "Python Programming"
summary: "One-line summary for quick LLM context retrieval"
related: ["[[async-await]]", "[[python-basics]]"]
status: draft | active | archived
source: "URL or book reference if applicable"
confidence: high | medium | low
---
```

### Field Definitions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | Yes | Human-readable title |
| `date` | date | Yes | Creation date (YYYY-MM-DD) |
| `updated` | date | No | Last modification date |
| `tags` | array | Yes | Categorization tags |
| `type` | enum | Yes | Note type for processing logic |
| `topic` | string | No | Broad subject area |
| `summary` | string | No | One-line description (used in RAG context) |
| `related` | array | No | Wiki-links to related notes |
| `status` | enum | No | Workflow status (default: active) |
| `source` | string | No | External reference |
| `confidence` | enum | No | How confident you are in the content |

### Note Types

| Type | Description | Chunking Strategy |
|------|-------------|-------------------|
| `concept` | Explanations of ideas/concepts | By header sections |
| `reference` | Quick lookup (commands, syntax) | Small chunks, preserve structure |
| `project` | Project notes, plans | By header sections |
| `daily` | Daily journal entries | Single chunk per day |
| `meeting` | Meeting notes | By agenda item/header |
| `snippet` | Code snippets, examples | Whole note as single chunk |

---

## Tooling Strategy

### Neovim Automation

#### 1. Auto-generate Frontmatter Template

Configure Telekasten to use templates with pre-filled frontmatter:

```lua
-- In Telekasten setup
require("telekasten").setup({
  home = vim.fn.expand("~/notes"),
  template_new_note = vim.fn.expand("~/notes/templates/note.md"),
  template_new_daily = vim.fn.expand("~/notes/templates/daily.md"),
})
```

#### 2. Template Files

**~/notes/templates/note.md:**
```markdown
---
title: "{{title}}"
date: {{date}}
tags: []
type: concept
topic: ""
summary: ""
related: []
status: draft
---

# {{title}}

## Overview



## Details



## References

```

**~/notes/templates/daily.md:**
```markdown
---
title: "Daily - {{date}}"
date: {{date}}
tags: [daily]
type: daily
summary: ""
status: active
---

# {{date}}

## Tasks

- [ ]

## Notes



## Log

```

#### 3. Snippet Support (LuaSnip)

```lua
-- Frontmatter snippet for quick insertion
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("markdown", {
  s("fm", {
    t({"---", "title: \""}), i(1, "Title"), t({"\"", "date: "}),
    f(function() return os.date("%Y-%m-%d") end),
    t({"", "tags: ["}), i(2), t({"]", "type: "}), i(3, "concept"),
    t({"", "summary: \""}), i(4), t({"\"", "status: draft", "---", "", "# "}),
    rep(1), t({"", "", ""}), i(0),
  }),
})
```

#### 4. Frontmatter Validation (Optional)

Use a pre-save hook to validate frontmatter:

```lua
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.md",
  callback = function()
    -- Check for required frontmatter fields
    local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
    local in_frontmatter = false
    local has_title, has_date, has_tags, has_type = false, false, false, false

    for _, line in ipairs(lines) do
      if line == "---" then
        if in_frontmatter then break end
        in_frontmatter = true
      elseif in_frontmatter then
        if line:match("^title:") then has_title = true end
        if line:match("^date:") then has_date = true end
        if line:match("^tags:") then has_tags = true end
        if line:match("^type:") then has_type = true end
      end
    end

    if in_frontmatter and not (has_title and has_date and has_tags and has_type) then
      vim.notify("Warning: Missing required frontmatter fields", vim.log.levels.WARN)
    end
  end,
})
```

---

## Architecture

### Component Overview

```
~/notes/                          # Note storage
├── *.md                          # Markdown notes
├── templates/                    # Note templates
└── .index/                       # Generated index (gitignored)

~/notes-rag/                      # RAG system
├── ingest.py                     # Ingestion script
├── query.py                      # Query interface
├── watch.py                      # File watcher daemon
├── config.yaml                   # Configuration
├── chroma_db/                    # Vector database
└── requirements.txt              # Python dependencies
```

### Technology Stack

| Component | Technology | Rationale |
|-----------|------------|-----------|
| Vector DB | ChromaDB | Local, simple, Python-native |
| Embeddings | nomic-embed-text (Ollama) | Local, fast, good quality |
| LLM | Ollama (llama3.2, mistral, etc.) | Local, private, flexible |
| Parser | python-frontmatter | Robust YAML+markdown parsing |
| Chunker | LangChain | Semantic chunking with overlap |
| Watcher | watchdog | Cross-platform file monitoring |
| CLI | Typer | Modern Python CLI framework |

### Data Flow

```
Note Created/Modified
        │
        ▼
   File Watcher (watchdog)
        │
        ▼
   Parse Frontmatter (python-frontmatter)
        │
        ├──▶ Metadata ──▶ SQLite Index (for fast filtering)
        │
        ▼
   Chunk Content (LangChain)
        │
        ▼
   Generate Embeddings (Ollama nomic-embed-text)
        │
        ▼
   Store in ChromaDB (with metadata)
```

---

## Code Implementation

### Requirements

**requirements.txt:**
```
chromadb>=0.4.0
ollama>=0.1.0
python-frontmatter>=1.0.0
langchain>=0.1.0
langchain-community>=0.0.10
watchdog>=3.0.0
typer>=0.9.0
rich>=13.0.0
pyyaml>=6.0
```

### Configuration

**config.yaml:**
```yaml
notes_dir: ~/notes
chroma_dir: ~/notes-rag/chroma_db
ollama_base_url: http://localhost:11434

embedding_model: nomic-embed-text
llm_model: llama3.2

chunk_size: 500
chunk_overlap: 50

# Note types to exclude from ingestion
exclude_types:
  - daily  # Optional: exclude daily notes

# Directories to ignore
ignore_dirs:
  - templates
  - .index
```

### Core Ingestion Script

**ingest.py:**
```python
#!/usr/bin/env python3
"""
Notes ingestion script for RAG system.
Parses markdown notes with frontmatter and stores in ChromaDB.
"""

import os
import hashlib
from pathlib import Path
from typing import Optional

import chromadb
import frontmatter
import ollama
import yaml
from langchain.text_splitter import RecursiveCharacterTextSplitter
from rich.console import Console
from rich.progress import track

console = Console()


def load_config(config_path: str = "config.yaml") -> dict:
    """Load configuration from YAML file."""
    with open(config_path) as f:
        config = yaml.safe_load(f)
    config["notes_dir"] = os.path.expanduser(config["notes_dir"])
    config["chroma_dir"] = os.path.expanduser(config["chroma_dir"])
    return config


def get_file_hash(content: str) -> str:
    """Generate hash of file content for change detection."""
    return hashlib.md5(content.encode()).hexdigest()


def parse_note(file_path: Path) -> Optional[dict]:
    """Parse a markdown note with frontmatter."""
    try:
        with open(file_path) as f:
            post = frontmatter.load(f)

        # Validate required fields
        required = ["title", "date", "tags", "type"]
        for field in required:
            if field not in post.metadata:
                console.print(f"[yellow]Warning: {file_path.name} missing '{field}'[/yellow]")
                return None

        return {
            "path": str(file_path),
            "filename": file_path.name,
            "metadata": post.metadata,
            "content": post.content,
            "hash": get_file_hash(post.content),
        }
    except Exception as e:
        console.print(f"[red]Error parsing {file_path}: {e}[/red]")
        return None


def chunk_note(note: dict, chunk_size: int = 500, overlap: int = 50) -> list[dict]:
    """Split note content into semantic chunks."""
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size,
        chunk_overlap=overlap,
        separators=["\n## ", "\n### ", "\n#### ", "\n\n", "\n", " "],
    )

    chunks = splitter.split_text(note["content"])

    return [
        {
            "id": f"{note['filename']}_{i}",
            "content": chunk,
            "metadata": {
                **note["metadata"],
                "filename": note["filename"],
                "path": note["path"],
                "chunk_index": i,
                "total_chunks": len(chunks),
            },
        }
        for i, chunk in enumerate(chunks)
    ]


def generate_embedding(text: str, model: str = "nomic-embed-text") -> list[float]:
    """Generate embedding using Ollama."""
    response = ollama.embeddings(model=model, prompt=text)
    return response["embedding"]


def ingest_notes(config: dict, force: bool = False):
    """Main ingestion function."""
    notes_dir = Path(config["notes_dir"])

    # Initialize ChromaDB
    client = chromadb.PersistentClient(path=config["chroma_dir"])
    collection = client.get_or_create_collection(
        name="notes",
        metadata={"hnsw:space": "cosine"},
    )

    # Get existing document hashes
    existing = {}
    if not force:
        try:
            results = collection.get(include=["metadatas"])
            for id_, meta in zip(results["ids"], results["metadatas"]):
                if "hash" in meta:
                    existing[meta.get("filename", "")] = meta["hash"]
        except Exception:
            pass

    # Find all markdown files
    md_files = list(notes_dir.glob("*.md"))
    ignore_dirs = config.get("ignore_dirs", [])

    console.print(f"[blue]Found {len(md_files)} markdown files[/blue]")

    added, updated, skipped = 0, 0, 0

    for file_path in track(md_files, description="Processing notes..."):
        # Skip ignored directories
        if any(ignored in str(file_path) for ignored in ignore_dirs):
            continue

        note = parse_note(file_path)
        if not note:
            skipped += 1
            continue

        # Skip if excluded type
        if note["metadata"].get("type") in config.get("exclude_types", []):
            skipped += 1
            continue

        # Skip if unchanged
        if note["filename"] in existing and existing[note["filename"]] == note["hash"]:
            skipped += 1
            continue

        # Delete old chunks if updating
        if note["filename"] in existing:
            old_ids = collection.get(where={"filename": note["filename"]})["ids"]
            if old_ids:
                collection.delete(ids=old_ids)
            updated += 1
        else:
            added += 1

        # Chunk and embed
        chunks = chunk_note(note, config["chunk_size"], config["chunk_overlap"])

        for chunk in chunks:
            # Include summary in embedding if available
            embed_text = chunk["content"]
            if summary := note["metadata"].get("summary"):
                embed_text = f"{summary}\n\n{embed_text}"

            embedding = generate_embedding(embed_text, config["embedding_model"])

            # Store hash for change detection
            chunk["metadata"]["hash"] = note["hash"]

            # Convert tags list to string for ChromaDB
            if "tags" in chunk["metadata"]:
                chunk["metadata"]["tags"] = ",".join(chunk["metadata"]["tags"])

            # Convert date to string
            if "date" in chunk["metadata"]:
                chunk["metadata"]["date"] = str(chunk["metadata"]["date"])

            # Remove any None values
            chunk["metadata"] = {k: v for k, v in chunk["metadata"].items() if v is not None}

            collection.add(
                ids=[chunk["id"]],
                embeddings=[embedding],
                documents=[chunk["content"]],
                metadatas=[chunk["metadata"]],
            )

    console.print(f"[green]Done! Added: {added}, Updated: {updated}, Skipped: {skipped}[/green]")


if __name__ == "__main__":
    config = load_config()
    ingest_notes(config)
```

### Query Interface

**query.py:**
```python
#!/usr/bin/env python3
"""
Query interface for notes RAG system.
"""

import chromadb
import ollama
import yaml
from rich.console import Console
from rich.markdown import Markdown
from rich.panel import Panel

console = Console()


def load_config(config_path: str = "config.yaml") -> dict:
    with open(config_path) as f:
        config = yaml.safe_load(f)
    config["chroma_dir"] = os.path.expanduser(config["chroma_dir"])
    return config


def query_notes(
    question: str,
    config: dict,
    n_results: int = 5,
    filter_tags: list[str] = None,
    filter_type: str = None,
) -> str:
    """Query notes and generate response."""

    # Initialize ChromaDB
    client = chromadb.PersistentClient(path=config["chroma_dir"])
    collection = client.get_collection("notes")

    # Generate query embedding
    query_embedding = ollama.embeddings(
        model=config["embedding_model"],
        prompt=question,
    )["embedding"]

    # Build filter
    where = {}
    if filter_tags:
        # ChromaDB doesn't support array contains, so we use string matching
        where["tags"] = {"$contains": filter_tags[0]}
    if filter_type:
        where["type"] = filter_type

    # Query
    results = collection.query(
        query_embeddings=[query_embedding],
        n_results=n_results,
        where=where if where else None,
        include=["documents", "metadatas", "distances"],
    )

    # Format context
    context_parts = []
    sources = []

    for doc, meta, dist in zip(
        results["documents"][0],
        results["metadatas"][0],
        results["distances"][0],
    ):
        title = meta.get("title", meta.get("filename", "Unknown"))
        context_parts.append(f"## {title}\n{doc}")
        sources.append(f"- {title} (relevance: {1-dist:.2f})")

    context = "\n\n---\n\n".join(context_parts)

    # Generate response
    system_prompt = """You are a helpful assistant answering questions based on the user's personal notes.
Use the provided context to answer questions accurately.
If the context doesn't contain relevant information, say so.
Always cite which notes you're drawing from."""

    response = ollama.chat(
        model=config["llm_model"],
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": f"Context from notes:\n\n{context}\n\n---\n\nQuestion: {question}"},
        ],
    )

    answer = response["message"]["content"]

    return answer, sources


def interactive_query(config: dict):
    """Interactive query loop."""
    console.print(Panel("Notes RAG System - Type 'quit' to exit", style="blue"))

    while True:
        question = console.input("\n[bold green]Question:[/bold green] ")

        if question.lower() in ("quit", "exit", "q"):
            break

        if not question.strip():
            continue

        console.print("\n[dim]Thinking...[/dim]")

        answer, sources = query_notes(question, config)

        console.print("\n[bold blue]Answer:[/bold blue]")
        console.print(Markdown(answer))

        console.print("\n[bold yellow]Sources:[/bold yellow]")
        for source in sources:
            console.print(source)


if __name__ == "__main__":
    import os
    config = load_config()
    interactive_query(config)
```

### File Watcher Daemon

**watch.py:**
```python
#!/usr/bin/env python3
"""
File watcher for automatic note ingestion.
"""

import time
from pathlib import Path

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from rich.console import Console

from ingest import load_config, parse_note, chunk_note, generate_embedding
import chromadb

console = Console()


class NoteHandler(FileSystemEventHandler):
    def __init__(self, config: dict):
        self.config = config
        self.client = chromadb.PersistentClient(path=config["chroma_dir"])
        self.collection = self.client.get_or_create_collection("notes")

    def on_modified(self, event):
        if event.is_directory or not event.src_path.endswith(".md"):
            return
        self._process_file(Path(event.src_path))

    def on_created(self, event):
        if event.is_directory or not event.src_path.endswith(".md"):
            return
        self._process_file(Path(event.src_path))

    def on_deleted(self, event):
        if event.is_directory or not event.src_path.endswith(".md"):
            return
        filename = Path(event.src_path).name
        old_ids = self.collection.get(where={"filename": filename})["ids"]
        if old_ids:
            self.collection.delete(ids=old_ids)
            console.print(f"[red]Deleted: {filename}[/red]")

    def _process_file(self, file_path: Path):
        note = parse_note(file_path)
        if not note:
            return

        # Delete old chunks
        old_ids = self.collection.get(where={"filename": note["filename"]})["ids"]
        if old_ids:
            self.collection.delete(ids=old_ids)

        # Re-ingest
        chunks = chunk_note(note, self.config["chunk_size"], self.config["chunk_overlap"])

        for chunk in chunks:
            embed_text = chunk["content"]
            if summary := note["metadata"].get("summary"):
                embed_text = f"{summary}\n\n{embed_text}"

            embedding = generate_embedding(embed_text, self.config["embedding_model"])

            chunk["metadata"]["hash"] = note["hash"]
            if "tags" in chunk["metadata"]:
                chunk["metadata"]["tags"] = ",".join(chunk["metadata"]["tags"])
            if "date" in chunk["metadata"]:
                chunk["metadata"]["date"] = str(chunk["metadata"]["date"])
            chunk["metadata"] = {k: v for k, v in chunk["metadata"].items() if v is not None}

            self.collection.add(
                ids=[chunk["id"]],
                embeddings=[embedding],
                documents=[chunk["content"]],
                metadatas=[chunk["metadata"]],
            )

        console.print(f"[green]Indexed: {file_path.name}[/green]")


def watch_notes(config: dict):
    """Start watching notes directory."""
    notes_dir = config["notes_dir"]

    console.print(f"[blue]Watching {notes_dir} for changes...[/blue]")
    console.print("[dim]Press Ctrl+C to stop[/dim]")

    handler = NoteHandler(config)
    observer = Observer()
    observer.schedule(handler, notes_dir, recursive=False)
    observer.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()

    observer.join()


if __name__ == "__main__":
    config = load_config()
    watch_notes(config)
```

---

## CLI Interface

**cli.py:**
```python
#!/usr/bin/env python3
"""
CLI interface for notes RAG system.
"""

import os
from pathlib import Path
from typing import Optional

import typer
from rich.console import Console
from rich.table import Table

from ingest import load_config, ingest_notes
from query import query_notes, interactive_query
from watch import watch_notes

app = typer.Typer(help="Notes RAG System CLI")
console = Console()


@app.command()
def ingest(
    force: bool = typer.Option(False, "--force", "-f", help="Force re-ingest all notes"),
    config_path: str = typer.Option("config.yaml", "--config", "-c"),
):
    """Ingest notes into the RAG system."""
    config = load_config(config_path)
    ingest_notes(config, force=force)


@app.command()
def query(
    question: str = typer.Argument(None, help="Question to ask"),
    interactive: bool = typer.Option(False, "--interactive", "-i", help="Interactive mode"),
    tags: str = typer.Option(None, "--tags", "-t", help="Filter by tags (comma-separated)"),
    note_type: str = typer.Option(None, "--type", help="Filter by note type"),
    results: int = typer.Option(5, "--results", "-n", help="Number of results to retrieve"),
    config_path: str = typer.Option("config.yaml", "--config", "-c"),
):
    """Query your notes using natural language."""
    config = load_config(config_path)

    if interactive or not question:
        interactive_query(config)
    else:
        filter_tags = tags.split(",") if tags else None
        answer, sources = query_notes(
            question, config,
            n_results=results,
            filter_tags=filter_tags,
            filter_type=note_type,
        )
        console.print(f"\n[bold blue]Answer:[/bold blue]\n{answer}")
        console.print(f"\n[bold yellow]Sources:[/bold yellow]")
        for source in sources:
            console.print(source)


@app.command()
def watch(config_path: str = typer.Option("config.yaml", "--config", "-c")):
    """Watch notes directory and auto-ingest changes."""
    config = load_config(config_path)
    watch_notes(config)


@app.command()
def stats(config_path: str = typer.Option("config.yaml", "--config", "-c")):
    """Show statistics about indexed notes."""
    import chromadb

    config = load_config(config_path)
    client = chromadb.PersistentClient(path=config["chroma_dir"])

    try:
        collection = client.get_collection("notes")
        count = collection.count()

        # Get unique files
        results = collection.get(include=["metadatas"])
        files = set(m.get("filename") for m in results["metadatas"])
        types = {}
        for m in results["metadatas"]:
            t = m.get("type", "unknown")
            types[t] = types.get(t, 0) + 1

        table = Table(title="Notes RAG Statistics")
        table.add_column("Metric", style="cyan")
        table.add_column("Value", style="green")

        table.add_row("Total chunks", str(count))
        table.add_row("Unique notes", str(len(files)))
        table.add_row("Note types", ", ".join(f"{k}: {v}" for k, v in types.items()))

        console.print(table)
    except Exception as e:
        console.print(f"[red]Error: {e}[/red]")
        console.print("[yellow]Run 'notes-rag ingest' first[/yellow]")


if __name__ == "__main__":
    app()
```

### Installation Script

**install.sh:**
```bash
#!/bin/bash
# Install notes-rag CLI

set -e

INSTALL_DIR="$HOME/notes-rag"

echo "Installing notes-rag to $INSTALL_DIR..."

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install chromadb ollama python-frontmatter langchain langchain-community watchdog typer rich pyyaml

# Create symlink for CLI
echo '#!/bin/bash
source "$HOME/notes-rag/venv/bin/activate"
python "$HOME/notes-rag/cli.py" "$@"' > "$HOME/.local/bin/notes-rag"
chmod +x "$HOME/.local/bin/notes-rag"

echo "Installation complete!"
echo "Run 'notes-rag --help' to get started"
```

---

## Neovim Integration

### Query from Neovim

Add to your Neovim config:

```lua
-- Notes RAG integration
vim.api.nvim_create_user_command("NotesQuery", function(opts)
  local question = opts.args
  if question == "" then
    question = vim.fn.input("Question: ")
  end

  local cmd = string.format("notes-rag query '%s'", question:gsub("'", "'\\''"))

  -- Open in floating window
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  })

  vim.fn.termopen(cmd)
  vim.cmd("startinsert")
end, { nargs = "?" })

-- Keybinding
vim.keymap.set("n", "<leader>nq", "<cmd>NotesQuery<CR>", { desc = "Query notes RAG" })
vim.keymap.set("n", "<leader>ni", "<cmd>!notes-rag ingest<CR>", { desc = "Ingest notes" })
```

### Telescope Integration (Optional)

```lua
-- Search notes by metadata
local function notes_search()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values

  -- Get notes metadata from RAG system
  local handle = io.popen("notes-rag stats --json 2>/dev/null")
  local result = handle:read("*a")
  handle:close()

  -- Parse and display
  -- ... (implementation depends on stats --json output)
end
```

---

## Quick Start

1. **Install Ollama** and pull required models:
   ```bash
   ollama pull nomic-embed-text
   ollama pull llama3.2
   ```

2. **Install notes-rag:**
   ```bash
   cd ~/notes-rag
   ./install.sh
   ```

3. **Configure:**
   ```bash
   cp config.yaml.example config.yaml
   # Edit as needed
   ```

4. **Initial ingest:**
   ```bash
   notes-rag ingest
   ```

5. **Query your notes:**
   ```bash
   notes-rag query "What do I know about Python async?"
   notes-rag query -i  # Interactive mode
   ```

6. **Auto-ingest on changes:**
   ```bash
   notes-rag watch  # Run in background/tmux
   ```

---

## Future Enhancements

- [ ] Web UI for browsing and querying
- [ ] Graph visualization of note relationships
- [ ] Automatic tag suggestions
- [ ] Summarization of note clusters
- [ ] Export to other formats (Anki, etc.)
- [ ] Multi-vault support
- [ ] Semantic duplicate detection
