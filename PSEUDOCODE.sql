FUNCTION init_inv()
    DEFINE item_code AS a list ["FS", "GL", "GW", "HC", "MS", "SC"]
    TRY
        WITH OPEN "ppe.txt" IN READ mode AS f THEN
            IF f.read() == "" THEN
                CALL FUNCTION init_supplier()
                data_list = CALL FUNCTION assign_supplier()
                DISPLAY "Inventory initiated"
                WITH OPEN "ppe.txt" IN APPEND mode AS f THEN
                    FOR i IN RANGE length of item_code THEN
                        f.write {item_code[i]},{100},{data_list[i]}\n TO ppe.txt
                    END FOR
                utype = CALL FUNCTION login()
                CALL FUNCTION menu(utype)
            ELSE THEN
                utype = CALL FUNCTION login()
                CALL FUNCTION menu(utype)
            END IF
        END TRY
    CATCH FileNotFoundError THEN 
        DISPLAY "The file was not found."
    END TRY
END FUNCTION

FUNCTION inv_update()
    DEFINE current_time AS DATE AND TIME WITH FORMAT "YYYY-MM-DD HH:MM:SS"
    DEFINE item_code, item_name AS lists ["FS", "GL", "GW", "HC", "MS", "SC"], ["Face Shield", "Gloves", "Gown", "Head Cover", "Mask", "Shoe Covers"]
    DEFINE hospital_list AS a list ["H1", "H2", "H3", "H4"]
    DEFINE select_data AS ["Receive","Distribute"]
    DEFINE list_data, trans_data AS lists
    DEFINE menu_select AS INTEGER
    WHILE TRUE THEN
        DISPLAY "Please select an option (Leave empty to quit):\n1. Receive\n2. Distribute\t\n> "
        GET menu_select
        IF menu_select IS EMPTY THEN
            RETURN
        END IF
        TRY
            menu_select IS INTEGER
            BREAK
        EXCEPT ValueError THEN
            DISPLAY "Please enter only numbers!"
            CONTINUE
        END TRY
    END WHILE
        
    WITH OPEN "ppe.txt" IN READ mode AS f THEN
        lines = f.readlines()
        FOR line IN lines THEN
            data = line.strip().split(",")
            APPEND data to list_data
        END FOR

        FOR c AND ele IN ENUMERATE list_data AND 1 THEN
            DISPLAY {c}. {item_name[item_code.index(ele[0])]} - {ele[1]} Boxes
        END FOR
        
        DEFINE selection, quantity_to_change AS INTEGER
        DISPLAY "Please enter item code number > "
        GET selection
        DISPLAY "Quantity to change > "
        GET quantity_to_change
        
        FOR c AND ele IN ENUMERATE list_data AND 1 THEN
            item = item_name[item_code.index(ele[0])]
            itemcode = ele[0]
            supplier = ele[2]
            IF selection IS EQUAL c THEN
                MATCH menu_select THEN
                    CASE 1:
                        new_quantity = CONVERT TO INTEGER ele[1] + quantity_to_change
                        trans_line = f"{select_data[menu_select-1]} | {item} | {supplier} | {current_time} | +{quantity_to_change}\n"
                    CASE 2:
                        IF CONVERT TO INTEGER ele[1] EQUALS 0 OR quantity_to_change LARGER THAN CONVERT TO INTEGER ele[1] THEN
                            DISPLAY "Insufficient for distribution"
                            CALL FUNCTION inv_update()
                        ELSE:
                            new_quantity = CONVERT TO INTEGER ele[1] - quantity_to_change
                            FOR c AND ele IN ENUMERATE hospital_list AND 1 THEN
                                DISPLAY {c}.{ele}
                            END FOR
                            WHILE TRUE:
                                DISPLAY "Distribute to hospital > "
                                DEFINE to_hospital AS INTEGER
                                TRY
                                    to_hospital IS INTEGER
                                    BREAK
                                EXCEPT ValueError:
                                    DISPLAY "Please enter a valid number!"
                                    CONTINUE
                            END WHILE
                            trans_line = {select_data[menu_select-1]} | {item} | {hospital_list[to_hospital-1]} | {current_time} | -{quantity_to_change}\n
                    CASE _:
                        DISPLAY "Invalid selection. Please try again."
                END MATCH
                
                # Append data        
                list_data[selection - 1] = {itemcode},{new_quantity},{supplier}\n
                APPEND trans_line to trans_data
            END IF
        END FOR
        
        WITH OPEN "ppe.txt" IN WRITE mode AS f THEN
            WRITE list_data TO ppe.txt
        WITH OPEN "transactions.txt" IN APPEND mode AS f THEN
            WRITE "\n".join(trans_data) TO transactions.txt
            DISPLAY Inventory updated>  {item_name[selection-1]} = {new_quantity} Boxes
        CALL FUNCTION inv_update()
END FUNCTION

FUNCTION login()
    DEFINE data_list AS a list

    WITH OPEN "users.txt" IN READ mode AS f THEN
        lines = f.readlines()
        
        FOR EACH line IN lines THEN
            APPEND line.strip().split(",") TO data_list
        END FOR
        
        WHILE TRUE THEN
            DEFINE username, passwd AS STRING
            DISPLAY "Please enter login credential (Leave empty to quit login):\n\tUsername: "
            GET username
            DISPLAY "\tPassword: "
            GET passwd

            IF username IN usernamelist AND passwd EQUALS PASSWORD OF THE SAME ROW OF username THEN
                check_type = data_list[3][data_list[1].index(username)]
                RETURN check_type
            ELSE IF username IS EMPTY AND passwd IS EMPTY:
                QUIT LOGIN
            ELSE THEN
                DISPLAY "Invalid credential. Please try again."
            END IF
        END WHILE
    CALL FUNCTION init_inv()
END FUNCTION

FUNCTION register()
    DEFINE data_list AS list
    DEFINE username AS INTEGER  

    WITH OPEN "users.txt" IN READ mode AS f THEN
        lines = f.readlines()
        FOR EACH line IN lines THEN
            APPEND line.strip().split(",") TO data_list
        END FOR

    FOR EACH c AND uid IN ENUMERATE data_list[0] AND 1 THEN
        last_id = c
    END FOR

    DISPLAY "Please enter registration credentials"
    DISPLAY "Username: "
    GET username
    IF username IN data_list[1] THEN
        DISPLAY "Username already exists!"
        CALL FUNCTION register()
    END IF

    data_list[0].append(f"uid{last_id[0]+1}")
    data_list[1].append(username)
    data_list[2].append(DISPLAY "Password: ")
    data_list[3].append(DISPLAY "Account Type (admin/staff): ").lower()

    CALL FUNCTION config_save("users.txt", "w", data_list[0], data_list[1], data_list[2], data_list[3])

    DISPLAY "New user added"
    DISPLAY "Returning to menu"
END FUNCTION

FUNCTION inv_track()
    DEFINE item_code, item_name AS lists ["FS","GL","GW","HC","MS","SC"], ["Face Shield","Gloves","Gown","Head Cover","Mask","Shoe Covers"]
    DEFINE selection, item_selection AS INTEGER
    DEFINE start_date, end_date AS STRING
    WHILE TRUE THEN
        DISPLAY "Please select an option (Leave empty to exit):"
        DISPLAY "1. Check all items quantity"
        DISPLAY "2. Item less than 25 boxes"
        DISPLAY "3. Check specific item"
        DISPLAY "4. Item received during specific time"
        GET selection
        IF selection IS EMPTY THEN
            RETURN
        END IF
        TRY
            selection IS INTEGER
            BREAK
        EXCEPT ValueError THEN
            DISPLAY "Please enter only numbers!"
            CONTINUE
        END TRY

    MATCH selection THEN
        CASE 1
            DISPLAY "Quantity of all items:"
        CASE 2
            DISPLAY "Item less than 25 Boxes:"
        CASE 3
            FOR EACH c AND ele IN ENUMERATE item_name AND 1 THEN
                DISPLAY c, ".", ele
            END FOR
            DISPLAY "Please select an item: "
            GET item_selection
        CASE 4
            DEFINE transactions_list, date_list, time_list AS lists

            WITH OPEN "transactions.txt" IN READ mode AS f THEN
                lines = f.readlines()
                FOR EACH line IN lines THEN
                    data, transactions_data, date_data = line.strip().split(" | "), line.strip(), data[3].strip().split(" ")
                    IF transactions_data STARTSWITH "Receive" THEN
                        date_list.append(date_data[0])
                        time_list.append(date_data[1])
                        transactions_list.append(transactions_data)
                    END IF
                END FOR

            DISPLAY "Date & time of received items"
            FOR EACH c, (date_ele, time_ele) IN ENUMERATE ZIP(date_list, time_list) AND 1 THEN
                DISPLAY c, ".", date_ele, time_ele
            END FOR

            DISPLAY "Please select a start date: "
            GET start_date
            DISPLAY "Please select an end date: "
            GET end_date

            DISPLAY "Type     Item From  Date & Time\t\t Quantity"
            DISPLAY "-------------------------------------"
            FOR transaction IN RANGE(start_date, end_date + 1) THEN
                DISPLAY transactions_list[transaction-1]
            END FOR

            CALL FUNCTION inv_track()

        CASE 5
            RETURN
        CASE OTHER THAN 1 TO 5
            DISPLAY "Invalid selection! Please try again."
            CALL FUNCTION inv_track()
    END MATCH

    WITH OPEN "ppe.txt" IN READ mode AS f THEN
        lines = f.readlines()
        FOR EACH c AND line IN ENUMERATE lines AND 1 THEN
            data = line.strip().split(",")
            items, quantity = item_name[item_code.index(data[0].strip())], CONVERT TO INTEGER data[1].strip()
            
            MATCH selection THEN
                CASE 1
                    DISPLAY items, "=", quantity
                CASE 2
                    IF quantity < 25 THEN
                        DISPLAY items, "=", quantity
                    ELSE THEN
                        DISPLAY "No items are less than 25 Boxes!"
                        BREAK
                    END IF
                CASE 3
                    IF items EQUALS item_name[item_selection-1] THEN
                        DISPLAY items, "=", quantity
                END MATCH
        END FOR

        CALL FUNCTION inv_track()
END FUNCTION

FUNCTION delete_user()
    DEFINE data_list AS a list
    DEFINE selection AS INTEGER

    WITH OPEN "users.txt" IN READ mode AS f THEN
        lines = f.readlines()
        
        FOR EACH line IN lines THEN
            APPEND line.strip().split(",") TO data_list
        END FOR
        
        FOR EACH c, ele IN ENUMERATE data_list[1] AND 1:
            DISPLAY c, ".", ele
        END FOR
        
        WHILE TRUE THEN
            DISPLAY "Select the user you want to remove (Leave empty to quit) > "
            GET selection
            IF selection IS EMPTY THEN
                RETURN
            END IF
            TRY
                selection IS INTEGER
                BREAK
            EXCEPT ValueError THEN
                DISPLAY "Please enter only a number!"
                CONTINUE
            END TRY
        END WHILE
        
        data_list[0].pop()
        FOR i IN RANGE 3:
            data_list[i+1].pop(selection-1)
        END FOR
        
        CALL FUNCTION config_save("users.txt", "w", data_list[0], data_list[1], data_list[2], data_list[3])
    END WITH

    CALL FUNCTION delete_user()
END FUNCTION

FUNCTION search_user(fileName, mode)
    DEFINE data_list AS a list
    DEFINE selection AS INTEGER

    WITH OPEN fileName IN mode AS f THEN
        lines = f.readlines()

        FOR EACH line IN lines THEN
            APPEND line.strip().split(",") TO data_list
        END FOR

        FOR EACH c, ele IN ENUMERATE data_list[1] AND 1:
            DISPLAY c, ".", ele
        END FOR

        WHILE TRUE THEN
            DISPLAY "Please select a user to search (Leave empty to quit)"
            GET selection
            IF selection IS EMPTY THEN
                RETURN
            END IF
            TRY
                selection IS INTEGER
                IF selection > length of data_list[1] THEN
                    DISPLAY "Please select a valid option!"
                ELSE
                    selected_user = data_list[1][selection-1]
                    DISPLAY "Selected user:", selected_user
                    DISPLAY "Username:", selected_user
                    DISPLAY "UID:", data_list[0][selection-1]
                    DISPLAY "Password:", data_list[2][selection-1]
                    DISPLAY "Type:", data_list[3][selection-1]
                END IF
                BREAK
            EXCEPT ValueError THEN
                DISPLAY "Please enter only a number!"
                CONTINUE
            END TRY
        END WHILE
    END WITH

    CALL FUNCTION search_user("users.txt", "r")
END FUNCTION

FUNCTION search():
    DEFINE selection AS INTEGER

    WHILE TRUE THEN
        DISPLAY "Please select a search option (Leave empty to quit):"
        DISPLAY "1. Distribution list"
        DISPLAY "2. Received list"
        DISPLAY "3. All"
        GET selection
        IF selection IS EMPTY THEN
            RETURN
        END IF
        TRY
            selection IS INTEGER
            BREAK
        EXCEPT ValueError THEN
            DISPLAY "Please enter only a number!"
            CONTINUE
        END TRY
    END WHILE

    MATCH selection THEN
        CASE 1 THEN
            DISPLAY "Type        Item  To  Date & Time\t\t    Quantity"
            DISPLAY "-" * 60
        CASE 2 THEN
            DISPLAY "Type     Item From  Date & Time\t\t\t Quantity"
            DISPLAY "-" * 60
    END MATCH

    WITH OPEN "transactions.txt" IN READ mode AS f THEN
        lines = f.readlines()
        FOR EACH line IN lines THEN
            data = line.strip()

            MATCH selection THEN
                CASE 1 THEN
                    IF data.startswith("Distribute"):
                        DISPLAY data
                        DISPLAY "-" * 60
                CASE 2 THEN
                    IF data.startswith("Receive"):
                        DISPLAY data
                        DISPLAY "-" * 60
                CASE 3 THEN
                    DISPLAY data
                CASE NOT 1 TO 3 THEN
                    DISPLAY "Invalid selection! Please try again."
            END MATCH
        END FOR
    END WITH

    CALL FUNCTION search()
END FUNCTION

FUNCTION modify_user()
    DEFINE data_list AS list
    DEFINE selection, modify_item, new_type AS INTEGER
    DEFINE new_password, new_username AS STRING
    WITH OPEN "users.txt" IN READ mode AS f THEN
        lines = f.readlines()
        FOR EACH line IN lines THEN
            data_list.append(line.strip().split(","))
        END FOR

        WHILE TRUE THEN
            FOR EACH c, ele IN ENUMERATE data_list[1], 1 THEN
                DISPLAY {c}. {ele} 
            END FOR

            GET selection
            IF selection IS EMPTY THEN
                RETURN
            END IF

            TRY
                selection IS INTEGER
                IF selection > LENGTH(data_list[1]) THEN
                    DISPLAY "Please select a valid option!"
                ELSE THEN
                    WHILE TRUE THEN
                        DISPLAY "Please select an item to modify (Leave empty to quit):"
                        DISPLAY "1. Username"
                        DISPLAY "2. Password"
                        DISPLAY "3. User Type"

                        GET modify_item

                        IF modify_item IS EMPTY THEN
                            RETURN
                        END IF

                        TRY
                            modify_item IS INTEGER
                            MATCH modify_item THEN
                                CASE 1 THEN
                                    WHILE TRUE THEN
                                        DISPLAY f"Please enter a new username"
                                        DISPLAY f"Current username: {data_list[1][selection-1]}"
                                        GET new_username

                                        IF new_username IS EMPTY THEN
                                            DISPLAY "Username cannot be empty. Please enter a valid username."
                                        ELIF new_username IN data_list[1] THEN
                                            DISPLAY "Username already exists. Please choose a different one."
                                        ELSE THEN
                                            data_list[1][selection-1] = new_username
                                            BREAK
                                        END IF
                                    END WHILE
                                CASE 2 THEN
                                    WHILE TRUE THEN
                                        DISPLAY f"Please enter a new password"
                                        DISPLAY f"Current password: {data_list[2][selection-1]}"
                                        GET new_password

                                        IF new_password IS EMPTY THEN
                                            DISPLAY "Password cannot be empty. Please enter a valid password."
                                        ELSE
                                            data_list[2][selection-1] = new_password
                                            BREAK
                                        END IF
                                    END WHILE
                                CASE 3 THEN
                                    WHILE TRUE THEN
                                        # Modify user type (admin or staff)
                                        DISPLAY f"Please enter a new user type"
                                        DISPLAY f"Current user type: {data_list[3][selection-1]}"
                                        DISPLAY "New user type (1. Admin / 2. Staff):"

                                        GET new_type

                                        IF new_type IS EMPTY THEN
                                            DISPLAY "User type cannot be empty. Please select a valid option."
                                        ELSE
                                            TRY
                                                new_type IS INTEGER
                                                MATCH new_type THEN
                                                    CASE 1 THEN
                                                        new_type = "admin"
                                                        data_list[3][selection-1] = new_type
                                                    CASE 2 THEN
                                                        new_type = "staff"
                                                        data_list[3][selection-1] = new_type
                                                    CASE NOT 1 OR 2 THEN
                                                        DISPLAY "Please select a valid option."
                                                END MATCH
                                                BREAK
                                            EXCEPT ValueError THEN
                                                DISPLAY "Please enter only numbers!"
                                            END TRY
                                        END IF
                                    END WHILE
                                CASE _:
                                    DISPLAY "Invalid selection! Please try again."
                                    CALL FUNCTION modify_user()
                            END MATCH

                            config_save("users.txt", "w", data_list[0], data_list[1], data_list[2], data_list[3])
                            DISPLAY "---------------------Done---------------------"
                            RETURN

                        EXCEPT ValueError THEN
                            DISPLAY "Please enter only numbers!"
                        END TRY
                    END WHILE
                END IF
            EXCEPT ValueError THEN
                DISPLAY "Please enter only numbers!"
            END TRY
        END WHILE
    END WITH
END FUNCTION

FUNCTION menu(user_type)
    DEFINE selection AS INTEGER
    IF user_type EQUALS "admin" THEN
        DISPLAY "INVENTORY MANAGEMENT SYSTEM (Admin)"
        DISPLAY "+++++++++++++++++++++++++++++"
        WHILE TRUE THEN
            DISPLAY "Please select an option:"
            DISPLAY "1. Item Inventory Update"
            DISPLAY "2. Item Inventory Tracking"
            DISPLAY "3. Search distribution list"
            DISPLAY "4. Add new user"
            DISPLAY "5. Delete user"
            DISPLAY "6. Search user"
            DISPLAY "7. Modify User"
            DISPLAY "8. Logout"
            GET selection
            TRY
                SELECT IS INTEGER
            EXCEPT ValueError THEN
                DISPLAY "Please enter only numbers!"
                CONTINUE
            END TRY
            MATCH SELECT THEN
                CASE 1 THEN
                    CALL FUNCTION inv_update()
                CASE 2 THEN
                    CALL FUNCTION inv_track()
                CASE 3 THEN
                    CALL FUNCTION search()
                CASE 4 THEN
                    CALL FUNCTION register()
                CASE 5 THEN
                    CALL FUNCTION delete_user()
                CASE 6 THEN
                    CALL FUNCTION search_user("users.txt", "r")
                CASE 7 THEN
                    CALL FUNCTION modify_user()
                CASE 8 THEN
                    CALL FUNCTION quit()
                CASE NOT 1 TO 9 THEN
                    DISPLAY "Invalid selection! Please try again."
            END MATCH
    ELSE THEN
        DISPLAY "INVENTORY MANAGEMENT SYSTEM (User)"
        DISPLAY "++++++++++++++++++++++++++++"
    WHILE TRUE THEN
        DISPLAY "Please select an option:"
        DISPLAY "1. Item Inventory Update"
        DISPLAY "2. Item Inventory Tracking"
        DISPLAY "3. Search distribution list"
        DISPLAY "4. Logout"
        GET selection
        TRY
            SELECT IS INTEGER
        EXCEPT ValueError THEN
            DISPLAY "Please enter only numbers!"
            CONTINUE
        END TRY
        MATCH SELECT THEN
            CASE 1 THEN
                CALL FUNCTION inv_update()
            CASE 2 THEN
                CALL FUNCTION inv_track()
            CASE 3 THEN
                CALL FUNCTION search()
            CASE 4 THEN
                CALL FUNCTION quit()
            CASE NOT 1 TO 4 THEN
                CALL FUNCTION DISPLAY "Invalid selection! Please try again."
        END MATCH
END FUNCTION

FUNCTION assign_supplier()
    DEFINE item_name AS list = ["Face Shield", "Gloves", "Gown", "Head Cover", "Mask", "Shoe Covers"]
    DEFINE data_list AS list
    DEFINE supplier_selection AS INTEGER
    WITH OPEN "suppliers.txt" IN READ mode AS f THEN
        lines = f.readlines()
        
        IF length of lines is NOT EQUAL TO 0 THEN
            WITH OPEN "ppe.txt" IN READ mode AS f THEN
                ppelines = f.readlines()
                
                IF length of ppelines is EQUAL TO 0 THEN
                    splist = split lines[0] by ","
                    spname = split lines[1] by ","
                    supplier_counts = CREATE a list containing 0s with the same length as spname
                    
                    FOR i IN RANGE 6 THEN
                        WHILE TRUE THEN
                            FOR c AND ele IN ENUMERATE spname AND 1 THEN
                                DISPLAY {c}. {ele}
                            
                            TRY
                                supplier_selection = DISPLAY "Please select a supplier to supply {item_name[i]} > "
                                GET supplier_selection
                                IF 1 SMALLER THAN AND EQUALS supplier_selection SMALLER THAN AND EQUALS length of spname THEN
                                    IF supplier_counts[supplier_selection - 1] SMALLER THAN 2 THEN
                                        data_list.append(splist[supplier_selection - 1])
                                        supplier_counts[supplier_selection - 1] INCREASE BY 1
                                        BREAK
                                    ELSE:
                                        DISPLAY f"{spname[supplier_selection - 1]} has already supplied two items. Please select another supplier."
                                ELSE:
                                    DISPLAY "Invalid supplier number. Please enter a valid number."
                                
                            EXCEPT ValueError:
                                DISPLAY "Please enter a valid number."
                        END WHILE
                END IF
            END WITH
        ELSE THEN
            DISPLAY "Suppliers assigned"
        END IF
    RETURN data_list
END UNCTION

FUNCTION init_supplier()
    DEFINE supplier_code, supplier_data AS list
    DEFINE supplier_name AS STRING

    WITH OPEN "suppliers.txt" IN READ mode AS f:
        lines = f.readlines()
        
        IF length of lines is EQUAL TO 0 THEN
            DISPLAY "Setup wizard"
            DISPLAY "Require at least four suppliers! (Not changeable)"
            
            WHILE length of supplier_data < 4:
                DISPLAY "Please enter supplier" {length of supplier_data + 1} "name >"
                GET supplier_name
                APPEND supplier_name TO supplier_data
                sp_code = f"S{length of supplier_data}"
                APPEND sp_code TO supplier_code
            
            WITH OPEN "suppliers.txt" IN WRITE mode AS f:
                f.write ",".join(supplier_code) + "\n"
                f.write ",".join(supplier_data) + "\n"
        ELSE THEN
            RETURN
        END IF
END FUNCTION

FUNCTION config_save(fileName,mode,data_list)
    FOR data in data_list THEN
        WRITE ",".JOIN(data) + "\n"
# Initiate inventory
CALL FUNCTION init_inv()


