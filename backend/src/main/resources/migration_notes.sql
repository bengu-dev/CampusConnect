-- ─────────────────────────────────────────────
-- MIGRATION: Kişisel Notlar Tablosu
-- Bu dosyayı init.sql'in sonuna ekle VEYA
-- Docker çalışırken psql ile çalıştır:
--   docker exec -i <container> psql -U postgres -d campusconnect < migration_notes.sql
-- ─────────────────────────────────────────────

-- NOTES tablosu
CREATE TABLE IF NOT EXISTS notes (
    id         BIGSERIAL    PRIMARY KEY,
    user_id    BIGINT       NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title      VARCHAR(300) NOT NULL,
    content    TEXT         DEFAULT '',
    category   VARCHAR(20)  NOT NULL DEFAULT 'PERSONAL'
               CHECK (category IN ('PERSONAL', 'WORK', 'SOCIAL')),
    color      VARCHAR(20)  DEFAULT '#6366F1',
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_notes_user     ON notes(user_id);
CREATE INDEX IF NOT EXISTS idx_notes_category ON notes(user_id, category);
CREATE INDEX IF NOT EXISTS idx_notes_updated  ON notes(user_id, updated_at DESC);
