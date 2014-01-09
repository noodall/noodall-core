Node.ensure_index(:position)
Node.ensure_index(:published_at)
Node.ensure_index(:published_to)
Node.ensure_index(:permalink)

Search.ensure_index(:_keywords)

Tagging.ensure_index(:tags)
