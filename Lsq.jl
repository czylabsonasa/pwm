# based on 
# https://docs.makie.org/stable/examples/blocks/slider/
# and
# https://docs.makie.org/stable/api/#SliderGrid

module Lsq
  using Tools

  using GLMakie


###########################################
# line
###########################################

  function lsq_line_mkdata()
    a0,a1=6.0*rand(3).-3.0
    M=20
    rx=6.0*rand(M).-3.0
    ry=a0 .+ a1*rx .+ randn(M)
    A=hcat(fill(1,M),rx)
    b0,b1=(A'*A)\(A'*ry)
    optδ=sum((b0 .+ b1*rx .- ry).^2)
    mini,maxi=extrema(rx)
    xx=LinRange(mini-1,maxi+1,10)  
    opty=b0 .+ b1*xx 
    (b0=b0,b1=b1,rx=rx,ry=ry,M=M,optδ=optδ,opty=opty,xx=xx)
  end

  function lsq_line()
    pname="random point set+least squares error of a line"
    data=lsq_line_mkdata()

    set_theme!(backgroundcolor = :gray90)

    fig = Figure()

    obs_show=Observable(false)
    obs_title=Observable("init")
    ax = Axis(
      fig[1, 1],
      title=obs_title,
      titlefont="TeX Mono",
    )

    sg = SliderGrid(
      fig[2, 1],
      (label = "intercept", range = -10:0.01:10, format = "{:.2f}", startvalue = 0),
      (label = "slope", range = -10:0.01:10, format = "{:.2f}", startvalue = 1),
    )

    btn=Button(
      fig[2, 2], 
      label=lift(obs_show) do v
        v ? "HIDE" : "SHOW"
      end,
      font="TeX Mono",
      # tellwidth=true,
    )
    on(btn.clicks) do _
      obs_show[]=!obs_show[]
    end


    yy = lift(sg.sliders[1].value, sg.sliders[2].value) do A0, A1
      obs_title[]="actual distance"*lpad(string(sum((A0 .+ A1*data.rx .- data.ry).^2)|>mround),10)
      A0 .+ A1*data.xx
    end

    lines!(ax, data.xx, yy, color = :blue)
    lines!(ax, data.xx, data.opty, color = :green, visible=obs_show, linewidth=3)
    scatter!(ax, data.rx, data.ry, markersize=10)
    limits!(ax, -10, 10, -10, 10)
    hlines!(ax, [0] , linewidth=2, color=:black)
    vlines!(ax, [0] , linewidth=2, color=:black)

    Label(
      fig[0,1],
      """$(pname)
      
      opt. coeff.: b0=$(data.b0|>mround), b1=$(data.b1|>mround)
      opt dist.: $(data.optδ|>mround)
      """,
      fontsize=22,
      tellwidth=false
    )
    current_figure()
  end

  export lsq_line

###########################################
# quad
###########################################
  function lsq_quad_mkdata()
    a0,a1,a2=6.0*rand(3).-3.0
    M=20
    rx=6.0*rand(M).-3.0
    ry=a2*rx.^2 .+ a1*rx .+ a0 .+ randn(M)
    A=hcat(fill(1,M),rx,rx.^2)
    b0,b1,b2=(A'*A)\(A'*ry)
    optδ=sum((b0 .+ b1*rx .+ b2*rx.^2 .- ry).^2)
    mini,maxi=extrema(rx)
    xx=LinRange(mini-1,maxi+1,50)  
    opty=b0 .+ b1*xx .+ b2*xx.^2  
    (b0=b0,b1=b1,b2=b2,rx=rx,ry=ry,M=M,optδ=optδ,opty=opty,xx=xx)
  end

  function lsq_quad()
    pname="random point set+least squares error of a parabola"
    data=lsq_quad_mkdata()

    set_theme!(backgroundcolor = :gray90)

    fig = Figure()

    obs_show=Observable(false)
    obs_title=Observable("init")
    ax = Axis(
      fig[1, 1],
      title=obs_title,
      titlefont="TeX Mono",
    )

    sg = SliderGrid(
      fig[2, 1],
      (label = "A0", range = -10:0.01:10, format = "{:.2f}", startvalue = 0),
      (label = "A1", range = -10:0.01:10, format = "{:.2f}", startvalue = 0),
      (label = "A2", range = -10:0.01:10, format = "{:.2f}", startvalue = 1),
    )

    btn=Button(
      fig[2, 2], 
      label=lift(obs_show) do v
        v ? "HIDE" : "SHOW"
      end,
      font="TeX Mono",
      # tellwidth=true,
    )
    on(btn.clicks) do _
      obs_show[]=!obs_show[]
    end


    yy = lift(sg.sliders[1].value, sg.sliders[2].value, sg.sliders[3].value) do A0, A1, A2
      obs_title[]="actual distance"*lpad(string(sum((A0 .+ A1*data.rx .+ A2*data.rx.^2 .- data.ry).^2)|>mround),10)
      A0 .+ A1*data.xx .+ A2*data.xx.^2
    end

    lines!(ax, data.xx, yy, color = :blue)
    lines!(ax, data.xx, data.opty, color = :green, visible=obs_show, linewidth=3)
    scatter!(ax, data.rx, data.ry, markersize=10)
    limits!(ax, -10, 10, -10, 10)
    hlines!(ax, [0] , linewidth=2, color=:black)
    vlines!(ax, [0] , linewidth=2, color=:black)

    Label(
      fig[0,1],
      """$(pname)
      
      opt. coeff.: b0=$(data.b0|>mround), b1=$(data.b1|>mround), b2=$(data.b2|>mround)
      opt dist.: $(data.optδ|>mround)
      """,
      fontsize=22,
      tellwidth=false
    )

    current_figure()
  end # of lsq_quad

  export lsq_quad

end


