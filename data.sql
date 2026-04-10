-- (PostgresSQL syntax)
-- Question 2: CS 6083 Spring 2026

-- ==================
-- RESET: Delete all data (respect FK order) and drop tables
-- ==================
DROP TABLE IF EXISTS Booking CASCADE;
DROP TABLE IF EXISTS Flight CASCADE;
DROP TABLE IF EXISTS FlightService CASCADE;
DROP TABLE IF EXISTS Passenger CASCADE;
DROP TABLE IF EXISTS Aircraft CASCADE;
DROP TABLE IF EXISTS Airport CASCADE;

-- ==================
-- TABLE CREATION
-- ==================

CREATE TABLE Airport (
    airport_code VARCHAR(3) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
);

CREATE TABLE Aircraft (
    plane_type VARCHAR(30) PRIMARY KEY,
    capacity INT NOT NULL
);

CREATE TABLE FlightService (
    flight_number VARCHAR(10) PRIMARY KEY,
    airline_name VARCHAR(50) NOT NULL,
    origin_code VARCHAR(3) NOT NULL,
    dest_code VARCHAR(3) NOT NULL,
    departure_time TIME NOT NULL,
    duration INTERVAL NOT NULL,
	FOREIGN KEY (origin_code) REFERENCES Airport(airport_code),
	FOREIGN KEY (dest_code) REFERENCES Airport(airport_code)
);

CREATE TABLE Flight (
    flight_number VARCHAR(10) NOT NULL,
    departure_date DATE NOT NULL,
    plane_type VARCHAR(30) NOT NULL,
    PRIMARY KEY (flight_number, departure_date),
	FOREIGN KEY (flight_number) REFERENCES FlightService(flight_number),
	FOREIGN KEY (plane_type) REFERENCES Aircraft(plane_type)
);

CREATE TABLE Passenger (
    pid INT PRIMARY KEY,
    passenger_name VARCHAR(100) NOT NULL
);

CREATE TABLE Booking (
    pid INT NOT NULL,
    flight_number VARCHAR(10) NOT NULL,
    departure_date DATE NOT NULL,
    seat_number INT NOT NULL,
    PRIMARY KEY (pid, flight_number, departure_date),
	FOREIGN KEY (pid) REFERENCES Passenger(pid),
	FOREIGN KEY (flight_number, departure_date) REFERENCES Flight(flight_number, departure_date)
);


-- ==================
-- DATA
-- ==================

-- Airports: includes 2 in Chicago, 2 in Paris/France
INSERT INTO Airport VALUES
('JFK', 'John F Kennedy International', 'New York', 'United States'),
('LAX', 'Los Angeles International', 'Los Angeles', 'United States'),
('ORD', 'O''Hare International', 'Chicago', 'United States'),
('MDW', 'Midway International', 'Chicago', 'United States'),
('LHR', 'Heathrow Airport', 'London', 'United Kingdom'),
('CDG', 'Charles de Gaulle Airport', 'Paris', 'France'),
('ORY', 'Paris Orly Airport', 'Paris', 'France'),
('SFO', 'San Francisco International', 'San Francisco', 'United States'),
('MIA', 'Miami International', 'Miami', 'United States'),
('ATL', 'Hartsfield-Jackson International', 'Atlanta', 'United States'),
('NRT', 'Narita International', 'Tokyo', 'Japan'),
('SIN', 'Changi Airport', 'Singapore', 'Singapore');

-- Aircraft: small capacities for manageable data
INSERT INTO Aircraft VALUES
('CRJ-200', 10),
('Boeing 737', 20),
('Airbus A320', 15),
('Boeing 787', 25);

-- Flight Services (duration = scheduled flight time)
INSERT INTO FlightService VALUES
('AA101', 'American Airlines', 'JFK', 'LAX', '08:00:00', INTERVAL '3 hours 30 minutes'),
('AA205', 'American Airlines', 'JFK', 'LAX', '14:00:00', INTERVAL '3 hours 30 minutes'),
('UA302', 'United Airlines', 'SFO', 'ORD', '09:00:00', INTERVAL '6 hours'),
('DL410', 'Delta Air Lines', 'ATL', 'MIA', '10:00:00', INTERVAL '2 hours 30 minutes'),
('BA178', 'British Airways', 'LHR', 'JFK', '10:00:00', INTERVAL '3 hours'),
('AF023', 'Air France', 'CDG', 'NRT', '22:00:00', INTERVAL '19 hours'),
('SQ321', 'Singapore Airlines', 'SIN', 'LHR', '23:00:00', INTERVAL '7 hours'),
('AA550', 'American Airlines', 'ORD', 'MIA', '07:00:00', INTERVAL '4 hours'),
('DL620', 'Delta Air Lines', 'JFK', 'ATL', '16:00:00', INTERVAL '2 hours 30 minutes'),
('UA789', 'United Airlines', 'LAX', 'SFO', '12:00:00', INTERVAL '1 hour 30 minutes');

-- Flights
INSERT INTO Flight VALUES
('AA101', '2025-12-29', 'Boeing 737'),
('AA101', '2025-12-31', 'Boeing 737'),
('AA205', '2025-12-31', 'Boeing 737'),
('UA302', '2025-12-31', 'CRJ-200'),
('DL410', '2025-12-31', 'Airbus A320'),
('BA178', '2025-12-31', 'Boeing 787'),
('AF023', '2025-12-30', 'Boeing 787'),
('SQ321', '2025-12-30', 'Boeing 787'),
('DL620', '2025-12-30', 'Airbus A320'),
('DL620', '2025-12-31', 'Airbus A320'),
('AA550', '2025-12-31', 'CRJ-200'),
('UA789', '2025-12-31', 'Airbus A320');

-- Passengers
INSERT INTO Passenger VALUES
(1, 'John Adams'),
(2, 'Sarah Miller'),
(3, 'Michael Chen'),
(4, 'Emily Wong'),
(5, 'David Park'),
(6, 'Lisa Johnson'),
(7, 'James Brown'),
(8, 'Maria Garcia'),
(9, 'Robert Kim'),
(10, 'Jennifer Lee'),
(11, 'Thomas Wilson'),
(12, 'Amanda Clark'),
(13, 'Christopher Davis'),
(14, 'Jessica Martinez'),
(15, 'Daniel Taylor'),
(16, 'Rachel Anderson'),
(17, 'William Thomas'),
(18, 'Nicole White'),
(19, 'Kevin Harris'),
(20, 'Stephanie Moore'),
(21, 'Andrew Jackson'),
(22, 'Michelle Robinson'),
(23, 'Brian Lewis'),
(24, 'Laura Walker'),
(25, 'Steven Hall');

-- Bookings
-- AA101, 2025-12-29 (Boeing 737, cap 20): 5 passengers
INSERT INTO Booking VALUES
(1, 'AA101', '2025-12-29', 1),
(2, 'AA101', '2025-12-29', 2),
(3, 'AA101', '2025-12-29', 3),
(4, 'AA101', '2025-12-29', 4),
(5, 'AA101', '2025-12-29', 5);

-- AA101, 2025-12-31 (Boeing 737, cap 20): 15 passengers
INSERT INTO Booking VALUES
(1, 'AA101', '2025-12-31', 1),
(2, 'AA101', '2025-12-31', 2),
(3, 'AA101', '2025-12-31', 3),
(4, 'AA101', '2025-12-31', 4),
(5, 'AA101', '2025-12-31', 5),
(6, 'AA101', '2025-12-31', 6),
(7, 'AA101', '2025-12-31', 7),
(8, 'AA101', '2025-12-31', 8),
(9, 'AA101', '2025-12-31', 9),
(10, 'AA101', '2025-12-31', 10),
(11, 'AA101', '2025-12-31', 11),
(12, 'AA101', '2025-12-31', 12),
(13, 'AA101', '2025-12-31', 13),
(14, 'AA101', '2025-12-31', 14),
(15, 'AA101', '2025-12-31', 15);

-- AA205, 2025-12-31 (Boeing 737, cap 20): 4 passengers
INSERT INTO Booking VALUES
(16, 'AA205', '2025-12-31', 1),
(17, 'AA205', '2025-12-31', 2),
(18, 'AA205', '2025-12-31', 3),
(19, 'AA205', '2025-12-31', 4);

-- UA302, 2025-12-31 (CRJ-200, cap 10): 10 passengers
INSERT INTO Booking VALUES
(1, 'UA302', '2025-12-31', 1),
(2, 'UA302', '2025-12-31', 2),
(3, 'UA302', '2025-12-31', 3),
(4, 'UA302', '2025-12-31', 4),
(5, 'UA302', '2025-12-31', 5),
(6, 'UA302', '2025-12-31', 6),
(7, 'UA302', '2025-12-31', 7),
(8, 'UA302', '2025-12-31', 8),
(9, 'UA302', '2025-12-31', 9),
(10, 'UA302', '2025-12-31', 10);

-- DL410, 2025-12-31 (Airbus A320, cap 15): 14 passengers
INSERT INTO Booking VALUES
(5, 'DL410', '2025-12-31', 1),
(6, 'DL410', '2025-12-31', 2),
(7, 'DL410', '2025-12-31', 3),
(8, 'DL410', '2025-12-31', 4),
(9, 'DL410', '2025-12-31', 5),
(10, 'DL410', '2025-12-31', 6),
(11, 'DL410', '2025-12-31', 7),
(12, 'DL410', '2025-12-31', 8),
(13, 'DL410', '2025-12-31', 9),
(14, 'DL410', '2025-12-31', 10),
(15, 'DL410', '2025-12-31', 11),
(16, 'DL410', '2025-12-31', 12),
(17, 'DL410', '2025-12-31', 13),
(18, 'DL410', '2025-12-31', 14);

-- BA178, 2025-12-31 (Boeing 787, cap 25): 6 passengers
INSERT INTO Booking VALUES
(20, 'BA178', '2025-12-31', 1),
(21, 'BA178', '2025-12-31', 2),
(22, 'BA178', '2025-12-31', 3),
(23, 'BA178', '2025-12-31', 4),
(24, 'BA178', '2025-12-31', 5),
(25, 'BA178', '2025-12-31', 6);

-- AF023, 2025-12-30 (Boeing 787, cap 25): 4 passengers
INSERT INTO Booking VALUES
(1, 'AF023', '2025-12-30', 1),
(2, 'AF023', '2025-12-30', 2),
(3, 'AF023', '2025-12-30', 3),
(4, 'AF023', '2025-12-30', 4);

-- SQ321, 2025-12-30 (Boeing 787, cap 25): 3 passengers
INSERT INTO Booking VALUES
(5, 'SQ321', '2025-12-30', 1),
(6, 'SQ321', '2025-12-30', 2),
(7, 'SQ321', '2025-12-30', 3);

-- DL620, 2025-12-30 (Airbus A320, cap 15): 4 passengers
INSERT INTO Booking VALUES
(10, 'DL620', '2025-12-30', 1),
(11, 'DL620', '2025-12-30', 2),
(12, 'DL620', '2025-12-30', 3),
(13, 'DL620', '2025-12-30', 4);

-- DL620, 2025-12-31 (Airbus A320, cap 15): 5 passengers
INSERT INTO Booking VALUES
(20, 'DL620', '2025-12-31', 1),
(21, 'DL620', '2025-12-31', 2),
(22, 'DL620', '2025-12-31', 3),
(23, 'DL620', '2025-12-31', 4),
(24, 'DL620', '2025-12-31', 5);

-- AA550, 2025-12-31 (CRJ-200, cap 10): 7 passengers
INSERT INTO Booking VALUES
(8, 'AA550', '2025-12-31', 1),
(9, 'AA550', '2025-12-31', 2),
(10, 'AA550', '2025-12-31', 3),
(11, 'AA550', '2025-12-31', 4),
(12, 'AA550', '2025-12-31', 5),
(13, 'AA550', '2025-12-31', 6),
(14, 'AA550', '2025-12-31', 7);

-- UA789, 2025-12-31 (Airbus A320, cap 15): 3 passengers
INSERT INTO Booking VALUES
(22, 'UA789', '2025-12-31', 1),
(23, 'UA789', '2025-12-31', 2),
(24, 'UA789', '2025-12-31', 3);
