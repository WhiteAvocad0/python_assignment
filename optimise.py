data_list = []
with open("hospitals.txt","r") as f:
    lines = f.readlines()
    for line in lines:
        data_list.append(line.strip().split(",")) 
    print(data_list[0])
