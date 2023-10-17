using Makie, GLMakie
using FileIO
using Statistics
using CSV
using DataFrames
using Tables
using Colors

# Load the data
df = CSV.read("../../assets/v_order_analysis.csv", DataFrame; header=false)

# Since you only have one column, we'll treat the row number as the time step
time_column = 1:nrow(df)
data_column = df[:, :Column1]

# Create the plot
fig = Figure(resolution = (2400, 1800), backgroundcolor = :white)
ax = Axis(fig[1, 1], xlabel = "Iterations", ylabel = "Order Parameter")
ylims!(ax, 0, 1.01)
lines!(ax, time_column, data_column, color = :blue, linewidth = 2)
scatter!(ax, time_column, data_column, color = :red, markersize = 4, marker = :circle)

# Styling
labelsize = 60
titlesize = 80

ax.titletextcolor = :black
ax.titletextsize = 16
ax.axislabeltextcolor = :black
ax.axislabeltextsize = 14
ax.ticklabeltextcolor = :black
ax.gridcolor = RGBf0(0.9, 0.9, 0.9)
ax.xlabelsize = titlesize
ax.ylabelsize = titlesize
ax.xticklabelsize = labelsize
ax.yticklabelsize = labelsize
tight_yticklabel_spacing!(ax)
# Save the plot
save("time_plot.png", fig, padding = 100)

# Display the plot (optional, for interactive environments like Pluto.jl or Jupyter)
fig

