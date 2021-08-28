"""
```@setup hide
    colors(i; opacity)

Custom colors
```
"""
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
    # Signal colors
    i == 8001 && return "rgba(255, 0, 0, $opacity)" # Red
    i == 8002 && return "rgba(0, 0, 255, $opacity)" # Blue
    i == 8003 && return "rgba(255, 0, 255, $opacity)" # Magenta
    i == 8004 && return "rgba(255, 165, 0, $opacity)" # Bright Orange
end

