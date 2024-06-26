INSERT INTO stg.boarding_passes 
    (ticket_no, flight_id, boarding_no, seat_no) 

SELECT
    ticket_no,
    flight_id,
    boarding_no,
    seat_no
FROM
    bookings.boarding_passes

ON CONFLICT(ticket_no, flight_id) 
DO UPDATE SET
    boarding_no = EXCLUDED.boarding_no,
    seat_no = EXCLUDED.seat_no,
    updated_at = CASE WHEN 
                        stg.boarding_passes.boarding_no <> EXCLUDED.boarding_no
                        OR stg.boarding_passes.seat_no <> EXCLUDED.seat_no
                THEN 
                        CURRENT_TIMESTAMP
                ELSE
                        stg.boarding_passes.updated_at
                END;