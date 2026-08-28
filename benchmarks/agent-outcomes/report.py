"""Plain, loss-preserving Markdown rendering for offline aggregates."""


def render(rows, summary=None):
    lines=["# Agent outcome benchmark", "", "## Measured facts", "", "| Task | Condition | Success | Evidence |", "| --- | --- | --- | --- |"]
    for row in rows:
        lines.append("| {task} | {condition} | {success} | {evidence} |".format(**row))
    if summary:
        lines += ["", "## Coverage", "", f"Planned trials: {summary['planned']}; complete: {summary['complete']}; incomplete: {summary['incomplete']}."]
        for name, metric in summary.get("metrics", {}).items():
            lines.append(f"{name}: {metric['summary']}; unavailable: {metric['unavailable']}.")
    lines += ["", "## Interpretation", "", "Results are task- and runtime-bound; this maintained corpus does not establish universal coding-agent or foundation-model quality. No improvement claim is made without complete objective evidence."]
    return "\n".join(lines)+"\n"
