FUNCTION init_inventory():
        OPEN "ppe.txt" IN READ mode as f
        READ the contents of the file into a variable data
        IF data is empty THEN
            DISPLAY "Inventory is empty. Initiating inventory..."
            OPEN "ppe.txt" IN APPEND mode as file
            FOR EACH item in item_code, quantity, and supplier_list:
                WRITE item to file in the format "item_code = quantity = supplier_list"
            DISPLAY "Inventory Initiated"
        ELSE:
            CALL FUNCTION login()
        END IF

FUNCTION inv_reset():
        OPEN "ppe.txt" IN READ mode as f
        FOR i IN RANGE (COUNT OF item_code) THEN
            WRITE item to the file in the format "item_code = quantity = supplier_list"
        END FOR 
        DISPLAY "Inventory reset done"
        CALL FUNCTION admin_menu()

FUNCTION login():
        DEFINE user_name, user_password, user_type AS STRING
        OPEN "users.txt" IN READ mode as f
        READ all lines from the file into a variable lines
        # .strip() removes the \n character from the end of each line#
        # .split(",") splits the line into a list of strings separated by commas#
        user_name = lines[3].strip().split(",")
        user_password = lines[5].strip().split(",")
        user_type = lines[7].strip().split(",")

        WHILE True THEN
            DEFINE username, passwd, check_type AS STRING
            username, passwd = INPUT("Please enter login credentials (Leave empty to quit login):\n\tUsername: "), INPUT("\tPassword: ")
            GET username, passwd
            IF username IN user_name AND passwd EQUAL TO user_password[user_name.index(username)] THEN
                check_type = user_type[user_name.index(username)]
                IF check_type IS "admin" THEN
                    CALL FUNCTION admin_menu()
                ELSE THEN
                    CALL FUNCTION user_menu()
                END IF
                BREAK
            ELSE IF username AND passwd IS EMPTY THEN
                QUIT()
            ELSE THEN
                DISPLAY "Invalid credentials. Please try again."
            END IF