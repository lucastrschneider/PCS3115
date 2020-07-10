################################################################################
# @file turbo_tb.py
# @brief Generate test cases for turbo controller
# @author Lucas Schneider (lucastrschneider@usp.br)
# @date 2020-07-10
################################################################################

import random

TEST_PER_SENSIB = 100  
WORDS_PER_TEST = 32  # Should not be changed

def print_data(sensib, dataInput, dataOutput):
    print (f"{sensib:004b}")

    out_input = ""
    for i in range (0, WORDS_PER_TEST):
        out_input += f"{dataInput[i]:008b}" + " "
    print(out_input)
    
    out_output = ""
    for i in range (0, WORDS_PER_TEST):
        out_output += f"{dataOutput[i]:008b}" + " "
    print(out_output)

def remap(old_value:float, old_min:float, old_max:float, new_min:float, new_max:float) -> float:
    new_value = (old_value - old_min) * (new_max - new_min)
    new_value /= (old_max - old_min)
    new_value += (new_min)
    return new_value

for i in range(0,4):
    sensib = int(pow(2,i))
    
    for test_number in range (0, TEST_PER_SENSIB):
        changing_rate = int(remap(test_number, 0, TEST_PER_SENSIB - 1, 1, sensib + 2))
        dataInput = []
        dataOutput = []
        value = random.randint(0, 255)
        dataInput.append(value)
        dataOutput.append(value)
        counter = 0

        for j in range (1, WORDS_PER_TEST):
            keep = random.randint(0,changing_rate)

            if (keep == 0):
                value_aux = random.randint(0, 254)
                if (value_aux >= value):
                    value = value_aux + 1
                else:
                    value = value_aux
                    
                dataOutput.append(value)
                counter = 0
                
            else:
                if (counter < sensib):
                    dataOutput.append(0)
                    counter += 1
                else:
                    dataOutput.append(value)

            dataInput.append(value)
        
        print_data(sensib, dataInput, dataOutput)