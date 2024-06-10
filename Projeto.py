import mysql.connector


conn = mysql.connector.connect(
    host="127.0.0.1",
    user="root",
    password="ckd5998506",
    database="mydb"
)

mycursor = conn.cursor()

mycursor.execute("SHOW DATABASES")

for x in mycursor:
  print(x)
