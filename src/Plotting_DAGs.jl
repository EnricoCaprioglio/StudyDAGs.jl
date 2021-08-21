using LightGraphs
using Plots
using LinearAlgebra
using Colors
using GraphPlot

"""
``DAG_plot_2D(g, pos, l_path, s_path,
    nodesizes = false, nodefillcs = false,
    rotated = false, nodelabels = false,
    edgestrokes = false)``
"""
function DAG_plot_2D(g, pos, l_path, s_path,
    nodesizes = false, nodefillcs = false,
    rotated = false, nodelabels = false,
    edgestrokes = false)

    if length(pos[1,:]) != 2
        throw(DomainError(:wrongdimension))
    end
    N = size(pos)[1];
    locs_x = pos[:,1];
    locs_y = ones(N)-pos[:,2];
    θ = π/4;
    x_prime = locs_x.*cos(θ) + locs_y.*sin(θ)
    y_prime = (locs_y.*cos(θ) - locs_x.*sin(θ)).*5
    # plot graph
    if nodesizes
        nodesize = [degree(g)[v] for v in vertices(g)];
    else
        nodesize = ones(size(pos)[1]);
    end
    if nodefillcs
        # from https://juliagraphs.org/GraphPlot.jl/
        max_size = [degree(g)[v] for v in vertices(g)]
        alphas = max_size/maximum(max_size);
        nodefillc = [RGBA(0.0,0.8,0.8,i) for i in alphas];
    else
        # from https://juliagraphs.org/GraphPlot.jl/
        membership = ones(N);
        for k in l_path
            membership[k] = 2
        end
        for k in s_path
            membership[k] = 3
            if k in l_path
                membership[k] = 4
            end
        end
        membership[1] = 4
        membership[l_path[1]] = 4
        nodecolor = [colorant"lightseagreen", colorant"red", colorant"blue", colorant"green"];
        nodefillc = nodecolor[convert(Vector{Int64}, membership)];
    end
    if edgestrokes
        membership2 = ones(g.ne)
        nodecolor2 = [colorant"lightgray", colorant"red", colorant"blue", colorant"green"];
        order1 = l_path[end:-1:1];
        order2 = s_path[end:-1:1];
        fadjlist = g.fadjlist;
        for i in 1:length(order1)-1
            index = findall(x -> x==order1[i+1], fadjlist[order1[i]])
            sum = 0;
            if order1[i]>1
                for j in 1:(order1[i]-1)
                    sum += length(fadjlist[j])
                end
                membership2[abs(sum + index[1])] = 2;
            else
                membership2[abs(sum + index[1])] = 2;
            end
        end
        for i in 1:length(order2)-1
            index = findall(x -> x==order2[i+1], fadjlist[order2[i]])
            sum = 0;
            if order2[i]>1
                for j in 1:(order2[i]-1)
                    sum += length(fadjlist[j])
                end
                if membership2[abs(sum + index[1])] == 2
                    membership2[abs(sum + index[1])] = 4;
                else
                    membership2[abs(sum + index[1])] = 3;
                end
            else
                if membership2[abs(sum + index[1])] == 2
                    membership2[abs(sum + index[1])] = 4;
                else
                    membership2[abs(sum + index[1])] = 3;
                end
            end
        end
        edgestrokec = nodecolor2[convert(Vector{Int64}, membership2)];
    else
        membership2 = ones(g.ne);
        edgestrokec = nodecolor2[convert(Vector{Int64}, membership2)];
    end
    if rotated
        if nodelabels
            nodelabel = collect(1:N)
            my_plot = gplot(g, x_prime, y_prime,
            nodefillc=nodefillc, nodesize=nodesize,
            nodelabel=nodelabel, arrowlengthfrac = 0.01,
            edgestrokec=edgestrokec)
        else
            my_plot = gplot(g, x_prime, y_prime,
            nodefillc=nodefillc, nodesize=nodesize,
            arrowlengthfrac = 0.01, edgestrokec=edgestrokec)
        end
    else
        if nodelabels
            nodelabel = collect(1:N)
            my_plot = gplot(g, locs_x, locs_y,
            nodefillc=nodefillc, nodesize=nodesize,
            nodelabel=nodelabel, arrowlengthfrac = 0.01,
            edgestrokec=edgestrokec)
        else
            my_plot = gplot(g, locs_x, locs_y,
            nodefillc=nodefillc, nodesize=nodesize,
            arrowlengthfrac = 0.01, edgestrokec=edgestrokec)
        end
    end
    return my_plot
end

function DAG_Plot_3D(Box_pos, g)
    if length(Box_pos[1,:]) != 3
        throw(DomainError(:wrongdimension))
    end
    z = Box_pos[:,1];
    x = Box_pos[:,2];
    y = Box_pos[:,3];
    display(scatter(x,y,z,legend = false))
    N = size(Box_pos)[1]
    for i in 1:N
        for j ∈ g.fadjlist[i]
            z1 = [Box_pos[i,:][1],Box_pos[j,:][1]]
            x1 = [Box_pos[i,:][2],Box_pos[j,:][2]]
            y1 = [Box_pos[i,:][3],Box_pos[j,:][3]]
            display(plot!(x1, y1, z1, line=:arrow, arrow=:closed))
        end
    end
end

"""
``function plot_G_with_unit_ball(x_shift,y_shift,r,p)``
    scatter plot of some points in a graph together with their unit balls.

    x_shif and y_shift need to be vectors.
"""
function plot_G_with_unit_ball(x_shift,y_shift,r,p, alpha = 0.25)
    iters = length(x_shift)
    my_plot = plot()
    colors = [:red, :green, :blue, :lightseagreen, :purple, :orange]
    for t in 1:iters
        colors = [:red, :green, :blue, :purple, :brown, :orange, :lightseagreen]
        x = collect(0:0.01:r);
        to_plot = zeros(length(x)*4, 2);
        y = (abs.((ones(length(x)).*r).^p-abs.(x).^p)).^(1/p);
        k = 0;
        for i in 1:4
            for j in 1:length(x)
                if i < 3
                    to_plot[k+j, 1] = x[j] + x_shift[t]
                else
                    to_plot[k+j, 1] = -x[j] + x_shift[t]
                end
                if i%2 == 1
                    to_plot[k+j, 2] = y[j] + y_shift[t]
                else
                    to_plot[k+j, 2] = -y[j] + y_shift[t]
                end
            end
            k += length(x)
        end
        s = 0
        for i in 1:4
            x_prime = to_plot[1+s:s+length(x),1];
            y_prime = to_plot[1+s:s+length(x),2];
            # plot lines
            my_plot = plot!(x_prime, y_prime,
            color = colors[c], aspect_ratio=:equal, label = "")
            # fill areas
            if i%2 == 1
                my_plot = plot!(x_prime, ones(length(x)).*y_shift[t],
                fillrange = y_prime, fillalpha = 0.35,
                label = "", linewidth=0, c = colors[t])
            else
                my_plot = plot!(x_prime, y_prime,
                fillrange = ones(length(x)).*y_shift[t],
                fillalpha = alpha, label = "",
                linewidth=0, c = colors[t])
            end
            if i == 4
                my_plot = plot!(label = "p = $p")
            end
            s+=length(x)
        end
    end
    scatter!(x_shift,y_shift, c = colors[1:length(x_shift)]) # , label = "ball $t"
    return my_plot
end