CREATE TYPE transaction_status_enum AS ENUM
(
    'BORROWED',
    'RETURNED',
    'OVERDUE',
    'LOST',
    'CANCELLED'
);

CREATE TYPE fine_reason_enum AS ENUM
(
    'LATE_RETURN',
    'DAMAGED_BOOK',
    'LOST_BOOK',
    'OTHER'
);



CREATE TABLE authors
(
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(100) NOT NULL,
    surname     VARCHAR(100) NOT NULL,
    birth_date  DATE
);

CREATE TABLE categories
(
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE roles
(
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(100) NOT NULL UNIQUE,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE staff
(
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email       VARCHAR(255) NOT NULL UNIQUE,
    name        VARCHAR(100) NOT NULL,
    surname     VARCHAR(100) NOT NULL,
    role_id     UUID NOT NULL,
    CONSTRAINT fk_staff_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE students
(
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name             VARCHAR(100) NOT NULL,
    surname          VARCHAR(100) NOT NULL,
    email            VARCHAR(255) NOT NULL UNIQUE,
    email_confirmed  BOOLEAN NOT NULL DEFAULT FALSE,
    is_active        BOOLEAN NOT NULL DEFAULT TRUE,
    fine_point       INTEGER NOT NULL DEFAULT 0 CHECK (fine_point >= 0)
);

CREATE TABLE books
(
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barcode_no    VARCHAR(50) NOT NULL UNIQUE,
    name          VARCHAR(255) NOT NULL,
    author_id     UUID NOT NULL,
    stock         INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    CONSTRAINT fk_books_author
        FOREIGN KEY (author_id)
        REFERENCES authors(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE book_categories
(
    book_id       UUID NOT NULL,
    category_id   UUID NOT NULL,
    PRIMARY KEY (book_id, category_id),
    CONSTRAINT fk_book_categories_book
        FOREIGN KEY (book_id)
        REFERENCES books(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_book_categories_category
        FOREIGN KEY (category_id)
        REFERENCES categories(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE library_transactions
(
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id     UUID NOT NULL,
    book_id        UUID NOT NULL,
    staff_id       UUID NOT NULL,
    start_date     TIMESTAMP NOT NULL,
    end_date       TIMESTAMP NOT NULL,
    delivery_date  TIMESTAMP NULL,
    status         transaction_status_enum NOT NULL,
    CONSTRAINT fk_transactions_student
        FOREIGN KEY (student_id)
        REFERENCES students(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_transactions_book
        FOREIGN KEY (book_id)
        REFERENCES books(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_transactions_staff
        FOREIGN KEY (staff_id)
        REFERENCES staff(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_transaction_dates
        CHECK (end_date >= start_date),
    CONSTRAINT chk_delivery_after_start
        CHECK (delivery_date IS NULL OR delivery_date >= start_date)
);

CREATE TABLE fines
(
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id  UUID NOT NULL UNIQUE,
    price           NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    is_paid         BOOLEAN NOT NULL DEFAULT FALSE,
    reason          fine_reason_enum NOT NULL,
    CONSTRAINT fk_fines_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES library_transactions(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);



INSERT INTO authors (id, name, surname, birth_date) VALUES
('11111111-1111-1111-1111-111111111111', 'George', 'Orwell', '1903-06-25'),
('11111111-1111-1111-1111-111111111112', 'Fyodor', 'Dostoevsky', '1821-11-11'),
('11111111-1111-1111-1111-111111111113', 'Jane', 'Austen', '1775-12-16'),
('11111111-1111-1111-1111-111111111114', 'Ahmet', 'Hamdi Tanpinar', '1901-06-23'),
('11111111-1111-1111-1111-111111111115', 'Sabahattin', 'Ali', '1907-02-25');


INSERT INTO categories (id, name) VALUES
('22222222-2222-2222-2222-222222222221', 'Roman'),
('22222222-2222-2222-2222-222222222222', 'Klasik'),
('22222222-2222-2222-2222-222222222223', 'Bilim Kurgu'),
('22222222-2222-2222-2222-222222222224', 'Psikoloji'),
('22222222-2222-2222-2222-222222222225', 'Turk Edebiyati');


INSERT INTO roles (id, name, is_active) VALUES
('33333333-3333-3333-3333-333333333331', 'Kutuphane Muduru', TRUE),
('33333333-3333-3333-3333-333333333332', 'Kutuphane Gorevlisi', TRUE),
('33333333-3333-3333-3333-333333333333', 'Arsiv Sorumlusu', TRUE),
('33333333-3333-3333-3333-333333333334', 'Danisma Personeli', TRUE),
('33333333-3333-3333-3333-333333333335', 'Stajyer', TRUE);


INSERT INTO staff (id, email, name, surname, role_id) VALUES
('44444444-4444-4444-4444-444444444441', 'ayse.yilmaz@library.edu', 'Ayse', 'Yilmaz', '33333333-3333-3333-3333-333333333331'),
('44444444-4444-4444-4444-444444444442', 'mehmet.kaya@library.edu', 'Mehmet', 'Kaya', '33333333-3333-3333-3333-333333333332'),
('44444444-4444-4444-4444-444444444443', 'zeynep.demir@library.edu', 'Zeynep', 'Demir', '33333333-3333-3333-3333-333333333333'),
('44444444-4444-4444-4444-444444444444', 'ali.can@library.edu', 'Ali', 'Can', '33333333-3333-3333-3333-333333333334'),
('44444444-4444-4444-4444-444444444445', 'elif.sahin@library.edu', 'Elif', 'Sahin', '33333333-3333-3333-3333-333333333335');


INSERT INTO students (id, name, surname, email, email_confirmed, is_active, fine_point) VALUES
('55555555-5555-5555-5555-555555555551', 'Kaan', 'Kaya', 'kaan.kaya@student.edu', TRUE, TRUE, 2),
('55555555-5555-5555-5555-555555555552', 'Merve', 'Aydin', 'merve.aydin@student.edu', TRUE, TRUE, 0),
('55555555-5555-5555-5555-555555555553', 'Burak', 'Celik', 'burak.celik@student.edu', FALSE, TRUE, 1),
('55555555-5555-5555-5555-555555555554', 'Ece', 'Arslan', 'ece.arslan@student.edu', TRUE, TRUE, 5),
('55555555-5555-5555-5555-555555555555', 'Yusuf', 'Kurt', 'yusuf.kurt@student.edu', TRUE, FALSE, 0);


INSERT INTO books (id, barcode_no, name, author_id, stock) VALUES
('66666666-6666-6666-6666-666666666661', 'BK-1001', '1984', '11111111-1111-1111-1111-111111111111', 4),
('66666666-6666-6666-6666-666666666662', 'BK-1002', 'Suclu ve Ceza', '11111111-1111-1111-1111-111111111112', 3),
('66666666-6666-6666-6666-666666666663', 'BK-1003', 'Ask ve Gurur', '11111111-1111-1111-1111-111111111113', 5),
('66666666-6666-6666-6666-666666666664', 'BK-1004', 'Huzur', '11111111-1111-1111-1111-111111111114', 2),
('66666666-6666-6666-6666-666666666665', 'BK-1005', 'Kurk Mantolu Madonna', '11111111-1111-1111-1111-111111111115', 6);

INSERT INTO book_categories (book_id, category_id) VALUES
('66666666-6666-6666-6666-666666666661', '22222222-2222-2222-2222-222222222223'),
('66666666-6666-6666-6666-666666666662', '22222222-2222-2222-2222-222222222224'),
('66666666-6666-6666-6666-666666666663', '22222222-2222-2222-2222-222222222222'),
('66666666-6666-6666-6666-666666666664', '22222222-2222-2222-2222-222222222225'),
('66666666-6666-6666-6666-666666666665', '22222222-2222-2222-2222-222222222221');


INSERT INTO library_transactions
(id, student_id, book_id, staff_id, start_date, end_date, delivery_date, status) VALUES
(
    '77777777-7777-7777-7777-777777777771',
    '55555555-5555-5555-5555-555555555551',
    '66666666-6666-6666-6666-666666666661',
    '44444444-4444-4444-4444-444444444442',
    '2026-04-01 10:00:00',
    '2026-04-10 10:00:00',
    '2026-04-08 14:00:00',
    'RETURNED'
),
(
    '77777777-7777-7777-7777-777777777772',
    '55555555-5555-5555-5555-555555555552',
    '66666666-6666-6666-6666-666666666662',
    '44444444-4444-4444-4444-444444444442',
    '2026-04-03 09:30:00',
    '2026-04-12 09:30:00',
    NULL,
    'BORROWED'
),
(
    '77777777-7777-7777-7777-777777777773',
    '55555555-5555-5555-5555-555555555553',
    '66666666-6666-6666-6666-666666666663',
    '44444444-4444-4444-4444-444444444443',
    '2026-03-20 11:00:00',
    '2026-03-29 11:00:00',
    '2026-04-02 16:00:00',
    'OVERDUE'
),
(
    '77777777-7777-7777-7777-777777777774',
    '55555555-5555-5555-5555-555555555554',
    '66666666-6666-6666-6666-666666666664',
    '44444444-4444-4444-4444-444444444444',
    '2026-03-10 13:15:00',
    '2026-03-19 13:15:00',
    '2026-03-18 10:00:00',
    'RETURNED'
),
(
    '77777777-7777-7777-7777-777777777775',
    '55555555-5555-5555-5555-555555555555',
    '66666666-6666-6666-6666-666666666665',
    '44444444-4444-4444-4444-444444444445',
    '2026-03-05 08:45:00',
    '2026-03-14 08:45:00',
    NULL,
    'LOST'
);


INSERT INTO fines (id, transaction_id, price, is_paid, reason) VALUES
('88888888-8888-8888-8888-888888888881', '77777777-7777-7777-7777-777777777771', 0.00, TRUE, 'OTHER'),
('88888888-8888-8888-8888-888888888882', '77777777-7777-7777-7777-777777777772', 0.00, FALSE, 'OTHER'),
('88888888-8888-8888-8888-888888888883', '77777777-7777-7777-7777-777777777773', 35.50, FALSE, 'LATE_RETURN'),
('88888888-8888-8888-8888-888888888884', '77777777-7777-7777-7777-777777777774', 0.00, TRUE, 'OTHER'),
('88888888-8888-8888-8888-888888888885', '77777777-7777-7777-7777-777777777775', 250.00, FALSE, 'LOST_BOOK');



SELECT b.name AS book_name, a.name || ' ' || a.surname AS author_name, b.stock
FROM books b
JOIN authors a ON a.id = b.author_id;


SELECT
     t.id,
     s.name || ' ' || s.surname AS student_name,
     b.name AS book_name,
     t.start_date,
     t.end_date,
     t.status
 FROM library_transactions t
 JOIN students s ON s.id = t.student_id
 JOIN books b ON b.id = t.book_id
 WHERE t.status IN ('BORROWED', 'OVERDUE', 'LOST');



 SELECT
    f.id,
     b.name AS book_name,
     s.name || ' ' || s.surname AS student_name,
     f.price,
     f.reason,
     f.is_paid
 FROM fines f
 JOIN library_transactions t ON t.id = f.transaction_id
 JOIN students s ON s.id = t.student_id
 JOIN books b ON b.id = t.book_id;
