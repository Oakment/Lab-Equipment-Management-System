SET NAMES utf8mb4;

DROP TABLE IF EXISTS damage_reports;
DROP TABLE IF EXISTS borrow_requests;
DROP TABLE IF EXISTS equipment;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;

-- ---------------------------------------------------------------------------
-- users: students and lab administrators. Public registration creates students;
-- admins are created via seed/manual SQL.
-- ---------------------------------------------------------------------------
CREATE TABLE users (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name           VARCHAR(100) NOT NULL,
  email          VARCHAR(255) NOT NULL,
  password_hash  VARCHAR(255) NOT NULL,          -- bcrypt hash (60 chars), never plaintext
  role           ENUM('student', 'admin') NOT NULL DEFAULT 'student',
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- categories
-- ---------------------------------------------------------------------------
CREATE TABLE categories (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name         VARCHAR(100) NOT NULL,
  description  VARCHAR(255) NULL,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_categories_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- equipment: one row per physical item.
-- status  = where the item is right now.
-- is_active = FALSE means removed from the catalogue ("deleted") but kept so
--             past borrow requests and damage reports still reference it.
-- ---------------------------------------------------------------------------
CREATE TABLE equipment (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  category_id    INT UNSIGNED NOT NULL,
  name           VARCHAR(150) NOT NULL,
  description    TEXT NULL,
  model          VARCHAR(100) NULL,
  serial_number  VARCHAR(100) NULL,               -- NULL allowed for items without one
  location       VARCHAR(100) NULL,               -- e.g. lab room / cabinet
  status         ENUM('Available', 'Requested', 'Borrowed', 'Damaged', 'Under Maintenance')
                 NOT NULL DEFAULT 'Available',
  is_active      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_equipment_serial (serial_number),  -- multiple NULLs are allowed
  KEY idx_equipment_category (category_id),
  KEY idx_equipment_active_status (is_active, status),
  CONSTRAINT fk_equipment_category
    FOREIGN KEY (category_id) REFERENCES categories (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- borrow_requests: lifecycle Pending -> Approved -> Returned, or Pending -> Rejected.
-- requested_at doubles as the row's creation timestamp.
-- "Only one open request per item" is enforced by the backend (conditional
-- equipment status update inside a transaction), not by a constraint here.
-- ---------------------------------------------------------------------------
CREATE TABLE borrow_requests (
  id                   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id              INT UNSIGNED NOT NULL,
  equipment_id         INT UNSIGNED NOT NULL,
  status               ENUM('Pending', 'Approved', 'Rejected', 'Returned') NOT NULL DEFAULT 'Pending',
  purpose              VARCHAR(255) NULL,          -- student's reason for borrowing
  admin_note           VARCHAR(255) NULL,          -- e.g. reason for rejection
  requested_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  planned_return_date  DATE NOT NULL,
  actual_return_date   DATETIME NULL,              -- set only when returned
  updated_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_requests_user_status (user_id, status),
  KEY idx_requests_equipment (equipment_id),
  KEY idx_requests_status (status),
  CONSTRAINT fk_requests_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_requests_equipment
    FOREIGN KEY (equipment_id) REFERENCES equipment (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_requests_return_date
    CHECK (planned_return_date >= DATE(requested_at)),
  CONSTRAINT chk_requests_returned_consistency
    CHECK ((status = 'Returned') = (actual_return_date IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- damage_reports: filed by students (or admins), reviewed by admins.
-- ---------------------------------------------------------------------------
CREATE TABLE damage_reports (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id       INT UNSIGNED NOT NULL,
  equipment_id  INT UNSIGNED NOT NULL,
  description   TEXT NOT NULL,
  status        ENUM('Open', 'Resolved', 'Dismissed') NOT NULL DEFAULT 'Open',
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_reports_status (status),
  KEY idx_reports_user (user_id),
  KEY idx_reports_equipment (equipment_id),
  CONSTRAINT fk_reports_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_reports_equipment
    FOREIGN KEY (equipment_id) REFERENCES equipment (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
