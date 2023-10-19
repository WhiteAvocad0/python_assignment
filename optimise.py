def update_hospital():
    data_list = []
    with open("hospitals.txt","r") as f:
        lines = f.readlines()
        for line in lines:
            data_list.append(line.strip().split(","))
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
                    data_list[0].append(f"S{len(data_list[0])+1}")
                case 2:
                    for c,ele in enumerate(data_list[0],1):
                        print(f"{c}. {ele}")
                    select = int(input("Please select a hospital to update name > "))
                    data_list[1][select-1] = input("Please enter new name: ")

                case 3:
                    if len(data_list[0]) == 3:
                        print("There must be minimum 3 hospital in system, unable to delete.")
                    for c,ele in enumerate(data_list[0],1):
                        print(f"{c}. {ele}")
                    delete = int(input("Please select a hospital to delete > "))
                    (data_list[1]).pop(delete-1)
                    (data_list[0]).pop()
                
                case _:
                    print("Please select a valid option")

            with open("hospitals.txt","w") as f:
                        for data in data_list:
                            f.write(",".join(data) + "\n")
update_hospital()