create table courses
(
    course_id   INTEGER not null
        primary key autoincrement,
    title       TEXT,
    description TEXT,
    subject     TEXT,
    provider    TEXT,
    difficulty  INTEGER,
    link        TEXT,
    rating      INTEGER,
    image       TEXT,
    archived    INTEGER not null default 0
);

create table users
(
    user_id          INTEGER not null
        primary key autoincrement,
    username         TEXT,
    password         TEXT,
    email            TEXT,
    permission_level INTEGER
);

CREATE TABLE messages
(
    message_id      INTEGER not null primary key,
    thread_id       INTEGER,
    message_body    TEXT,
    message_summary TEXT,
    sender_id       INTEGER constraint messages_users_user_id_fk references users,
    timestamp       TEXT
);

create table profiles
(
    first_name   TEXT,
    last_name    TEXT,
    course_level INTEGER,
    year         INTEGER,
    user_id      INTEGER
        references users
            on delete cascade,
    profile_id   INTEGER not null
        primary key autoincrement,
    interests TEXT
        default "[]"
);

create table course_progress
(
    course_id  INTEGER
        references courses
            on delete cascade,
    learner_id INTEGER
        references profiles
            on delete cascade,
    progress   INTEGER,
    rating     INTEGER,
    progress_id   INTEGER not null
        primary key autoincrement
);

create table user_tokens
(
    user_id     INTEGER
        references users
            on delete cascade,
    created_at  INTEGER,
    token       TEXT,
    token_id    INTEGER not null
        primary key autoincrement
);

create table course_approval_queue
(
  course_id   INTEGER not null
        primary key autoincrement,
    title       TEXT,
    description TEXT,
    subject     TEXT,
    provider    TEXT,
    difficulty  INTEGER,
    link        TEXT,
    rating      INTEGER,
    image       TEXT,
  approved BOOLEAN DEFAULT false
);

create table suspended_users
(
    ban_id  INTEGER not null
        primary key autoincrement,
    user_id INTEGER
        references users
            on delete cascade,
    suspended_by INTEGER
        references users
            on delete cascade,
    expiry  INTEGER
);

CREATE TABLE bookmarks (
    bookmark_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    FOREIGN KEY(user_id) REFERENCES users(user_id),
    FOREIGN KEY(course_id) REFERENCES courses(course_id)
);
