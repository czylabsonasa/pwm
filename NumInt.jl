module NumInt
  using GLMakie, Tools, LaTeXStrings
###########################################
# mkdata
###########################################
  function mkdata_numint(fun)
    if fun=="sin(x)"
      a=0.0
      b=pi
      xx=LinRange(a,b,200)
      f=x->sin(x)
      yy=f.(xx)
      exact=2.0
      desc=L"\int_{0}^{\pi} \sin(x)\mathrm{d}x"*"=$(exact)"
      limits=(-0.1,pi+0.1,-0.1,1.1)
    elseif fun=="x^3"
      a=-1
      b=2
      xx=LinRange(a,b,200)
      f=x->x^3
      yy=f.(xx)
      exact=15/4
      desc=L"\int_{-1}^{2} x^3 \mathrm{d}x"*"=$(exact)"
      limits=(-1.1,2.1,-1.1,8.1)
    elseif fun=="x*sin(x^2)"
      a=0
      b=3
      xx=LinRange(a,b,200)
      f=x->x*sin(x^2)
      yy=f.(xx)
      exact=0.9555651
      desc=L"\int_{0}^{3} x~ \sin(x^2)\mathrm{d}x"*"=$(exact)"
      limits=(-0.1,3.1,-3.1,3.1)
    elseif fun=="x*sin(5x)"
      a=0
      b=3
      xx=LinRange(a,b,200)
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

 
#############################################################
# restructured (old -> Numint0)
#############################################################


#############################################################
# mid
#############################################################

  function mid()
    pname=L"\text{mid-point method}~~~|error|\le \frac{C_{a,b,f}}{m^2}"
    function plotupd(ax,ax_title,data,m,plt)
      tmp=LinRange(data.a, data.b, m+1)
      x=vcat(tmp[1], repeat(tmp[2:end-1], inner=2), tmp[end])
      h=(data.b-data.a)/m
      mid=data.a +0.5*h .+ (0:m-1)*h
      fmid=data.f.(mid)
      I=h*sum(fmid)
      yupper=repeat(fmid, inner=2)
      ylower=fill(0.0,2*m)
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
        [(Point2f(x[i],yupper[i]),Point2f(x[i+1],yupper[i])) for i in 1:length(x)-1],
      )
      plt2=linesegments!(
        ax,
        pts,
        color=(:black,0.3),
      )
      plt3=linesegments!(
        ax,
        [(Point2f(mid[i],0),Point2f(mid[i],fmid[i])) for i in 1:m],
        color=(:red,0.6),
      )
      
      ax_title[]="m:"*lpad(string(m),3)*", approx:"*lpad(mround(I),5)*", error:"*lpad(mround(abs(I-data.exact)),5)

      [plt1,plt2,plt3]
    end
    pname, plotupd
  end
  export mid

#############################################################
# trap
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
        [(Point2f(x[i],0.0),Point2f(x[i],fx[i])) for i in 1:length(x)],
        [(Point2f(x[i],fx[i]),Point2f(x[i+1],fx[i+1])) for i in 1:length(x)-1]
      )

      plt2=linesegments!(
        ax,
        pts,
        color=(:red,0.6),
      )
      plt=[plt1,plt2]
      ax_title[]="m:"*lpad(string(m),3)*", approx:"*lpad(mround(I),10)*", error:"*lpad(mround(abs(I-data.exact)),10)

      plt
    end
    
    
    pname,plotupd
  end # trap
  export trap

#############################################################
# simp
#############################################################

  function simp()
    function mkquad(a,m,b,fa,fm,fb,h)
      d1=2*(fm-fa)/h
      d2=2*(fb-fm)/h
      d3=(d2-d1)/h
      x->fa+d1*(x-a)+d3*(x-a)*(x-m)
    end
  
    pname=L"\text{Simpson method}~~~|error|\le \frac{C_{a,b,f}}{m^4}"
    function plotupd(ax,ax_title,data,m,plt)
      x=range(data.a, data.b, m+1)
      h=(data.b-data.a)/m
      mid=data.a+0.5*h .+ h*(0:m-1)

      fx=data.f.(x)
      fmid=data.f.(mid)
      I=h/6*(fx[1]+2*sum(fx[2:end-1])+fx[end]+4*sum(fmid))
      
      xx=data.xx
      M=length(xx)
      yupper=fill(0.0,M)
      ylower=fill(0.0,M)

      j=1
      i=1
      while i<m+1
        q=mkquad(x[i],mid[i],x[i+1],fx[i],fmid[i],fx[i+1],h)
        while xx[j]<x[i+1]
          yupper[j]=q(xx[j])
          j+=1
        end
        i+=1
      end
      yupper[end]=fx[end]
      
      for p in plt
        delete!(ax,p)
      end
      plt1=band!(
        ax,
        xx, ylower, yupper, 
        color=(:black,0.1),
      )

      plt2=lines!(
        ax,
        xx, yupper,
        color=(:red,0.6),
      )
      

      plt3=linesegments!(
        ax,
        [(Point2f(x[i],0.0),Point2f(x[i],fx[i])) for i in 1:length(x)],
        color=(:red,0.6),
      )

      
      plt=[plt1,plt2,plt3]
      ax_title[]="m:"*lpad(string(m),3)*", approx:"*lpad(mround(I),10)*", error:"*lpad(mround(abs(I-data.exact)),10)

      plt
    end
    
    
    pname,plotupd
  end # simp
  export simp

#############################################################
# numint
#############################################################
 
  function numint(method="")
    pname, plotupd=if method=="trap"
      trap()
    elseif method=="mid"
      mid()
    elseif method=="simp"
      simp()
    else
      println("""call:\nnumint(method)\nwhere method in {"trap", "mid", "simp"}""")
      return
    end
    
    _lab1_title=pname
    _lab2_title=Observable(L"init")
    m=1                    # number of sub-intervals
    plt0=[]
    plt1=[]
    _ax_title=Observable("init")
    data=nothing
    

    # plan for the layout
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
