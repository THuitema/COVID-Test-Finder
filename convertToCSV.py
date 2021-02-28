import csv
with open('sloppyinfo.txt') as f:
    lines = f.readlines()

# getting rid of useless elements
lines = [x for x in lines if "More info" not in x]
lines = [x for x in lines if "Directions" not in x]
lines = [x for x in lines if "mi\n" not in x]
lines = [x for x in lines if x[:4] != 'Ste ']
lines = [x for x in lines if x[:5] != 'Ste. ']
lines = [x for x in lines if x[:5] != 'Suite']
lines = [x for x in lines if x[:4] != 'Unit']
lines = [x for x in lines if x != '\n']
lines = [x for x in lines if x != 'VA']
lines = [x for x in lines if x != '102\n']
lines = [x for x in lines if x[0] != '#']
lines = [x for x in lines if 'Email' not in x]
lines = [x for x in lines if '3rd Floor' not in x]





# related elements grouped together (name, address, zip, phone)
grouped = [lines[x:x+4] for x in range(0, len(lines),4)]
output_list = []
for group in grouped:
    # merging addres w/ city, state, zip code
    group[1:2] = [''.join(group[1:2])]

    # getting rid of 'Phone: ' in phone number category
    if len(group[3].split(' ')) > 1:
        group = [group[0].strip(), group[1].strip() + ' ' + group[2].strip(), group[3].strip().split(' ')[1]]
    else:
        group = [group[0].strip(), group[1].strip() + ' ' + group[2].strip(), group[3].strip()]
    output_list.append(group)

with open('locations2.csv', 'a') as f:
    wr = csv.writer(f, dialect='excel')
    # wr.writerow(grouped[0])
    for group in output_list:
        print(group)
        wr.writerow(group)


