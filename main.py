import datetime

current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

#Check ppe.txt and suppliers.txt
def init_inv():
    item_code = ["FS","GL","GW","HC","MS","SC"]
    try:
        with open("ppe.txt","r") as f:
            if f.read() == "":
                utype = login()
                init_supplier()
                init_hospital()
                data_list = assign_supplier()
                print("Inventory initiated")
                with open("ppe.txt","a") as f:
                    for i in range(len(item_code)):
                        f.write(f"{item_code[i]},{100},{data_list[i]}\n")
                menu(utype)
            else:
                utype = login()
                menu(utype)
    except FileNotFoundError:
        print("The file was not found.")

#Update inventory
def inv_update():
    item_code,item_name = ["FS","GL","GW","HC","MS","SC"], ["Face Shield","Gloves","Gown","Head Cover","Mask","Shoe Covers"]
    hospital_list = []
    list_data = []
    trans_data = []
    while True:
        menu_select, select_data = input("Please select an option (Leave empty to quit):\n1. Receive\n2. Distribute\t\n> "), ["Receive","Distribute"]
        if not menu_select:
            return
        try:
            menu_select = int(menu_select)
            break
        except ValueError:
            print("Please enter only numbers!")
            continue
    with open("ppe.txt","r") as f, open("hospitals.txt","r") as hf:
        lines = f.readlines()
        hlines = hf.readlines()
        for line in hlines:
            hospital_list.append(line.strip().split(","))
        for line in lines:
            data = line.strip().split(",")
            list_data.append(data)
        for c,ele in enumerate(list_data,1):
            print(f"{c}. {item_name[item_code.index(ele[0])]} - {ele[1]} Boxes")
        selection = int(input("Please enter item code number > "))
        quantity_to_change = int(input("Quantity to change > "))
        for c,ele in enumerate(list_data,1):
            item = item_name[item_code.index(ele[0])]
            itemcode = ele[0]
            supplier = ele[2]
            if selection == c:
                match menu_select:
                    case 1:
                        new_quantity = int(ele[1]) + quantity_to_change
                        trans_line = (f"{select_data[menu_select-1]} | {item} | {supplier} | {current_time} | {quantity_to_change}\n")
                    case 2:
                        if int(ele[1]) == 0 or quantity_to_change > int(ele[1]):
                            print("Insufficient for distribution")
                            inv_update()
                        else:
                            new_quantity = int(ele[1]) - quantity_to_change
                            for c,ele in enumerate(hospital_list[0],1):
                                print(f"{c}.{ele}")
                            while True:
                                to_hospital = input("Distribute to hospital > ")
                                try:
                                    to_hospital = int(to_hospital)
                                    break
                                except ValueError:
                                    print("Please valid number!")
                                    continue
                        trans_line = (f"{select_data[menu_select-1]} | {item} | {hospital_list[0][to_hospital-1]} | {current_time} | {quantity_to_change}\n") 
                    case _:
                        print("Invalid selection. Please try again.")
                #Append data        
                lines[selection - 1] = (f"{itemcode},{new_quantity},{supplier}\n")
                trans_data.append(trans_line)
        #Write data
        with open("ppe.txt","w") as pf, open("transactions.txt","a") as tf:
            pf.writelines(lines)
            tf.writelines("\n".join(trans_data))
            print(f"Inventory updated>  {item_name[selection-1]} = {new_quantity} Boxes")
        inv_update()  

#Login menu
def login():
    data_list = readfiles("users.txt")
    #Check if username match password
    while True:
        username,passwd = input("Please enter login credential (Leave empty to quit login):\n\tUsername: "), input("\tPassword: ")
        if username in data_list[1] and passwd == data_list[2][data_list[1].index(username)]:
            check_type = (data_list[3][data_list[1].index(username)])
            return check_type
        elif username == "" and passwd == "":
            quit()
        else:
            print("Invalid credential. Please try again.")
            break
    init_inv()

#Add new user
def register():
    #Read users.txt
    data_list = readfiles("users.txt")
    #UID Generation
    for c in enumerate(data_list[0],1):
        last_id = c
    username = input("\tPlease enter register credential\n\tUsername: ")
    #Check if username already exist
    if username in data_list[1]:
        print("Username already exist!")
        register()
    else:
        #Append User Data
        data_list[0].append(f"uid{last_id[0]+1}")
        data_list[1].append(username)
        data_list[2].append(input("\tPassword: "))
        data_list[3].append(input("\tAccount Type (admin/staff): ").lower())
        #Write Data
        config_save("users.txt","w",data_list)
        print("> New user added\nReturning to menu...")
        return

#Inventory tracking
def inv_track():
    item_code,item_name = ["FS","GL","GW","HC","MS","SC"], ["Face Shield","Gloves","Gown","Head Cover","Mask","Shoe Covers"]
    items_list, quantity_list = [],[]
    with open("ppe.txt","r") as f:
        lines = f.readlines()
        for c,line in enumerate(lines,1):
            data = line.strip().split(",")
            items_list.append(item_name[item_code.index(data[0].strip())])
            quantity_list.append(int(data[1].strip()))
    while True:
        #Select an option from menu
        selection = (input(f"{'-'*66}\n\tPlease select and option (Leave empty to exit) :\n\t1. Check all items quantity\n\t2. Item less than 25 boxes\n\t3. Check specific item\n\t4. Item received during specific time\n\tn> "))
        if not selection:
            return
        try:
            selection = int(selection)
        except ValueError:
            print("Please enter only number!")
            continue
        match selection:
            #Option 1, check all items
            case 1:
                print("\tQuantity of all items:")
                for items,quantity in zip(items_list,quantity_list):
                    print(f"\t{items} = {quantity}")
            #Option 2, display item that is less than 25 boxes
            case 2:
                print("\tItem less than 25 Boxes:")
                for items,quantity in zip(items_list,quantity_list):
                    #Check if item is less than 25 boxes
                    if quantity < 25:
                        print(f"\t{items} = {quantity}")
            #Option 3, display specific item
            case 3:
                #List out all items 
                for c,ele in enumerate(item_name,1):
                    print(f"\t{c}. {ele}")
                #Item selection
                item_selection = int(input("Please select an item: "))
                for items,quantity in zip(items_list,quantity_list):
                    if items == item_name[item_selection-1]:
                                print(f"\t{items} = {quantity}")
            #Option 4. display item from specific date 
            case 4:
                transactions_list,date_list,time_list = [],[],[]
                #Read transactions.txt
                with open("transactions.txt","r") as f:
                    lines = f.readlines()
                    for line in lines:
                        data =  line.strip().split(" | ")
                        transactions_data = line.strip()
                        date_data = (data[3].strip().split(" "))
                        #Find data that starts with "Receive"
                        if transactions_data.startswith("Receive"):
                            #Append filtered data into list
                            date_list.append(date_data[0])
                            time_list.append(date_data[1])
                            transactions_list.append(transactions_data)
                    print("Date & time of received items")
                    #List out all date and time data
                    for c,(date_ele,time_ele) in enumerate(zip(date_list,time_list),1):
                        print(f"{c}. {date_ele} {time_ele}")
                    #Input start date and end date
                    start_date,end_date = int(input("Please select an start date > ")), int(input("Please select an end date > "))
                    print(f"Type     Item From  Date & Time\t\t Quantity\n{'-'*53}")
                    for transaction in range(start_date,end_date+1):
                        print(transactions_list[transaction-1])
                    inv_track()
            case _:
                print("Invalid selection! Please try again.")
                inv_track()

#Delete user
def delete_user(user_type):
    #Read users.txt
    data_list = readfiles("users.txt")
    #Print username list
    for c,ele in enumerate(data_list[1],1):
        print(f"{c}. {ele}")
    while True:
        #Prompt user to select a user to remove
        selection = (input("Select the user you want to remove (Leave empty to quit) > "))
        if not selection:
            return
        try:
            selection = int(selection)
            break
        except ValueError:
            print("Please enter only number!")
            continue
    #Check if the selected users is current logged in user
    if data_list[1][selection-1] == user_type:
        print("Unable to delete current logged in user!")
        delete_user(user_type)
    else:
        #Remove selected data from users.txt
        data_list[0].pop()
        for i in range(3):
            data_list[i+1].pop(selection-1)
        config_save("users.txt","w",data_list)
        delete_user(user_type)

#Search user
def search_user():
    #Read data from users.txt
    data_list = readfiles("users.txt")
    #List all user data 
    for c,ele in enumerate(data_list[1],1):
        print(f"{c}. {ele}")
    while True:
        #Prompt user to select an user
        selection = input("Please select an user to search (Leave empty to quit)\n> ")
        if not selection:
            return
        try:
            selection = int(selection)
            #Check is selection is bigger than numbers of data
            if selection > len(data_list[1]):
                print("Please select a valid option!")
            else:
                print(f"Selected user: {data_list[1][selection-1]}\nUsername: {data_list[1][selection-1]}\nUID: {data_list[0][selection-1]}\nPassword: {data_list[2][selection-1]}\nType: {data_list[3][selection-1]}")
            break
        except ValueError:
            print("Please enter only number!")
            continue 
    search_user()

#Search Transactions.txt
def search():
    item_code,item_name = ["FS","GL","GW","HC","MS","SC"], ["Face Shield","Gloves","Gown","Head Cover","Mask","Shoe Covers"]
    while True:
        #Prompt user to select an option
        selection = (input("\tPlease select search option (Leave empty to quit):\n\t1. Distribution list\n\t2. Received list\n\t3. Specific Item\n\t4. All\n\t> "))
        if not selection:
            return
        try:
            selection = int(selection)
            break
        except ValueError:
            print("Please enter only number!")
            continue
    #Read data from transactions.txt
    with open("transactions.txt","r") as f:
        supplier_code = ["S1","S2","S3","S4"]
        transaction_suppliercode = []
        transaction_quantity = []
        lines = f.readlines()
        match selection:
            case 1:
                for line in lines:
                    data = line.strip()
                    #Find data that starts with "Distribute"
                    if data.startswith("Distribute"):
                        print(data)
            case 2:
                for line in lines:
                    data = line.strip()
                    #Find data that starts with "Receive"
                    if data.startswith("Receive"):
                        print(data)
            case 3:
                data_list = []
                item_code, item_name = ["FS", "GL", "GW", "HC", "MS", "SC"], ["Face Shield", "Gloves", "Gown", "Head Cover", "Mask", "Shoe Covers"]
                supplier_code = ["S1", "S2", "S3", "S4"]
                hospital_code = ["H1", "H2", "H3", "H4"]
                quantities = [0] * len(supplier_code)

                for c, ele in enumerate(item_code, 1):
                    print(f"{c}. {ele}")
                item_code_selection = int(input("Please select an item: "))

                with open("transactions.txt", "r") as f:
                    lines = f.readlines()
                    for line in lines:
                        data = line.strip().split(" | ")
                        data.pop(3)
                        data_list.append(data)
                type_selection = int(input("Please select an option:\n1. Receive\n2. Distribute\n> "))
                match type_selection:
                    case 1:
                        for data in data_list:
                            if data[1] == item_name[item_code_selection - 1]:
                                supplier_index = supplier_code.index(data[2])
                                quantities[supplier_index] += int(data[3])
                        print(f"\n{item_name[item_code_selection - 1]}")
                        for spcode,quantity in zip(supplier_code,quantities):
                            print(f"{spcode} = {quantity}")
                    
                    case 2:
                        for data in data_list:
                            if data[1] == item_name[item_code_selection - 1]:
                                hospital_index = hospital_code.index(data[2])
                                quantities[hospital_index] += int(data[3])
                        print(f"\n{item_name[item_code_selection - 1]}")
                        for hpcode,quantity in zip(hospital_code,quantities):
                            print(f"{hpcode} = {quantity}")
                    case _:
                        print("Invalid Selection")

            case 4:
                for line in lines:
                    data = line.strip()
                    #Print all data
                    print(data)
            case _:
                print("Invalid selection! Please try again.")
    search()

#Modify user
def modify_user():
    data_list = readfiles("users.txt")
    #Print username list
    while True:
        for c,ele in enumerate(data_list[1],1):
            print(f"{c}. {ele}")
        selection = input("Please select an user to modify (Leave empty to quit)\n> ")
        if not selection:
            return
        try:
            selection = int(selection)
            if selection > len(data_list[1]):
                print("Please select a valid option!")
            else:
                while True:
                    modify_item = input("\tPlease select an item to modify (Leave empty to quit)\n\t1. Username\n\t2. Password\n\t3. User Type\t\n> ")
                    if not modify_item:
                        return
                    try:
                        modify_item = int(modify_item)
                        break
                    except ValueError:
                        print("Please enter only numbers!")
                        continue
                match modify_item:
                    case 1:
                        while True:
                            #Prompt user to input new username
                            new_username = input(f"Please enter a new username\nCurrent username: {data_list[1][selection-1]}\nNew username: ")
                            if not new_username:
                                #If input is empty
                                print("Username cannot be empty. Please enter a valid username.")
                            elif new_username in data_list[1]:
                                print("Username already exists. Please choose a different one.")
                            else:
                                data_list[1][selection-1] = new_username
                                break
                    case 2:
                        while True:
                            #Prompt user to enter new password
                            new_password = input(f"Please enter a new password\nCurrent password: {data_list[2][selection-1]}\nNew password: ")
                            if not new_password:
                                #If input is empty
                                print("Password cannot be empty. Please enter a valid password.")
                            else:
                                data_list[2][selection-1] = new_password
                                break
                    case 3:     
                        while True:
                            #Prompt user to input new user type
                            new_type = int(input(f"Please enter a new user type\nCurrent user type: {data_list[3][selection-1]}\nNew user type (1. Admin/2. Staff): "))
                            if not new_type:
                                print("User type cannot be empty. Please select a valid option.")
                            else:
                                match new_type:
                                    case 1:
                                        #If new user type is admin
                                        new_type = "admin"
                                        data_list[3][selection-1] = new_type
                                    case 2:
                                        #If new user type is staff
                                        new_type = "staff"
                                        data_list[3][selection-1] = new_type
                                    case _:
                                        print("Please select a valid option.")
                                        continue
                                break
                            try:
                                new_type = int(new_type)
                            except ValueError:
                                print("Please enter only numbers!")
                    case _:
                        print("Invalid selection! Please try again.")
                        modify_user()
                #Write new data into users.txt
                config_save("users.txt","w",data_list)
                print("---------------------Done---------------------")
        except ValueError:
            print("Please enter only number!")
            continue    

#Admin menu
def menu(user_type):
    if user_type == "admin":
        print(f"\tINVENTORY MANAGEMENT SYSTEM (Admin)\n\t{'+'*34}")
        while True:
            select = input("\t1. Item Inventory Update\n\t2. Item Inventory Tracking\n\t3. Search distribution list\n\t4. Add new user\n\t5. Delete user\n\t6. Search user\n\t7. Modify User\n\t8. Update hospital\n\t9. Logout\n> ")
            try:
                #Check if user entered anythings other than number
                select = int(select)
            except ValueError:
                print("Please enter only number!")
                continue
            #Check menu selection
            match select:
                case 1:
                    inv_update()
                case 2:
                    inv_track()
                case 3:
                    search()
                case 4:
                    register()
                case 5:
                    delete_user(user_type)
                case 6:
                    search_user()
                case 7:
                    modify_user()
                case 8:
                    update_hospital()
                case 9:
                    backup()
                case _:
                    print("Invalid selection! Please try again.") 
    else:
         print("\n\tINVENTORY MANAGEMENT SYSTEM (User)\n\t++++++++++++++++++++++++++++++++++") 
    while True:
        select = input("\t1. Item Inventory Update\n\t2. Item Inventory Tracking\n\t3. Search distribution list\n\t4. Logout\n> ")
        try:
            #Check if user entered anythings other than number
            select = int(select)
        except ValueError:
            print("Please enter only number!")
            continue
        #Check menu selection
        match select:
            case 1:
                inv_update()
            case 2:
                inv_track()
            case 3:
                search()
            case 4:
                quit()
            case _:
                print("Invalid selection! Please try again.")

#assign supplier
def assign_supplier():
    item_name = ["Face Shield","Gloves","Gown","Head Cover","Mask","Shoe Covers"]
    data_list = []
    with open("suppliers.txt", "r") as f:
        lines = f.readlines()
        if len(lines) != 0:
            with open("ppe.txt","r") as f:
                ppelines = f.readlines()
                if len(ppelines) == 0:
                    splist = lines[0].strip().split(",")
                    spname = lines[1].strip().split(",")
                    supplier_counts = [0] * len(spname)
                    #data will become > [0,0,0,0]
                    for i in range(6):
                        while True:
                            for c, ele in enumerate(spname, 1):
                                print(f"{c}. {ele}")
                            try:
                                supplier_selection = int(input(f"Please select a supplier to supply {item_name[i]} > "))
                                if 1 <= supplier_selection <= len(spname):
                                    if supplier_counts[supplier_selection - 1] < 2:
                                        #data will become [1,0,0,0] when 1 is selected
                                        data_list.append(splist[supplier_selection - 1])
                                        supplier_counts[supplier_selection - 1] += 1
                                        break
                                    else:
                                        print(f"{spname[supplier_selection - 1]} has already supplied two items. Please select another supplier.")
                                else:
                                    print("Invalid supplier number. Please enter a valid number.")
                            except ValueError:
                                print("Please enter a valid number.")
        else:
            print("Suppliers assigned")
    return data_list

#setup supplier.txt
def init_supplier():
    supplier_data = []
    supplier_code = []
    with open("suppliers.txt","r") as f:
        lines = f.readlines()
        if len(lines) == 0:
            print("Setup wizard\nRequire at least four suppliers! (Not changable)")
            while len(supplier_data) < 4:
                supplier_name = input(f"Please enter supplier {len(supplier_data) + 1} name > ")
                supplier_data.append(supplier_name)
                sp_code = (f"S{len(supplier_data)}")
                supplier_code.append(sp_code)
            #Assign items to supplier
            with open("suppliers.txt",'w') as f:
                f.write(",".join(supplier_code)+"\n")
                f.write(",".join(supplier_data)+"\n")
        else:
            return

#Initial Hospital
def init_hospital():
    data_list,code_list,name_list = [],[],[]
    with open("hospitals.txt","r") as f:
        lines = f.readlines()
        for line in lines:
                data_list.append(line.strip().split(","))
        if len(lines) == 0:
                for i in range(3):
                    name_list.append(input(f"There should be minimum of three hospital (Current: {len(name_list)+1})\nPlease enter hospital {i+1} name: "))
                    code_list.append(f"H{len(name_list)}")
                    with open("hospitals.txt","w") as f:
                        f.write(",".join(code_list) + "\n")
                        f.write(",".join(name_list))

#Modify hospital
def update_hospital():
    
    data_list = readfiles("hospitals.txt")
    while True:
        selection = input("\tPlease select an option (Leave empty to quit):\n\t1. Add hospital\n\t2. Change hospital name\n\t3. Delete hospital\n\t> ")
        if not selection:
            return
        try:
            selection = int(selection)
        except ValueError:
            print("Please enter only number!")
            continue
        match selection:
            case 1:
                data_list[1].append(input("Please enter new hospital name: "))
                data_list[0].append(f"H{len(data_list[0])+1}")
            case 2:
                for c,ele in enumerate(data_list[0],1):
                    print(f"{c}. {ele}")
                while True:
                    select = input("Please select a hospital to update name > ")
                    try:
                        select = int(select)
                        break
                    except ValueError:
                        print("Please enter only numbers!")
                        continue
                data_list[1][select-1] = input("Please enter new name: ")
            case 3:
                if len(data_list[0]) == 3:
                    print("There must be minimum 3 hospital in system, unable to delete.")
                for c,ele in enumerate(data_list[1],1):
                    print(f"{c}. {ele}")
                while True:
                    delete = input("Please select a hospital to delete > ")
                    try:
                        delete = int(delete)
                        break
                    except ValueError:
                        print("Please enter only number!")
                        continue
                (data_list[1]).pop(delete-1)
                (data_list[0]).pop()
            
            case _:
                print("Please select a valid option")

        config_save("hospitals.txt","w",data_list)

def update_supplier():
    data_list = readfiles("suppliers.txt")
    while True:
        selection = input("\tPlease select an option (Leave empty to quit):\n\t1. Add Supplier\n\t2. Change Supplier name\n\t3. Delete Supplier")
        if not selection:
            return
        try:
            selection.isdigit()
            break
        except ValueError:
            print("Please enter only number!")
            continue
    match selection:
        case 1:
            for c,ele in enumerate(data_list[1],1):
                print(f"{c}. {ele}")
            
            

#save config for ppe.txt    
def config_save(fileName,mode,data_list):
    with open(fileName,mode) as f:
        for data in data_list:
            f.write(",".join(data) + "\n")

#Backup when quit
def backup():
    data_list,files, = [],["ppe.txt","users.txt"]
    for file in files:
        with open(file,"r") as f:
            lines = f.readlines()
            for line in lines:
                data_list.append(line.strip().split(","))
        with open("backup.txt","w") as f:
            for i in data_list:
                f.write(",".join(i) + "\n")
    quit()

#Read files
def readfiles(file):
    data_list = []
    with open(file,"r") as f:
        lines = f.readlines()
        for line in lines:
            data_list.append(line.strip().split(","))
    return data_list

init_inv()