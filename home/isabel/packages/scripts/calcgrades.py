#!/usr/bin/env python3

def int_input(prompt):
  return int(input(prompt))

grades = list(map(int, input("Enter an all your grades separated by spaces ").split()))
only_count = int_input("Out of the grades you input, how many of the best do we wish to count? ")
max_mark = int_input("What is the maximum mark for each grade? ")
weight = int_input("weight of this section of the module as a decimal, e.g. 40% = 0.4")

# Sort the grades in descending order and select the top amount defined by only_count
sorted_grades = sorted(grades, reverse=True)[:only_count]

# Calculate the total marks obtained
total_marks = sum(sorted_grades)

# Calculate the maximum possible marks
max_possible_marks = max_mark * only_count

# Calculate the percentage achieved
percentage_achieved = (total_marks / max_possible_marks) * 100

# Calculate the weighted percentage achieved for this section
weighted_percentage_achieved = percentage_achieved * weight

print("Percentage achieved for this section: {:.2f}%".format(weighted_percentage_achieved))
