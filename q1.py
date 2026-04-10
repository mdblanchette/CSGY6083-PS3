import streamlit as st
import psycopg2
import pandas as pd
from datetime import date
from dotenv import load_dotenv
import os

# Database config

load_dotenv()

required_vars = ["DB_HOST", "DB_NAME", "DB_USER", "DB_PASSWORD"]
missing = [v for v in required_vars if not os.getenv(v)]
if missing:
    st.error(f"Missing environment variables: {', '.join(missing)}")
    st.stop()

DB_CONFIG = {
    "host": os.getenv("DB_HOST"),
    "database": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "port": int(os.getenv("DB_PORT", 5432)),
}


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def run_query(query, params=None):
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute(query, params)
        columns = [desc[0] for desc in cur.description]
        rows = cur.fetchall()
        return pd.DataFrame(rows, columns=columns)
    except Exception as e:
        st.error(f"Database error: {e}")
        return pd.DataFrame()
    finally:
        conn.close()


# Page setup

st.set_page_config(page_title="Flight Search", page_icon="✈️", layout="wide")
st.title("✈️ Flight Search System")

# a) Search form
with st.form("search_form"):
    col1, col2 = st.columns(2)
    with col1:
        origin = st.text_input("Origin Airport Code", placeholder="e.g. JFK")
    with col2:
        destination = st.text_input(
            "Destination Airport Code", placeholder="e.g. LAX")

    col3, col4 = st.columns(2)
    with col3:
        start_date = st.date_input("From Date", value=date(2025, 12, 1))
    with col4:
        end_date = st.date_input("To Date", value=date(2025, 12, 31))

    submitted = st.form_submit_button(
        "🔍 Search Flights", use_container_width=True)


if submitted:
    origin_clean = origin.strip().upper()
    dest_clean = destination.strip().upper()

    if not origin_clean or not dest_clean:
        st.error("Please enter both origin and destination airport codes.")
        st.session_state.pop("flights_df", None)
    elif start_date > end_date:
        st.error("'From Date' must be on or before 'To Date'.")
        st.session_state.pop("flights_df", None)
    else:
        query = """
            SELECT
                f.flight_number,
                fs.airline_name,
                f.departure_date,
                fs.origin_code,
                fs.dest_code,
                fs.departure_time,
                fs.duration,
                f.plane_type
            FROM Flight f
            JOIN FlightService fs ON f.flight_number = fs.flight_number
            WHERE fs.origin_code = %s
              AND fs.dest_code   = %s
              AND f.departure_date BETWEEN %s AND %s
            ORDER BY f.departure_date, fs.departure_time
        """
        flights_df = run_query(
            query, (origin_clean, dest_clean, start_date, end_date))
        st.session_state["flights_df"] = flights_df
        st.session_state["search_origin"] = origin_clean
        st.session_state["search_dest"] = dest_clean

# b) Display matching flights (if any)
if "flights_df" in st.session_state:
    flights_df = st.session_state["flights_df"]

    if flights_df.empty:
        st.warning("No flights found.")
    else:
        origin_lbl = st.session_state.get("search_origin", "")
        dest_lbl = st.session_state.get("search_dest", "")
        st.divider()
        st.subheader(f"Flights from {origin_lbl} → {dest_lbl}")

        # Prepare a clean display table
        display_df = flights_df[
            ["flight_number", "airline_name", "departure_date",
             "origin_code", "dest_code", "departure_time", "duration"]
        ].copy()
        display_df.columns = [
            "Flight #", "Airline", "Departure Date",
            "Origin", "Destination", "Departure Time", "Duration"
        ]
        st.dataframe(display_df, use_container_width=True, hide_index=True)

        # c) Seat availability for selected flight
        st.divider()
        st.subheader("🪑 Seat Availability")

        # Build human-readable options
        options = []
        for _, row in flights_df.iterrows():
            label = (
                f"{row['flight_number']}  ·  {row['airline_name']}  ·  "
                f"{row['departure_date']}  ·  Dep {row['departure_time']}"
            )
            options.append(label)

        selected_idx = st.selectbox(
            "Click on a flight to see seat details",
            range(len(options)),
            format_func=lambda i: options[i],
        )

        # Fetch capacity & bookings for the selected flight
        selected_row = flights_df.iloc[selected_idx]
        fn = selected_row["flight_number"]
        dd = selected_row["departure_date"]

        seat_query = """
            SELECT
                a.plane_type,
                a.capacity,
                COUNT(b.pid) AS booked_seats
            FROM Aircraft a
            JOIN Flight f
                ON a.plane_type = f.plane_type
            LEFT JOIN Booking b
                ON f.flight_number = b.flight_number
               AND f.departure_date = b.departure_date
            WHERE f.flight_number  = %s
              AND f.departure_date = %s
            GROUP BY a.plane_type, a.capacity
        """
        seat_df = run_query(seat_query, (fn, dd))

        if not seat_df.empty:
            plane_type = seat_df.iloc[0]["plane_type"]
            capacity = int(seat_df.iloc[0]["capacity"])
            booked = int(seat_df.iloc[0]["booked_seats"])
            available = max(capacity - booked, 0)

            st.markdown(f"**Aircraft:** {plane_type}")

            c1, c2, c3 = st.columns(3)
            c1.metric("Plane Capacity", capacity)
            c2.metric("Booked Seats", booked)
            c3.metric("Available Seats", available)

            # Visual progress bar
            pct_booked = min(booked / capacity, 1.0) if capacity > 0 else 0.0
            st.progress(
                pct_booked, text=f"{booked}/{capacity} seats booked ({pct_booked:.0%})")

            if available == 0:
                st.error("🚫 This flight is fully booked!")
            elif available <= 3:
                st.warning(f"⚠️ Only {available} seat(s) remaining!")
            else:
                st.success(f"✅ {available} seats available")
