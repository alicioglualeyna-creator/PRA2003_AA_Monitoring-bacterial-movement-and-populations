#### asymmetry and dN/dP as a function of momentum for one WT/mutant pair ###

# the packages needed to run this code!
import numpy as np # handles fast maths
import pandas as pd # reads CSVs
import matplotlib.pyplot as plt # draws grpahs
from matplotlib.ticker import LogLocator, FuncFormatter, NullFormatter # control y-axis tick marks

# settings
# the first bin starts at 0, so no bacteria are left out
bins = np.array([0, 1, 2, 3, 4.5, 7, 10, 15, 21])
# version that starts at 1 (bacteria with P < 1 are not used):
# bins = np.array([1, 1.5, 2, 2.5, 3, 4, 6, 8, 12, 16])
unit = "10^-20 kg m/s" # the actual unit of momentum
unit_plot = r"$10^{-20}$ kg m/s" # the same unit for the graphs
n_sets = 10 # number of subsample files
events_per_set = 500_000 # events in one subsample (dN/dP is given per event)
use_sem = False # True = SEM as error bar / False = plain std

# input() waits until you type something in the terminal and press enter
pid1 = 3334 # wild type: Salmonella enterica
pid2 = -pid1 # mutant

# read the momenta of this pair from every subsample
momenta_by_file = []
for i in range(1, n_sets + 1): # starts an empty list and loops i = 1 - 10
    data = pd.read_csv(f"momenta-Set{i}.csv", usecols=["ID", "p"]) # reads one CSV
    momenta_by_file.append({pid: data.loc[data["ID"] == pid, "p"].to_numpy()
                            for pid in (pid1, pid2)})

all_p = np.concatenate([mom[pid] for mom in momenta_by_file for pid in (pid1, pid2)]) # for every file & both IDs, momenta get glued together into an array
if len(all_p) == 0:
    raise SystemExit(f"No bacteria with ID {pid1} or {pid2} in the files.") # stop here
print(np.percentile(all_p, [1, 5, 10, 25, 50, 75, 90, 95, 99, 99.9])) # prints momentum at these percentiles
print(all_p.max())

error_div = np.sqrt(n_sets) if use_sem else 1 # what the std is divided by
error_name = "SEM" if use_sem else "std"

# checking subsamples
n1 = np.array([len(mom[pid1]) for mom in momenta_by_file]) # WT count per subsample
n2 = np.array([len(mom[pid2]) for mom in momenta_by_file]) # mutant count per subsample
medians = np.array([np.median(np.concatenate([mom[pid1], mom[pid2]])) for mom in momenta_by_file]) # median momentum of each subsample
typical = np.median(medians) # ^^ typical value is the median of those 10 medians
spread = 1.4826 * np.median(np.abs(medians - typical)) # robust "standard deviation"
print(f"\n{'Set':>4} {'N WT':>9} {'N mutant':>9} {'median p':>9}") # prints table header
odd_sets = []
for i in range(n_sets):
    off = abs(medians[i] - typical)
    odd = off > 5 * spread and off > 0.05 * typical # how far its median is from the typical one
    if odd:
        odd_sets.append(i + 1)
    print(f"{i + 1:>4} {n1[i]:>9} {n2[i]:>9} {medians[i]:>9.3f}" + ("   <-- different" if odd else ""))
if odd_sets: # prints only if some set was flagged
    print(f"WARNING: Set {odd_sets} has a different momentum distribution from the other subsamples.\n"
          "         It is still included, but it makes the uncertainties larger.")

def weighted_mean_std(values, weights):
    """Weighted mean and weighted standard deviation over the subsamples (rows)."""
    total = np.maximum(weights.sum(axis=0), 1) # prevents division by zero in empty bins
    n_used = np.maximum(np.sum(weights > 0, axis=0), 2) # subsamples that contributed
    mean = np.sum(weights * values, axis=0) / total # weighted mean
    var = np.sum(weights * (values - mean) ** 2, axis=0) / total * n_used / (n_used - 1) # weighted variance
    return mean, np.sqrt(var) # returns mean + std per bin

# counts per bin: one row per subsample, one column per bin
# the extra last bin collects everything above the last edge!
edges = np.append(bins, max(all_p.max(), bins[-1]) + 1) # adds one extra edge beyond the largest momentum
# 10 x 11 array, with 10 subsamples as rows and 11 bins as columns
counts1 = np.array([np.histogram(mom[pid1], bins=edges)[0] for mom in momenta_by_file])
counts2 = np.array([np.histogram(mom[pid2], bins=edges)[0] for mom in momenta_by_file])
n_bins = len(edges) - 1
# percentage of bacteria below the first edge
below = 100 * np.sum(all_p < bins[0]) / len(all_p)
if bins[0] > 0:
    print(f"\nPair {pid1} / {pid2}: {len(all_p)} bacteria, {below:.1f}% have P < {bins[0]:g} {unit} and are not used")
else:
    print(f"\nPair {pid1} / {pid2}: {len(all_p)} bacteria, all of them are used")

# asymmetry per bin per subsample, then weighted mean and std
# a subsample with few bacteria in a bin gives a very noisy A, so it gets a small weight
N = counts1 + counts2 # bacteria per subsample per bin
asymmetries = (counts1 - counts2) / np.maximum(N, 1) # A per subsample (0 where the bin is empty)
mean_A, std_A = weighted_mean_std(asymmetries, N)
err_A = std_A / error_div

# overall asymmetry (all bacteria of the pair), one value per subsample
A_tot = ((n1 - n2) / (n1 + n2)).reshape(-1, 1) # .reshape(-1, 1) turns 10 values into a 10 x 1 column
mean_tot, std_tot = weighted_mean_std(A_tot, (n1 + n2).reshape(-1, 1))
mean_tot, err_tot = mean_tot[0], std_tot[0] / error_div

# dN/dP = (number in bin) / (bin width), per event (the open last bin has no width so it's left out)
bin_width = np.diff(bins) # np.diff gives the width of each bin
bin_centers = 0.5 * (bins[:-1] + bins[1:]) # bins[:-1] is all left edges and bins[1:] all right edges
dNdP1_all = counts1[:, :-1] / bin_width / events_per_set # [:, :-1] means all rows and all columns except the last
dNdP2_all = counts2[:, :-1] / bin_width / events_per_set
mean1, err1 = dNdP1_all.mean(axis=0), dNdP1_all.std(axis=0, ddof=1) / error_div # mean over subsamples per bin
mean2, err2 = dNdP2_all.mean(axis=0), dNdP2_all.std(axis=0, ddof=1) / error_div

# numbers
labels = [f"{bins[b]:g} - {bins[b + 1]:g}" for b in range(n_bins - 1)] + [f"> {bins[-1]:g}"]
table = pd.DataFrame({ # builds the actual table
    "P_range": labels,
    # np.append / np.nan adds a blank for the last bin because dN/dP arrays have one fewer entry than there even are bins
    "dNdP_WT": np.append(mean1, np.nan), "dNdP_WT_err": np.append(err1, np.nan),
    "dNdP_mutant": np.append(mean2, np.nan), "dNdP_mutant_err": np.append(err2, np.nan),
    "A": mean_A, "A_err": err_A, "A_over_err": mean_A / err_A,
})
print(f"\n{'P range':>10} {'dN/dP WT':>10} {error_name:>9} {'dN/dP mut':>10} {error_name:>9} " # prints the table
      f"{'A':>9} {error_name:>8} {'A/' + error_name:>6}")
for r in table.itertuples(): # itertuples() loops over rows with columns
    print(f"{r.P_range:>10} {r.dNdP_WT:>10.4g} {r.dNdP_WT_err:>9.3g} {r.dNdP_mutant:>10.4g} "
          f"{r.dNdP_mutant_err:>9.3g} {r.A:>9.4f} {r.A_err:>8.4f} {r.A_over_err:>6.1f}")
table.to_csv(f"asymmetry-{pid1}.csv", index=False) # saves the table to a CSV and then prints the average counts + overall symmetry
print(f"\nAverage count per subsample: WT {n1.mean():.1f} +- {n1.std(ddof=1) / error_div:.1f}, "
      f"mutant {n2.mean():.1f} +- {n2.std(ddof=1) / error_div:.1f}  ({error_name})")
print(f"Overall asymmetry (all bacteria of the pair): {mean_tot:.5f} +- {err_tot:.5f}  ({error_name})")

# colors!
c_points = "tab:green" # asymmetry points
c_band = "orchid" # band of the overall asymmetry
c_zero = "red" # line at zero
c_wt, c_mut = "orchid", "tab:green" # WT and mutant in the dN/dP graph

# name of the strain for the titles
names = {211: "E. coli", 321: "B. subtilis", 2212: "P. aeruginosa",
         3122: "S. pneumoniae", 3312: "M. tuberculosis", 3334: "Salmonella"}
strain = names.get(pid1, f"ID {pid1}")

# graph 1: asymmetry
t_title = f"{strain}: WT ({pid1}) vs mutant ({pid2})"
t_xlabel = f"Momentum (P) ({unit_plot})"
t_ylabel = "Asymmetry  (N$_{WT}$ − N$_{mut}$) / (N$_{WT}$ + N$_{mut}$)"
t_band = f"Asymmetry of all bacteria, all momenta combined = {mean_tot:.4f} ± {err_tot:.4f} ({error_name})"
t_zero = "No asymmetry: Equal numbers of WT and mutant"
t_points = (f"Average asymmetry of the 10 sub-samples in each momentum bin\n"
            f"vertical bar = uncertainty of the average ({error_name})\n"
            "horizontal bar = momentum range of the bin")
t_last = f"all P > {bins[-1]:g}"

# graph 2: dN/dP
t2_title = (f"{strain}: how many bacteria there are at each momentum\n"
            f"WT ({pid1}) and mutant ({pid2}), average of 10 sub-samples ± {error_name}")
t2_xlabel = f"Momentum (P) ({unit_plot})"
t2_ylabel = f"dN/dP (bacteria per event per {unit_plot})"
t2_wt = f"WT ({pid1})"
t2_mut = f"mutant ({pid2})"

# style of the graphs
plt.rcParams.update({ # global style settings (bigger fonts/smaller legend text/etc)
    "font.size": 12, # bigger text!
    "axes.spines.top": False, "axes.spines.right": False, # no box around the graph, just the two axes
    "axes.titlesize": 13, "axes.titleweight": "bold", "axes.titlelocation": "left",
    "legend.fontsize": 10.5,
})

# the legend shows only the first line of t_points (its other lines go in a small note under the graph)
points_label = t_points.split("\n")[0]
points_note = "  |  ".join(t_points.split("\n")[1:])

# graph 1: asymmetry against momentum
last_width = bins[-1] - bins[-2] # the last bin is drawn as wide as the one before
x = np.append(bin_centers, bins[-1] + last_width / 2)
half = np.append(bin_width, last_width) / 2

# constrained_layout: the graph re-arranges itself when the window is resized or maximised
fig1, ax = plt.subplots(figsize=(9.5, 6), constrained_layout=True) # auto-adjusts spacing so labels don't overlap!
ax.axvspan(bins[-1], bins[-1] + last_width, color="0.94", zorder=0) # grey area = the open last bin
ax.axhspan(mean_tot - err_tot, mean_tot + err_tot, color=c_band, alpha=0.25, lw=0, label=t_band)
ax.axhline(mean_tot, color=c_band, lw=1) # thin line in the middle of the band
ax.axhline(0, color=c_zero, ls="--", lw=1.2, label=t_zero)
ax.errorbar(x, mean_A, yerr=err_A, xerr=half, fmt="o", ms=8, mec="white", mew=0.8, capsize=4, elinewidth=1.6, color=c_points, label=points_label) # the main data
ax.set_xticks(bins) # puts tickets at every bin edge
# on a long axis, only the whole-number edges get a label, otherwise the labels overlap
ax.set_xticklabels([f"{e:g}" if (bins[-1] <= 8 or e == int(e)) else "" for e in bins])
# finds the lowest & highest things to show (always including 0)
low = min(0, np.nanmin(mean_A - err_A), mean_tot - err_tot)
high = max(0, np.nanmax(mean_A + err_A), mean_tot + err_tot)
ax.set_ylim(low - 0.15 * (high - low), high + 0.50 * (high - low))
ax.set_xlim(bins[0] - 0.5, bins[-1] + last_width)
# label inside the grey area: x in momentum units, y as a fraction of the axis height
# sits at the very bottom, in the empty strip below the lowest error bar, away from the legend
ax.text(bins[-1] + last_width / 2, 0.02, t_last, transform=ax.get_xaxis_transform(), ha="center", va="bottom", color="0.35", fontsize=10.5)
ax.set_xlabel(t_xlabel)
ax.set_ylabel(t_ylabel)
ax.set_title(t_title, pad=12)
ax.grid(axis="y", color="0.9", lw=0.8)
ax.set_axisbelow(True) # grid lines behind the points
ax.legend(loc="upper left", frameon=False) # inside the graph, in the empty space on top
# places the small note under the graph
ax.annotate(points_note, xy=(1, 0), xycoords="axes fraction", xytext=(0, -48), textcoords="offset points", ha="right", va="top", fontsize=9.5, color="0.35")
fig1.savefig(f"asymmetry-{pid1}.png", dpi=200) # saves figure as a PNG @ 200 dots per inch

# graph 2: dN/dP against momentum
fig2, bx = plt.subplots(figsize=(9.5, 6), constrained_layout=True)
bx.errorbar(bin_centers, mean1, yerr=err1, xerr=bin_width / 2, fmt="o", ms=8, capsize=4, elinewidth=1.6, color=c_wt, label=t2_wt)
bx.errorbar(bin_centers, mean2, yerr=err2, xerr=bin_width / 2, fmt="o", ms=11, capsize=6, elinewidth=1.2, color=c_mut, mfc="none", mew=1.8, label=t2_mut) # mfc="none" lets you see both despite overlap
bx.set_yscale("log")
# readable y-axis: tick marks at 1, 2 and 5 times each power of ten, written as plain numbers
bx.yaxis.set_major_locator(LogLocator(base=10, subs=(1, 2, 5)))
bx.yaxis.set_major_formatter(FuncFormatter(lambda value, position: f"{value:g}")) # receives tick's value and position and turns the number into compact plain text
bx.yaxis.set_minor_formatter(NullFormatter()) # turns off minor labels so there's no clutter
# puts a tick @ every bin edge, and adds a label for each tick if the axis is short/edge is a whole number
bx.set_xticks(bins)
bx.set_xticklabels([f"{e:g}" if (bins[-1] <= 8 or e == int(e)) else "" for e in bins])
# axis label + title
bx.set_xlabel(t2_xlabel)
bx.set_ylabel(t2_ylabel)
bx.set_title(t2_title, pad=12)
bx.grid(axis="y", which="major", color="0.9", lw=0.8)
bx.set_axisbelow(True)
bx.legend(loc="upper right", frameon=False) # draws legend in upper right corner
fig2.savefig(f"spectrum-{pid1}.png", dpi=200) # yet again, saves figure as PNG file

print(f"\nSaved asymmetry-{pid1}.png, spectrum-{pid1}.png and asymmetry-{pid1}.csv") # reports the saved files and opens both graph windows
plt.show()