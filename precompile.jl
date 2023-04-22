# this script was used to create the sysimage
using GLMakie
x=range(0,10,length=100)
y=sin.(x)
lines(x,y)
scatter!(y,x)
display(current_figure())
