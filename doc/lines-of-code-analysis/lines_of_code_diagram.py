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
    "font.size": 16,
    #    "legend.fontsize": 10,
    #    "axes.labelsize": 10,
})


# ------------------------- ALL -----------------------------------------------
# Create data
group_names = [
    '33\%',
    '20\%',
    '47\%',
]
group_size = [
    2730,
    430 + 489 + 224 + 129 + 182 + 119 + 85,
    2743 + 208 + 708 + 107 + 27,
]
group_names_legs = [
    'Matlab',
    'HLS',
    'VHDL',
]

# Create colors
color_blue, color_red, color_green = [plt.cm.Blues, plt.cm.Reds, plt.cm.Greens]

# First Ring (outside)
fig, ax = plt.subplots()
fig.set_size_inches(6, 4)
ax.axis('equal')
mypie, _ = ax.pie(group_size, radius=1.45,
                  labels=group_names,
                  labeldistance=0.6,
                  colors=[
                      color_blue(0.6),
                      color_green(0.6),
                      color_red(0.6),
                  ])
plt.setp(mypie, width=0.9, edgecolor='white')

plt.margins(0, 0)
plt.legend()
handles, labels = ax.get_legend_handles_labels()

ax.legend(handles[:], group_names_legs, loc=(0.95, 0.3))
#plt.suptitle('\\textbf{Lines Of Code}', fontsize=14)
plt.tight_layout()

# show and save
plt.savefig('../thesis/img/matlab/lines_of_code_pie_chart_py_all.pdf')
plt.show()

# ---------------------- HLS --------------------------------------------------
# Create data
group_names = [
    'IP Design',
    'Testbench',
]
group_names_legs = [
    'IP Design',
    'Testbench',
]
group_size = [
    430 + 489,
    224 + 129 + 182 + 119 + 85,
]

subgroup_names = [
    '100\%',
    '48\%',
    '25\%',
    '16\%',
    '12\%',
]
subgroup_names_legs = [
    'C\\texttt{++}',
    'C\\texttt{++}',
    'Tcl',
    'make',
    'Python',
]
subgroup_size = [
    430 + 489,  # C++ IP
    224 + 129,  # C++ Tb
    182,        # Tcl Tb
    119,        # make Tb
    85,         # python Tb
]

# Create colors
color_blue, color_red, color_green = [plt.cm.Blues, plt.cm.Reds, plt.cm.Greens]

# First Ring (outside)
fig, ax = plt.subplots()
fig.set_size_inches(6, 4)
ax.axis('equal')
mypie, _ = ax.pie(group_size, radius=1.45,
                  labels=group_names,
                  labeldistance=0.82,
                  colors=[
                      color_blue(0.6),
                      color_red(0.6),
                  ],
                  rotatelabels=False,
                  textprops=dict(rotation_mode='anchor', va='center', ha='center')
                  )
plt.setp(mypie, width=0.6, edgecolor='white')

# Second Ring (Inside)
mypie2, _ = ax.pie(subgroup_size, radius=1.3 - 0.3,
                   labels=subgroup_names,
                   labeldistance=0.7,
                   colors=[
                       color_blue(0.5),
                       color_red(0.5), color_red(0.4), color_red(0.3), color_red(0.2),
                   ],
                   rotatelabels=True,
                   textprops=dict(rotation_mode='anchor', va='center', ha='center')
                   )
plt.setp(mypie2, width=0.6, edgecolor='white')
plt.margins(0, 0)

plt.legend()
handles, labels = ax.get_legend_handles_labels()

ax.legend(handles[len(group_names):], subgroup_names_legs, loc=(0.95, 0.2))
#plt.suptitle('\\textbf{Lines Of Code}', fontsize=14)
plt.tight_layout()

# show and save
plt.savefig('../thesis/img/matlab/lines_of_code_pie_chart_py_hls.pdf')
plt.show()


# ---------------------- VHDL --------------------------------------------------
# Create data
group_names = [
    'IP Design',
    'Testbench',
]
group_names_legs = [
    'IP Design',
    'Testbench',
]
group_size = [
    # TODO HERE
    430 + 489,
    224 + 129 + 182 + 119 + 85,
]

subgroup_names = [
    '33\%',
    '33\%',
    '25\%',
    'xx\%',
    'xx\%',
]
subgroup_names_legs = [
    'C\\texttt{++}',
    'C\\texttt{++}',
    'Tcl',
    'make',
    'Python',
]
subgroup_size = [
    430 + 489,  # C++ IP
    224 + 129,  # C++ Tb
    182,        # Tcl Tb
    119,        # make Tb
    85,         # python Tb
]

# Create colors
color_blue, color_red, color_green = [plt.cm.Blues, plt.cm.Reds, plt.cm.Greens]

# First Ring (outside)
fig, ax = plt.subplots()
fig.set_size_inches(6, 4)
ax.axis('equal')
mypie, _ = ax.pie(group_size, radius=1.45,
                  labels=group_names,
                  labeldistance=0.75,
                  colors=[
                      color_blue(0.6),
                      color_red(0.6),
                  ])
plt.setp(mypie, width=0.6, edgecolor='white')

# Second Ring (Inside)
mypie2, _ = ax.pie(subgroup_size, radius=1.3 - 0.3,
                   labels=subgroup_names,
                   labeldistance=0.5,
                   colors=[
                       color_blue(0.5),
                       color_red(0.5), color_red(0.4), color_red(0.3), color_red(0.2),
                   ])
plt.setp(mypie2, width=0.6, edgecolor='white')
plt.margins(0, 0)

plt.legend()
handles, labels = ax.get_legend_handles_labels()

ax.legend(handles[len(group_names):], subgroup_names_legs, loc=(0.95, 0.2))
#plt.suptitle('\\textbf{Lines Of Code}', fontsize=14)
plt.tight_layout()

# show and save
plt.savefig('../thesis/img/matlab/lines_of_code_pie_chart_py_hls.pdf')
plt.show()

# -------------------------------------------------------------------------
