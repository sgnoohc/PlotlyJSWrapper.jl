"""
    default_options = Dict{Symbol, Any}

Default options of all the togglable options are documented here.

# Output file name

    :outputname => "plot.pdf", # or "plot.{pdf,png}" or "". TODO create output dir if not exist

# Axes and labeling

    :ratiotitle => "Data/MC"
    :xaxistitle => "variable [unit]"
    :yaxistitle => "Events"

    :ratiotitlesize => 29

# Axes scale and ranges

    :yrange => []
    :xrange => []
    :ratiorange => [0, 2]
    :yminclipnegative => true, # Clip minimum at 0
    :ymaxscale => 1.8 # Multiplicative factor to ymax points across all histograms

# Legend labels

    :backgroundlabels => []
    :signallabels => []
    :datalabels => ["Data"]

# Histogram colors

    :datacolors => ["black", "red", "blue", "orange", "green", "purple", "gray"]
    :backgroundcolors => [4020, 4023, 4021, 4024, 2001, 6004, ... , (many more)]
    :signalcolors => repeat([8001, 8002, 8003, 8004],10)
    :stackedsignalopacity => 0.6 # Set the opacity of stacked signal fill

Color indexs are defined in [https://github.com/sgnoohc/PlotlyJSWrapper.jl/blob/main/src/colors.jl](@ref).

# LHC Experiment related labels

    # Currently only "CMS" label implemented
    :addcmsextralabel => true # To add extra label
    :cmsextralabeltext => "Preliminary" # Label to be added next to "CMS"
    :showbeaminfo => true # Show lumi and energy
    :lumivalue => 137
    :comenergy => 13

# Extra labels settings

    :totalsystlabel => ["+1σ", "-1σ"]

# Extra operations

    :dofit => false # Scales all background such that integral is same as `data[1]` histogram
    :stacksignals => false # Stacks signals on top of total background
    :showsignalsinratio => false # Show signals above unity line in ratio panel
    :hideratio => false # Hide the ratio panel below
    :poissonerror => false # Make the data error poisson
    :showtotal => true # Show total background line
    :showtotallegend => true # Show total background line legend item

    # To provide a custom poisson error treatment lambda
    # Must be of the form where a count `x` is provided and mapped to `[upper, lower]` error
    # e.g.  x -> [sqrt(x+0.25)+0.5, sqrt(x+0.25)-0.5]
    # default option is set to `nothing` and when not provided the above lambda will be used
    :poissonerrorfunc => nothing

# Significance (or other figure of merit) scans

    # Define the "figure of merit"
    # Following are available:
    # ("soverb" | "soversqrtb" | "soversqrtsplusb" | "llsignif" | "custom")
    :fom => "soversqrtb" # Default figure of merit is S/√B

    # if :fom => "custom" then, a custom anonymous function (lambda) must be provided
    # The lambda must be of x->something format where `x` is assumed to be a struct of the following
    #   struct BinInfo
    #       s::Float64   # signal yield
    #       se::Float64  # signal yield error
    #       b::Float64   # totalbkg yield
    #       be::Float64  # totalbkg yield error
    #       d::Float64   # data yield
    #       de::Float64  # data yield error (i.e. sqrt(N))
    #       ibin::Int64  # bin index
    #   end
    # Below is an example of how one might provide a custom function
    # e.g. User wants a custom fom defining s/sqrt(s+b+berror^2+(0.15*b)^2) (to mimic 15% systematics)
    #      then a following lambda must be provided:
    #
    #          :customfom => x -> x.s / sqrt(x.b + x.be^2 + (0.15*x.b)^2)
    #
    # N.B. only the first element of provided `data` histogram array can be used
    #
    # The default value of the option when not being used is set to
    :customfom => nothing

    # Three options: compute fom per bin or scan from left or right
    :showfomperbin => false # Show figure of merit (fom) per bin
    :showfomfromleft => false # Show fom cumulatively cut from left
    :showfomfromright => false # Show fom cumulatively cut from right

"""
const default_options = Dict(
                            :outputname => "plot.pdf",
                            :dofit => false,
                            :ratiotitle => "Data/MC",
                            :ratiotitlesize => 29,
                            :ymaxscale => 1.8,
                            :yminclipnegative => true,
                            :yrange => [],
                            :xrange => [],
                            :ratiorange => [],
                            :xaxistitle => "variable [unit]",
                            :yaxistitle => "Events",
                            :addcmsextralabel => true,
                            :cmsextralabeltext => "Preliminary",
                            :showbeaminfo => true,
                            :lumivalue => 137,
                            :comenergy => 13,
                            :datacolors => ["black", "red", "blue", "orange", "green", "purple", "gray"],
                            :backgroundcolors => [4020, 4023, 4021, 4024, 2001, 6004, 11005, 11004, 11003, 11002, 11001, 11000, 11011, 11012, 11013, 11014, 11015, 3001, 3000, 3011, 5001, 5002, 5003, 5004, 5005, 7000, 7001, 7002, 7003, 7004, 7005, 7006, 7007, 7011, 7012, 7013, 7014, 7015, 7016, 7017, 9001, 9002, 9003, 9004, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 4001, 4002, 4003, 4004, 4005, 4006, 4007, 4008, 4009, 4010, 4011, 4012, 4013, 4014, 4015, 4016, 4017, 4018, 4019, 4020, 4021, 4022, 4023, 4024, 4101, 4102, 4103, 4104, 4201, 4305, 6002, 6003, 6004, 6005, 6006, 6007, 6008,],
                            :signalcolors => repeat([8001, 8002, 8003, 8004],10),
                            :stackedsignalopacity => 0.6,
                            :backgroundlabels => [],
                            :signallabels => [],
                            :datalabels => ["Data"],
                            :totalsystlabel => ["+1σ", "-1σ"],
                            :stacksignals => false,
                            :showsignalsinratio => false,
                            :hideratio => false,
                            :fom => "soversqrtb",
                            :customfom => nothing,
                            :showfomperbin => false,
                            :showfomfromleft => false,
                            :showfomfromright => false,
                            :poissonerror => false,
                            :poissonerrorfunc => nothing,
                            :showtotal => true,
                            :showtotallegend => false,
                            )
