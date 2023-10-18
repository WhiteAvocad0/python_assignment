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

backup()