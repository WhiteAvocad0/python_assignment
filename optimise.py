
def test1():
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

test1()
