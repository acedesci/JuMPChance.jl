using Base.Meta

import JuMP.@gendict

macro indepnormal(m, x, mean, var)
    m = esc(m)
    @assert isexpr(mean,:kw) && mean.args[1] == :mean
    @assert isexpr(var,:kw) && var.args[1] == :var
    mean = esc(mean.args[2])
    var = esc(var.args[2])

    if isa(x,Symbol)
        # easy case
        return quote
            $(esc(x)) = IndepNormal($m,$mean,$var,$(string(x)))
            nothing
        end
    else
        if !isexpr(x,:ref)
            error("Syntax error: Expected $var to be of form var[...]")
        end

        refcall, idxvars, idxsets, idxpairs, condition = JuMP.buildrefsets(x)
        varname = JuMP.getname(x)

        varstr = :(string($(string(varname)),"["))
        for idxvar in idxvars
            push!(varstr.args,:(string($(esc(idxvar)))))
            push!(varstr.args,",")
        end
        deleteat!(varstr.args,length(varstr.args))
        push!(varstr.args,"]")

        code = :( $(refcall) = IndepNormal($m, $mean, $var, $varstr ) )
        looped = JuMP.getloopedcode(x, code, condition, idxvars, idxsets, idxpairs, :IndepNormal)
        return quote
            $looped
            $(esc(varname))
        end
    end
end

macro defIndepNormal(m, x, mean, var)
    Base.warn_once("@defIndepNormal is deprecated. Use @indepnormal instead")
    return :(@indepnormal($(esc(m)),$(esc(x)),$(esc(mean)),$(esc(var))))
end
export @defIndepNormal

# Extensions to make JuMP macros work with chance constraints

function JuMP.constructconstraint!(faff::CCAffExpr, sense::Symbol)
    if sense == :(<=) || sense == :≤
        return ChanceConstr(faff, :(<=))
    elseif sense == :(>=) || sense == :≥
        return ChanceConstr(faff, :(>=))
    elseif sense == :(==)
        error("Equality chance constraints not supported")
    end
    error("Unrecognized constraint type $sense")
end

JuMP.constructconstraint!(faff::CCAffExpr, lb::AffExpr, ub::AffExpr) = TwoSideChanceConstr(faff, lb, ub)
JuMP.constructconstraint!(faff::CCAffExpr, lb, ub) = TwoSideChanceConstr(faff, convert(AffExpr,lb), convert(AffExpr,ub))
