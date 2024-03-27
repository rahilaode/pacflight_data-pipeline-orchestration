with 
	stg_tickets as (
    	select * 
    	from stg.tickets
    ),

	dim_passengers as (
    	select *
    	from final.dim_passenger 
	),
	
	stg_ticket_flights as (
	    select *
	    from stg.ticket_flights
	),
	
	stg_flights as (
	    select *
	    from stg.flights
	),
	
	dim_dates as (
	    select *
	    from final.dim_date
	),
	
	dim_times as (
	    select *
	    from final.dim_time
	),
	
	dim_airports as (
	    select *
	    from final.dim_airport
	),
	
	dim_aircrafts as (
	    select *
	    from final.dim_aircraft
	),
	
	stg_boarding_passes as (
	    select *
	    from stg.boarding_passes
	),
	
	final_fct_boarding_pass as (
	    select 
	        st.ticket_no as ticket_no,
	        st.book_ref as book_ref,
	        dp.passenger_id as passenger_id,
	        stf.flight_id as flight_id,
	        sf.flight_no as flight_no,
	        sbp.boarding_no as boarding_no,
	        dd1.date_id as scheduled_departure_date_local,
	        dd2.date_id as scheduled_departure_date_utc,
	        dt1.time_id as scheduled_departure_time_local,
	        dt2.time_id as scheduled_departure_time_utc,
	        dd3.date_id as scheduled_arrival_date_local,
	        dd4.date_id as scheduled_arrival_date_utc,
	        dt3.time_id as scheduled_arrival_time_local,
	        dt4.time_id as scheduled_arrival_time_utc,
	        da1.airport_id as departure_airport,
	        da2.airport_id as arrival_airport,
	        dac.aircraft_id as aircraft_code,
	        sf.status as status,
	        stf.fare_conditions as fare_conditions,
	        sbp.seat_no
	        
	    from stg_tickets st
	    join dim_passengers dp
	        on dp.passenger_id = st.id
	    join stg_ticket_flights stf 
	        on stf.ticket_no = st.ticket_no
	    join stg_flights sf 
	        on sf.flight_id = stf.flight_id
	    join dim_dates dd1 
	        on dd1.date_actual = DATE(sf.scheduled_departure)
	    join dim_dates dd2
	        on dd2.date_actual = DATE(sf.scheduled_departure AT TIME ZONE 'UTC')
	    join dim_times dt1
	        on dt1.time_actual::time = (sf.scheduled_departure)::time
	    join dim_times dt2
	        on dt2.time_actual::time = (sf.scheduled_departure AT TIME ZONE 'UTC')::time
	    join dim_dates dd3
	        on dd3.date_actual = DATE(sf.scheduled_arrival)
	    join dim_dates dd4
	        on dd4.date_actual = DATE(sf.scheduled_arrival AT TIME ZONE 'UTC')
	    join dim_times dt3
	        on dt3.time_actual::time = (sf.scheduled_arrival)::time
	    join dim_times dt4
	        on dt4.time_actual::time = (sf.scheduled_arrival AT TIME ZONE 'UTC')::time
	    join dim_airports da1 
	        on da1.airport_nk = sf.departure_airport
	    join dim_airports da2
	        on da2.airport_nk = sf.arrival_airport
	    join dim_aircrafts dac
	        on dac.aircraft_nk = sf.aircraft_code
	    join stg_boarding_passes sbp
	        on sbp.flight_id = stf.flight_id
	        and sbp.ticket_no = stf.ticket_no
	)

INSERT INTO final.fct_boarding_pass (
    ticket_no, 
    book_ref, 
    passenger_id, 
    flight_id, 
    flight_no, 
    boarding_no, 
    scheduled_departure_date_local, 
    scheduled_departure_date_utc, 
    scheduled_departure_time_local, 
    scheduled_departure_time_utc, 
    scheduled_arrival_date_local, 
    scheduled_arrival_date_utc, 
    scheduled_arrival_time_local, 
    scheduled_arrival_time_utc, 
    departure_airport, 
    arrival_airport, 
    aircraft_code, 
    status, 
    fare_conditions, 
    seat_no
)

select 
	* 
from 
	final_fct_boarding_pass

ON CONFLICT(ticket_no, flight_id, boarding_no) 
DO UPDATE SET
	book_ref = EXCLUDED.book_ref,
	passenger_id = EXCLUDED.passenger_id,
	flight_no = EXCLUDED.flight_no,
	scheduled_departure_date_local = EXCLUDED.scheduled_departure_date_local,
	scheduled_departure_date_utc = EXCLUDED.scheduled_departure_date_utc,
	scheduled_departure_time_local = EXCLUDED.scheduled_departure_time_local,
	scheduled_departure_time_utc = EXCLUDED.scheduled_departure_time_utc,
	scheduled_arrival_date_local = EXCLUDED.scheduled_arrival_date_local,
	scheduled_arrival_date_utc = EXCLUDED.scheduled_arrival_date_utc,
	scheduled_arrival_time_local = EXCLUDED.scheduled_arrival_time_local,
	scheduled_arrival_time_utc = EXCLUDED.scheduled_arrival_time_utc,
	departure_airport = EXCLUDED.departure_airport,
	arrival_airport = EXCLUDED.arrival_airport,
	aircraft_code = EXCLUDED.aircraft_code,
	status = EXCLUDED.status,
	fare_conditions = EXCLUDED.fare_conditions,
	seat_no = EXCLUDED.seat_no,
	updated_at = CURRENT_TIMESTAMP;

