data_list = []
with open("ppe.txt","r") as f:
    lines = f.readlines()
    for line in lines:
        data = line.strip().split(",")
        print(data[0])