# Emit "get NAME" / "set NAME" for every _ENV access in a luac -l -l listing.
{
    op = $3; a = $4; b = $5; c = $6
    name = ""
    if (match($0, /"[A-Za-z_0-9]+"$/)) name = substr($0, RSTART + 1, RLENGTH - 2)
    if (op == "GETTABUP" && $0 ~ /; _ENV "/) print "get", name
    else if (op == "SETTABUP" && $0 ~ /; _ENV "/) print "set", name
    else if (op == "GETUPVAL" && $0 ~ /; _ENV$/) env[a] = 1
    else if (op == "LOADK" && name != "") key[a] = name
    else if (op == "GETTABLE" && (b in env) && (c in key)) print "get", key[c]
    else if (op == "SETTABLE" && (a in env) && (b in key)) print "set", key[b]
    else if (op == "GETFIELD" && (b in env)) print "get", name
    else if (op == "SETFIELD" && (a in env)) print "set", name
    if (op != "GETUPVAL" && op != "LOADK") { delete env; delete key }
    if (op == "GETUPVAL" || op == "LOADK") {} 
}
