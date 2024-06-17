

import tkinter as tk                    #visual tree manager
from tkinter import ttk                 #visual tree manager
import databasePg                       #auxiliary file for credentials
import psycopg2                         #import that allows connection to postgreSQL
from psycopg2 import OperationalError   #errors handler
from unicodedata import numeric         #auxiliary import tool
import csv                              #export file format
from mySql_file import processText      #auxiliary function 

#Tree for visual tables
root = tk.Tk()
root.geometry("500x500")
tree = ttk.Treeview(root)

columns = ("Table Name",)

tree = ttk.Treeview(root, columns=columns, show="headings")
tree.heading("Table Name", text="Table Name")

#Credentials for postgresql
db_name = databasePg.database
db_user = databasePg.user
db_pass = databasePg.password
db_host = databasePg.host  
db_port = databasePg.db_port   

#Checks connection
def connect():
    try:
        # Attempt to connect to your database
        # Establish the connection
        conn = psycopg2.connect(
            dbname=db_name,
            user=db_user,
            password=db_pass,
            host=db_host,
            port=db_port
        )
        print(f"\nConnection to PostgreSQL {db_name} successful\n")

        #general cursor for queries execution
        cursor = conn.cursor()

        return conn

    except psycopg2.OperationalError as e:
        # Handle the error
        print(f"The error '{e}' occurred")



def postgreSQL():
    
    conn = connect()
    cursor = conn.cursor()
    
    limitPg = 1000 # Limit of records to show, for postgreSQL specifically
    selector = 0
    
    while (selector != 1 and selector != 2 and selector != 3):
        selector = input("\nSelect an option\n 1- Input a query\n 2- Visualize the tables, datatypes and others\n 3- Edit limit of rows for queries result\n 4- Export dataset\n  Your answer: ")
        
        if (selector == "exit"):
            return

        selector = numeric(selector)

    
        if(selector == 1):
            query = ""
            while(query.lower() != "exit"):
                query = input("\nInsert your query: ")
                query = str(query)

                if (query.lower() == "exit"):
                    return

                query = query + f" LIMIT {limitPg}"
                

                try:
                    cursor.execute(query)
                    rows = cursor.fetchall()

                    # Insert table names into the treeview
                    for row in rows:
                        print(row)

                    #Export query procedure
                    saveOut=""
                    while(saveOut.lower() != "yes" and saveOut.lower() != "y" and saveOut.lower() != "no" and saveOut.lower() != "n" ):
                        
                        saveOut = input(f"Would you like to export your last query {query} ?\n Your answer(yes/y - no/n): ")
                        saveOut = saveOut.lower()
                        
                        #Exports query
                        if(saveOut == "yes" or saveOut == "y"):      
                            with open('QueryExportPG.csv', 'w', newline='') as csvfile:
                                csvwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
                                for row in rows:
                                    csvwriter.writerow(row)
                        elif (saveOut == "no" or saveOut == "n"):
                            break
                                
                except psycopg2.OperationalError as err:
                    query = query.split()
                    if query[0].lower() == "exit":
                        selector = 0
                        conn.commit()
                        break
                    
                    print("\nInvalid query: ",err)
                    
                    

        elif (selector == 2):
            visualTablesPg()
        elif (selector == 3):
            limit = input(f"Current limit: {limit} \nSet limit: ")
            if (limit.isnumeric()):
                selector=0
        
        elif (selector == 4):
            
            #Gets all the tables from the database
            cursor.execute("SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname = 'public';")
            tables = cursor.fetchall()
            with open('datasetPG.csv', 'w', newline='') as csvfile:
                csvwriter = csv.writer(csvfile)

                for table in tables:
                    
                    current_table = processText(table) #Clear text from ' and ()

                    cursor.execute(f"select * from {current_table}") 
                    rows = cursor.fetchall()                       

                    csvwriter.writerow(table)
                    for row in rows:
                        csvwriter.writerow(row)
                    csvwriter.writerow("\n")

            print("Data Exported")
                    
    
    # Close the cursor and connection    
    cursor.close()
    conn.commit()
    conn.close()


def handle_selection(event):
    selected_item = tree.selection()[0]  # Get the selected item
    print(f"Selected table: {tree.item(selected_item, 'values')[0]}")
    print("...")
    tree2 = ttk.Treeview(root)
    
    table = tree.item(selected_item, 'values')[0]  
    cursor2 = connect().cursor()

    tree2 = ttk.Treeview(root, columns=columns, show="headings")
    tree2.heading("Table Name", text="Table Name")
    
    tree2["columns"] = ("Column1", "Column2", "Column3")
    
    tree2.heading("#1", text="Field")
    tree2.heading("#2", text="Type")
    tree2.heading("#3", text="Primary Key")

    cursor2.execute(f"SELECT cols.column_name, cols.data_type, CASE WHEN pk.constraint_type = 'PRIMARY KEY' THEN 'yes'ELSE 'no' END as is_primary_key FROM information_schema.columns cols LEFT JOIN information_schema.key_column_usage kcu ON cols.table_name = kcu.table_name AND cols.column_name = kcu.column_name LEFT JOIN information_schema.table_constraints pk ON kcu.constraint_name = pk.constraint_name AND pk.constraint_type = 'PRIMARY KEY' WHERE cols.table_name = 'instructor' ORDER BY cols.ordinal_position;")
    rows2 = cursor2.fetchall()

    for row in rows2:
        print(row)
        tree2.insert("", "end", values=row)
    tree2.pack()




def visualTablesPg():

    conn = connect()
    cursor = conn.cursor()
    # Execute a query to get table names
    cursor.execute("SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname = 'public';")
    rows = cursor.fetchall()
    print(rows)

    # Insert table names into the treeview
    for (row,) in rows:
        print(row)
        tree.insert("", "end", values=(row,))

    # Bind the selection event to the handle_selection function
    tree.bind("<<TreeviewSelect>>", handle_selection)

    tree.pack(fill="both", expand="false")
    root.mainloop()