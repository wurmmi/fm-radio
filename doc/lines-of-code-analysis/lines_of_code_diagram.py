# -------------------------------------------------------------------------
# File        : lines_of_code_diagram.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Create a diagram to represent the lines of code.
# -------------------------------------------------------------------------

import matplotlib.pyplot as plt

# plt.rcParams.update({
#    "text.usetex": True,
#    "font.family": "sans-serif",
#    "font.sans-serif": ["Helvetica"]
# })
# for Palatino and other serif fonts use:
plt.rcParams.update({
    "text.usetex": True,
    "font.family": "serif",
    #    "font.serif": ["Palatino"],
    "font.sans-serif": ["Helvetica"]
})


# Make data: I have 3 groups and 7 subgroups
group_names = ['\\textbf{Matlab}', '\\textbf{VHDL}', '\\textbf{HLS}']
group_size = [2730,
              2743 + 208 + 708 + 107 + 27,
              430 + 489 + 224 + 129 + 182 + 119 + 85]
subgroup_names = ['', 'IP Design', 'Testbench', 'IP Design', 'Testbench']
subgroup_size = [2730, 2743 + 208, 708 + 107 + 27, 430 + 489, 224 + 129 + 182 + 119 + 85]
# subgroup_size = [2730,
#                 2743, 208,
#                 708, 107, 27,
#                 430, 489,
#                 224, 129, 182, 119, 85]

# Create colors
color_matlab, color_vhdl, color_hls = [plt.cm.Blues, plt.cm.Reds, plt.cm.Greens]

# First Ring (outside)
fig, ax = plt.subplots()
fig.set_size_inches(6, 4)
ax.axis('equal')
mypie, _ = ax.pie(group_size, radius=1.45,
                  labels=group_names,
                  labeldistance=0.75,
                  colors=[
                      color_matlab(0.6), color_vhdl(0.6), color_hls(0.6)])
plt.setp(mypie, width=0.6, edgecolor='white')

# Second Ring (Inside)
mypie2, _ = ax.pie(subgroup_size, radius=1.3 - 0.3,
                   labels=subgroup_names,
                   labeldistance=0.5,
                   colors=[
                       color_matlab(0.5),
                       color_vhdl(0.5), color_vhdl(0.4),
                       color_hls(0.5), color_hls(0.4)])
plt.setp(mypie2, width=0.6, edgecolor='white')
plt.margins(0, 0)

plt.legend()
subgroup_names_legs = ['Matlab',
                       'IP Design', 'Testbench',
                       'IP Design', 'Testbench']
handles, labels = ax.get_legend_handles_labels()

ax.legend(handles[len(group_names):], subgroup_names_legs, loc=(0.95, 0.4))
plt.suptitle('\\textbf{Lines Of Code}')
plt.tight_layout()

# show and save
plt.savefig('../thesis/img/matlab/lines_of_code_pie_chart_py.pdf')
plt.show()
