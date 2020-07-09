TEST_PER_SENSIB = 10
WORDS_PER_TEST = 32

def print_data(sensib, dataInput, dataOutput):
    out = "{0:004b}".format(sensib)

    for i in range (0, WORDS_PER_TEST):
        out += " " + "{0:008b}".format(dataInput[i])
        out += " " + "{0:008b}".format(dataOutput[i])
    
    print out

import random

for i in range(0,4):
    sensib = int(pow(2,i))
    
    for test_numbers in range (0, TEST_PER_SENSIB):
        dataInput = []
        dataOutput = []
        value = random.randint(0, 255)
        dataInput.append(value)
        dataOutput.append(value)
        counter = 0

        for j in range (1, WORDS_PER_TEST):
            keep = random.randint(0,sensib+2)

            if (keep == 0):
                value = random.randint(0, 255)
                dataOutput.append(value)
                counter = 0
            else:
                if (counter < sensib):
                    dataOutput.append(0)
                    counter += 1
                else:
                    dataOutput.append(value)

            dataInput.append(value)
        
        print_data(sensib, dataInput, dataOutput);