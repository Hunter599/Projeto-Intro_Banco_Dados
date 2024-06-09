import mysql.connector

try:
    # Establish the connection
    conn = mysql.connector.connect(
        host="localhost",       
        user="root",            # MySQL username
        password="-", # MySQL password
        database="employees"   # database name
    )

    if conn.is_connected():
        print("Successfully connected to the database")

        # Create a cursor object
        cursor = conn.cursor()

        # Execute a query
        cursor.execute("SELECT * FROM employees")

        # Fetch all the rows
        rows = cursor.fetchall()

        # Print the rows
        for row in rows:
            print(row)

except mysql.connector.Error as err:
    print(f"Error: {err}")

finally:
    if conn.is_connected():
        cursor.close()
        conn.close()
        print("Connection closed")
