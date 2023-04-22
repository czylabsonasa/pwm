module NumInt
  using GLMakie, Tools, LaTeXStrings
###########################################
# mkdata
###########################################
  function mkdata_numint(fun)
    if fun=="sin(x)"
      a=0.0
      b=pi
      xx=LinRange(a,b,100)
      f=x->sin(x)
      yy=f.(xx)
      exact=2.0
      desc=L"\int_{0}^{\pi} \sin(x)\mathrm{d}x"*"=$(exact)"
      limits=(-0.1,pi+0.1,-0.1,1.1)
    elseif fun=="x^3"
      a=-1
      b=2
      xx=LinRange(a,b,100)
      f=x->x^3
      yy=f.(xx)
      exact=15/4
      desc=L"\int_{-1}^{2} x^3 \mathrm{d}x"*"=$(exact)"
      limits=(-1.1,2.1,-1.1,8.1)
    elseif fun=="x*sin(x^2)"
      a=0
      b=3
      xx=LinRange(a,b,100)
      f=x->x*sin(x^2)
      yy=f.(xx)
      exact=0.9555651
      desc=L"\int_{0}^{3} x~ \sin(x^2)\mathrm{d}x"*"=$(exact)"
      limits=(-0.1,3.1,-3.1,3.1)
    elseif fun=="x*sin(5x)"
      a=0
      b=3
      xx=LinRange(a,b,100)
      f=x->x*sin(5*x)
      yy=f.(xx)
      exact=0.481824
      desc=L"\int_{0}^{3} x~ \sin(5x)\mathrm{d}x"*"=$(exact)"
      limits=(-0.1,3.1,-3.1,3.1)
    else
      nothing
    end
    (a=a,b=b,f=f,desc=desc,xx=xx,yy=yy,exact=exact,limits=limits)
  end # of mkdata_numint

 
###########################################
# numint_mid
###########################################
  function numint_mid()
    pname="integral approx by mid-point method"

    #data=mkdata("sin")
    data=mkdata_numint("x^3")

    set_theme!(backgroundcolor = :gray90)

    fig = Figure()
    obs_title=Observable("init")

    ax = Axis(
      fig[1, 1],
      title=obs_title,
      titlefont="TeX Mono",
      xgridvisible=false,
      ygridvisible=false,  
    )

    lines!(ax, data.xx, data.yy, color = :blue)
    limits!(ax, data.limits...)
    hlines!(ax, [0] , linewidth=2, color=:black)
    vlines!(ax, [0] , linewidth=2, color=:black)



    sg = SliderGrid(
      fig[2, 1],
      (label = "delta", range = -10:10, format = "{:d}", startvalue = 1),
    )

    m=1
    delta=Observable(1)

    btn=Button(
      fig[2, 2], 
      label="GO",
      font="TeX Mono",
    )

    on(sg.sliders[1].value, update=true) do v
      delta[]=v
    end


    plt1=nothing
    plt2=nothing
    on(btn.clicks,update=true) do _
      mm=m+delta.val
      (mm<2) && (mm=2)
      (mm>200) && (mm=200)
      (m==mm)&&return
      m=mm

      tmp=LinRange(data.a, data.b, m)
      x=vcat(tmp[1], repeat(tmp[2:end-1], inner=2), tmp[end])
      h=(data.b-data.a)/(m-1)
      mid=data.a +0.5*h .+ (0:m-2)*h
      fmid=data.f.(mid)
      I=h*sum(fmid)
      yupper=repeat(fmid, inner=2)
      ylower=fill(0.0,2*m-2)
      if plt1!==nothing
        delete!(ax,plt1)
        delete!(ax,plt2)        
      end
      plt1=band!(
        ax,
        x, ylower, yupper, 
        color=(:black,0.4),
      )
      pts=vcat( 
        [(Point2f(x[i],ylower[i]),Point2f(x[i],yupper[i])) for i in 1:length(x)], 
        [(Point2f(x[i],yupper[i]),Point2f(x[i+1],yupper[i])) for i in 1:length(x)-1]
      )
      plt2=linesegments!(
        ax,
        pts,
        color=(:black,0.6),
      )
      obs_title[]="m:"*lpad(string(m),3)*", approx:"*lpad(mround(I),5)*", error:"*lpad(mround(abs(I-data.exact)),5)
    end



    Label(
      fig[-1,1],
      pname,
      fontsize=22,
      tellwidth=false
    )

    Label(
      fig[0,1],
      latexstring(data.desc,"=$(data.exact)"),
      fontsize=22,
      tellwidth=false
    )


    current_figure()
  end # of numint_mid
  export numint_mid

###########################################
# numint_trap
###########################################
  function numint_trap()
  
    _lab1_title="integral approx by trapesoidal method"
    _lab2_title=Observable(L"init")
    m=2                    # number base poitns
    delta=Observable(1)     # the extent of change for 'm'
    plt0=[]
    plt1=nothing
    plt2=nothing
    _ax_title=Observable("init")
    data=nothing
    

    #data=mkdata("sin")
    #data=mkdata_numint("x^3")

    fig=Figure()
    _lab1=fig[1,1:8]; _menu=fig[1:2,9:10];
    _lab2=fig[2,1:8]; ####################
    _ax  =fig[3:12,1:10];#################
    _sld =fig[13,1:8]; _btn=fig[13,9:10];

    set_theme!(backgroundcolor = :gray90)



    ax = Axis(
      _ax,
      title=_ax_title,
      titlefont="TeX Mono",
      xgridvisible=false,
      ygridvisible=false,  
    )

    
    function plotini()
      for p in plt0
        delete!(ax, p)
      end
      plt0=[]
      limits!(ax, data.limits...)
      push!(
        plt0,
        lines!(ax, data.xx, data.yy, color = :blue),
        hlines!(ax, [0] , linewidth=2, color=:black),
        vlines!(ax, [0] , linewidth=2, color=:black),
      )
    end
    
    function plotupd()
      x=LinRange(data.a, data.b, m)
      h=(data.b-data.a)/(m-1)
      fx=data.f.(x)
      I=h*(sum(fx)-0.5*(fx[1]+fx[end]))
      yupper=fx
      ylower=fill(0.0,m)
      if plt1!==nothing
        delete!(ax,plt1)
        delete!(ax,plt2)        
      end
      plt1=band!(
        ax,
        x, ylower, yupper, 
        color=(:black,0.4),
      )
      pts=[(Point2f(x[i],ylower[i]),Point2f(x[i],yupper[i])) for i in 1:length(x)]

      plt2=linesegments!(
        ax,
        pts,
        color=(:black,0.6),
      )
      _ax_title[]="m:"*lpad(string(m),3)*", approx:"*lpad(mround(I),6)*", error:"*lpad(mround(abs(I-data.exact)),6)
    end
    
    sg = SliderGrid(
      _sld,
      (label = "delta", range = -10:10, format = "{:d}", startvalue = 1),
    )

    menu = Menu(
      _menu, 
      options = ["sin(x)", "x^3", "x*sin(x^2)", "x*sin(5x)"],
      fontsize=16,
    )      
    on(menu.selection,update=true) do fun
      data=mkdata_numint(fun)
      _lab2_title[]=latexstring(data.desc,"=$(data.exact)")
      m=2
      delta[]=1
      set_close_to!(sg.sliders[1],1)
      plotini()
      plotupd()
    end



    btn=Button(
      _btn, 
      label="GO",
      font="TeX Mono",
      fontsize=16,
    )

    on(sg.sliders[1].value, update=true) do v
      delta[]=v
    end


#    on(btn.clicks,update=true) do _
    on(btn.clicks) do _
      mm=m+delta.val
      (mm<2) && (mm=2)
      (mm>200) && (mm=200)
      (m==mm)&&return
      m=mm
      plotupd()
    end


    Label(
      _lab1,
      _lab1_title,
      fontsize=22,
      tellwidth=false
    )

    Label(
      _lab2,
      #latexstring(data.desc,"=$(data.exact)"),
      _lab2_title,
      fontsize=22,
      tellwidth=false
    )

    current_figure()
  end # of numint_trap
  export numint_trap


  # drop out the slider
  function numint_trap2()
  
    _lab1_title=latexstring("trapesoidal method  ", L"|error|\le \frac{C_{a,b,f}}{m^2}")
    _lab2_title=Observable(L"init")
    m=1                    # number sub-intervals
    plt0=[]
    plt1=nothing
    plt2=nothing
    _ax_title=Observable("init")
    data=nothing
    

    #data=mkdata("sin")
    #data=mkdata_numint("x^3")

    fig=Figure()
    _lab1=fig[1,1:8]; _menu=fig[1:2,9:10];
    _lab2=fig[2,1:8]; ####################
    _ax  =fig[3:12,1:10];#################
    subfig=fig[13,6:10]=GridLayout()
    _btnmul =subfig[1,1]; _btnplus=subfig[1,2];
    _btndiv =subfig[2,1]; _btnminus=subfig[2,2];
    

    set_theme!(backgroundcolor = :gray90)


    ax = Axis(
      _ax,
      title=_ax_title,
      titlefont="TeX Mono",
      xgridvisible=false,
      ygridvisible=false,  
      tellheight=true,
    )

    
    function plotini()
      for p in plt0
        delete!(ax, p)
      end
      plt0=[]
      limits!(ax, data.limits...)
      push!(
        plt0,
        lines!(ax, data.xx, data.yy, color = :blue),
        hlines!(ax, [0] , linewidth=2, color=:black),
        vlines!(ax, [0] , linewidth=2, color=:black),
      )
    end
    
    function plotupd()
      x=LinRange(data.a, data.b, m+1)
      h=(data.b-data.a)/m
      fx=data.f.(x)
      I=h*(sum(fx)-0.5*(fx[1]+fx[end]))
      yupper=fx
      ylower=fill(0.0,m+1)
      if plt1!==nothing
        delete!(ax,plt1)
        delete!(ax,plt2)        
      end
      plt1=band!(
        ax,
        x, ylower, yupper, 
        color=(:black,0.1),
      )
      pts=vcat(
        [(Point2f(x[i],ylower[i]),Point2f(x[i],yupper[i])) for i in 1:length(x)],
        [(Point2f(x[i],yupper[i]),Point2f(x[i+1],yupper[i+1])) for i in 1:length(x)-1]
      )

      plt2=linesegments!(
        ax,
        pts,
        color=(:black,0.7),
      )
      _ax_title[]="m:"*lpad(string(m),3)*", approx:"*lpad(mround(I),10)*", error:"*lpad(mround(abs(I-data.exact)),10)
    end
    
    menu = Menu(
      _menu, 
      options = ["sin(x)", "x^3", "x*sin(x^2)", "x*sin(5x)"],
      fontsize=16,
      tellwidth=false,
    )      
    on(menu.selection,update=true) do fun
      data=mkdata_numint(fun)
      _lab2_title[]=data.desc
      m=1
      plotini()
      plotupd()
    end



    btnplus=Button(
      _btnplus, 
      label="add 1",
      font="TeX Mono",
      fontsize=16,
      tellwidth=false,
    )

    btnminus=Button(
      _btnminus, 
      label="sub 1",
      font="TeX Mono",
      fontsize=16,
      tellwidth=false,
    )

    btnmul=Button(
      _btnmul, 
      label="mul by 2",
      font="TeX Mono",
      fontsize=16,
      tellwidth=false,
    )

    btndiv=Button(
      _btndiv, 
      label="div by 2",
      font="TeX Mono",
      fontsize=16,
      tellwidth=false,
    )


#    on(btn.clicks,update=true) do _
    on(btnplus.clicks) do _
      mm=m+1
      (mm>512) && (mm=512)
      (m==mm)&&return
      m=mm
      plotupd()
    end
    on(btnminus.clicks) do _
      mm=m-1
      (mm<1) && (mm=1)
      (m==mm)&&return
      m=mm
      plotupd()
    end

    on(btnmul.clicks) do _
      mm=m*2
      (mm>512) && (mm=512)
      (m==mm)&&return
      m=mm
      plotupd()
    end
    on(btndiv.clicks) do _
      mm=m÷2
      (mm<1) && (mm=1)
      (m==mm)&&return
      m=mm
      plotupd()
    end




    Label(
      _lab1,
      _lab1_title,
      fontsize=22,
      tellwidth=false
    )

    Label(
      _lab2,
      _lab2_title,
      fontsize=22,
      tellwidth=false
    )

    current_figure()
  end # of numint_trap2
  export numint_trap2


#############################################################
# restructure
#############################################################


  function trap()
    pname=L"\text{trapesoidal method}~~~|error|\le \frac{C_{a,b,f}}{m^2}"
    function plotupd(ax,ax_title,data,m,plt)
      x=LinRange(data.a, data.b, m+1)
      h=(data.b-data.a)/m
      fx=data.f.(x)
      I=h*(sum(fx)-0.5*(fx[1]+fx[end]))
      yupper=fx
      ylower=fill(0.0,m+1)
      for p in plt
        delete!(ax,p)
      end
      plt1=band!(
        ax,
        x, ylower, yupper, 
        color=(:black,0.1),
      )
      pts=vcat(
        [(Point2f(x[i],ylower[i]),Point2f(x[i],yupper[i])) for i in 1:length(x)],
        [(Point2f(x[i],yupper[i]),Point2f(x[i+1],yupper[i+1])) for i in 1:length(x)-1]
      )

      plt2=linesegments!(
        ax,
        pts,
        color=(:black,0.7),
      )
      plt=[plt1,plt2]
      ax_title[]="m:"*lpad(string(m),3)*", approx:"*lpad(mround(I),10)*", error:"*lpad(mround(abs(I-data.exact)),10)

      plt
    end
    
    
    pname,plotupd
  end # trap
  export trap
  

  function numint(method="")
    pname, plotupd=if method=="trap"
      trap()
    else
      println("""call:\nnumint(method)\nwhere method in {"trap", "mid", "simp"}""")
      return
    end
    
    _lab1_title=pname
    _lab2_title=Observable(L"init")
    m=1                    # number sub-intervals
    plt0=[]
    plt1=[]
    _ax_title=Observable("init")
    data=nothing
    

    #data=mkdata("sin")
    #data=mkdata_numint("x^3")

    fig=Figure()
    _lab1=fig[1,1:8]; _menu=fig[1:2,9:10];
    _lab2=fig[2,1:8]; ####################
    _ax  =fig[3:12,1:10];#################
    subfig=fig[13,6:10]=GridLayout()
    _btnmul =subfig[1,1]; _btnplus=subfig[1,2];
    _btndiv =subfig[2,1]; _btnminus=subfig[2,2];
    

    set_theme!(backgroundcolor = :gray90)

    ax = Axis(
      _ax,
      title=_ax_title,
      titlefont="TeX Mono",
      xgridvisible=false,
      ygridvisible=false,  
      tellheight=true,
    )

    
    function plotini()
      for p in plt0
        delete!(ax, p)
      end
      plt0=[]
      limits!(ax, data.limits...)
      push!(
        plt0,
        lines!(ax, data.xx, data.yy, color = :blue),
        hlines!(ax, [0] , linewidth=2, color=:black),
        vlines!(ax, [0] , linewidth=2, color=:black),
      )
    end
    
    
    menu = Menu(
      _menu, 
      options = ["sin(x)", "x^3", "x*sin(x^2)", "x*sin(5x)"],
      fontsize=16,
      tellwidth=false,
    )      
    on(menu.selection,update=true) do fun
      data=mkdata_numint(fun)
      _lab2_title[]=data.desc
      m=1
      plotini()
      plt1=plotupd(ax,_ax_title,data,m,plt1)
    end



    btnplus=Button(
      _btnplus, 
      label="add 1",
      font="TeX Mono",
      fontsize=16,
      tellwidth=false,
    )

    btnminus=Button(
      _btnminus, 
      label="sub 1",
      font="TeX Mono",
      fontsize=16,
      tellwidth=false,
    )

    btnmul=Button(
      _btnmul, 
      label="mul by 2",
      font="TeX Mono",
      fontsize=16,
      tellwidth=false,
    )

    btndiv=Button(
      _btndiv, 
      label="div by 2",
      font="TeX Mono",
      fontsize=16,
      tellwidth=false,
    )


#    on(btn.clicks,update=true) do _
    on(btnplus.clicks) do _
      mm=m+1
      (mm>512) && (mm=512)
      (m==mm)&&return
      m=mm
      plt1=plotupd(ax,_ax_title,data,m,plt1)
    end
    on(btnminus.clicks) do _
      mm=m-1
      (mm<1) && (mm=1)
      (m==mm)&&return
      m=mm
      plt1=plotupd(ax,_ax_title,data,m,plt1)
    end

    on(btnmul.clicks) do _
      mm=m*2
      (mm>512) && (mm=512)
      (m==mm)&&return
      m=mm
      plt1=plotupd(ax,_ax_title,data,m,plt1)
    end
    on(btndiv.clicks) do _
      mm=m÷2
      (mm<1) && (mm=1)
      (m==mm)&&return
      m=mm
      plt1=plotupd(ax,_ax_title,data,m,plt1)
    end




    Label(
      _lab1,
      _lab1_title,
      fontsize=22,
      tellwidth=false
    )

    Label(
      _lab2,
      _lab2_title,
      fontsize=22,
      tellwidth=false
    )

    current_figure()
  end # of numint(method)
  export numint


end
