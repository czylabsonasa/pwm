# this script was used to create the sysimage
#using PackageCompiler
#create_sysimage(:GLMakie; sysimage_path="sysimage.so",precompile_execution_file="precompile.jl")


using GLMakie
x=range(0,10,length=100)
y=sin.(x)
lines(x,y)
scatter!(y,x)
display(current_figure())
