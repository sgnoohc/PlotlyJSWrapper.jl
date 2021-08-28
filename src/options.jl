"""
    default_options = Dict{Symbol, Any}

Default options of all the togglable options are documented here.

# Output file name

    :outputname => "plot.pdf", # TODO create output dir if not exist

# Axes title and labeling

    :ratiotitle => "Data/MC",  
    :xaxistitle => "variable [unit]",  
    :yaxistitle => "Events",  

# Axes scale and ranges

    :yrange => [],  
    :xrange => [],  
    :ratiorange => [0, 2],  
    :yminclipnegative => true, # Clip minimum at 0 
    :ymaxscale => 1.8, # Multiplicative factor to ymax points across all histograms

# Legend labels

    :backgroundlabels => [],  
    :signallabels => [],  
    :datalabels => ["Data"],  

# Histogram colors

    :datacolors => ["black", "red", "blue", "orange", "green", "purple", "gray"],  
    :backgroundcolors => [4020, 4023, 4021, 4024, 2001, 6004, ... , (many more)],  

Color indexs are defined in [src/colors.jl](@ref).

# Experiment labels

    # Currently only "CMS" label implemented
    :addpreliminarylabel => true,  
    :lumivalue => 137,  
    :comenergy => 13,  

# Extra labels settings

    :totalsystlabel => ["+1σ", "-1σ"],  

# Extraneous operations

    :dofit => false, # Scales all background such that integral is same as `data[1]` histogram

"""
const default_options = Dict(
                            :outputname => "plot.pdf",
                            :dofit => false,
                            :ratiotitle => "Data/MC",
                            :ymaxscale => 1.8,
                            :yminclipnegative => true,
                            :yrange => [],
                            :xrange => [],
                            :ratiorange => [0, 2],
                            :xaxistitle => "variable [unit]",
                            :yaxistitle => "Events",
                            :addpreliminarylabel => true,
                            :lumivalue => 137,
                            :comenergy => 13,
                            :datacolors => ["black", "red", "blue", "orange", "green", "purple", "gray"],
                            :backgroundcolors => [4020, 4023, 4021, 4024, 2001, 6004, 11005, 11004, 11003, 11002, 11001, 11000, 11011, 11012, 11013, 11014, 11015, 3001, 3000, 3011, 5001, 5002, 5003, 5004, 5005, 7000, 7001, 7002, 7003, 7004, 7005, 7006, 7007, 7011, 7012, 7013, 7014, 7015, 7016, 7017, 9001, 9002, 9003, 9004, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 4001, 4002, 4003, 4004, 4005, 4006, 4007, 4008, 4009, 4010, 4011, 4012, 4013, 4014, 4015, 4016, 4017, 4018, 4019, 4020, 4021, 4022, 4023, 4024, 4101, 4102, 4103, 4104, 4201, 4305, 6002, 6003, 6004, 6005, 6006, 6007, 6008,],
                            :backgroundlabels => [],
                            :signallabels => [],
                            :datalabels => ["Data"],
                            :totalsystlabel => ["+1σ", "-1σ"],
                            )
