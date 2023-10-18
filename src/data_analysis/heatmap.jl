using Makie
using CairoMakie
using CSV
using DataFrames
using Tables

CairoMakie.activate!()

function read_data(folder, file_name)
    file_path = joinpath(folder, file_name)
    df = CSV.read(file_path, DataFrame; header=false)
    return Matrix(df)
end

function heatmap_difference(matrix1::Matrix{T}, matrix2::Matrix{T}; scale=:linear) where T
    # Check if matrices have the same size
    if size(matrix1) != size(matrix2)
        error("Matrices must be of the same size!")
    end

    # Compute the difference
    difference = matrix1 - matrix2
    max_diff = maximum(abs.(difference))
    original_range = (-max_diff, max_diff)

    # Depending on the scale chosen, transform the difference matrix
    if scale == :log
        difference = sign.(difference) .* log.(1 .+ abs.(difference))
    elseif scale == :sqrt
        difference = sign.(difference) .* sqrt.(abs.(difference))
    end

    # Beautify the heatmap for publication
    fig = Figure(resolution = (800, 800), title = "Difference Heatmap")
    ax = fig[1, 1] = Axis(
        fig,
        xlabel = "Columns",
        ylabel = "Rows",
        title = "Difference Heatmap"
    )
    hm = heatmap!(
        ax,
        difference,
        colormap = :viridis,
        colorrange = original_range
    )

    # Modify colorbar ticks for log scale
    if scale == :log
        tick_vals = [sign(x) * log(1 + abs(x)) for x in original_range]
        cbar = Colorbar(
            fig,
            hm,
            width = 20,
            label = "Difference",
            ticks = tick_vals
        )
    else
        cbar = Colorbar(
            fig,
            hm,
            width = 20,
            label = "Difference"
        )
    end

    fig[1, 2] = cbar
    fig
end

 # for example, but you can use others like :plasma, :inferno, :cividis, etc.
function make_symmetric_with_min(matrix::Matrix{T}) where T
    # Check if the matrix is square
    if size(matrix, 1) != size(matrix, 2)
        error("Input matrix must be square!")
    end

    n, m = size(matrix)
    for i in 1:n
        for j in (i+1):m
            # Keep the minimum value between matrix[i, j] and matrix[j, i]
            min_val = min(matrix[i, j], matrix[j, i])
            matrix[i, j] = min_val
            matrix[j, i] = min_val
        end
    end
    return matrix
end

function normalize_matrix(matrix::Matrix{Float64})::Matrix{Float64}
    min_val = minimum(matrix)
    max_val = maximum(matrix)

    return (matrix .- min_val) ./ (max_val - min_val)
end

distance_3D = read_data("../../MeshCartographyLib/meshes/data", "ellipsoid_x4_open_distance_old.csv")
distance_3D = make_symmetric_with_min(distance_3D)
distance_3D = normalize_matrix(distance_3D)

distance_kachelmuster = read_data("../../MeshCartographyLib/meshes/data", "ellipsoid_x4_uv_kachelmuster_distance_matrix_static.csv")
distance_kachelmuster = normalize_matrix(distance_kachelmuster)

heatmap_difference(distance_3D, distance_kachelmuster, scale=:log)
