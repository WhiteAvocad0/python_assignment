def update_supplier():
    data_list = readfiles("suppliers.txt")
    while True:
        selection = input("\tPlease select an option (Leave empty to quit):\n\t1. Add Supplier\n\t2. Change Supplier name\n\t3. Delete Supplier\n\t> ")
        if not selection:
            return
        try:
            selection = int(selection)
        except ValueError:
            print("Please enter only number!")
            continue
        match selection:
            case 1:
                if len(data_list[0]) == 4:
                    print("Maximum suppliers is 4.")
                else:
                    data_list[1].append(input("Please enter supllier name: "))
                    data_list[0].append(f"S{len(data_list[1]) + 1}")
            case 2:
                for c,ele in enumerate(data_list[1],1):
                    print(f"{c}. {ele}")
                while True:
                    selection = input("Please select a supplier: ")
                    if not selection:
                        return
                    try:
                        selection = int(selection)
                        break
                    except ValueError:
                        print("Please enter only number!")
                        continue
                new_name = input("Please enter (Leave empty to quit)")
                if not new_name:
                    return
                else:
                    data_list[1][selection-1] = new_name
            case 3:
                if len(data_list[0]) == 3:
                    print("Minimum suppliers is 3")
                else:
                    for c,ele in enumerate(data_list[1],1):
                        print(f"{c}. {ele}")
                    while True:
                        delete = input("Please select a supplier to delete: ")
                        if not delete:
                            return
                        try:
                            delete = int(delete)
                            break
                        except ValueError:
                            print("Please enter only number!")
                            continue
                    data_list[1].pop(selection-1)
                    data_list[0].pop()
            case _:
                print("Please select a valid option")


def readfiles(file):
    data_list = []
    with open(file,"r") as f:
        lines = f.readlines()
        for line in lines:
            data_list.append(line.strip().split(","))
    return data_list

update_supplier()