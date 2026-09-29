-- Lab Equipment Management System — sample data
-- Run after schema.sql on an empty database.
-- Dates are relative to "now" so the data always looks current
-- (e.g. one borrow is always overdue, one request always pending).
--
-- Logins (bcrypt cost 10):
--   admin@lab.edu    / Admin@123    (admin)
--   arjun@uni.edu    / Student@123  (student)
--   sara@uni.edu     / Student@123  (student)

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------
-- Users
-- ---------------------------------------------------------------------------
INSERT INTO users (id, name, email, password_hash, role) VALUES
  (1, 'Lab Administrator', 'admin@lab.edu', '$2b$10$UQ/qMa6U3SKp9Zc20GYbwu8L9GRtDv2qapGIdohK9jP.0/doZdw02', 'admin'),
  (2, 'Arjun Mehta',       'arjun@uni.edu', '$2b$10$LdVsLE5NIawIoSAcEftnJOuRdFLrFLCBSgbHrUFs1Ikkd/aCm.5f6', 'student'),
  (3, 'Sara Thomas',       'sara@uni.edu',  '$2b$10$LdVsLE5NIawIoSAcEftnJOuRdFLrFLCBSgbHrUFs1Ikkd/aCm.5f6', 'student');

-- ---------------------------------------------------------------------------
-- Categories
-- ---------------------------------------------------------------------------
INSERT INTO categories (id, name, description) VALUES
  (1, 'Electronics',              'Oscilloscopes, signal generators, power supplies and tools'),
  (2, 'Measurement & Testing',    'Multimeters, calipers, meters and sensors'),
  (3, 'Optics & Microscopy',      'Microscopes and optical instruments'),
  (4, 'Computing & Networking',   'Laptops, single-board computers and network gear'),
  (5, 'Robotics & Embedded',      'Microcontroller kits and robotics components');

-- ---------------------------------------------------------------------------
-- Equipment (status must agree with the borrow requests / reports below)
-- ---------------------------------------------------------------------------
INSERT INTO equipment (id, category_id, name, description, model, serial_number, location, status, is_active) VALUES
  (1,  1, 'Digital Oscilloscope',        '4-channel, 100 MHz digital storage oscilloscope.',       'Rigol DS1054Z',      'OSC-2021-001', 'Electronics Lab, Bench 1', 'Borrowed',          TRUE),
  (2,  1, 'Digital Oscilloscope',        '4-channel, 100 MHz digital storage oscilloscope.',       'Rigol DS1054Z',      'OSC-2021-002', 'Electronics Lab, Bench 2', 'Available',         TRUE),
  (3,  1, 'Function Generator',          'Dual-channel arbitrary waveform generator, 25 MHz.',     'Siglent SDG1025',    'FG-2020-001',  'Electronics Lab, Shelf A', 'Available',         TRUE),
  (4,  1, 'DC Bench Power Supply',       'Triple output 0-30 V / 0-3 A linear supply.',           'Keysight E3631A',    'PSU-2019-004', 'Electronics Lab, Shelf A', 'Requested',         TRUE),
  (5,  2, 'Digital Multimeter',          'True-RMS handheld multimeter with probes.',              'Fluke 117',          'DMM-2022-001', 'Measurement Cabinet',      'Available',         TRUE),
  (6,  2, 'Digital Multimeter',          'True-RMS handheld multimeter with probes.',              'Fluke 117',          'DMM-2022-002', 'Measurement Cabinet',      'Damaged',           TRUE),
  (7,  3, 'Compound Microscope',         'Binocular microscope, 40x-1000x, LED illumination.',     'Olympus CX23',       'MIC-2018-011', 'Biology Lab, Cabinet 2',   'Available',         TRUE),
  (8,  3, 'Stereo Microscope',           'Zoom stereo microscope, 7x-45x.',                        'AmScope SM-4TZ',     'MIC-2019-003', 'Biology Lab, Cabinet 2',   'Under Maintenance', TRUE),
  (9,  4, 'Laptop',                      '14" laptop, Intel i5, 16 GB RAM, Ubuntu + Windows.',     'Dell Latitude 5440', 'LAP-2023-007', 'IT Store Room',            'Borrowed',          TRUE),
  (10, 4, 'Raspberry Pi 4 Kit',          '4 GB board, case, PSU, 32 GB microSD, HDMI cable.',      'Raspberry Pi 4 B',   'RPI-2022-015', 'Embedded Lab, Drawer 3',   'Requested',         TRUE),
  (11, 5, 'Arduino Starter Kit',         'Arduino Uno with breadboard, sensors and components.',   'Arduino Uno R3',     'ARD-2021-021', 'Embedded Lab, Drawer 1',   'Available',         TRUE),
  (12, 5, 'Arduino Starter Kit',         'Arduino Uno with breadboard, sensors and components.',   'Arduino Uno R3',     'ARD-2021-022', 'Embedded Lab, Drawer 1',   'Available',         TRUE),
  (13, 4, 'Managed Network Switch',      '24-port gigabit managed switch for networking labs.',    'Cisco CBS250-24T',   'NET-2020-002', 'Networking Lab, Rack 1',   'Available',         TRUE),
  (14, 1, 'Soldering Station',           'Temperature-controlled soldering station. Retired.',     'Hakko FX-888D',      'SOL-2016-001', 'Electronics Lab, Shelf B', 'Available',         FALSE),
  (15, 2, 'Digital Vernier Caliper',     '150 mm stainless digital caliper, 0.01 mm resolution.',  'Mitutoyo 500-196',   'CAL-2021-004', 'Measurement Cabinet',      'Available',         TRUE),
  (16, 2, 'pH Meter',                    'Benchtop pH meter with electrode and buffer solutions.', 'Hanna HI2211',       NULL,           'Chemistry Lab, Bench 4',   'Available',         TRUE);

-- ---------------------------------------------------------------------------
-- Borrow requests — one of each status, plus an overdue loan and an inactive item's history
-- ---------------------------------------------------------------------------
INSERT INTO borrow_requests
  (id, user_id, equipment_id, status, purpose, admin_note, requested_at, planned_return_date, actual_return_date) VALUES
  -- Approved and overdue (planned return date is in the past)
  (1, 2, 1,  'Approved', 'Signals & Systems mini project',     NULL,
      NOW() - INTERVAL 20 DAY, CURDATE() - INTERVAL 5 DAY,  NULL),
  -- Approved, currently borrowed, not yet due
  (2, 3, 9,  'Approved', 'Final year project development',     NULL,
      NOW() - INTERVAL 3 DAY,  CURDATE() + INTERVAL 7 DAY,  NULL),
  -- Pending
  (3, 3, 4,  'Pending',  'Power electronics lab assignment',   NULL,
      NOW() - INTERVAL 1 DAY,  CURDATE() + INTERVAL 5 DAY,  NULL),
  (4, 2, 10, 'Pending',  'IoT sensor logging project',         NULL,
      NOW() - INTERVAL 2 HOUR, CURDATE() + INTERVAL 14 DAY, NULL),
  -- Returned
  (5, 2, 2,  'Returned', 'Circuit analysis lab',               NULL,
      NOW() - INTERVAL 30 DAY, CURDATE() - INTERVAL 20 DAY, NOW() - INTERVAL 22 DAY),
  (6, 3, 14, 'Returned', 'PCB assembly workshop',              NULL,
      NOW() - INTERVAL 60 DAY, CURDATE() - INTERVAL 50 DAY, NOW() - INTERVAL 52 DAY),
  -- Rejected
  (7, 3, 11, 'Rejected', 'Personal hobby project',             'Kits are reserved for scheduled lab sessions.',
      NOW() - INTERVAL 10 DAY, CURDATE() - INTERVAL 3 DAY,  NULL);

-- ---------------------------------------------------------------------------
-- Damage reports — one of each status
-- ---------------------------------------------------------------------------
INSERT INTO damage_reports (id, user_id, equipment_id, description, status, created_at) VALUES
  (1, 2, 6,  'Display flickers and continuity mode beeps even with open probes.',          'Open',      NOW() - INTERVAL 4 DAY),
  (2, 3, 8,  'Zoom knob is stiff and the right eyepiece image is blurry at all settings.', 'Open',      NOW() - INTERVAL 9 DAY),
  (3, 3, 5,  'Black probe lead insulation is frayed near the connector.',                  'Resolved',  NOW() - INTERVAL 25 DAY),
  (4, 2, 15, 'Readings seem off by about 0.3 mm.',                                          'Dismissed', NOW() - INTERVAL 15 DAY);
