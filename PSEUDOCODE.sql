
BEGIN
    FUNCTION init_inv()
        DEFINE item_code AS a list ["FS", "GL", "GW", "HC", "MS", "SC"]
        DEFINE data_list AS list
        DEFINE utype AS STRING
        DEFINE quantity AS INTEGER
        TRY
            OPEN "ppe.txt" IN READ mode AS f THEN
                IF ppe.txt IS EMPTY THEN
                    CALL FUNCTION init_supplier()
                    CALL FUNCTION init_hospital()
                    data_list = CALL FUNCTION assign_supplier()
                    WITH OPEN "ppe.txt" IN APPEND mode AS f THEN
                        FOR i IN RANGE LENGTH OF item_code THEN
                            DISPLAY "Please enter quantity for {item_code[i]} (Leave empty for default (100)): "
                            GET quantity
                            IF quantity IS EMPTY THEN
                                quantity = 100
                            f.write {item_code[i]},{quantity},{data_list[i]}\n TO ppe.txt
                            DISPLAY "Inventory initiated"
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
        DEFINE item_code, item_name AS lists ["FS","GL","GW","HC","MS","SC"], ["Face Shield","Gloves","Gown","Head Cover","Mask","Shoe Covers"]
        DEFINE hospital_list AS list
        DEFINE list_data AS list
        DEFINE trans_data AS list
        DEFINE selection, quantity_to_change, to_hospital AS INTEGER

        WHILE TRUE THEN
            menu_select, select_data = INPUT("Please select an option (Leave empty to quit):\n1. Receive\n2. Distribute\n> "), ["Receive","Distribute"]
            IF menu_select IS EMPTY THEN
                RETURN
            END IF
            TRY
                IS menu_select INTEGER?
                BREAK
            EXCEPT menu_select IS NOT INTEGER THEN
                DISPLAY "Please enter only numbers!"
                CONTINUE
            END TRY
        END WHILE

        OPEN "ppe.txt" IN READ mode AS f AND OPEN "hospitals.txt" IN READ mode AS hf
        READ all lines FROM f INTO lines
        READ all lines FROM hf INTO hlines

        FOR line IN hlines
            APPEND line WITH STRIPPED AND REMOVE "," TO hospital_list
        END FOR

        FOR line IN lines
            APPEND line WITH STRIPPED AND REMOVE "," TO list_data
        END FOR

        FOR c AND ele IN ENUMERATE list_data AND START WITH 1
            DISPLAY c, ". ", item name, " - ", quantity, " Boxes"
        END FOR

        DISPLAY "Please enter item code number > "
        GET selection
        DISPLAT"Quantity to change > "
        GET quantity_to_change

        FOR c, ele IN ENUMERATE list_data AND START WITH 1
            item = MATCH item name in item_name LIST
            itemcode = ele[0]
            current_quantity = ele[1]
            supplier = ele[2]

            IF selection IS EQUAL TO c THEN
                MATCH menu_select
                    CASE 1 THEN
                        new_quantity = current_quantity + quantity_to_change
                        trans_line = {select_data[menu_select-1]} | {item} | {supplier} | {current_time} | {quantity_to_change}\n
                    CASE 2 THEN
                        IF current_quantity IS EQUAL TO 0 OR quantity_to_change BIGGER THAN current_quantity THEN
                            DISPLAY "Insufficient for distribution"
                            CALL FUNCTION inv_update()
                        ELSE
                            new_quantity = current_quantity - quantity_to_change
                            FOR c, ele IN ENUMERATE hospital_list[0] AND START WITH 1
                                DISPLAY c, ".", ele
                            END FOR

                            WHILE TRUE THEN
                                DISPLAY "Distribute to hospital > "
                                GET to_hospital
                                TRY
                                    IS to_hospital INTEGER?
                                    BREAK
                                EXCEPT to_hospital IS NOT INTEGER
                                    DISPLAY "Please enter only numbers!"
                                    CONTINUE
                                END TRY
                            END WHILE
                            trans_line = {select_data[menu_select-1]} | {item} | {hospital_list[0][to_hospital-1]} | {current_time} | {quantity_to_change}\n
                        END IF
                    CASE NONE THEN
                        DISPLAY "Invalid selection. Please try again."
                END MATCH
                list_data[selection - 1] = {itemcode},{new_quantity},{supplier}\n
                APPEND trans_line TO trans_data
            END IF
        END FOR

        OPEN "ppe.txt" IN WRITE mode AS pf AND OPEN "transactions.txt" IN APPEND mode AS tf
        WRITE list_data TO ppe.txt
        WRITE JOIN(trans_data, "\n") TO transactions.txt
        DISPLAY f"Inventory updated> {item_name[selection-1]} = {new_quantity} Boxes"
        CALL FUNCTION inv_update()
    END FUNCTION

    FUNCTION login()
        DEFINE data_list AS a list
        DEFINE username, passwd, check_type AS STRING
        data_list = CALL FUNCTION readfiles("users.txt")        
        WHILE TRUE THEN
            DISPLAY "Please enter login credential (Leave empty to quit login):\n\tUsername: "
            GET username
            DISPLAY "\tPassword: "
            GET passwd

            IF username IN usernamelist AND passwd EQUALS PASSWORD OF THE SAME ROW OF username THEN
                check_type = FORTH COLMN OF users.txt AND SAME ROW OF username
                RETURN check_type
            ELSE IF username IS EMPTY AND passwd IS EMPTY THEN
                QUIT LOGIN
            ELSE THEN
                DISPLAY "Invalid credential. Please try again."
                BREAK
            END IF
        END WHILE
        CALL FUNCTION init_inv()
    END FUNCTION

    FUNCTION register()
        DEFINE data_list AS list
        DEFINE username, password AS STRING 
        data_list = CALL FUNCTION readfiles("users.txt")

        FOR EACH c AND uid IN ENUMERATE UID AND START WITH 1 THEN
            last_id = c
        END FOR

        DISPLAY "Please enter registration credentials"
        DISPLAY "Username: "
        GET username
        IF username IN SECOND COLUMN OF users.txt THEN
            DISPLAY "Username already exists!"
            CALL FUNCTION register()
        END IF

        data_list[0].append("uid" + LAST ID AVAILABLE IN CURRENT UID DATA)
        data_list[1].append(username)
        data_list[2].append(DISPLAY "Password: ", GET passwd)
        data_list[3].append(DISPLAY "Account Type (admin/staff): ", GET user_type) IN LOWERCASE

        CALL FUNCTION config_save("users.txt", "w", data_list)
        DISPLAY "New user added"
        DISPLAY "Returning to menu"
    END FUNCTION

    FUNCTION inv_track()
        DEFINE item_code, item_name AS lists ["FS", "GL", "GW", "HC", "MS", "SC"], ["Face Shield", "Gloves", "Gown", "Head Cover", "Mask", "Shoe Covers"]
        DEFINE items_list, quantity_list, data AS lists
        OPEN "ppe.txt" IN READ mode AS f
        READ all lines FROM f INTO lines
        
        FOR c AND line IN ENUMERATE LINES AND START WITH 1 THEN
            data = LINE WITH STRIPPED SPACE AND REMOVED ","
            APPEND ITEM NAME INTO items_list
            APPEND QUANTITY TO quantity_list
        
        WHILE TRUE THEN
            DISPLAY "--------------------------------------------"
            DISPLAY "Please select an option (Leave empty to exit):"
            DISPLAY "1. Check all items quantity"
            DISPLAY "2. Items with less than 25 boxes"
            DISPLAY "3. Check a specific item"
            DISPLAY "4. Items received during a specific time"
            GET selection

            IF selection IS EMPTY THEN
                RETURN
            END IF
            TRY
                IS selection INTEGER?
            EXCEPT selection IS NOT INTEGER
                DISPLAY "Please enter a number"
                CONTINUE
            END TRY

            MATCH selection
                CASE 1 THEN
                    DISPLAY "Quantity of all items:"
                    FOR item AND quantity IN items_list AND quantity_list
                        DISPLAY item, " = ", quantity
                    END FOR
                CASE 2 THEN
                    DISPLAY "Items with less than 25 boxes:"
                    FOR item AND quantity IN items_list AND quantity_list
                        IF quantity LESS THAN 25 THEN
                            DISPLAY item, " = ", quantity
                        END IF
                    END FOR
                selection IS 3 THEN
                    DISPLAY "Select an item:"
                    FOR c AND ele IN ENUMERATE item_name AND START WITH 1 THEN
                        DISPLAY c, ". ", ele
                    END FOR
                    GET item_selection
                    FOR EACH item AND quantity IN items_list AND quantity_list
                        IF item IS EQUAL TO SELECTED item_name THEN
                            DISPLAY item, " = ", quantity
                        END IF
                    END FOR
                CASE 4 THEN
                    DEFINE transactions_list, date_list, time_list AS lists
                    OPEN "transactions.txt" IN READ mode AS tf
                    READ all lines FROM tf INTO lines
                    
                    FOR line IN lines
                        data = line REMOVED " | "
                        transactions_data = line WITH STRIPPED SPACE
                        date_data = date AND time WITH STRIPPED SPACE
                        IF transactions_data STARTSWITH "Receive" THEN
                            APPEND TYPE TO date_list
                            APPEND ITEM NAME TO time_list
                            APPEND transactions_data TO transactions_list
                        END IF
                    END FOR
                    
                    DISPLAY "Date & time of received items:"
                    FOR c, (date_ele, time_ele) IN ENUMERATE ZIP(date_list, time_list) AND START WITH 1
                        DISPLAY c, ". ", date_ele, " ", time_ele
                    END FOR

                    GET start_date
                    GET end_date
                    DISPLAY "Type     Item From  Date & Time       Quantity"
                    DISPLAY "-------------------------------------------------"

                    FOR transaction IN RANGE start_date TO end_date + 1
                        DISPLAY transactions_list[transaction - 1]
                    END FOR
                CASE _:
                    DISPLAY "Invalid selection! Please try again."
            END MATCH
        END WHILE
    END FUNCTION

    FUNCTION delete_user(user_type)
        DEFINE data_list AS a list
        DEFINE selection AS INTEGER
        data_list = CALL FUNCTION readfiles("users.txt")

        FOR c AND ele IN ENUMERATE UID AND 1:
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
            EXCEPT selection IS NOT INTEGER
                DISPLAY "Please enter only a number!"
                CONTINUE
            END TRY
        END WHILE
        IF SELECTED USERNAME IS CURRENTLY LOGGED IN USER THEN
            DISPLAY "Unable to delete currently logged in user!"
            CALL delete_user(user_type)
        ELSE THEN
            UID.pop()
            FOR i IN RANGE 3:
                data_list[i+1].pop(selection-1)
                SELECTED usernme.pop()
                SELECTED password.pop()
                SELECTED usertype.pop()
            CALL FUNCTION config_save("users.txt", "w", data_list)
            CALL FUNCTION delete_user(user_type)   

        CALL FUNCTION delete_user()
    END FUNCTION

    FUNCTION search_user(fileName, mode)
        DEFINE data_list AS a list
        DEFINE selection AS INTEGER
        data_list = CALL FUNCTION readfiles("users.txt")

        FOR c AND ele IN ENUMERATE USERNAME AND 1:
            DISPLAY c, ".", ele
        END FOR

        WHILE TRUE THEN
            DISPLAY "Please select a user to search (Leave empty to quit)"
            GET selection
            IF selection IS EMPTY THEN
                RETURN
            END IF
            TRY
                IS selection INTEGER?
                IF selection IS BIGGER THAN AVAILABLE NUMBERS OF USERNAME THEN
                    DISPLAY "Please select a valid option!"
                ELSE THEN
                    selected_user = data_list[1][selection-1]
                    DISPLAY "Selected user:", selected_user
                    DISPLAY "Username:", selected_user
                    DISPLAY "UID:", data_list[0][selection-1]
                    DISPLAY "Password:", data_list[2][selection-1]
                    DISPLAY "Type:", data_list[3][selection-1]
                END IF
                BREAK
            EXCEPT selection IS NOT INTEGER
                DISPLAY "Please enter only a number!"
                CONTINUE
            END TRY
        END WHILE

        CALL FUNCTION search_user("users.txt", "r")
    END FUNCTION

    FUNCTION search()
        item_list = CALL FUNCTION readfiles("ppe.txt")
        DEFINE item_code, item_name AS LIST [], ["Face Shield", "Gloves", "Gown", "Head Cover", "Mask", "Shoe Covers"]
        DEFINE selection, item_code_selection, type_selection, current_quantity AS INTEGER
        FOR item IN item_list
            APPEND item[FIRST ITEM] TO item_code
        
        WHILE TRUE THEN
            selection = INPUT("\tPlease select a search option (Leave empty to quit):\n\t1. Distribution list\n\t2. Received list\n\t3. Specific Item\n\t4. All\n\t> ")
            IF selection IS EMPTY THEN
                RETURN
            END IF
            TRY
                IS selection INTEGER?
                BREAK
            EXCEPT selection IS NOT INTEGER
                DISPLAY "Please enter only numbers!"
                CONTINUE
            END TRY

            OPEN "transactions.txt" IN READ mode AS f
            READ all lines FROM f INTO lines

                MATCH selection
                    CASE 1 THEN
                        DISPLAY "Distribution list:"
                        FOR line IN lines
                            data = line WITH SPACE STRIPPED 
                            IF data STARTSWITH "Distribute" THEN
                                DISPLAY data
                            END IF
                        END FOR
                    CASE 2 THEN
                        DISPLAY "Received list:"
                        FOR line IN lines
                            data = line WITH SPACE STRIPPED
                            IF data STARTSWITH "Receive" THEN
                                DISPLAY data
                            END IF
                        END FOR
                    CASE 3 THEN
                        DEFINE data_list AS LIST
                        supplier_code = CALL FUNCTION readfiles("suppliers.txt")
                        hospital_code = CALL FUNCTION readfiles("hospitals.txt")
                        quantities = [0] * LENGTH OF supplier_code[0]

                        FOR c AND ele IN ENUMERATE item_code AND START WITH 1
                            DISPLAY {c}. {item_code}
                        END FOR

                        DISPLAY "Please select an item: "
                        GET item_code_selection
                        OPEN "transactions.txt" IN READ mode AS f
                        READ all lines FROM f INTO lines
                            FOR line in lines THEN
                                data = line WITH SPACE STRIPPED AND " | " REMOVED
                                APPEND data INTO data_list
                                current_quantity = data[4]
                        DISPLAY "Please select an option:\n1. Receive\n2. Distribute\n> "
                        GET type_selection
                        IF LENGTH OF lines EQUALS 0 THEN
                            DISPLAY "No transaction found!"
                        ELSE THEN
                            MATCH type_selection
                                CASE 1 THEN
                                    FOR data IN data_list
                                        IF data[0] EQUALS "Receive" AND data[1] EQUALS item name AND data[2][0] EQUALS "S" THEN
                                            supplier_index = INDEX OF data[2] IN supplier_code[0]
                                            quantities[supplier_index] += item_exist_quantity
                                        END IF
                                    END FOR
                                    DISPLAY Item: {item name}
                                    FOR spcode AND quantity IN ZIP(supplier_code[1] AND quantities)
                                        DISPLAY "From" + {spcode} = {quantity}
                                    END FOR
                                CASE 2 THEN
                                    FOR data IN data_list
                                        IF data[0] EQUALS "Distribute" AND data[1] EQUALS item_name AND data[2][0] EQUALS "H" THEN
                                            hospital_index = INDEX OF data[2] IN hospital_code[0]
                                            quantities[hospital_index] += current_quantity
                                        END IF
                                    END FOR
                                    DISPLAY f"Item: {item_name[item_code_selection - 1]}"
                                    FOR EACH hpcode, quantity IN ZIP(hospital_code[1], quantities)
                                        DISPLAY f"To {hpcode} = {quantity}"
                                    END FOR
                                CASE _:
                                    DISPLAY "No data found!"
                            END MATCH
                        END IF
                    CASE 4 THEN
                        DISPLAY "All Transactions:"
                        FOR line IN lines
                            data = line WITH SPACE STRIPPED
                            DISPLAY data
                        END FOR
                    CASE _:
                        DISPLAY "Invalid selection! Please try again."
                END MATCH
            END WITH
        END WHILE
    END FUNCTION

    FUNCTION modify_user()
        data_list = CALL FUNCTION readfiles("users.txt")
        DEFINE selection, modify_item, new_type AS INTEGER
        DEFINE new_password, new_username AS STRING
        WHILE TRUE THEN
            FOR c AND ele IN ENUMERATE username AND 1 THEN
                DISPLAY {c}. {ele} 
            END FOR
            
            DISPLAY "Please select an user to modify (Leave empty to quit)\n> "
            GET selection
            IF selection IS EMPTY THEN
                RETURN
            END IF

            TRY
                IS selection INTEGER?
                IF selection INPUT LARGER THAN LENGTH OF data_list[1] THEN
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
                            IS modify_item INTEGER?
                            MATCH modify_item THEN
                                CASE 1 THEN
                                    WHILE TRUE THEN
                                        DISPLAY f"Please enter a new username"
                                        DISPLAY f"Current username: {data_list[1][selection-1]}"
                                        GET new_username
                                        IF new_username IS EMPTY THEN
                                            DISPLAY "Username cannot be empty. Please enter a valid username."
                                        ELSE IF new_username IN data_list[1] THEN
                                            DISPLAY "Username already exists. Please choose a different one."
                                        ELSE THEN
                                            SELECTED USERNAME ROW = new_username
                                            BREAK
                                        END IF
                                    END WHILE
                                CASE 2 THEN
                                    WHILE TRUE THEN
                                        DISPLAY "Please enter a new password"
                                        DISPLAY "Current password: {data_list[2][selection-1]}"
                                        GET new_password

                                        IF new_password IS EMPTY THEN
                                            DISPLAY "Password cannot be empty. Please enter a valid password."
                                        ELSE
                                            SELECTED PASSWORD ROW = new_password
                                            BREAK
                                        END IF
                                    END WHILE
                                CASE 3 THEN
                                    WHILE TRUE THEN
                                        DISPLAY "Please enter a new user type"
                                        DISPLAY "Current user type: {data_list[3][selection-1]}"
                                        DISPLAY "New user type (1. Admin / 2. Staff):"
                                        GET new_type

                                        IF new_type IS EMPTY THEN
                                            DISPLAY "User type cannot be empty. Please select a valid option."
                                        ELSE
                                            TRY
                                                IS new_type INTEGER?
                                                MATCH new_type THEN
                                                    CASE 1 THEN
                                                        new_type = "admin"
                                                        SELECTED USER TYPE = new_type
                                                    CASE 2 THEN
                                                        new_type = "staff"
                                                        SELECTED USER TYPE = new_type
                                                    CASE NOT 1 OR 2 THEN
                                                        DISPLAY "Please select a valid option."
                                                END MATCH
                                                BREAK
                                            EXCEPT new_type IS NOT INTEGER
                                                DISPLAY "Please enter only numbers!"
                                            END TRY
                                        END IF
                                    END WHILE
                                CASE _:
                                    DISPLAY "Invalid selection! Please try again."
                                    CALL FUNCTION modify_user()
                            END MATCH

                            config_save("users.txt", "w", data_list)
                            DISPLAY "---------------------Done---------------------"
                            RETURN

                        EXCEPT ValueError THEN
                            DISPLAY "Please enter only numbers!"
                        END TRY
                    END WHILE
                END IF
            EXCEPT selection IS NOT INTEGER
                DISPLAY "Please enter only numbers!"
            END TRY
        END WHILE
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
                    is selection IS INTEGER
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
                        CALL FUNCTION update_hospital()
                    CASE 9 THEN 
                        CALL FUNCTION update_supplier()
                    CASE 0 THEN
                        CALL FUNCTION backup()
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
                    CALL FUNCTION backup()
                CASE NOT 1 TO 4 THEN
                    CALL FUNCTION DISPLAY "Invalid selection! Please try again."
            END MATCH
    END FUNCTION

    FUNCTION assign_supplier()
        DEFINE item_name AS list = ["Face Shield", "Gloves", "Gown", "Head Cover", "Mask", "Shoe Covers"]
        DEFINE data_list AS list
        DEFINE supplier_selection AS INTEGER
        WITH OPEN "suppliers.txt" IN READ mode AS f THEN
        READ all lines IN f INTO line
            IF length of lines is NOT EQUAL TO 0 THEN
                WITH OPEN "ppe.txt" IN READ mode AS f THEN
                    READ all lines IN f INTO ppelines
                    
                    IF length of ppelines is EQUAL TO 0 THEN
                        splist = lines[0] WITH SPACE STRIPPED AND "," REMOVED
                        spname = lines[1] WITH SPACE STRIPPED AND "," REMOVED
                        FOR i IN RANGE 6 THEN
                            WHILE TRUE THEN
                                FOR c AND ele IN ENUMERATE spname AND 1 THEN
                                    DISPLAY {c}. {ele}
                                supplier_selection = DISPLAY "Please select a supplier to supply {item_name[i]} > "
                                GET supplier_selection
                                TRY
                                    IS supplier_selection INTEGER?
                                    BREAK
                                    
                                EXCEPT supplier_selection IS NOT INTEGER
                                    DISPLAY "Please enter a valid number."
                                    CONTINUE
                            APPEND supplier code INTO data_list
                            END WHILE
                    END IF
            ELSE THEN
                DISPLAY "Suppliers assigned"
            END IF
        RETURN data_list
    END FUNCTION

    FUNCTION init_supplier()
        DEFINE supplier_code, supplier_data AS list
        DEFINE supplier_name AS STRING

        WITH OPEN "suppliers.txt" IN READ mode AS f:
        READ all lines OF f INTO lines
            IF length of lines is EQUAL TO 0 THEN
                DISPLAY "Setup wizard"
                DISPLAY "Require at least four suppliers! (Not changeable)"
                WHILE length of supplier_data < 4:
                    DISPLAY "Please enter supplier" {length of supplier_data + 1} "name >"
                    GET supplier_name
                    APPEND supplier_name TO supplier_data
                    sp_code = "S" + {length of supplier_data}
                    APPEND sp_code TO supplier_code
                
                WITH OPEN "suppliers.txt" IN WRITE mode AS f:
                    f.write ",".join(supplier_code) + "\n"
                    f.write ",".join(supplier_data) + "\n"
            ELSE THEN
                RETURN
            END IF
    END FUNCTION

    FUNCTION init_hospital()
        DEFINE data_list, code_list, name_list AS LIST
        DEFINE name_list_input AS STRING
        WITH OPEN "hospitals.txt" IN READ MODE AS f
        READ all lines OF f INTO lines
        FOR line IN LINES
            APPEND line WITH SPACE STRIPPED AND "," REMOVED INTO data_list
        IF LENGTH OF line IS 0 THEN
            FOR I IN RANGE(3)
                DISPLAY "There should be minimum of three hospital" + Current: {len(name_list)+1})\n + "Please enter hospital {i+1} name: "
                GET name_list_input
                APPEND name_list_input INTO name_list
                APPEND ("H" + {LENGTH OF name_list}) INTO code_list
                WITH OPEN "hospitals.txt" IN WRITE MODE AS file
                    WRITE ".".JOIN(code_list) + "\n" INTO f
                    WRITE ".".JOIN(name_list) INTO f
            END FOR
        END IF
    END FUNCTION

    FUNCTION update_hospital()
        data_list = CALL FUNCTION readfiles("hospitals.txt")
        DEFINE selection, select, delete, new_name, new_hospital_name AS INTEGER
        WHILE TRUE THEN
            DISPLAY "\tPlease select an option (Leave empty to quit):\n"
            DISPLAY "\t1. Add hospital\n"
            DISPLAY "\t2. Change hospital name\n"
            DISPLAY "\t3. Delete hospital\n"
            DISPLAY "Select an option > "
            GET selection
            IF selection IS EMPTY THEN
                RETURN
            TRY
                IS selection INTEGER?
                BREAK
            EXCEPT selection IS NOT INTEGER THEN
                DISPLAY "Please enter only numbers!"
                CONTINUE 
            END IF

            MATCH selection THEN
                CASE 1 THEN
                    DISPLAY "Please enter the new hospital name: "
                    GET new_hospital_name
                    data_list[1].APPEND(new_hospital_name)
                    data_list[0].APPEND("H" + {LENGTH OF hospital code} + 1)

                CASE 2 THEN
                    FOR c AND ele IN ENUMERATE hospital code, 1:
                        DISPLAY {c}. {ele}
                    WHILE TRUE THEN
                        DISPLAY "Please select a hospital to update name > "
                        GET select
                        TRY
                            select = CONVERT TO INTEGER select
                            BREAK
                        EXCEPT ValueError THEN
                            DISPLAY "Please enter only numbers!" 
                            CONTINUE
                        DISPLAY "Please enter the new name: "
                        GET new_name
                        SELECTED HOSPITAL NAME = new_name
                    END WHILE
                    END FOR 

                CASE 3 THEN
                    IF LENGTH OF data_list index 0 IS 3 THEN
                        DISPLAY "There must be a minimum of 3 hospitals in the system. Unable to delete."
                    ELSE:
                        FOR c AND ele IN ENUMERATE hospital code, 1:
                            DISPLAY {c}. {ele}
                        WHILE TRUE THEN
                            DISPLAY "Please select a hospital to delete > "
                            GET delete
                            TRY
                                IS delete INTEGER? 
                                BREAK
                            EXCEPT deleet IS NOT INTEGER THEN
                                DISPLAY "Please enter only numbers!" 
                                CONTINUE
                        END WHILE
                        END FOR
                        data_list[1].POP(delete - 1)
                        data_list[0].POP()
                    END IF
                CASE NONE THEN
                    DISPLAY "Please select a valid option"

            config_save("hospitals.txt", "w", data_list)
    END FUNCTION

    FUNCTION update_supplier()
        DEFINE selection AS INTEGER
        DEFINE new_name AS STRING
        data_list = readfiles("suppliers.txt")
        WHILE TRUE THEN
            DISPLAY "Please select an option (Leave empty to quit):"
            DISPLAY "1. Change Supplier name"
            GET selection
            IF selection IS EMPTY THEN
                RETURN
            END IF
            TRY
                IS selection INTEGER?
                BREAK
            EXCEPT selection IS NOT INTEGER THEN
                DISPLAY "Please enter only number!"
                CONTINUE
            MATCH selection THEN   
                CASE 1 THEN
                    FOR c AND ele IN ENUMERATE supplier code AND START WITH 1 THEN
                        DISPLAY {c}. {ele}
                    WHILE TRUE THEN
                        DISPLAY "Please select a supplier: "
                        GET selection
                        IF selection IS EMPTY THEN
                            RETURN
                        END IF
                        TRY
                            IS selection INTEGER?
                            BREAK
                        EXCEPT selection IS NOT INTEGER THEN
                            DISPLAY "Please enter only number!"
                            CONTINUE
                        DISPLAY "Please enter new name (Leave empty to quit): "
                        GET new_name
                        IF new_name IS EMPTY THEN
                            RETURN
                        ELSE THEN
                            selected supplier name = new_name
                CASE NONE THEN
                    DISPLAY "Please select a valid option"
                CALL FUNCTION config_save("suppliers.txt","w",data_list)
    END FUNCTION
                        
    FUNCTION config_save(fileName,mode,data_list)
        FOR data in data_list THEN
            WRITE ",".JOIN(data) + "\n"

    FUNCTION backup()
        DEFINE data_list AS list 
        DEFINE files AS list ["ppe.txt", "users.txt"]

        FOR EACH file IN files THEN
            WITH OPEN file IN READ mode AS f:
                lines = f.readlines()
                FOR EACH line IN lines THEN
                    APPEND line.strip().split(",") TO data_list
                END FOR
        END FOR

            WITH OPEN "backup.txt" IN WRITE mode AS f THEN
                FOR EACH i IN data_list THEN
                    f.write ",".join(i) + "\n"
                END FOR

        QUIT()
    END FUNCTION    

    CALL FUNCTION init_inv()
END
