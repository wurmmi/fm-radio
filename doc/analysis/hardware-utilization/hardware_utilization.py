# -------------------------------------------------------------------------
# File        : hardware_utilization.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Create a diagram to represent the hardware utilization.
# -------------------------------------------------------------------------

import matplotlib.pyplot as plt
import numpy as np

plt.rcParams.update({
    "text.usetex": True,
    "font.family": "serif",
    "font.sans-serif": ["Helvetica"],
    "font.size": 16,
})

# Data
labels = ['LUT', 'FF', 'LUTRAM', 'SRL', 'RAMB18', 'DSP48']
values_vhdl = [1203, 1361, 176, 0, 0, 8]
values_hls = [650, 494, 0, 56, 7, 6]

barwidth = 0.4

# the label locations
x1 = np.arange(len(labels)) * 1.5
x2 = [x + barwidth for x in x1]

# Plot
fig, ax = plt.subplots()
fig.set_size_inches(8, 5)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

rects1 = ax.bar(x1, values_vhdl, barwidth, label='VHDL', color=plt.cm.Greens(0.6), edgecolor='black')
rects2 = ax.bar(x2, values_hls, barwidth, label='HLS', color=plt.cm.Blues(0.6), edgecolor='black')

# Add some text for labels, title and custom x-axis tick labels, etc.
# ax.set_ylabel('Scores')
ax.set_title('Hardware Utilization')
plt.xticks([r + barwidth / 2 for r in x1], labels)
ax.set_xticklabels(labels)
ax.legend(loc='best')
#ax.legend(loc=(1.0, 0.2))
#ax.legend(loc='center left', bbox_to_anchor=(1.0, 0.5))

ax.bar_label(rects1, padding=3)
ax.bar_label(rects2, padding=3)

# show and save
plt.tight_layout()
plt.savefig('../../thesis/img/matlab/hardware_utilization.pdf')
plt.show()
