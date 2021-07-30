# -------------------------------------------------------------------------
# File        : lines_of_code_diagram.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Create a diagram to represent the lines of code.
# -------------------------------------------------------------------------

import matplotlib.pyplot as plt

plt.rcParams.update({
    "text.usetex": True,
    "font.family": "serif",
    "font.sans-serif": ["Helvetica"],
    "font.size": 20,
    #    "legend.fontsize": 10,
    #    "axes.labelsize": 10,
})


# Create data
group_names = [
    '\\textbf{Matlab}',
    '\\textbf{HLS}',
    '\\textbf{VHDL}',
]
group_size = [
    2730,
    430 + 489 + 224 + 129 + 182 + 119 + 85,
    2743 + 208 + 708 + 107 + 27,
]
#subgroup_names = [' ', ' ', ' ', ' ', ' ']
subgroup_names = [
    'Matlab',
    'IP Design', 'Testbench',
    'IP Design', 'Testbench',
]
subgroup_names_legs = [
    'Matlab',
    'IP Design', 'Testbench',
    'IP Design', 'Testbench',
]

subgroup_size = [
    2730,
    430 + 489, 224 + 129 + 182 + 119 + 85,
    2743 + 208, 708 + 107 + 27,
]
# subgroup_size = [2730,
#                 2743, 208,
#                 708, 107, 27,
#                 430, 489,
#                 224, 129, 182, 119, 85]

# Create colors
color_blue, color_red, color_green = [plt.cm.Blues, plt.cm.Reds, plt.cm.Greens]

# First Ring (outside)
fig, ax = plt.subplots()
fig.set_size_inches(6, 4)
ax.axis('equal')
mypie, _ = ax.pie(group_size, radius=1.45,
                  labels=group_names,
                  labeldistance=0.78,
                  colors=[
                      color_blue(0.6),
                      color_green(0.6),
                      color_red(0.6),
                  ])
plt.setp(mypie, width=0.6, edgecolor='white')

# Second Ring (Inside)
mypie2, _ = ax.pie(subgroup_size, radius=1.3 - 0.3,
                   labels=subgroup_names,
                   labeldistance=0.45,
                   colors=[
                       color_blue(0.5),
                       color_green(0.5), color_green(0.4),
                       color_red(0.5), color_red(0.4),
                   ])
plt.setp(mypie2, width=0.6, edgecolor='white')
plt.margins(0, 0)

plt.legend()
handles, labels = ax.get_legend_handles_labels()

ax.legend(handles[len(group_names):], subgroup_names_legs, loc=(0.9, 0.35))
#plt.suptitle('\\textbf{Lines Of Code}', fontsize=14)
plt.tight_layout()

# show and save
plt.savefig('../thesis/img/matlab/lines_of_code_pie_chart_py.pdf')
plt.show()
