import tkinter as tk                    #visual tree manager
from tkinter import ttk                 #visual tree manager
from unicodedata import numeric         #auxiliary import tool
import csv                              #export file format
import sys                              #helps for auxiliary systems exits
import mysql.connector                  #allows the connection to mySQL database
from mysql.connector import errorcode   #errors handler

from databaseMySql import *             #auxiliary file for credentials

#Defining tree
root = tk.Tk()
root.geometry("500x500")
tree = ttk.Treeview(root)

# Checks connection for MySQL database
try:
    conn = mysql.connector.connect(
        host=my_host,
        user=my_user,
        password=my_password,
        database=my_database
    )
except mysql.connector.Error as err:
    if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
        print("Something is wrong with your user name or password")
    elif err.errno == errorcode.ER_BAD_DB_ERROR:
        print("Database does not exist")
    else:
        print(err)

#general cursor for queries execution
cursor = conn.cursor()


# Define columns for the Treeview
columns = ("Table Name",)

tree = ttk.Treeview(root, columns=columns, show="headings")
tree.heading("Table Name", text="Table Name")


def handle_selection(event):
    selected_item = tree.selection()[0]  # Get the selected item
    print(f"Selected table: {tree.item(selected_item, 'values')[0]}")

    tree2 = ttk.Treeview(root)
    
    table = tree.item(selected_item, 'values')[0]  
    cursor2 = conn.cursor()

    tree2 = ttk.Treeview(root, columns=columns, show="headings")
    tree2.heading("Table Name", text="Table Name")
    
    tree2["columns"] = ("Column1", "Column2", "Column3", "Column4", "Column5", "Column6")
    
    tree2.heading("#1", text="Field")
    tree2.heading("#2", text="Type")
    tree2.heading("#3", text="Null")
    tree2.heading("#4", text="Key")
    tree2.heading("#5", text="Default")
    tree2.heading("#6", text="Column6")

    


    cursor2.execute(f"DESCRIBE {table}")
    rows2 = cursor2.fetchall()

    for row in rows2:
        print(row)
        tree2.insert("", "end", values=row)
    tree2.pack()




def visualTables():

    # Execute a query to get table names
    cursor.execute("SHOW TABLES")
    rows = cursor.fetchall()

    # Insert table names into the treeview
    for (row,) in rows:
        tree.insert("", "end", values=(row,))

    # Bind the selection event to the handle_selection function
    tree.bind("<<TreeviewSelect>>", handle_selection)

    tree.pack(fill="both", expand="false")
    root.mainloop()

#Removes thrash from wanted text
def processText(text):
    
    text = str(text)
    text =text.replace("'","")
    text =text.replace(",","")
    text =text.replace(")","")
    text =text.replace("(","")

    return text

#Main code for everything that we are dealing inside the mySql database
def mySqlDb():
    
    limit = 1000
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
                query = query + f" LIMIT {limit}"
                

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
                            with open('QueryExportSQL.csv', 'w', newline='') as csvfile:
                                csvwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
                                for row in rows:
                                    csvwriter.writerow(row)
                        elif (saveOut == "no" or saveOut == "n"):
                            break
                                
                except mysql.connector.Error as err:
                    query = query.split()
                    if query[0].lower() == "exit":
                        selector = 0
                        conn.commit()
                        break

                    print("Invalid query: ",err)
                    sys.exit(1)

        elif (selector == 2):
            visualTables()
        elif (selector == 3):
            limit = input(f"Current limit: {limit} \nSet limit: ")
            if (limit.isnumeric()):
                selector=0
        
        elif (selector == 4):
            
            #Gets all the tables from the database
            cursor.execute("SHOW TABLES")
            tables = cursor.fetchall()
                  
            with open('datasetSQL.csv', 'w', newline='') as csvfile:
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