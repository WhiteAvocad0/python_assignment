##optimise

ppepath = "Python Assignment/ppe.txt"
item_code = ["HC","FS","MS","GL","GW","SC"]
item_name = ["Face Shield","Gloves","Gown","Head Cover","Mask","Shoe Covers"]
hospital_list = ["H1","H2","H3","H4"]
def inv_update():
     menu_select = int(input("Please select an option:\n1. Increase\n2. Decrease"))           
     for c,ele in enumerate(item_code,1):
          print(c,ele)
     selected,change_quantity = int(input("Item code number> ")),int(input("Quantity to increase/decrease> "))

     with open(ppepath,"r") as f:
            lines = f.readlines()
            for number_line,line in enumerate(lines,1):
                data = line.strip().split("=")
                items,quantity = data[0].strip(),int(data[1].strip())
                if selected == number_line:
                        if menu_select == 1:
                              new_quantity = quantity + change_quantity
                        else:
                              new_quantity = quantity - change_quantity
                        lines[number_line - 1] = (f"{items} = {new_quantity}\n")
            with open(ppepath,"w") as f:
                f.writelines(lines)
                print(f"Inventory updated> {items} = {new_quantity}")


def register():
    username,passwd,usertype = input("\tPlease enter register credential\n\tUsername: "),input("\tPassword: "),input("\tAccount Type (admin/user): ").lower()    
    with open("Python Assignment/users.txt","r") as f:
        lines = f.readlines()

        ##USER DATA
        uid,userid,password,type = [],[],[],[]
        for line in lines:
             line = line.strip()
             if line.endswith(":"):
                  current_section = line[:-1]
             elif current_section:
                  if current_section == 'UID':
                       uid.append(line)
                  elif current_section == 'UserID':
                       userid.append(line)
                  elif current_section == 'Password':
                       password.append(line)
                  elif current_section == 'Type':
                       type.append(line)
        ##UID Generation
        if len(uid) > 0:
             uid_count = len(uid) + 1
        else:
             uid_count = 1
        uid.append(f"uid{uid_count}")

        ##Appen User Data
        userid.append(username)
        password.append(passwd)
        type.append(usertype)

        ##Write Data
        with open("Python Assignment/users.txt","w") as f:
             f.write("UID:\n")
             f.write(','.join(uid) + "\n")
             f.write("UserID:\n")
             f.write(",".join(userid) + "\n")
             f.write("Password:\n")
             f.write(",".join(password) + "\n")
             f.write("Type:\n")
             f.write(",".join(type)+ "\n")
        print("Registered")

##register()

def registercopy():
    username,passwd = input("\tPlease enter register credential\n\tUsername: "),input("\tPassword: ")   
    while True:
         usertype = input("\tAccount Type (admin/user): ").lower() 
         if usertype != "admin" or usertype != "user":
              print("Please enter only <admin> or <user> !")
              continue
    with open("Python Assignment/users.txt","r") as f:
        lines = f.readlines()

        ##USER DATA
        uid,userid,password,type = [],[],[],[]
        for line in lines:
             line = line.strip()
             if line.endswith(":"):
                  current_section = line[:-1]
             elif current_section:
                  if current_section == 'UID':
                       uid.append(line)
                  elif current_section == 'UserID':
                       userid.append(line)
                  elif current_section == 'Password':
                       password.append(line)
                  elif current_section == 'Type':
                       type.append(line)
        ##UID Generation
        uid_data = lines[1].strip().split("uid")
        uid_count = (len(uid_data))
        uid.append(f"uid{uid_count}")

        ##Appen User Data
        userid.append(username)
        password.append(passwd)
        type.append(usertype)

        ##Write Data
        with open("Python Assignment/users.txt","w") as f:
             f.write("UID:\n"+",".join(uid)+"\n")
             f.write("UserID:\n"+",".join(userid)+"\n")
             f.write("Password:\n"+",".join(password)+"\n")
             f.write("Type:\n"+",".join(type)+"\n")
        print("Registered")

##registercopy()
               
def login():
     with open("users.txt","r") as f:
          lines = f.readlines()
          usernames,password,type = 4,6,8
          ##List check
          user_name = lines[usernames-1].strip().split(",")
          user_password = lines[password-1].strip().split(",")
          user_type = lines[type-1].strip().split(",")
          ##Check if username match password
          while True:
               username,passwd = input("Please enter login credential:\n\tUsername: "), input("\tPasswordd: ")
               try:
                    if username in user_name and passwd == user_password[username.index(username)]:
                         check_type = (user_type[username.index(username)])
                         if check_type == "admin":
                              print("admin menu initiated")
                              break
                         else:
                              print("user menu initated")
                              break
               except username in user_name and passwd != user_password[username.index(username)]:
                    print("credential error") 
                    continue
##login()

def remove_user():
     ##Item line in .txt
     uid,username,password,type = 2,4,6,8
     with open("users.txt","r") as f:
          lines = f.readlines()
          ##List check
          uid_data = lines[uid-1].strip().split(",")
          username_data = lines[username-1].strip().split(",")
          password_data = lines[password-1].strip().split(",")
          type_data = lines[type-1].strip().split(",")
          ##Print username list
          for c,ele in enumerate(username_data,1):
               print(f"{c}.{ele}")
          selection = int(input("Select the user you want to remove> "))-1
          uid_data.remove(uid_data[selection])
          username_data.remove(username_data[selection])
          password_data.remove(password_data[selection])
          password_data.remove(type_data[selection])
          lines[username-1] = (",".join(username_data) + "\n")
          print(lines)
          with open("users.txt","w") as f:
               f.write("UID:\n"+",".join(uid_data)+"\n")
               f.write("UserID:\n"+",".join(username_data)+"\n")
               f.write("Password:\n"+",".join(password_data)+"\n")
               f.write("Type:\n"+",".join(type_data)+"\n")
               
##remove_user()


def remove_user2():
     ##Item line in .txt
     data = ["uid_data","username_data","password_data","type_data"]
     uid,username,password,type = 2,4,6,8
     with open("users.txt","r") as f:
          lines = f.readlines()
          ##List check
          uid_data = lines[uid-1].strip().split(",")
          username_data = lines[username-1].strip().split(",")
          password_data = lines[password-1].strip().split(",")
          type_data = lines[type-1].strip().split(",")
          ##Print username list
          for c,ele in enumerate(username_data,1):
               print(f"{c}.{ele}")
          selection = int(input("Select the user you want to remove> "))
          for i in data:
               i.pop(i.index(i[selection-1]))
               uid_data.pop(uid_data.index(uid_data[selection-1]))
               username_data.pop(username_data.index(username_data[selection-1]))
               password_data.pop(password_data.index(password_data[selection-1]))
               type_data.pop(type_data.index(type_data[selection-1]))
          with open("users.txt","w") as f:
               f.write("UID:\n"+",".join(uid_data)+"\n")
               f.write("UserID:\n"+",".join(username_data)+"\n")
               f.write("Password:\n"+",".join(password_data)+"\n")
               f.write("Type:\n"+",".join(type_data)+"\n")
##remove_user2()

##Update inventory
def inv_update():
    select_data = ["Receive","Distribute"]
    menu_select = int(input("Please select an option:\n1. Received\n2. Distributed\n> "))
    for c,ele in enumerate(item_name,1):
        print(f"{c}.{ele}")
    selected,change_quantity = int(input("Please enter item code number> ")),int(input("Quantity to change> "))
    for c,ele in enumerate(hospital_list,1):
        print(f"{c}.{ele}")
    current_time = datetime.datetime.now()
    with open(ppepath,"r") as f:
        lines = f.readlines()
    with open("transactions.txt","r") as f:
        trans_line = f.readlines()
        trans_data = []
        for line in trans_line:
             data = line.strip()
             trans_data.append(data)
        for number_line,line in enumerate(lines,1):
            data = line.strip().split("=")
            items,quantity = data[0].strip(),int(data[1].strip())
            if selected == number_line:
                if menu_select == 1:
                        new_quantity = quantity + change_quantity
                else:
                        new_quantity = quantity - change_quantity
                lines[number_line - 1] = (f"{items} = {new_quantity}\n")
                match menu_select:
                    case "1":
                        from_supplier = int(input("Received from supplier> "))
                        trans_line = (f"{select_data[selected-1]} {change_quantity} {item_name[item.index(items)]} {hospital_list[to_hospital]} {current_time}\n")
                    case "2":
                        to_hospital = int(input("Distribute to hospital> ")) 
                        trans_line = (f"{select_data[selected-1]} {change_quantity} {item_name[item.index(items)]} {hospital_list[to_hospital]} {current_time}\n") 
                trans_data.append(trans_line)
        with open(ppepath,"w") as f:
            f.writelines(lines)
            print(f"Inventory updated> {items} ({item_name[selected]}) = {new_quantity} Boxes")
        with open("transactions.txt","w") as f:
            f.writelines("\n".join(trans_data))
            
##inv_update()
