def update_supplier():
    data_list = readfiles("suppliers.txt")
    while True:
        selection = input("\tPlease select an option (Leave empty to quit):\n\t1. Add Supplier\n\t2. Change Supplier name\n\t3. Delete Supplier")
        if not selection:
            return
        try:
            selection.isdigit()
        except ValueError:
            print("Please enter only number!")
            continue
        match selection:
            case 1:
                for data in data_list:
                    print(data)


def readfiles(file):
    data_list = []
    with open(file,"r") as f:
        lines = f.readlines()
        for line in lines:
            data_list.append(line.strip().split(","))
    return data_list

update_supplier()