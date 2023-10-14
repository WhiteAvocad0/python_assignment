def inv_update():
    trans_data = []
    menu_select,select_data = int(input("Please select an option:\n1. Receive\n2. Distribute\n3. Quit\n> ")), ["Receive","Distribute"]
    with open("ppe.txt","r") as f:
        lines = f.readlines()
    #Print list of items and remains quantity
    for c, (ele,line) in enumerate(zip(item_name,lines),1):
        remain = line.strip().split(",")
        print(f"{c}.{ele} - {remain[1]}Boxes")
    while True:
        selected,change_quantity = input("Please enter item code number> "), input("Quantity to change > ")
        try:
            selected = int(selected)
            change_quantity = int(change_quantity)
            break
        except ValueError:
            print("Please enter only number!")
            continue
    for number_line,line in enumerate(lines,1):
        data = line.strip().split(",")
        items,quantity = data[0].strip(),int(data[1].strip())
        splr = data[2].strip()
        #Loop through list to find the matched selection
        if selected == number_line:
            match menu_select:
                case 1:
                    new_quantity = quantity + change_quantity
                    trans_line = (f"{select_data[menu_select-1]} | {items} | {splr} | {current_time} | +{change_quantity}\n")
                case 2:
                    if quantity == 0 or change_quantity > quantity:
                        print("Insufficient for distribution!")
                        menu()
                    else:
                        new_quantity = quantity - change_quantity
                    #Print hospital list
                    for c,ele in enumerate(hospital_list,1):
                        print(f"{c}.{ele}")
                    while True:
                        to_hospital = input("Distribute to hospital > ")
                        try:
                            to_hospital = int(to_hospital)
                        except ValueError:
                            print("Please valid number!")
                            continue
                        break
                    trans_line = (f"{select_data[menu_select-1]} | {items} | {hospital_list[to_hospital-1]} | {current_time} | -{change_quantity}\n") 
                case 3:
                    return
                case _:
                    print("Invalid selection! Please try again.")
            #Append data        
            lines[number_line - 1] = (f"{items},{new_quantity},{splr}\n")
            trans_data.append(trans_line)
    #Write data
    with open("ppe.txt","w") as f:
        f.writelines(lines)
    with open("transactions.txt","a") as f:
        f.writelines("\n".join(trans_data))
        print(f"Inventory updated>  {items} ({item_name[selected-1]}) = {new_quantity} Boxes")
    inv_update()
        