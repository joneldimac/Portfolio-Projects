-- Get the total number of flights, on-time flights, cancelled flights, diverted flights and their corresponding percentages.
-- As per US Department of Transportation - Bureau of Statistics,  A flight is counted as "on time" if it operated less than 15 minutes later than the scheduled time shown in the carriers' Computerized Reservations Systems (CRS). Arrival performance is based on arrival at the gate. Departure performance is based on departure from the gate. 
SELECT 
	COUNT(*) AS Total_Flights,
	(SELECT COUNT(*) FROM flights WHERE ARRIVAL_DELAY < 15 AND DIVERTED = 0 AND CANCELLED = 0) AS Total_Ontime_Flights,
    ROUND((SELECT COUNT(*) FROM flights WHERE ARRIVAL_DELAY < 15 AND DIVERTED = 0 AND CANCELLED = 0)*100/COUNT(*),2) AS Percentage_Ontime_Flights,
    SUM(DIVERTED) AS Total_Diverted_Flights,
    ROUND(SUM(DIVERTED)*100/COUNT(*),2) AS Percentage_Diverted,
    SUM(CANCELLED) AS Total_Cancelled_Flights,
    ROUND(SUM(CANCELLED)*100/COUNT(*),2) AS Percentage_Cancelled,
    (SELECT COUNT(*) FROM flights WHERE DEPARTURE_DELAY >= 15) AS Total_Delayed_Departures,
    ROUND((SELECT COUNT(*) FROM flights WHERE DEPARTURE_DELAY >= 15)*100/COUNT(*),2) AS Percentage_Delayed_Departures,
	(SELECT COUNT(*) FROM flights WHERE ARRIVAL_DELAY >= 15) AS Total_Delayed_Flights,
    ROUND((SELECT COUNT(*) FROM flights WHERE ARRIVAL_DELAY >= 15)*100/COUNT(*),2) AS Percentage_Delayed_Flights
FROM flights;

-- Get the total number of airports, total number of airlines, average delay in minutes, average taxi out, average taxi in, average elapsed time, average airtime, average distance, total elapsed time, total airtime, total distance.

SELECT
COUNT(DISTINCT origin_airport) AS Total_Airports,
COUNT(DISTINCT airline) AS Total_Airlines,
ROUND((SELECT AVG(arrival_delay) FROM flights WHERE arrival_delay >= 15), 2) AS Average_Delay_Minutes,
ROUND(AVG(taxi_out),2) AS Average_Taxi_Out,
ROUND(AVG(taxi_in),2) AS Average_Taxi_In,
ROUND(AVG(elapsed_time),2) AS Average_Elapsed_Time,
ROUND(AVG(air_time),2) AS Average_Airtime,
ROUND(AVG(distance),2) AS Average_Distance,
SUM(elapsed_time) AS Total_Elapsed_Time,
SUM(Air_Time) AS Total_Airtime,
SUM(distance) AS Total_Distance
FROM flights


-- Get the total delay minutes, delay by cause and corresponding percentages.

SELECT
    total.Total_Delay,
    SUM(f.AIR_SYSTEM_DELAY) AS Air_System_Delay,
    ROUND(SUM(f.AIR_SYSTEM_DELAY) * 100 / total.Total_Delay, 2) AS Percentage_Air_System_Delay,
    SUM(f.SECURITY_DELAY) AS Security_Delay,
    ROUND(SUM(f.SECURITY_DELAY) * 100 / total.Total_Delay, 2) AS Percentage_Security_Delay,
    SUM(f.AIRLINE_DELAY) AS Airline_Delay,
    ROUND(SUM(f.AIRLINE_DELAY) * 100 / total.Total_Delay, 2) AS Percentage_Airline_Delay,
    SUM(f.LATE_AIRCRAFT_DELAY) AS Late_Aircraft_Delay,
    ROUND(SUM(f.LATE_AIRCRAFT_DELAY) * 100 / total.Total_Delay, 2) AS Percentage_Late_Aircraft_Delay,
    SUM(f.WEATHER_DELAY) AS Weather_Delay,
    ROUND(SUM(f.WEATHER_DELAY) * 100 / total.Total_Delay, 2) AS Percentage_Weather_Delay
FROM flights f
JOIN (
    SELECT 
        SUM(AIR_SYSTEM_DELAY) + SUM(SECURITY_DELAY) + SUM(AIRLINE_DELAY) + SUM(LATE_AIRCRAFT_DELAY) + SUM(WEATHER_DELAY) AS Total_Delay
    FROM flights
) total
ON TRUE
GROUP BY total.Total_Delay;



-- Get total number of daily total flights, delayed, diverted and cancelled flights. 

SELECT
	MONTH,
    DAY,
    COUNT(CASE WHEN DEPARTURE_DELAY >= 15 
			THEN FLIGHT_NUMBER END) AS Total_Delayed_Departures,
	ROUND((COUNT(CASE WHEN DEPARTURE_DELAY >= 15 THEN FLIGHT_NUMBER END))*100/COUNT(*),2) AS Percentage_Delayed_Departures,
	COUNT(CASE WHEN ARRIVAL_DELAY >= 15 
			THEN FLIGHT_NUMBER END) AS Total_Delayed_Arrivals,
	ROUND((COUNT(CASE WHEN ARRIVAL_DELAY >= 15 THEN FLIGHT_NUMBER END))*100/COUNT(*),2) AS Percentage_Delayed_Arrivals,
	COUNT(CASE WHEN DIVERTED = 1
			THEN FLIGHT_NUMBER END) AS Total_Diverted_Flights,
	ROUND((COUNT(CASE WHEN DIVERTED = 1 THEN FLIGHT_NUMBER END))*100/COUNT(*),2) AS Percentage_Diverted_Flights,
	COUNT(CASE WHEN CANCELLED = 1
			THEN FLIGHT_NUMBER END) AS Total_Cancelled_FLights,
	ROUND((COUNT(CASE WHEN CANCELLED = 1 THEN FLIGHT_NUMBER END))*100/COUNT(*),2) AS Percentage_Diverted_Flights,
	COUNT(*) As Total_Flights
FROM flights
GROUP BY MONTH, DAY
ORDER BY MONTH, DAY

-- Get flight information for each airline - total flights, number of on-time, delayed, cancelled and diverted flights and the corresponding percentages.
-- As additional context, the basis for classifying flight as delayed is if the arrival delay is greater than or equal to 15 minutes. However, data for delayed departures is also considered in the query as additional information.

SELECT 
    airlines.AIRLINE,
    COUNT(flights.FLIGHT_NUMBER) AS Total_Flights,
    COUNT(CASE WHEN ARRIVAL_DELAY < 15 AND DIVERTED = 0 AND CANCELLED = 0
			THEN FLIGHT_NUMBER END) AS Total_Ontime_Flights,
	ROUND((COUNT(CASE WHEN ARRIVAL_DELAY < 15 AND DIVERTED = 0 AND CANCELLED = 0
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Ontime_Flights_Percentage,
    COUNT(CASE WHEN DEPARTURE_DELAY >= 15
			THEN FLIGHT_NUMBER END) AS Total_Delayed_Departures,
	ROUND((COUNT(CASE WHEN DEPARTURE_DELAY >= 15
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Delayed_Departures_Percentage,
	COUNT(CASE WHEN ARRIVAL_DELAY >= 15
			THEN FLIGHT_NUMBER END) AS Total_Delayed_Arrivals,
	ROUND((COUNT(CASE WHEN ARRIVAL_DELAY >= 15
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Delayed_Arrivals_Percentage,
	COUNT(CASE WHEN CANCELLED = 1
			THEN FLIGHT_NUMBER END) AS Total_Cancelled_Flights,
	ROUND((COUNT(CASE WHEN CANCELLED = 1
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Cancelled_Flights_Percentage,
	COUNT(CASE WHEN DIVERTED = 1
			THEN FLIGHT_NUMBER END) AS Total_Diverted_Flights,
	ROUND((COUNT(CASE WHEN DIVERTED = 1
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Diverted_Flights_Percentage
FROM flights
LEFT JOIN airlines
    ON flights.AIRLINE = airlines.IATA_CODE
GROUP BY airlines.AIRLINE
ORDER BY Total_Flights DESC;

-- Get flight information for each destination airport - total flights, number of on-time, delayed, cancelled and diverted flights and the corresponding percentages.

SELECT
    AIRPORT,
    IATA_CODE,
	COUNT(flights.FLIGHT_NUMBER) AS Total_Flights,
    COUNT(CASE WHEN ARRIVAL_DELAY < 15 AND DIVERTED = 0 AND CANCELLED = 0
			THEN FLIGHT_NUMBER END) AS Total_Ontime_Flights,
	ROUND((COUNT(CASE WHEN ARRIVAL_DELAY < 15 AND DIVERTED = 0 AND CANCELLED = 0
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Ontime_Flights_Percentage,
	COUNT(CASE WHEN ARRIVAL_DELAY >= 15
			THEN FLIGHT_NUMBER END) AS Total_Delayed_Arrivals,
	ROUND((COUNT(CASE WHEN ARRIVAL_DELAY >= 15
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Delayed_Arrivals_Percentage,
	COUNT(CASE WHEN CANCELLED = 1
			THEN FLIGHT_NUMBER END) AS Total_Cancelled_Flights,
	ROUND((COUNT(CASE WHEN CANCELLED = 1
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Cancelled_Flights_Percentage,
	COUNT(CASE WHEN DIVERTED = 1
			THEN FLIGHT_NUMBER END) AS Total_Diverted_Flights,
	ROUND((COUNT(CASE WHEN DIVERTED = 1
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Diverted_Flights_Percentage
FROM flights
LEFT JOIN airports
	ON flights.DESTINATION_AIRPORT = airports.IATA_CODE
GROUP BY AIRPORT, IATA_CODE
ORDER BY Total_Flights DESC;

-- Get flight information for each origin airport - total flights, number of on-time, delayed, cancelled and diverted flights and the corresponding percentages.

SELECT
    AIRPORT,
    IATA_CODE,
	COUNT(flights.FLIGHT_NUMBER) AS Total_Flights,
    COUNT(CASE WHEN DEPARTURE_DELAY < 15 AND DIVERTED = 0 AND CANCELLED = 0
			THEN FLIGHT_NUMBER END) AS Total_Ontime_Flights,
	ROUND((COUNT(CASE WHEN DEPARTURE_DELAY < 15 AND DIVERTED = 0 AND CANCELLED = 0
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Ontime_Flights_Percentage,
    COUNT(CASE WHEN DEPARTURE_DELAY >= 15
			THEN FLIGHT_NUMBER END) AS Total_Delayed_Departures,
	ROUND((COUNT(CASE WHEN DEPARTURE_DELAY >= 15
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Delayed_Departures_Percentage,
	COUNT(CASE WHEN CANCELLED = 1
			THEN FLIGHT_NUMBER END) AS Total_Cancelled_Flights,
	ROUND((COUNT(CASE WHEN CANCELLED = 1
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Cancelled_Flights_Percentage,
	COUNT(CASE WHEN DIVERTED = 1
			THEN FLIGHT_NUMBER END) AS Total_Diverted_Flights,
	ROUND((COUNT(CASE WHEN DIVERTED = 1
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Diverted_Flights_Percentage
FROM flights
LEFT JOIN airports
	ON flights.ORIGIN_AIRPORT = airports.IATA_CODE
GROUP BY AIRPORT, IATA_CODE
ORDER BY Total_Flights DESC;

-- Get flight information for each airport pair (origin-destination), considering both departures and arrivals. 

SELECT
    ORIGIN_AIRPORT,
    DESTINATION_AIRPORT,
	COUNT(flights.FLIGHT_NUMBER) AS Total_Flights,
    COUNT(CASE WHEN ARRIVAL_DELAY < 15 AND DIVERTED = 0 AND CANCELLED = 0
			THEN FLIGHT_NUMBER END) AS Total_Ontime_Flights,
	ROUND((COUNT(CASE WHEN ARRIVAL_DELAY < 15 AND DIVERTED = 0 AND CANCELLED = 0
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Ontime_Flights_Percentage,
    COUNT(CASE WHEN DEPARTURE_DELAY >= 15
			THEN FLIGHT_NUMBER END) AS Total_Delayed_Departures,
	(COUNT(CASE WHEN DEPARTURE_DELAY >= 15
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER) AS Delayed_Departures_Percentage,
	COUNT(CASE WHEN ARRIVAL_DELAY >= 15
			THEN FLIGHT_NUMBER END) AS Total_Delayed_Arrivals,
	(COUNT(CASE WHEN ARRIVAL_DELAY >= 15
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER) AS Delayed_Arrivals_Percentage,
	COUNT(CASE WHEN CANCELLED = 1
			THEN FLIGHT_NUMBER END) AS Total_Cancelled_Flights,
	ROUND((COUNT(CASE WHEN CANCELLED = 1
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Cancelled_Flights_Percentage,
	COUNT(CASE WHEN DIVERTED = 1
			THEN FLIGHT_NUMBER END) AS Total_Diverted_Flights,
	ROUND((COUNT(CASE WHEN DIVERTED = 1
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Diverted_Flights_Percentage
FROM flights
LEFT JOIN airports
	ON flights.ORIGIN_AIRPORT = airports.IATA_CODE
GROUP BY ORIGIN_AIRPORT, DESTINATION_AIRPORT
ORDER BY  Total_Flights DESC;

-- Get flight information for each day of the week - total flights, number of on-time, delayed, cancelled and diverted flights and the corresponding percentages.

SELECT
    DAY_OF_WEEK,
	COUNT(flights.FLIGHT_NUMBER) AS Total_Flights,
    COUNT(CASE WHEN ARRIVAL_DELAY < 15 AND DIVERTED = 0 AND CANCELLED = 0
			THEN FLIGHT_NUMBER END) AS Total_Ontime_Flights,
	ROUND((COUNT(CASE WHEN ARRIVAL_DELAY < 15 AND DIVERTED = 0 AND CANCELLED = 0
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Ontime_Flights_Percentage,
    COUNT(CASE WHEN DEPARTURE_DELAY >= 15
			THEN FLIGHT_NUMBER END) AS Total_Delayed_Departures,
	ROUND((COUNT(CASE WHEN DEPARTURE_DELAY >= 15
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Delayed_Departures_Percentage,
	COUNT(CASE WHEN ARRIVAL_DELAY >= 15
			THEN FLIGHT_NUMBER END) AS Total_Delayed_Arrivals,
	ROUND((COUNT(CASE WHEN ARRIVAL_DELAY >= 15
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Delayed_Arrivals_Percentage,
	COUNT(CASE WHEN CANCELLED = 1
			THEN FLIGHT_NUMBER END) AS Total_Cancelled_Flights,
	ROUND((COUNT(CASE WHEN CANCELLED = 1
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Cancelled_Flights_Percentage,
	COUNT(CASE WHEN DIVERTED = 1
			THEN FLIGHT_NUMBER END) AS Total_Diverted_Flights,
	ROUND((COUNT(CASE WHEN DIVERTED = 1
			THEN FLIGHT_NUMBER END))*100/COUNT(flights.FLIGHT_NUMBER),2) AS Diverted_Flights_Percentage
FROM flights
GROUP BY DAY_OF_WEEK
ORDER BY DAY_OF_WEEK;


-- Running total flights per day

SELECT 
    DAY,
    COUNT(*) AS Daily_Flights,
    SUM(COUNT(*)) OVER (ORDER BY DAY) AS Running_Total_of_Flights
FROM Flights
GROUP BY DAY
ORDER BY DAY;


-- Running total of on-time flights per day

WITH Total_Ontime_Flights_per_Day AS (
SELECT
	DAY,
    COUNT(CASE WHEN ARRIVAL_DELAY < 15 AND DIVERTED = 0 AND CANCELLED = 0 THEN 1 END) AS Total_Ontime_Flights
FROM flights
GROUP BY DAY
)

SELECT
	DAY,
    Total_Ontime_Flights,
    SUM(Total_Ontime_Flights) OVER (ORDER BY DAY) AS Running_Total_of_Ontime_Flights
FROM Total_Ontime_Flights_per_Day



-- Running total of delayed flights by day

WITH Total_Delayed_Flights_per_Day AS (
SELECT
	DAY,
    COUNT(CASE WHEN ARRIVAL_DELAY >= 15 THEN 1 END) AS Total_Delayed_Flights
FROM flights
GROUP BY DAY
)

SELECT
	DAY,
    Total_Delayed_Flights,
    SUM(Total_Delayed_Flights) OVER (ORDER BY DAY) AS Running_Total_of_Delayed_Flights
FROM Total_Delayed_Flights_per_Day



-- Running total of cancelled flights per day

WITH Total_Cancelled_Flights_per_Day AS (
SELECT
	DAY,
    COUNT(CASE WHEN CANCELLED = 1 THEN 1 END) AS Total_Cancelled_Flights
FROM flights
GROUP BY DAY
)

SELECT
	DAY,
    Total_Cancelled_Flights,
    SUM(Total_Cancelled_Flights) OVER (ORDER BY DAY) AS Running_Total_of_Cancelled_Flights
FROM Total_Cancelled_Flights_per_Day


-- Running total of diverted flights per day

WITH Total_Diverted_Flights_per_Day AS (
SELECT
	DAY,
    COUNT(CASE WHEN DIVERTED = 1 THEN 1 END) AS Total_Diverted_Flights
FROM flights
GROUP BY DAY
)

SELECT
	DAY,
    Total_Diverted_Flights,
    SUM(Total_Diverted_Flights) OVER (ORDER BY DAY) AS Running_Total_of_Diverted_Flights
FROM Total_Diverted_Flights_per_Day


-- Get flight cancellation reason and the corresponding percentages

WITH Flights_by_cancellation_reason AS (
    SELECT
        cancellation_codes.CANCELLATION_DESCRIPTION,
        COUNT(*) AS Count_of_Flights
    FROM flights
    LEFT JOIN cancellation_codes
        ON flights.CANCELLATION_REASON = cancellation_codes.cancellation_reason
    WHERE cancellation_codes.CANCELLATION_DESCRIPTION IS NOT NULL
    GROUP BY cancellation_codes.CANCELLATION_DESCRIPTION
),

Total_Flights AS (
    SELECT
        SUM(Count_of_Flights) AS Total_Count
    FROM Flights_by_cancellation_reason
)

SELECT
    fbcr.CANCELLATION_DESCRIPTION,
    fbcr.Count_of_Flights,
    ROUND(fbcr.Count_of_Flights * 100.0 / tf.Total_Count, 2) AS Percentage
FROM Flights_by_cancellation_reason AS fbcr
CROSS JOIN Total_Flights AS tf;


    
