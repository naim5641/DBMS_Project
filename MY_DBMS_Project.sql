-- 1. Create database (optional if you already have one)
-- CREATE DATABASE hospital_db;
-- \c hospital_db

-- 2. Create Tables

CREATE TABLE Patients (
    patient_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10),
    contact_info VARCHAR(255)
);

CREATE TABLE Doctors (
    doctor_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100),
    contact_info VARCHAR(255)
);

CREATE TABLE Appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INTEGER REFERENCES Patients(patient_id) ON DELETE CASCADE,
    doctor_id INTEGER REFERENCES Doctors(doctor_id) ON DELETE CASCADE,
    appointment_date TIMESTAMP NOT NULL,
    reason TEXT,
    status VARCHAR(50) DEFAULT 'Scheduled'
);

CREATE TABLE Patient_History (
    history_id SERIAL PRIMARY KEY,
    patient_id INTEGER REFERENCES Patients(patient_id) ON DELETE CASCADE,
    visit_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diagnosis TEXT,
    treatment TEXT
);

-- 3. Trigger: Auto-create patient history when an appointment is completed

CREATE OR REPLACE FUNCTION add_patient_history()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'Completed' THEN
        INSERT INTO Patient_History (patient_id, visit_date)
        VALUES (NEW.patient_id, NEW.appointment_date);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER appointment_completed_trigger
AFTER UPDATE OF status ON Appointments
FOR EACH ROW
EXECUTE FUNCTION add_patient_history();

-- 4. Sample Inserts

-- Register Patients
INSERT INTO Patients (full_name, date_of_birth, gender, contact_info)
VALUES
('John Doe', '1990-05-15', 'Male', 'john@example.com'),
('Jane Smith', '1985-08-22', 'Female', 'jane@example.com');

-- Register Doctors
INSERT INTO Doctors (full_name, specialty, contact_info)
VALUES
('Dr. Alice Brown', 'Cardiology', 'alice.brown@example.com'),
('Dr. Bob White', 'Neurology', 'bob.white@example.com');

-- Book Appointments
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, reason)
VALUES
(1, 1, '2025-04-27 10:00:00', 'Regular checkup'),
(2, 2, '2025-04-28 11:00:00', 'Headache issue');

-- 5. Update Appointment to Completed (trigger will insert into Patient_History)

UPDATE Appointments
SET status = 'Completed'
WHERE appointment_id = 1;

-- 6. View Data

-- View Patients
SELECT * FROM Patients;

-- View Doctors
SELECT * FROM Doctors;

-- View Appointments
SELECT * FROM Appointments;

-- View Patient History
SELECT * FROM Patient_History;






