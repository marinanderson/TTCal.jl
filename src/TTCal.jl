# Copyright (c) 2015 Michael Eastwood
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

__precompile__()

module TTCal

export PointSource
export readsources, writesources

export genvis
export getspec
export fitvis
export subsrc!

export bandpass
export polcal
export peel!
export applycal!

using JSON
using CasaCore.Quanta
using CasaCore.Measures
using CasaCore.Tables
using MeasurementSets

const c = 2.99792e+8
include("rungekutta.jl")

include("sourcemodel.jl")
include("fringepattern.jl")
include("genvis.jl")
include("getspec.jl")
include("fitvis.jl")
include("subsrc.jl")

abstract Calibration
include("bandpass.jl")
include("applycal.jl")
include("peel.jl")
include("io.jl")

#include("polcal.jl")
#include("diagnose.jl")

function run_bandpass(args)
    ms = Table(ascii(args["--input"]))
    sources = readsources(args["--sources"])
    maxiter = haskey(args,"--maxiter")? args["--maxiter"] : 20
    tolerance = haskey(args,"--tolerance")? args["--tolerance"] : 1e-4
    force_imaging_columns = haskey(args,"--force-imaging")
    cal = bandpass(ms,sources,
                   maxiter=maxiter,
                   tolerance=tolerance,
                   force_imaging_columns=force_imaging_columns)
    write(args["--output"],cal)
    cal
end

#function run_polcal(args)
#    ms = Table(ascii(args["--input"]))
#    sources = haskey(args,"--sources")? readsources(args["--sources"]) : Source[]
#    maxiter = haskey(args,"--maxiter")? args["--maxiter"] : 20
#    tol = haskey(args,"--tolerance")? args["--tolerance"] : 1e-4
#    criteria = StoppingCriteria(maxiter,tol)
#    force_imaging_columns = haskey(args,"--force-imaging")
#    model_already_present = !haskey(args,"--sources")
#    gains,gain_flags = polcal(ms,sources,criteria,
#                              force_imaging_columns=force_imaging_columns,
#                              model_already_present=model_already_present)
#    write_gains(args["--output"],gains,gain_flags)
#    gains, gain_flags
#end

function run_peel(args)
    ms = Table(ascii(args["--input"]))
    sources = readsources(args["--sources"])
    minuvw = haskey(args,"--minuvw")? args["--minuvw"] : 15.0
    peel!(ms,sources,minuvw=minuvw)
end

function run_applycal(args)
    cal = read(args["--calibration"])
    force_imaging_columns = haskey(args,"--force-imaging")
    apply_to_corrected = haskey(args,"--corrected")
    for input in args["--input"]
        ms = Table(ascii(input))
        applycal!(ms,cal,
                  force_imaging_columns=force_imaging_columns,
                  apply_to_corrected=apply_to_corrected)
    end
    nothing
end

#function run_diagnose(args)
#    diagnose(args["--calibration"])
#end

end

