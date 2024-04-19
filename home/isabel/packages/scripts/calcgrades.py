#!/usr/bin/env python3

grades = [6, 10, 9, 9, 6, 8, 10]
only_count = 8  # we only count the best 8 grades
max_mark = 10 # maximum mark for each grade
weight = 0.4 # weight of this section of the module as a decimal, e.g. 40% = 0.4

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
