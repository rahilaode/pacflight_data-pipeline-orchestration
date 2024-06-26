INSERT INTO stg.tickets 
    (ticket_no, book_ref, passenger_id, passenger_name, contact_data) 

SELECT
    ticket_no, 
    book_ref, 
    passenger_id, 
    passenger_name, 
    contact_data
FROM
    bookings.tickets

ON CONFLICT(ticket_no) 
DO UPDATE SET
    book_ref = EXCLUDED.book_ref,
    passenger_id = EXCLUDED.passenger_id,
    passenger_name = EXCLUDED.passenger_name,
    contact_data = EXCLUDED.contact_data,
    updated_at = CASE WHEN 
                        stg.tickets.book_ref <> EXCLUDED.book_ref
                        OR stg.tickets.passenger_id <> EXCLUDED.passenger_id
                        OR stg.tickets.passenger_name <> EXCLUDED.passenger_name
                        OR stg.tickets.contact_data <> EXCLUDED.contact_data
                THEN 
                        CURRENT_TIMESTAMP
                ELSE
                        stg.tickets.updated_at
                END;