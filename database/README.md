# Database

MySQL schema and sample data for the Lab Equipment Management System.
Works with **MySQL 8.0.16+** and **MariaDB 10.4+** (needed for enforced `CHECK` constraints).

| File         | Purpose                                                          |
|--------------|------------------------------------------------------------------|
| `schema.sql` | Drops and recreates all tables (**deletes existing data**)       |
| `seed.sql`   | Inserts sample users, categories, equipment, requests, reports   |

## Setup

Run these from the `database/` folder. On MariaDB you can use `mariadb` instead of `mysql`.

**1. Create the database and an app user** (as the MySQL root/admin user):

```bash
mysql -u root -p
```

```sql
CREATE DATABASE lab_equipment_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'lab_app'@'localhost' IDENTIFIED BY 'change_this_password';
GRANT ALL PRIVILEGES ON lab_equipment_db.* TO 'lab_app'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

The backend will connect as `lab_app` (credentials go in `backend/.env`, never in code).

**2. Create the tables:**

```bash
mysql -u lab_app -p lab_equipment_db < schema.sql
```

**3. Load the sample data:**

```bash
mysql -u lab_app -p lab_equipment_db < seed.sql
```

**Reset everything** at any time by running steps 2 and 3 again.

## Sample logins

| Role    | Email           | Password      |
|---------|-----------------|---------------|
| Admin   | `admin@lab.edu` | `Admin@123`   |
| Student | `arjun@uni.edu` | `Student@123` |
| Student | `sara@uni.edu`  | `Student@123` |

Passwords are stored as bcrypt hashes (cost 10). These are for local development only.

## Tables

```
users ──< borrow_requests >── equipment >── categories
  └────< damage_reports  >──────┘
```

- **users** — `role` is `student` or `admin`; `email` is unique and used to log in.
- **categories** — unique `name`.
- **equipment** — one row per physical item. `status` is where the item is now
  (`Available`, `Requested`, `Borrowed`, `Damaged`, `Under Maintenance`).
  `is_active = FALSE` means removed from the catalogue.
- **borrow_requests** — `Pending → Approved → Returned`, or `Pending → Rejected`.
- **damage_reports** — `Open`, then `Resolved` or `Dismissed` by an admin.

## Assumptions

- **Equipment is never deleted.** Deactivate it with `is_active = FALSE`. All foreign keys
  use `ON DELETE RESTRICT`, so the database refuses to delete a user, item or category that
  history still points to.
- **Equipment status and request status must be kept in sync by the backend.** e.g. approving
  a request sets the request to `Approved` *and* the item to `Borrowed`, in one transaction.
  The seed data follows these rules.
- **One open request per item** (Pending/Approved) is enforced by the backend, which only
  accepts a request if the item is still `Available`.
- `requested_at` is the request's creation time; `actual_return_date` is set only when the
  status is `Returned` (enforced by a `CHECK` constraint).
- `planned_return_date` cannot be earlier than the request date (`CHECK` constraint).
- Seed dates are relative to the current date, so there is always one overdue loan,
  two pending requests and one currently borrowed item.
