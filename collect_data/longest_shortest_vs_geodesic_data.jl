using Dagology
using LightGraphs
using Distributions
using Plots

##########################################################################
###############
# Set up data #
###############
p = 0.75; N = 500; d = 2; perc = 10;
max_R = d_minkowski(ones(d), zeros(d), d, p);
## Choose the kind of graph to use
(pos, g) = cube_space_digraph(N, d, (max_R/100)*perc, p);
# (pos, g) = cone_space_digraph(N, d, (1/100)*perc);
# (pos, g) = static_cube_space(N, d, max_R/fraction, p)
adjlist = g.badjlist;
## Find longest path
start = 1;
dists = my_sslp(g, topological_sort_by_dfs(g), start);
length_longest_path = maximum(dists);
vertex_longest_path = findall(x -> x == length_longest_path, dists)[1];
longest_path_vertices = get_longest_path_vertices(adjlist, dists, pos, p);
# println("This is the longest path: ", longest_path_vertices[end:-1:1])
## Find shortest path
dst = longest_path_vertices[1];
ds = dijkstra_shortest_paths(g,1,weights(g));
shortest_path_vertices = get_shortest_path_vertices(adjlist, ds.dists, dst, pos, p);
##########################################################################
## Uncomment if you want to plot
my_plot = DAG_plot_2D(g, pos, longest_path_vertices, 
shortest_path_vertices, false, false, false, false, true)
##########################################################################
## calculate distance:
long_sum = 0;
for i in 1:(length(longest_path_vertices)-1)
    x_index = longest_path_vertices[i]
    y_index = longest_path_vertices[i+1]
    x = pos[x_index,:]
    y = pos[y_index,:]
    long_sum += d_minkowski(x,y,d,p)
end
short_sum = 0;
for i in 1:(length(shortest_path_vertices)-1)
    x_index = shortest_path_vertices[i]
    y_index = shortest_path_vertices[i+1]
    x = pos[x_index,:]
    y = pos[y_index,:]
    short_sum += d_minkowski(x,y,d,p)
end
max_R = d_minkowski(ones(d), zeros(d), d, p);

println("This is the longest path distance: $long_sum")
println("Compare with the shortest path distance: $short_sum")
println("Finally, compare with the maximum Minkowski distance in the system: $max_R")

##########################################################################
## Some basic data analysis degree distribution
using Distributions
k_out, k_in = degree_distr(g)
println("This is the maximum k_out, $(maximum(k_out)) ")
println("This is the maximum k_in, $(maximum(k_in)) ")
distr_out = fit(Normal, k_out)
distr_in = fit(Normal, k_in)
println("The mean of k_out is $(distr_out.μ) with standard deviation: $(distr_out.σ)")
println("The mean of k_in is $(distr_in.μ) with standard deviation: $(distr_in.σ)")

data = k_out; N = length(k_out);
f_dict, num_zeros = frequencies_dict(data, N);
sorted_dict = sort(f_dict);
# to sort by values we need to use
# (from https://stackoverflow.com/questions/29848734/is-it-possible-to-sort-a-dictionary-in-julia)
sort(collect(zip(values(f_dict),keys(f_dict))))

using Plots
scatter(sorted_dict.keys, (sorted_dict.vals)/maximum(sorted_dict.vals))
# histogram(data, bins = (length(sorted_dict.keys)+1))