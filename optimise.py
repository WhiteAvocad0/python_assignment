def test():
    username, password = input("Please enter login credential (Leave empty to quit login):\n\tUsername: "), input("\tPassword: ")
    
    with open("test.txt", "r") as f:
        lines = f.readlines()
    
    with open("test.txt", "w") as f:
        f.write(lines[0]+","+username+"\n"+lines[1]+"\n"+password)

test()

'''''
def register():
    uid_list = []
    username,passwd,usertype = input("\tPlease enter register credential\n\tUsername: "),input("\tPassword: "),input("\tAccount Type (admin/staff): ").lower()    
    with open("users.txt","r") as f:
        lines = f.readlines()
        user_name = lines[1].strip().split(",")
        uid_list.extend(lines[0].strip().split(","))
        #Check if username already exist
        if username in user_name:
            print("Username already exist!")
            register()
        #UID Generation
        for c in enumerate(uid_list,1):
            last_id = c
        #Append User Data
        uid_list.append(f"uid{last_id[0]+1}")
        #Write Data
        with open("users.txt","w") as f:
            f.wirtelines(lines[0]+ "," + f"uid{last_id}")
            f.wirtelines(lines[0]+ "," + username)
            f.wirtelines(lines[0]+ "," + passwd)
            f.wirtelines(lines[0]+ "," + usertype)
        print("> Registered")
        init_inv()
'''''
'''''
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
        uid_list.extend(lines[0].strip().split(","))
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
        init_inv()
'''''