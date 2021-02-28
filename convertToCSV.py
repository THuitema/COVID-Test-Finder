with open('sloppyinfo.txt') as f:
    lines = f.readlines()

lines.remove('More info\n')
lines.remove('Directions\n')
print(lines)

# remove useless info like the Directions, More Info,
