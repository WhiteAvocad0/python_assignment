FUNCTION init_inv():
    TRY
        OPEN "ppe.txt" IN READ mode AS f
            IF data IS empty THEN
                DISPLAY "Inventory is empty. Initiating inventory..."
                OPEN "ppe.txt" IN APPEND mode AS file
                FOR EACH item in item_code, quantity, and supplier_list:
                    WRITE the item information to the file in the format "item_code = quantity = supplier_list"
                    DISPLAY "Inventory Initiated"
            ELSE:
                CALL FUNCTION login()
            END FOR
    CATCH FileNotFound:
        DISPLAY "The file was not found"

FUNCTION inv_update():
    DEFINE trans_data AS list
    DEFINE menu_select, lines, select_data AS INTEGER and list ["Receive", "Distribute"]
    
    DISPLAY "Please select an option:\n1. Receive\n2. Distribute\n3. Quit\n> "
    GET menu_select
    
    OPEN "ppe.txt" IN READ mode AS f
    lines = f.readlines()
    
    FOR c AND ele, line IN ENUMERATE item_name AND lines THEN
        DEFINE remain AS line.strip().split(",")
        DISPLAY {c + 1}.{ele} - {remain[1]} "Boxes"
        
        WHILE TRUE THEN
            DISPLAY "Please enter item code number > "
            GET selected
            DISPLAY "Quantity to change > "
            GET change_quantity
            
            TRY
                selected IS INTEGER
                change_quantity IS INTEGER
                BREAK
            EXCEPT ValueError THEN
                DISPLAY "Please enter only numbers!"
                CONTINUE
            END TRY
    END FOR
            
        FOR EACH number_line, line IN ENUMERATE lines, STARTING FROM 1 THEN
            DEFINE data AS line.strip().split(",")
            DEFINE items AS data[0].strip()
            DEFINE quantity AS data[1].strip()
            DEFINE splr AS data[2].strip()
            
            IF selected IS EQUAL number_line THEN
                MATCH menu_select:
                    CASE 1 THEN
                        new_quantity = quantity + change_quantity
                        trans_line = f"{select_data[menu_select - 1]} | {items} | {splr} | {current_time} | +{change_quantity}\n"
                    CASE 2 THEN
                        IF quantity == 0 OR change_quantity > quantity THEN
                            DISPLAY "Insufficient for distribution!"
                            CALL FUNCTION admin_menu()
                        ELSE THEN
                            new_quantity = quantity - change_quantity
                        END IF 
                            FOR EACH c, ele IN ENUMERATE hospital_list, STARTING FROM 1 THEN
                                DISPLAY {c}.{ele}
                            END FOR
                            WHILE TRUE THEN
                                DEFINE to_hospital AS INTEGER
                                DISPLAY "Distribute to hostpital > "
                                GET to_hospital
                                TRY
                                    to_hospital IS INTEGER
                                EXCEPT ValueError THEN
                                    DISPLAY "Please enter a valid number!"
                                    CONTINUE
                                BREAK
                            END WHILE
                            trans_line = {select_data[menu_select - 1]} | {items} | {hospital_list[to_hospital - 1]} | {current_time} | -{change_quantity}\n
                    CASE 3:
                        RETURN
                    CASE _:
                        DISPLAY "Invalid selection! Please try again."
                END MATCH
            END IF
                
                # Append data        
                lines[number_line - 1] = {items},{new_quantity},{splr}\n
                APPEND trans_data, trans_line
    END TRY
    TRY
        OPEN "ppe.txt" IN WRITE mode AS f
        WRITE lines
        
        OPEN "transactions.txt" IN APPEND mode AS f
        WRITE "\n".join(trans_data)
        DISPLAY Inventory updated: {items} ({item_name[selected - 1]}) = {new_quantity} Boxes
        
        CALL FUNCTION inv_update()
    END TRY

FUNCTION login(username, passwd):
    DEFINE user_name, user_password, user_type, lines, check_type AS STRING
    TRY
        OPEN "users.txt" IN READ mode AS f
        lines = f.readlines()
        
        user_name = lines[1].strip().split(",")
        user_password = lines[2].strip().split(",")
        user_type = lines[3].strip().split(",")
        
        WHILE True THEN
            IF username IN user_name AND passwd EQUAL TO user_password[user_name.index(username)]:
                check_type = user_type[user_name.index(username)]
                IF check_type IS "admin" THEN
                    CALL FUNCTION admin_menu()
                ELSE THEN
                    CALL FUNCTION user_menu()
                BREAK
                END IF
            ELSE IF username AND passwd IS EMPTY THEN
                return
            ELSE THEN
                DISPLAY "Invalid credential. Please try again."
                BREAK
            END IF
        END WHILE
        
        CALL FUNCTION init_inv()
        
    CATCH FileNotFound THEN
        DISPLAY "The file was not found"
    END TRY

FUNCTION register():
    DEFINE uid_list, username_list, password_list, type_list AS lists

    DISPLAY "\tPlease enter register credentials\n\tUsername: "
    GET username
    DISPLAY "\tPassword: "
    GET passwd
    DISPLAY "\tAccount Type (admin/staff): "
    GET usertype
    
    TRY
        OPEN "users.txt" IN READ mode AS f
        lines = f.readlines()
        
        user_id = lines[0].strip().split(",")
        user_name = lines[1].strip().split(",")
        user_password = lines[2].strip().split(",")
        user_type = lines[3].strip().split(",")
        
        uid_list.extend(user_id)
        username_list.extend(user_name)
        password_list.extend(user_password)
        type_list.extend(user_type)
        
        IF username IN user_name THEN
            DISPLAY "Username already exists!"
            CALL FUNCTION register()
        END IF
        
        FOR EACH c AND last_id IN ENUMERATE uid_list AND number, STARTING FROM 1 THEN
            last_id = number
        END FOR

        uid_list.append(f"uid{last_id + 1}")
        username_list.append(username)
        password_list.append(passwd)
        type_list.append(usertype)
        
        CALL FUNCTION config_save("users.txt", "w", uid_list, username_list, password_list, type_list)
        DISPLAY "> Registered"
        CALL FUNCTION admin_menu()
        
    CATCH IOError or FileNotFoundError:
        DISPLAY "An error occurred while accessing the file."
    END TRY


