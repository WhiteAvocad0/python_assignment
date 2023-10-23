def test():
    supplier_name = readfiles("suppliers.txt")
    print(supplier_name[1])



def readfiles(file):
    data_list = []
    with open(file,"r") as f:
        lines = f.readlines()
        for line in lines:
            data_list.append(line.strip().split(","))
    return data_list

test()