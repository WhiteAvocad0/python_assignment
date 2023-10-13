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
                            CALL admin_menu()
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
        PRINT Inventory updated: {items} ({item_name[selected - 1]}) = {new_quantity} Boxes
        
        CALL inv_update()
    END TRY


