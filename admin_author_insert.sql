INSERT INTO admin.author(name_, email_, access_, start_date, create_date, source_)
SELECT 'kds discovery author', 'kds@kds_discovery.com', 'all', '2025-04-02', '2025-04-02', 'kds discovery'
WHERE NOT EXISTS (SELECT 1 FROM admin.author);
