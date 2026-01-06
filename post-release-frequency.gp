# Set the delimiter to comma for CSV parsing
set datafile separator ","

# Define the time format for the x-axis
set xdata time
# The format in your CSV is 'YYYY-MM-DD HH:MM:SS+Offset'
set timefmt "%Y-%m-%d %H:%M:%S%z"

# Visual settings
set title "MLT feed with zero results per 10 Minutes"
set xlabel "Time (HH:MM)"
set ylabel "Number of MLT"
set grid

# Format the x-axis labels to show only hours and minutes
set format x "%m/%d %H:%M"

# Optional: Adjust the range to give some padding
set xtics rotate by -45
set key left top

# Define the vertical line time
# We use strptime to convert the user string to gnuplot internal time format
# format used here: "06/01/2026 11:49" -> "%d/%m/%Y %H:%M"
v_line_time = strptime("%d/%m/%Y %H:%M:%S%z", "06/01/2026 11:49:00+11")

# Add the vertical line (arrow with no head)
# "graph 0" to "graph 1" spans the full height of the plot
set arrow from v_line_time, graph 0 to v_line_time, graph 1 nohead lc rgb "red" lw 2

# Label the vertical line
set label "BS-2670 Release" at v_line_time, graph 0.9 offset 0.5,0 tc rgb "red"

# Output settings (Generates a PNG file)
set terminal pngcairo size 800,600
set output 'post-release-zero-result-mlt-frequency.png'

# Plot the data
# skip 1 skips the header row
# using 1:2 tells gnuplot to use column 1 for X and column 2 for Y
plot 'data/cloudwatch/post-release-zero-result-mlt-frequency.csv' every ::1 using 1:2 with linespoints \
     linewidth 2 pointtype 7 pointsize 0.2 \
     title 'MLT per 10 Minutes'
