---
description: Generate or update database schema SQL from the data model
allowed-tools: Read, Write, Edit
---

Generate PostgreSQL DDL schema based on the data model in docs/03-Data-Model-Schema.md.

Requirements:
- Read the current data model document first
- Generate complete CREATE TABLE statements
- Include all indexes, constraints, and triggers
- Use the naming conventions defined in the doc (snake_case tables, UUID primary keys)
- Output to a new file or update existing schema file
