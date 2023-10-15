import datetime

item_code,item_name, quantity = ["FS","GL","GW","HC","MS","SC"], ["Face Shield","Gloves","Gown","Head Cover","Mask","Shoe Covers"], [100,100,100,100,100,100]
hospital_list, supplier_list, supplier_name = ["H1","H2","H3","H4"], ["S1","S2","S3","S3","S4","S4"], ["SupplierA","SupplierB","SupplierC","SupplierD"]
current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def init_inv():
    init_supplier()
    data_list = assign_supplier()
    try:
        with open("ppe.txt","r") as f:
            if f.read() == "":
                print("Inventory initiated")
                with open("ppe.txt","a") as f:
                    for i in range(len(item_code)):
                        f.write(f"{item_code[i]},{quantity[i]},{data_list[i]}\n")
                login()
            else:
                login()
    except FileNotFoundError:
        print("The file was not found.")

def inv_update():
    list_data = []
    trans_data = []
    select_data = ["Receive","Distribute"]
    while True:
        menu_select = input("Please select an option (Leave empty to quit):\n1. Receive\n2. Distribute\t\n> ")
        if not menu_select:
            menu()
        try:
            menu_select = int(menu_select)
            break
        except ValueError:
            print("Please enter only numbers!")
            continue
    with open("ppe.txt","r") as f:
        lines = f.readlines()
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
                        trans_line = (f"{select_data[menu_select-1]} | {item} | {supplier} | {current_time} | +{quantity_to_change}\n")
                    case 2:
                        if int(ele[1]) == 0 or quantity_to_change > int(ele[1]):
                            print("Insufficient for distribution")
                            menu()
                        else:
                            new_quantity = int(ele[1]) - quantity_to_change
                            for c,ele in enumerate(hospital_list,1):
                                print(f"{c}.{ele}")
                            while True:
                                to_hospital = input("Distribute to hospital > ")
                                try:
                                    to_hospital = int(to_hospital)
                                    break
                                except ValueError:
                                    print("Please valid number!")
                                    continue
                        trans_line = (f"{select_data[menu_select-1]} | {item} | {hospital_list[to_hospital-1]} | {current_time} | -{quantity_to_change}\n") 
                    case _:
                        print("Invalid selection. Please try again.")
                #Append data        
                lines[selection - 1] = (f"{itemcode},{new_quantity},{supplier}\n")
                trans_data.append(trans_line)
        #Write data
        with open("ppe.txt","w") as f:
            f.writelines(lines)
        with open("transactions.txt","a") as f:
            f.writelines("\n".join(trans_data))
            print(f"Inventory updated>  {item_name[selection-1]} = {new_quantity} Boxes")
        inv_update()  

def login():
    with open("users.txt","r") as f:
        lines = f.readlines()
        #List check
        user_name = lines[1].strip().split(",")
        user_password = lines[2].strip().split(",")
        user_type = lines[3].strip().split(",")
        #Check if username match password
        while True:
            username,passwd = input("Please enter login credential (Leave empty to quit login):\n\tUsername: "), input("\tPassword: ")
            if username in user_name and passwd == user_password[user_name.index(username)]:
                check_type = (user_type[user_name.index(username)])
                if check_type == "admin":
                    menu()
                else:
                    user_menu()
                break
            elif username == "" and passwd == "":
                quit()
            else:
                print("Invalid credential. Please try again.")
                break
        init_inv()

#Add new user
def register():
    uid_list,username_list,password_list,type_list = [],[],[],[]
    username,passwd,usertype = input("\tPlease enter register credential\n\tUsername: "),input("\tPassword: "),input("\tAccount Type (admin/staff): ").lower()    
    with open("users.txt","r") as f:
        lines = f.readlines()
        #List check
        user_id = lines[0].strip().split(",")
        user_name = lines[1].strip().split(",")
        user_password = lines[2].strip().split(",")
        user_type = lines[3].strip().split(",")
        #Append user data to new list
        uid_list.extend(user_id)
        username_list.extend(user_name)
        password_list.extend(user_password)
        type_list.extend(user_type)
        #Check if username already exist
        if username in user_name:
            print("Username already exist!")
            register()
        #UID Generation
        for c in enumerate(uid_list,1):
            last_id = c
        #Append User Data
        uid_list.append(f"uid{last_id[0]+1}")
        username_list.append(username)
        password_list.append(passwd)
        type_list.append(usertype)
        #Write Data
        config_save("users.txt","w",uid_list,username_list,password_list,type_list)
        print("> Registered")
        menu()

#Inventory tracking
def inv_track():
    while True:
        selection = (input(f"{'-'*66}\n\tPlease select and option:\n\t1. Check all items quantity\n\t2. Item less than 25 boxes\n\t3. Check specific item\n\t4. Item received during specific time\n\t5. Back\n> "))
        try:
            selection = int(selection)
            break
        except ValueError:
            print("Please enter only number!")
            continue
    match selection:
        case 1:
            print("\tQuantity of all items:")
        case 2:
            print("\tItem less than 25 Boxes:")
        case 3:
            for c,ele in enumerate(item_name,1):
                print(f"\t{c}. {ele}")
            item_selection = int(input("Please select an item: "))
        case 4:
            transactions_list,date_list,time_list = [],[],[]
            with open("transactions.txt","r") as f:
                lines = f.readlines()
                for line in lines:
                    data,transactions_data,date_data = line.strip().split(" | "),line.strip(),(data[3].strip().split(" "))
                    if transactions_data.startswith("Receive"):
                        date_list.append(date_data[0])
                        time_list.append(date_data[1])
                        transactions_list.append(transactions_data)
                print("Date & time of received items")
                for c,(date_ele,time_ele) in enumerate(zip(date_list,time_list),1):
                    print(f"{c}. {date_ele} {time_ele}")
                start_date,end_date = int(input("Please select an start date > ")), int(input("Please select an end date > "))
                print(f"Type     Item From  Date & Time\t\t Quantity\n{'-'*53}")
                for transaction in range(start_date,end_date+1):
                    print(transactions_list[transaction-1])
                inv_track()
        case 5:
            menu()
        case _:
            print("Invalid selection! Please try again.")
            inv_track()
    with open("ppe.txt","r") as f:
        lines = f.readlines()
        for c,line in enumerate(lines,1):
            data = line.strip().split(",")
            items,quantity = item_name[item_code.index(data[0].strip())],int(data[1].strip())
            match selection:
                case 1:
                    print(f"\t{items} = {quantity}")
                case 2:
                    if quantity < 25:
                        print(quantity)
                        print(f"\t{items} = {quantity}")
                    else:
                        print("\tNo items are less than 25 Boxes !")
                        break
                case 3:
                    if items == item_name[item_selection-1]:
                        print(f"\t{items} = {quantity}")
        inv_track()

#Delete user
def delete_user(fileName,mode):
    with open(fileName,mode) as f:
        lines = f.readlines()
        #List check
        uid_data = lines[0].strip().split(",")
        username_data = lines[1].strip().split(",")
        password_data = lines[2].strip().split(",")
        type_data = lines[3].strip().split(",")
        #Print username list
        for c,ele in enumerate(username_data,1):
            print(f"{c}. {ele}")
        while True:
            selection = (input("Select the user you want to remove> "))
            try:
                selection = int(selection)
                break
            except ValueError:
                print("Please enter only number!")
                continue
        #Remove selected data from users.txt
        uid_data.pop()
        username_data.pop(username_data.index(username_data[selection-1]))
        password_data.pop(selection-1)
        type_data.pop(selection-1)
        config_save("users.txt","w",uid_data,username_data,password_data,type_data)
    init_inv()

def search_user(fileName,mode):
    with open(fileName,mode) as f:
        lines = f.readlines()
        #List check
        uid_data,username_data,password_data,type_data = lines[0].strip().split(","),lines[1].strip().split(","),lines[2].strip().split(","),lines[3].strip().split(",")
    for c,ele in enumerate(username_data,1):
        print(f"{c}. {ele}")
    while True:
        selection = int(input("Please select an user to search (Enter 0 to quit)\n> "))
        try:
            selection = int(selection)
            break
        except ValueError:
            print("Please enter only number!")
            continue 
    print(f"Selected user: {username_data[selection-1]}\nUsername: {username_data[selection-1]}\nUID: {uid_data[selection-1]}\nPassword: {password_data[selection-1]}\nType: {type_data[selection-1]}")
    search_user("users.txt","r")

#Search Transactions.txt
def search():
    while True:
        selection = (input("\tPlease select search option:\n\t1. Distribution list\n\t2. Received list\n\t3. All\n\t4. Exit\n> "))
        try:
            selection = int(selection)
            break
        except ValueError:
            print("Please enter only number!")
            continue
    match selection:
        case 1:
            print(f"Type        Item  To  Date & Time\t\t    Quantity\n{'-'*60}")
        case 2:
            print(f"Type     Item From  Date & Time\t\t\t Quantity\n{'-'*60}")
    with open("transactions.txt","r") as f:
        lines = f.readlines()
        for line in lines:
            data = line.strip()
            match selection:
                case 1:
                    if data.startswith("Distribute"):
                        print(f"{data}\n{'-'*60}")
                case 2:
                    if data.startswith("Receive"):
                        print(f"{data}\n{'-'*60}")
                case 3:
                    print(data)
                case 4:
                    menu()
                case _:
                    print("Invalid selection! Please try again.")
        search()

#Admin menu
def menu():
    print(f"\tINVENTORY MANAGEMENT SYSTEM (Admin)\n\t{'+'*34}")
    while True:
        select = input("\t1. Item Inventory Update\n\t2. Item Inventory Tracking\n\t3. Search distribution list\n\t4. Add new user\n\t5. Delete user\n\t6. Search user\n\t7. Modify User\n\t8. Logout\n> ")
        try:
            #Check if user entered anythings other than number
            select = int(select)
            break
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
            delete_user("users.txt","r")
        case 6:
            search_user("users.txt","r")
        case 7:
            modify_user()
        case 8:
            quit()
        case _:
            print("Invalid selection! Please try again.")
            menu()

def modify_user():
    #USER DATA
    uid_list,username_list,password_list,type_list = [],[],[],[]
    with open("users.txt","r") as f:
        lines = f.readlines()
        #Read user data from file
        uid_data = lines[0].strip().split(",")
        username_data = lines[1].strip().split(",")
        password_data = lines[2].strip().split(",")
        type_data = lines[3].strip().split(",")
        #Append user data to new list
        uid_list.extend(uid_data)
        username_list.extend(username_data)
        password_list.extend(password_data)
        type_list.extend(type_data)
        #Print username list
        for c,ele in enumerate(username_data,1):
            print(f"{c}. {ele}")
        while True:
            selection = input("Please select an user to modify (Leave empty to quit)\n> ")
            if not selection:
                menu()
            try:
                selection = int(selection)
                break
            except ValueError:
                print("Please enter only number!")
                continue
        match selection:
            case 0:
                menu()
        while True:
            modify_item = int(input("\tPlease select an item to modify\n\t1. Username\n\t2. Password\n\t3. User Type\n\t4. Back\n> ")) 
            match modify_item:
                case 1:
                    while True:
                        new_username = input(f"Please enter a new username\nCurrent username: {username_data[selection-1]}\nNew username: ")
                        if new_username in username_list:
                            print("Username already exists. Please choose a different one.")
                        else:
                            username_list[selection-1] = new_username
                            break
                case 2:
                    new_password = input(f"Please enter a new password\nCurrent password: {password_data[selection-1]}\nNew password: ")
                    password_list[selection-1] = new_password
                case 3:
                    new_type = int(input(f"Please enter a new user type\nCurrent user type: {type_data[selection-1]}\nNew user type (1. Admin/2. Staff): "))
                    match new_type:
                        case 1:
                            new_type = "admin"
                        case 2:
                            new_type = "staff"
                    type_list[selection-1] = new_type
                case 4:
                    modify_user()
                case _:
                    print("Invalid selection! Please try again.")
                    modify_user()
            #Write new data into users.txt
            config_save("users.txt","w",uid_list,username_list,password_list,type_list)
            print("---------------------Done---------------------")       

def user_menu():
    print("\n\tINVENTORY MANAGEMENT SYSTEM (User)\n\t++++++++++++++++++++++++++++++++++") 
    while True:
        select = input("\t1. Item Inventory Update\n\t2. Item Inventory Tracking\n\t3. Search distribution list\n\t4. Logout\n> ")
        try:
            #Check if user entered anythings other than number
            select = int(select)
            break
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
            return
        case _:
            print("Invalid selection! Please try again.")
            menu()     

def assign_supplier():
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

def config_save(fileName,mode,uid_list,username_list,password_list,type_list):
    with open(fileName,mode) as f:
        f.write(",".join(uid_list)+"\n")
        f.write(",".join(username_list)+"\n")
        f.write(",".join(password_list)+"\n")
        f.write(",".join(type_list)+"\n")

init_inv()