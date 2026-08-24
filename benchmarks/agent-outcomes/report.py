"""Plain, loss-preserving Markdown rendering for offline aggregates."""


def render(rows):
    lines=["# Agent outcome benchmark", "", "## Measured facts", "", "| Task | Condition | Success | Evidence |", "| --- | --- | --- | --- |"]
    for row in rows:
        lines.append("| {task} | {condition} | {success} | {evidence} |".format(**row))
    lines += ["", "## Interpretation", "", "Results are task- and runtime-bound; this maintained corpus does not establish universal coding-agent or foundation-model quality."]
    return "\n".join(lines)+"\n"
