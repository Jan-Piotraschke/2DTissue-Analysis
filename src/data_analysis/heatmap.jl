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

    # Custom transformation for the difference
    function custom_transform(x::T) where T
        if abs(x) <= 0.2
            return x
        else
            return sign(x) * 0.2 + (sign(x) * 0.2 * 0.9)
        end
    end
    difference = custom_transform.(difference)

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
        colormap = cgrad([:blue, :white, :red], [0, 0.5, 1], scale=:linear),
        colorrange = (-0.2, 0.2)  # custom color range
    )
    cbar = Colorbar(
        fig,
        hm,
        width = 20,
        label = "Difference"
    )
    fig[1, 2] = cbar
    return fig
end

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

fig = heatmap_difference(distance_3D, distance_kachelmuster, scale=:log)
save("difference_heatmap.png", fig; resolution = (2400, 2400))
