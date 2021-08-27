function make_fhist1d(x, e, bins)
    # Use FHist to create histogram based on provided data
    h = Hist1D(Float64; bins=bins)
    # Decide whether error term is provided or not and create the FHist object
    if isnothing(e)
        # Fill the FHist
        Threads.@threads for i in x
            push!(h, i)
        end
    else
        # If the content and error terms don't match in length throw an exception
        if length(x) != length(e)
            nx = length(x)
            ne = length(e)
            error("hist1d:: provided bin content and error content length do not match up! length(x) = $nx != length(e) = $ne")
        end
        # Fill the FHist
        Threads.@threads for i in 1:length(x)
            push!(h, x[i], e[i])
        end
    end
    return h
end

make_fhist1d(x, bins) = make_fhist1d(x, nothing, bins)

function make_fhist1d(th1::Dict{Symbol, Any})
    xmin = th1[:fXaxis_fXmin]
    xmax = th1[:fXaxis_fXmax]
    nbins = th1[:fXaxis_fNbins]
    bins = range(xmin, xmax, length=nbins+1)
    # println(length(bins))
    # println(length(th1[:fN][2:end-1]))
    # println(length(th1[:fSumw2][2:end-1]))
    h = Hist1D(Float64; bins=bins)
    h.hist.weights .= th1[:fN][2:end-1]
    h.sumw2 .= th1[:fSumw2][2:end-1]
    return h
end

function build_hist1dtrace(h; witherror=false, datastyle=false) # FHist 1d
    bin_low_edges = copy(binedges(h)) # bin edges
    bin_centers = copy(bincenters(h)) # bin edges
    bin_contents = copy(bincounts(h))
    push!(bin_contents, last(bin_contents))
    bin_errors = sqrt.(h.sumw2)
    push!(bin_errors, last(bin_errors))
    traces = GenericTrace{Dict{Symbol, Any}}[]
    if datastyle
        new_bin_contents = Float64[]
        new_bin_centers = Float64[]
        new_bin_errors = Float64[]
        for (y, x, ye) in zip(bin_contents, bin_centers, bin_errors)
            if y != 0
                push!(new_bin_contents, y)
                push!(new_bin_centers, x)
                push!(new_bin_errors, ye)
            end
        end
        s1 = scatter(y=new_bin_contents,
                     x=new_bin_centers,
                     error_y=attr(array=new_bin_errors, width=0),
                     opacity=1,
                     mode="markers",
                     marker_size=7,
                     marker_color="black",
                    )
        return s1
    end
    if witherror
        s1 = scatter(y=bin_contents,
                     x=bin_low_edges,
                     opacity=0.7,
                     mode="lines",
                     line_shape="hv",
                     line_width=0,
                     marker_size=0,
                     fillcolor="blue",
                     fill="tozeroy",
                     showlegend=false,
                    )
    else
        # println(bin_centers)
        # println(bin_contents)
        # println(bin_low_edges)
        s1 = bar(x=bin_centers,
                 y=bin_contents,
                 opacity=1.0,
                 marker_color="black",
                 # marker_line_width=1,
                 # marker_colorbar_color="black",
                )
        return s1
    end
    s2 = scatter(y=bin_contents+bin_errors,
                 x=bin_low_edges,
                 mode="lines",
                 marker_color="#444",
                 line_shape="hv",
                 line_width=0,
                 showlegend=false
                )
    s3 = scatter(y=bin_contents-bin_errors,
                 x=bin_low_edges,
                 mode="lines",
                 marker_color="#444",
                 fillcolor="rgba(68, 68, 68, 0.3)",
                 line_shape="hv",
                 fill="tonexty",
                 line_width=0,
                 showlegend=false
                )
    s1.fields[:line][:width]=1
    s1.fields[:line][:color]="blue"
    s1.fields[:fill]=""
    push!(traces, s1)
    push!(traces, s2)
    push!(traces, s3)
    return traces
end

function fit_bkg_to_data!(bkgs, total, data_)
    # If do fit, scale the background histogram to match the data
    # Check that there is even data to scale it to
    if length(data_) != 0
        # Compute the total integral
        bkgint = integral(total)
        # If total integral is 0 then throw exception
        if bkgint == 0
            error("ERROR [PlotlyJSWrapper scale_background!], Asked to rescale background but background integral = 0!")
            return
        end
        # Compute the data integral
        data_int = integral(data_[1])
        # Compute the data / bkg scale factor
        sf = data_int / bkgint
        # Scale the backgrounds
        bkgs = bkgs .|> x->x*sf
        # Recompute total
        total = sum(bkgs) # Recompute total
    else
        # If no data, print warning and move on
        println("Warning! [PlotlyJSWrapper plot_stack()] Asked for :dofit, but there is no data! Skipping...")
    end
end

function get_ymax(total, signals, data_)
    totalmax = maximum(bincounts(total)+sqrt.(total.sumw2))
    datamax = data_ .|> x->maximum(bincounts(x)+sqrt.(x.sumw2))
    sigmax = signals .|> x->maximum(bincounts(x)+sqrt.(x.sumw2))
    maxtocheck = [totalmax]
    length(datamax) != 0 && append!(maxtocheck, datamax)
    length(sigmax) != 0 && append!(maxtocheck, sigmax)
    ymax = maximum(maxtocheck)
end

function get_ymin(total, signals, data_)
    totalmin = minimum(bincounts(total)-sqrt.(total.sumw2))
    datamin = data_ .|> x->minimum(bincounts(x)-sqrt.(x.sumw2))
    sigmin = signals .|> x->minimum(bincounts(x)-sqrt.(x.sumw2))
    mintocheck = [totalmin]
    length(datamin) != 0 && append!(mintocheck, datamin)
    length(sigmin) != 0 && append!(mintocheck, sigmin)
    ymin = minimum(mintocheck)
end


function get_yrange(total, signals, data_)
    [get_ymin(total, signals, data_), get_ymax(total, signals, data_)]
end

function add_ratio_axes_traces!(traces; options)
    # Dummy traces for ratio panel
    # major ticks
    ratiopanel_majorticks_dummy_trace = scatter()
    ratiopanel_majorticks_dummy_trace.fields[:name] = "ratiopanel_majorticks"
    ratiopanel_majorticks_dummy_trace.fields[:yaxis] = "y"
    ratiopanel_majorticks_dummy_trace.fields[:xaxis] = "x"
    ratiopanel_majorticks_dummy_trace.fields[:name] = options[:ratiotitle]
    ratiopanel_majorticks_dummy_trace.fields[:showlegend] = false
    push!(traces, ratiopanel_majorticks_dummy_trace)
    # minor ticks
    ratiopanel_minorticks_dummy_trace = scatter()
    ratiopanel_minorticks_dummy_trace.fields[:name] = "ratiopanel_minorticks"
    ratiopanel_minorticks_dummy_trace.fields[:yaxis] = "y2"
    ratiopanel_minorticks_dummy_trace.fields[:xaxis] = "x2"
    ratiopanel_minorticks_dummy_trace.fields[:showlegend] = false
    push!(traces, ratiopanel_minorticks_dummy_trace)
    ratiopanel_unityline_dummy_trace = scatter()
    ratiopanel_unityline_dummy_trace.fields[:name] = "ratiopanel_unityline"
    ratiopanel_unityline_dummy_trace.fields[:yaxis] = "y3"
    ratiopanel_unityline_dummy_trace.fields[:xaxis] = "x3"
    ratiopanel_unityline_dummy_trace.fields[:showlegend] = false
    push!(traces, ratiopanel_unityline_dummy_trace)
    # Dummy traces for main panel
    # major ticks
    mainpanel_majorticks_dummy_trace = scatter()
    mainpanel_majorticks_dummy_trace.fields[:name] = "mainpanel_majorticks"
    mainpanel_majorticks_dummy_trace.fields[:yaxis] = "y4"
    mainpanel_majorticks_dummy_trace.fields[:xaxis] = "x4"
    mainpanel_majorticks_dummy_trace.fields[:showlegend] = false
    push!(traces, mainpanel_majorticks_dummy_trace)
    # minor ticks
    mainpanel_minorticks_dummy_trace = scatter()
    mainpanel_minorticks_dummy_trace.fields[:name] = "mainpanel_minorticks"
    mainpanel_minorticks_dummy_trace.fields[:yaxis] = "y5"
    mainpanel_minorticks_dummy_trace.fields[:xaxis] = "x5"
    mainpanel_minorticks_dummy_trace.fields[:showlegend] = false
    push!(traces, mainpanel_minorticks_dummy_trace)
end

function add_cms_label!(annotations; options)
    push!(annotations, attr(
                            xref="paper",
                            yref="paper",
                            xanchor="left",
                            yanchor="bottom",
                            x=0.0,
                            y=1.0,
                            text="<b>CMS</b>",
                            font=attr(
                                      color="black",
                                      size=24,
                                     ),
                            showarrow=false,
                           ))
    if options[:addpreliminarylabel]
        push!(annotations, attr(
                                xref="paper",
                                yref="paper",
                                xanchor="left",
                                yanchor="bottom",
                                x=0.18,
                                y=1.0,
                                text="<i>Preliminary</i>",
                                font=attr(
                                          color="black",
                                          size=20,
                                         ),
                                showarrow=false,
                               ))
    end
end

function add_lumi_label!(annotations; options)
    lumival = options[:lumivalue]
    comenergy = options[:comenergy]
    push!(annotations, attr(
                            xref="paper",
                            yref="paper",
                            xanchor="right",
                            yanchor="bottom",
                            x=1.0,
                            y=1.0,
                            text="$lumival fb<sup>-1</sup>($comenergy TeV)",
                            font=attr(
                                      color="black",
                                      size=20,
                                     ),
                            showarrow=false,
                           ))
end

function add_ratio_traces!(traces, ratio; options)
    # If no ratio plot then nothing to do just move on
    if length(ratio) == 0
        return
    end
    # Ratio trace
    ratio_traces = ratio .|> x->build_hist1dtrace(x, datastyle=true)
    if length(ratio_traces) > length(options[:datacolors])
        println("Warning! There are more data histograms than provided :datacolors!")
    end
    for (i, tr) in enumerate(ratio_traces)
        tr.fields[:yaxis] = "y"
        tr.fields[:xaxis] = "x"
        tr.fields[:name] = "Data/MC"
        tr.fields[:marker][:color] = options[:datacolors][i]
        tr.fields[:showlegend] = false
        push!(traces, tr)
    end
end

function add_background_traces!(traces, bkgs; options)
    # Main data trace
    stack_traces = bkgs .|> build_hist1dtrace
    for stack_trace in stack_traces
        stack_trace.fields[:yaxis] = "y4"
        stack_trace.fields[:xaxis] = "x4"
    end
    # Set the colors of the histograms
    for (tr, c) in zip(stack_traces, repeat(options[:backgroundcolors], 10)) # Not very safe.. but it works for now
        tr.fields[:marker][:color] = colors(c, opacity=1)
    end
    # Set the names of the histograms
    nice_names = deepcopy(options[:backgroundlabels])
    if length(nice_names) < length(stack_traces)
        for i in 1:(length(stack_traces)-length(nice_names))
            push!(nice_names, "trace$i")
        end
    end
    for (tr, n) in zip(stack_traces, nice_names)
        tr.fields[:name] = n
    end
    stack_traces = sort(stack_traces, by=x->sum(x.fields[:y]), rev=false)
    # Set the group to be individual based idx of the bkg
    for (g, tr) in enumerate(stack_traces)
        tr.fields[:legendgroup] = g
    end
    append!(traces, stack_traces)
end

function add_total_traces!(traces, total; options)
    totaltraces = total |> x->build_hist1dtrace(x, witherror=true)
    for totaltrace in totaltraces
        totaltrace.fields[:yaxis] = "y4"
        totaltrace.fields[:xaxis] = "x4"
    end
    totaltraces[1].fields[:name] = "total"
    totaltraces[2].fields[:name] = "total +1σ"
    totaltraces[3].fields[:name] = "total -1σ"
    append!(traces, totaltraces)
    # dummy total histogram for legend
    totallegendtrace = copy(totaltraces[1])
    totallegendtrace.fields[:showlegend] = true
    totallegendtrace.fields[:legendgroup] = -100
    push!(traces, totallegendtrace)
end

function add_data_traces!(traces, data; options)
    data_traces = data .|> x->build_hist1dtrace(x, datastyle=true)
    data_labels = deepcopy(options[:datalabels])
    if length(data_labels) < length(data_traces)
        for i in 1:(length(data_traces)-length(data_labels))
            push!(data_labels, "Data$i")
        end
    end
    for (i, (label, tr)) in enumerate(zip(data_labels, data_traces))
        tr.fields[:name] = label
        tr.fields[:marker][:color] = options[:datacolors][i]
        tr.fields[:yaxis] = "y4"
        tr.fields[:xaxis] = "x4"
        tr.fields[:legendgroup] = -1 * i
        push!(traces, tr)
    end
end

function colors(i; opacity)
    i == 11005 && return "rgba(103 , 0 , 31 , $opacity)"
    i == 11004 && return "rgba(178 , 24 , 43 , $opacity)"
    i == 11003 && return "rgba(214 , 96 , 77 , $opacity)"
    i == 11002 && return "rgba(244 , 165 , 130 , $opacity)"
    i == 11001 && return "rgba(253 , 219 , 199 , $opacity)"
    i == 11000 && return "rgba(247 , 247 , 247 , $opacity)"
    i == 11011 && return "rgba(209 , 229 , 240 , $opacity)"
    i == 11012 && return "rgba(146 , 197 , 222 , $opacity)"
    i == 11013 && return "rgba(67 , 147 , 195 , $opacity)"
    i == 11014 && return "rgba(33 , 102 , 172 , $opacity)"
    i == 11015 && return "rgba(5 , 48 , 97 , $opacity)"
    i == 3001 && return "rgba(239 , 138 , 98 , $opacity)"
    i == 3000 && return "rgba(247 , 247 , 247 , $opacity)"
    i == 3011 && return "rgba(103 , 169 , 207 , $opacity)"
    i == 5001 && return "rgba(251 , 180 , 174 , $opacity)"
    i == 5002 && return "rgba(179 , 205 , 227 , $opacity)"
    i == 5003 && return "rgba(204 , 235 , 197 , $opacity)"
    i == 5004 && return "rgba(222 , 203 , 228 , $opacity)"
    i == 5005 && return "rgba(254 , 217 , 166 , $opacity)"
    i == 7000 && return "rgba(0, 0, 0, $opacity)"
    i == 7001 && return "rgba(213, 94, 0, $opacity)" #r
    i == 7002 && return "rgba(230, 159, 0, $opacity)" #o
    i == 7003 && return "rgba(240, 228, 66, $opacity)" #y
    i == 7004 && return "rgba(0, 158, 115, $opacity)" #g
    i == 7005 && return "rgba(0, 114, 178, $opacity)" #b
    i == 7006 && return "rgba(86, 180, 233, $opacity)" #k
    i == 7007 && return "rgba(204, 121, 167, $opacity)" #p
    i == 7011 && return "rgba(110, 54, 0, $opacity)" #alt r
    i == 7012 && return "rgba(161, 117, 0, $opacity)" #alt o
    i == 7013 && return "rgba(163, 155, 47, $opacity)" #alt y
    i == 7014 && return "rgba(0, 102, 79, $opacity)" #alt g
    i == 7015 && return "rgba(0, 93, 135, $opacity)" #alt b
    i == 7016 && return "rgba(153, 153, 153, $opacity)" #alt k
    i == 7017 && return "rgba(140, 93, 119, $opacity)" #alt p
    i == 9001 && return "rgba(60, 186, 84, $opacity)"
    i == 9002 && return "rgba(244, 194, 13, $opacity)"
    i == 9003 && return "rgba(219, 50, 54, $opacity)"
    i == 9004 && return "rgba(72, 133, 237, $opacity)"
    # Color schemes from Hannsjoerg for WWW analysis
    i == 2001 && return "rgba(91 , 187 , 241 , $opacity)" #light-blue
    i == 2002 && return "rgba(60 , 144 , 196 , $opacity)" #blue
    i == 2003 && return "rgba(230 , 159 , 0 , $opacity)" #orange
    i == 2004 && return "rgba(180 , 117 , 0 , $opacity)" #brown
    i == 2005 && return "rgba(245 , 236 , 69 , $opacity)" #yellow
    i == 2006 && return "rgba(215 , 200 , 0 , $opacity)" #dark yellow
    i == 2007 && return "rgba(70 , 109 , 171 , $opacity)" #blue-violet
    i == 2008 && return "rgba(70 , 90 , 134 , $opacity)" #violet
    i == 2009 && return "rgba(55 , 65 , 100 , $opacity)" #dark violet
    i == 2010 && return "rgba(120 , 160 , 0 , $opacity)" #light green
    i == 2011 && return "rgba(0 , 158 , 115 , $opacity)" #green
    i == 2012 && return "rgba(204 , 121 , 167 , $opacity)" #pink?
    i == 4001 && return "rgba(49 , 76 , 26 , $opacity)"
    i == 4002 && return "rgba(33 , 164 , 105 , $opacity)"
    i == 4003 && return "rgba(176 , 224 , 160 , $opacity)"
    i == 4004 && return "rgba(210 , 245 , 200 , $opacity)"
    i == 4005 && return "rgba(232 , 249 , 223 , $opacity)"
    i == 4006 && return "rgba(253 , 156 , 207 , $opacity)"
    i == 4007 && return "rgba(121 , 204 , 158 , $opacity)"
    i == 4008 && return "rgba(158 , 0 , 42 , $opacity)"
    i == 4009 && return "rgba(176 , 0 , 195 , $opacity)"
    i == 4010 && return "rgba(20 , 195 , 0 , $opacity)"
    i == 4011 && return "rgba(145 , 2 , 206 , $opacity)"
    i == 4012 && return "rgba(255 , 0 , 255 , $opacity)"
    i == 4013 && return "rgba(243 , 85 , 0 , $opacity)"
    i == 4014 && return "rgba(157 , 243 , 130 , $opacity)"
    i == 4015 && return "rgba(235 , 117 , 249 , $opacity)"
    i == 4016 && return "rgba(90 , 211 , 221 , $opacity)"
    i == 4017 && return "rgba(85 , 181 , 92 , $opacity)"
    i == 4018 && return "rgba(172 , 50 , 60 , $opacity)"
    i == 4019 && return "rgba(42 , 111 , 130 , $opacity)"
    i == 4020 && return "rgba(240 , 155 , 205 , $opacity)" # ATLAS pink
    i == 4021 && return "rgba(77 , 161 , 60 , $opacity)" # ATLAS green
    i == 4022 && return "rgba(87 , 161 , 247 , $opacity)" # ATLAS blue
    i == 4023 && return "rgba(196 , 139 , 253 , $opacity)" # ATLAS darkpink
    i == 4024 && return "rgba(205 , 240 , 155 , $opacity)" # Complementary
    i == 4101 && return "rgba(102 , 102 , 204 , $opacity)" # ATLAS HWW / WW
    i == 4102 && return "rgba(89 , 185 , 26 , $opacity)" # ATLAS HWW / DY
    i == 4103 && return "rgba(225 , 91 , 226 , $opacity)" # ATLAS HWW / VV
    i == 4104 && return "rgba(103 , 236 , 235 , $opacity)" # ATLAS HWW / misid
    i == 4201 && return "rgba(16 , 220 , 138 , $opacity)" # Signal complementary
    i == 4305 && return "rgba(0, 208, 145, $opacity)" # green made up
    # https://brand.ucsd.edu/logos-and-brand-elements/color-palette/index.html
    # Core Colors
    i == 6001 && return "rgba(24, 43, 73, $opacity)" # UCSD Dark Blue Pantone 2767
    i == 6002 && return "rgba(0, 98, 155, $opacity)" # UCSD Ocean Blue Pantone 3015
    i == 6003 && return "rgba(198, 146, 20, $opacity)" # UCSD Kelp Pantone 1245
    i == 6004 && return "rgba(255, 205, 0, $opacity)" # UCSD Bright Gold Pantone 116
    # Accent Colors
    i == 6005 && return "rgba(0, 198, 215, $opacity)" # UCSD Cyan Pantone 3115
    i == 6006 && return "rgba(110, 150, 59, $opacity)" # UCSD Green Pantone 7490
    i == 6007 && return "rgba(243, 229, 0, $opacity)" # UCSD Bright Yellow Pantone 3945
    i == 6008 && return "rgba(252, 137, 0, $opacity)" # UCSD Orange Pantone 144
end

