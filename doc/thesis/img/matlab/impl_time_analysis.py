# -------------------------------------------------------------------------
# File        : impl_time_analysis.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Create a diagram to represent the implementation time.
# -------------------------------------------------------------------------

import matplotlib.pyplot as plt

plt.rcParams.update({
    "text.usetex": True,
    "font.family": "serif",
    "font.sans-serif": ["Helvetica"],
    "font.size": 16,
})

x = ['VHDL', 'HLS', 'Matlab']
energy = [18, 45000, 3100000]

x_pos = [i for i, _ in enumerate(x)]

fig = plt.figure()
fig.set_size_inches(6, 5)
ax = fig.add_subplot(1, 1, 1)

ax.set_yscale('log')

ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

plt.bar(x_pos, energy, width=0.5, edgecolor='black')
plt.xlabel("Implementation Variant")
#plt.ylabel("Samples per second")
plt.title("Processed Samples Per Second")

plt.xticks(x_pos, x)

# show and save
plt.tight_layout()
plt.savefig('impl_time_analysis.pdf')
plt.show()
