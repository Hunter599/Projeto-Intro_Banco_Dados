#Import everything for each file
from mySql_file import *
from postgreSQL_file import *

# Main code, where everything else is called 
def main():
    print("Type 'exit' to get out at any menu/\n\n")
    selector = 0
    
    while (selector != 1 and selector != 2):
        selector = input("\nSelect an option\n 1-MySQL,\n 2-PostgreSQL\n Your answer: ")

        if (selector == "exit"):
            return

        selector = numeric(selector)

        #Choosing database
        if(selector == 1):
            mySqlDb()
            selector=0
        elif(selector == 2):
            postgreSQL()
            selector=0
        


main()