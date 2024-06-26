INSERT INTO stg.seats 
    (aircraft_code, seat_no, fare_conditions) 

SELECT
    aircraft_code, 
    seat_no, 
    fare_conditions
FROM
    bookings.seats

ON CONFLICT(aircraft_code, seat_no) 
DO UPDATE SET
    fare_conditions = EXCLUDED.fare_conditions,
    updated_at = CASE WHEN 
                        stg.seats.fare_conditions <> EXCLUDED.fare_conditions
                THEN 
                        CURRENT_TIMESTAMP
                ELSE
                        stg.seats.updated_at
                END;