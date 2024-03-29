using Dagology
using LightGraphs
using GraphPlot
using Colors
using Plots
using LaTeXStrings
using Distributions
using LinearAlgebra
plotlyjs()
set_default_graphic_size(15cm,15cm)

##########################################################################
# plot a RGG
N = 100 ; d = 2; R = 0.1;
(pos, g) = RGG(N, R, d)
gplot(g, pos[:, 1], pos[:, 2])
# save positions
using JLD
x = pos[:, 1];
y = pos[:, 2];
# save positions
using FileIO
save(string("C:/Users/enric/Documents/Imperial/MSc_Thesis/Data//For_plots/x_and_y_RGG.jld"), "x", x, "y", y, "g", g)
# load files
loading = load("C:/Users/enric/Documents/Imperial/MSc_Thesis/Data//For_plots/x_and_y_RGG.jld")
x = loading["x"]
y = loading["y"]
g = loading["g"]
gplot(g, x, y)
# save figure
using Compose, Cairo
draw(PDF("C:/Users/enric/Documents/TexMaker/MSc_Dissertation/figures/RGG_example.pdf", 20cm, 20cm), gplot(g, x, y))
draw(PNG("C:/Users/enric/Documents/TexMaker/MSc_Dissertation/figures/RGG_example.png", 16cm, 16cm), gplot(g, x, y))

# Erdos-Renyi plot
# gplot(g_rand, pos_rand[:, 1], pos_rand[:, 2])
g_rand = erdos_renyi(100, 0.016)
gplot(g_rand, x, y)
gplot(g_rand, layout = spring_layout)
# save figure
using Compose, Cairo
draw(PDF("C:/Users/enric/Documents/TexMaker/MSc_Dissertation/figures/rand_G_example.pdf", 20cm, 20cm), gplot(g_rand, layout = spring_layout))
draw(PDF("C:/Users/enric/Documents/TexMaker/MSc_Dissertation/figures/rand_G_comparison.png", 20cm, 20cm), gplot(g_rand, x, y))
##########################################################################


##########################################################################
########################
## Figures for poster ##
########################
using JLD
loading = load("C:/Users/enric/Documents/Imperial/MSc_Thesis/Data//For_plots/x_and_y_theo_background.jld")
x = loading["x"]
y = loading["y"]


N=20; d=2; p = 1.5; perc = 40; percc = 12;
R = Inf64;
R_max = d_minkowski(ones(d), zeros(d), d, p)
positions = rand(N-2,d);
pos = vcat(zeros(d)', positions, ones(d)')
pos[:,1] = x
pos[:,2] = y
# x = pos[:,1]
# y = pos[:,2]
g_complete = SimpleDiGraph(N);
g_with_R = SimpleDiGraph(N);
g_with_R_p_neg = SimpleDiGraph(N);
g_with_R_p_medium = SimpleDiGraph(N);
pp = -1.5;
ppp = 0.75;
for i in 1:N
    for j in 1:N
        if all(pos[i,:]-pos[j,:].<0)
            if d_minkowski(pos[j,:], pos[i,:], d, p) < R;
                add_edge!(g_complete, i, j);
            end
            if d_minkowski(pos[j,:], pos[i,:], d, p) < R_max*perc/100;
                add_edge!(g_with_R, i, j);
            end
            if d_minkowski(pos[j,:], pos[i,:], d, pp) < R_max*percc/100;
                add_edge!(g_with_R_p_neg, i, j);
            end
            if d_minkowski(pos[j,:], pos[i,:], d, ppp) < R_max*perc/100;
                add_edge!(g_with_R_p_medium, i, j);
            end
        end
    end
end

##########################################################################
# cone
g_cone = SimpleDiGraph(N);
R_max = 1
θ = +π/4;
x_prime = x.*cos(θ) + y.*sin(θ)
y_prime = (y.*cos(θ) - x.*sin(θ))
for i in 1:N
    for j in 1:N
        spatial_diff = norm(y_prime[i] - y_prime[j]);
        temp_diff = x_prime[j] - x_prime[i];
        if (spatial_diff < temp_diff && (temp_diff^2 - spatial_diff^2)^(1/2) <= R_max*perc/100)
            add_edge!(g_cone, i, j);
        end
    end
end
arrowlen = 0.055
plot_g_complete = gplot(g_complete, pos[:,1], ones(N)-pos[:,2],arrowlengthfrac = arrowlen)
plot_g_with_R = gplot(g_with_R, pos[:,1], ones(N)-pos[:,2],arrowlengthfrac = arrowlen)
plot_g_with_R_neg_p = gplot(g_with_R_p_neg, pos[:,1], ones(N)-pos[:,2],arrowlengthfrac = arrowlen)
plot_g_with_R_medium = gplot(g_with_R_p_medium, pos[:,1], ones(N)-pos[:,2],arrowlengthfrac = arrowlen)
plot_g_cone = gplot(g_cone, pos[:,1], ones(N)-pos[:,2],arrowlengthfrac = arrowlen)

##########################################################################
# g_with_R
start = 1;  # this is the source vertex of the system
dists = my_sslp(g_with_R, topological_sort_by_dfs(g_with_R), start);
length_longest_path = maximum(dists);
vertex_longest_path = findall(x -> x == length_longest_path, dists)[1];
adjlist = g_with_R.badjlist;
longest_path_vertices = get_longest_path_vertices(adjlist, dists, pos, p);
dst = longest_path_vertices[1];
## Find shortest path distances
ds = dijkstra_shortest_paths(g_with_R,start,weights(g_with_R));
shortest_path_vertices = get_shortest_path_vertices(adjlist, ds.dists, dst, pos, p);
## Plot final graph
my_plot = DAG_plot_2D(g_with_R, pos, longest_path_vertices, 
shortest_path_vertices, false, false, false, false, true, arrowlen)
using Cairo, Compose
draw(
    PNG("C:/Users/enric/Documents/TexMaker/MSc_Dissertation/figures/example_g_with_R_paths.png", 16cm, 16cm), 
    DAG_plot_2D(g_with_R, pos, longest_path_vertices, 
    shortest_path_vertices, false, false, false, false, true, arrowlen)
)

##########################################################################
# g_complete
start = 1;  # this is the source vertex of the system
dists = my_sslp(g_complete, topological_sort_by_dfs(g_complete), start);
length_longest_path = maximum(dists);
vertex_longest_path = findall(x -> x == length_longest_path, dists)[1];
adjlist = g_complete.badjlist;
longest_path_vertices = get_longest_path_vertices(adjlist, dists, pos, p);
dst = longest_path_vertices[1];
## Find shortest path distances
ds = dijkstra_shortest_paths(g_complete,start,weights(g_complete));
shortest_path_vertices = get_shortest_path_vertices(adjlist, ds.dists, dst, pos, p);
## Plot final graph
my_plot = DAG_plot_2D(g_complete, pos, longest_path_vertices, 
shortest_path_vertices, false, false, false, false, true, arrowlen)
draw(
    PNG("C:/Users/enric/Documents/TexMaker/MSc_Dissertation/figures/example_g_complete_paths.png", 16cm, 16cm), 
    DAG_plot_2D(g_complete, pos, longest_path_vertices, 
    shortest_path_vertices, false, false, false, false, true, arrowlen)
)

##########################################################################
# g_cone
start = 1;  # this is the source vertex of the system
dists = my_sslp(g_cone, topological_sort_by_dfs(g_cone), start);
length_longest_path = maximum(dists);
vertex_longest_path = findall(x -> x == length_longest_path, dists)[1];
adjlist = g_cone.badjlist;
longest_path_vertices = get_longest_path_vertices(adjlist, dists, pos, p);
dst = longest_path_vertices[1];
## Find shortest path distances
ds = dijkstra_shortest_paths(g_cone,start,weights(g_cone));
shortest_path_vertices = get_shortest_path_vertices(adjlist, ds.dists, dst, pos, p);
## Plot final graph
my_plot = DAG_plot_2D(g_cone, pos, longest_path_vertices, 
shortest_path_vertices, false, false, false, false, true, arrowlen)
draw(
    PNG("C:/Users/enric/Documents/TexMaker/MSc_Dissertation/figures/example_g_cone_paths.png", 16cm, 16cm), 
    DAG_plot_2D(g_cone, pos, longest_path_vertices, 
    shortest_path_vertices, false, false, false, false, true, arrowlen)
)
##########################################################################
# g_with_R_neg_p
start = 1;  # this is the source vertex of the system
dists = my_sslp(g_with_R_p_neg, topological_sort_by_dfs(g_with_R_p_neg), start);
length_longest_path = maximum(dists);
vertex_longest_path = findall(x -> x == length_longest_path, dists)[1];
adjlist = g_with_R_p_neg.badjlist;
longest_path_vertices = get_longest_path_vertices(adjlist, dists, pos, p);
dst = longest_path_vertices[1];
## Find shortest path distances
ds = dijkstra_shortest_paths(g_with_R_p_neg,start,weights(g_with_R_p_neg));
shortest_path_vertices = get_shortest_path_vertices(adjlist, ds.dists, dst, pos, p);
## Plot final graph
my_plot = DAG_plot_2D(g_with_R_p_neg, pos, longest_path_vertices, 
shortest_path_vertices, false, false, false, false, true, arrowlen)
using Cairo, Compose
draw(
    PNG("C:/Users/enric/Documents/TexMaker/MSc_Dissertation/figures/example_g_with_R_p_neg_paths.png", 16cm, 16cm), 
    DAG_plot_2D(g_with_R_p_neg, pos, longest_path_vertices, 
    shortest_path_vertices, false, false, false, false, true, arrowlen)
)

##########################################################################
# g_with_R_p_medium
start = 1;  # this is the source vertex of the system
dists = my_sslp(g_with_R_p_medium, topological_sort_by_dfs(g_with_R_p_medium), start);
length_longest_path = maximum(dists);
vertex_longest_path = findall(x -> x == length_longest_path, dists)[1];
adjlist = g_with_R_p_medium.badjlist;
longest_path_vertices = get_longest_path_vertices(adjlist, dists, pos, p);
dst = longest_path_vertices[1];
## Find shortest path distances
ds = dijkstra_shortest_paths(g_with_R_p_medium,start,weights(g_with_R_p_medium));
shortest_path_vertices = get_shortest_path_vertices(adjlist, ds.dists, dst, pos, p);
## Plot final graph
my_plot = DAG_plot_2D(g_with_R_p_medium, pos, longest_path_vertices, 
shortest_path_vertices, false, false, false, false, true, arrowlen)
using Cairo, Compose
draw(
    PNG("C:/Users/enric/Documents/TexMaker/MSc_Dissertation/figures/example_g_with_R_p_medium_paths.png", 16cm, 16cm), 
    DAG_plot_2D(g_with_R_p_medium, pos, longest_path_vertices, 
    shortest_path_vertices, false, false, false, false, true, arrowlen)
)

##########################################################################
# https://juliapackages.com/p/jld
using JLD
x = pos[:,1]
y = pos[:,2]
save("C:/Users/enric/Documents/Imperial/MSc_Thesis/Data//For_plots/x_and_y_theo_background.jld", "x", x, "y", y, "g_complete", g_complete, "g_with_R", g_with_R, "perc", perc)
loading = load("C:/Users/enric/Documents/Imperial/MSc_Thesis/Data//For_plots/x_and_y_theo_background.jld")
x = loading["x"]
y = loading["y"]
using Compose, Cairo
draw(PNG("C:/Users/enric/Documents/Imperial/MSc_Thesis/Poster_figures/example_g_complete.png", 16cm, 16cm), gplot(g_complete, x, ones(N)-y,arrowlengthfrac = arrowlen))
draw(PNG("C:/Users/enric/Documents/Imperial/MSc_Thesis/Poster_figures/example_g_with_R.png", 16cm, 16cm), gplot(g_with_R, x, ones(N)-y,arrowlengthfrac = arrowlen))
draw(PNG("C:/Users/enric/Documents/Imperial/MSc_Thesis/Poster_figures/example_g_cone.png", 16cm, 16cm), gplot(g_cone, x, ones(N)-y,arrowlengthfrac = arrowlen))
