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
labels = ['VHDL', 'HLS']
hw_util_lut = [1203, 650]
hw_util_ff = [1361, 494]
hw_util_lutram = [176, 0]
hw_util_srl = [0, 56]
hw_util_ramb18 = [0, 7]
hw_util_dsp48 = [8, 6]

barwidth = 0.15

# the label locations
x1 = np.arange(len(labels))
x2 = [x + barwidth for x in x1]
x3 = [x + barwidth for x in x2]
x4 = [x + barwidth for x in x3]
x5 = [x + barwidth for x in x4]

# Plot
fig, ax = plt.subplots()
fig.set_size_inches(8, 5)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

rects1 = ax.bar(x2, hw_util_lut, barwidth, label='LUT', edgecolor='black')
rects2 = ax.bar(x1, hw_util_ff, barwidth, label='FF', edgecolor='black')
rects3 = ax.bar(x3, hw_util_lutram, barwidth, label='LUTRAM', edgecolor='black')
rects4 = ax.bar(x3, hw_util_srl, barwidth, label='SRL', edgecolor='black')
rects5 = ax.bar(x4, hw_util_ramb18, barwidth, label='RAMB18', edgecolor='black')
rects6 = ax.bar(x5, hw_util_dsp48, barwidth, label='DSP48', edgecolor='black')

# Add some text for labels, title and custom x-axis tick labels, etc.
# ax.set_ylabel('Scores')
ax.set_title('Hardware Utilization')
#ax.set_xticks([r + barwidth for r in range(len(labels))], labels)
plt.xticks([r + 2 * barwidth for r in range(len(labels))], labels)
ax.set_xticklabels(labels)
ax.legend(loc='center left', bbox_to_anchor=(1.0, 0.5))
#ax.legend(loc=(1.0, 0.2))

ax.bar_label(rects1, padding=3)
ax.bar_label(rects2, padding=3)
ax.bar_label(rects3, padding=3)
ax.bar_label(rects4, padding=3)
ax.bar_label(rects5, padding=3)
ax.bar_label(rects6, padding=3)

# show and save
plt.tight_layout()
plt.savefig('../../thesis/img/matlab/hardware_utilization.pdf')
plt.show()
