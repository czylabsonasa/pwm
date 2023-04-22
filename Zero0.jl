# test: forward/backward steps

module Zero
  #GLMakie.activate!()

  using GLMakie # , LinearAlgebra

#############################################################
# bisect
#############################################################

  function bisect()

    function pltupd(ax,ax_title,a,b,f,plt)
      for p in plt["upd"]
        delete!(ax,p)
      end
      empty!(plt["upd"])

      fa,fb=f(a),f(b)
      pts=[
        (Point2f(a,0),Point2f(b,0)),
        (Point2f(a,0),Point2f(a,fa)),    
        (Point2f(b,0),Point2f(b,fb)),    
      ]
      p=linesegments!(
        ax, 
        pts,
        linewidth=2,
        color=(:red,0.4)
      )
      ax_title[]="a=$(a), b=$(b), f((a+b)/2)=$(f(0.5*(a+b)))"
      push!(plt["upd"],p)
    end


    function pltini(_ax,_ax_title,_a,_b,_f,_plt)
      for p in _plt["ini"]
        delete!(_ax,p)
      end
      empty!(_plt["ini"])

      xx=range(_a,_b,200)
      yy=_f.(xx)
      p1=lines!(
        _ax,
        xx, yy,
        color=:blue,
        
      )
      p2=hlines!(
        _ax,
        [0],
        color=(:black,0.5),
        linewidth=1,
      )
      push!(_plt["ini"],p1,p2)
      pltupd(_ax,_ax_title,_a,_b,_f,_plt)
    end


    fig=Figure(
      fonts = (; regular= "TeX Mono")
    )
    ax_title=Observable("init")
    ax=Axis(
      fig[1,1],
      xgridvisible=false,
      ygridvisible=false,
      title=ax_title,
    )
    #hidedecorations!(ax)
    hidespines!(ax)
    set_theme!(backgroundcolor = :gray90)


    a=-1; b=1
    f(x)=x^3-0.3x+0.1     

    plt=Dict("ini"=>[],"upd"=>[])
    pltini(ax,ax_title,a,b,f,plt)

    btnstep=Button(
      fig[2,2], 
      label="step",
      font="TeX Mono",
      fontsize=16,
      tellwidth=true,
    )


    on(btnstep.clicks) do _
      mid=0.5*(a+b)
      if f(a)*f(mid)<=0.0
        b=mid
      else
        a=mid
      end
      println(f(a)," ",f(b))
      pltupd(ax,ax_title,a,b,f,plt)
    end

    btnzoom=Button(
      fig[3,2], 
      label="zoom",
      font="TeX Mono",
      fontsize=16,
      tellwidth=true,
    )


    on(btnzoom.clicks) do _
      pltini(ax,ax_title,a,b,f,plt)
    end


    fig
  end # of bisect()

  export bisect

#############################################################
# bisect2 = bisect restructured
#############################################################

  function bisect2()

    function pltupd(dir,store)
      
      for p in store["pltseq"]
        delete!(store["ax"],p)
      end
      empty!(store["pltseq"])

      a,b,f=store["a"],store["b"],store["f"]
      fa,fb=f(a),f(b)
      pts=[
        (Point2f(a,0),Point2f(b,0)),
        (Point2f(a,0),Point2f(a,fa)),    
        (Point2f(b,0),Point2f(b,fb)),    
      ]
      p=linesegments!(
        ax, 
        pts,
        linewidth=2,
        color=(:red,0.4)
      )
      store["ax_title"][]="a=$(a), b=$(b), f((a+b)/2)=$(f(0.5*(a+b)))"
      push!(store["pltseq"],p)
    end


    function pltini(store)
      for p in store["pltini"]
        delete!(store["ax"],p)
      end
      empty!(store["pltini"])

      a,b,f=store["a"],store["b"],store["f"]

      xx=range(a,b,200)
      yy=f.(xx)
      p1=lines!(
        store["ax"],
        xx, yy,
        color=:blue,
      )
      p2=hlines!(
        store["ax"],
        [0],
        color=(:black,0.5),
        linewidth=1,
      )
      push!(store["pltini"],p1,p2)
      pltupd(0,store)
    end


    fig=Figure(
      fonts = (; regular= "TeX Mono")
    )
    fax=fig[1:5,:1:5]
    fleft=fig[6,1] ; fzoom=fig[6,3]; fright=fig[6,5]
    
    
    ax_title=Observable("init")
    ax=Axis(
      fax,
      xgridvisible=false,
      ygridvisible=false,
      title=ax_title,
    )
    #hidedecorations!(ax)
    hidespines!(ax)
    set_theme!(backgroundcolor = :gray90)

    a=-1; b=1
    f(x)=x^3-0.3x+0.1     

    store=Dict(
      "a"=>a,"b"=>b, 
      "f"=>f,
      "ax"=>ax, "ax_title"=>ax_title,
      "pltseq"=>[],
      "pltini"=>[]
    )
    pltini(store)

    # right
    btnright=Button(
      fright, 
      label=">>",
      font="TeX Mono",
      fontsize=16,
      tellwidth=true,
    )
    on(btnright.clicks) do _
      a,b,f=store["a"],store["b"],store["f"]

      mid=0.5*(a+b)
      if f(a)*f(mid)<=0.0
        b=mid
      else
        a=mid
      end
      println(f(a)," ",f(b))
      store["a"],store["b"]=a,b
      pltupd(0,store)
    end

    # left
    btnleft=Button(
      fleft, 
      label="<<",
      font="TeX Mono",
      fontsize=16,
      tellwidth=true,
    )
    on(btnleft.clicks) do _
      a,b,f=store["a"],store["b"],store["f"]

      mid=0.5*(a+b)
      if f(a)*f(mid)<=0.0
        b=mid
      else
        a=mid
      end
      println(f(a)," ",f(b))
      store["a"],store["b"]=a,b
      pltupd(0,store)
    end




    btnzoom=Button(
      fzoom, 
      label="+",
      font="TeX Mono",
      fontsize=16,
      tellwidth=true,
    )


    on(btnzoom.clicks) do _
      pltini(store)
    end


    fig
  end # of bisect2()

  export bisect2


  ##
  #  the plots are really deleted during the delete!(ax,...) so they cannot be reused
  ##
  
  function bisect3()

    function mkplt(ax,a,b,f, xx=[],yy=[])
      if xx==[]
        xx=range(a,b,200)
        yy=f.(xx)
      end
      p1=lines!(
        ax,
        xx, yy,
        color=:blue,
      )
      p2=hlines!(
        ax,
        [0],
        color=(:black,0.5),
        linewidth=1,
      )
      pts=[
        (Point2f(a,0),Point2f(b,0)),
        (Point2f(a,0),Point2f(a,f(a))),    
        (Point2f(b,0),Point2f(b,f(b))),    
      ]
      p3=linesegments!(
        ax, 
        pts,
        linewidth=2,
        color=(:red,0.4)
      )
      ([p1,p2,p3],[xx,yy])
    end
    
    function zoom(store)
      pos=store["pos"]
      npos=store["npos"]
      (0<pos<npos) && return
      a,b,z=store["abseq"][pos]
      f=store["f"]
      (z==true) && return

      ax=store["ax"]
      for p in store["aktplt"]
        delete!(ax,p)
      end

      pos=store["pos"]=pos+1
      npos=store["npos"]=npos+1
      store["abseq"][pos]=(a,b,true)
      store["aktplt"],store["xyseq"][pos]=mkplt(ax,a,b,f)
      store["ax_title"][]="a=$(a), b=$(b), f((a+b)/2)=$(f(0.5*(a+b)))"
     end

    function right(store)
      pos=store["pos"]
      npos=store["npos"]
      ax=store["ax"]

      println(pos," ",npos)
  
      for p in store["aktplt"]
        delete!(ax,p)
      end

      a,b,z=store["abseq"][pos]
      f=store["f"]
      
      pos+=1
      if pos<=npos
        a,b,z=store["abseq"][pos]
        store["aktplt"],_=mkplt(ax,a,b,f,store["xyseq"][pos]...)
      else
        m=0.5*(a+b)
        if f(a)*f(m)<=0.0
          b=m
        else
          a=m
        end
        store["abseq"][pos]=(a,b,false)
        store["aktplt"],store["xyseq"][pos]=mkplt(ax,a,b,f,store["xyseq"][pos-1]...)
        npos+=1
      end

      store["pos"]=pos
      store["npos"]=npos
      store["ax_title"][]="a=$(a), b=$(b), f((a+b)/2)=$(f(0.5*(a+b)))"
    end

    function left(store)
      pos=store["pos"]
      npos=store["npos"]
      (pos<=1) && return
  
      ax=store["ax"]
      for p in store["aktplt"]
        delete!(ax,p)
      end
      
      pos-=1
      (a,b,z)=store["abseq"][pos]
      store["aktplt"],_=mkplt(ax,a,b,f,store["xyseq"][pos]...)
      store["pos"]=pos
      store["ax_title"][]="a=$(a), b=$(b), f((a+b)/2)=$(f(0.5*(a+b)))"
    end


    fig=Figure(
      fonts = (; regular= "TeX Mono")
    )
    fax=fig[1:5,:1:5]
    fleft=fig[6,1] ; fzoom=fig[6,3]; fright=fig[6,5]
    
    
    ax_title=Observable("init")
    ax=Axis(
      fax,
      xgridvisible=false,
      ygridvisible=false,
      title=ax_title,
    )
    #hidedecorations!(ax)
    hidespines!(ax)
    set_theme!(backgroundcolor = :gray90)

    a=-1.0; b=1.0
    f(x)=x^3-0.3x+0.1     

    store=Dict(
      "f"=>f,
      "ax"=>ax, 
      "ax_title"=>ax_title,
      "aktplt"=>[],
      "abseq"=>Dict(0=>(a,b,false)),
      "xyseq"=>Dict(0=>[]),
      "npos"=>0,
      "pos"=>0,
    )
    zoom(store)

    # right
    btnright=Button(
      fright, 
      label=">>",
      font="TeX Mono",
      fontsize=16,
      tellwidth=true,
    )
    on(btnright.clicks) do _
      right(store)
    end
    
    # left
    btnleft=Button(
      fleft, 
      label="<<",
      font="TeX Mono",
      fontsize=16,
      tellwidth=true,
    )
    on(btnleft.clicks) do _
      left(store)
    end

    btnzoom=Button(
      fzoom, 
      label="+",
      font="TeX Mono",
      fontsize=16,
      tellwidth=true,
    )

    on(btnzoom.clicks) do _
      zoom(store)
    end


    fig
  end # of bisect3()

  export bisect3

  

#############################################################
# regula-falsi
#############################################################

  function regulafalsi()

    function pltupd(ax,ax_title,a,b,f,plt)
      for p in plt["upd"]
        delete!(ax,p)
      end
      empty!(plt["upd"])

      fa,fb=f(a),f(b)
      c=a-fa/(fa-fb)*(a-b)

      pts=[
        (Point2f(a,0),Point2f(b,0)),
        (Point2f(a,0),Point2f(a,fa)),    
        (Point2f(b,0),Point2f(b,fb)),    
        (Point2f(a,fa),Point2f(b,fb)),            
      ]
      p=linesegments!(
        ax, 
        pts,
        linewidth=2,
        color=(:red,0.4)
      )
      ax_title[]="a=$(a), b=$(b), f(c)=$(f(c))"
      push!(plt["upd"],p)
    end


    function pltini(ax,ax_title,a,b,f,plt)
      for p in plt["ini"]
        delete!(ax,p)
      end
      empty!(plt["ini"])

      xx=range(a,b,200)
      yy=f.(xx)
      p1=lines!(
        ax,
        xx, yy,
        color=:blue,
      )
      p2=hlines!(
        ax,
        [0],
        color=(:black,0.5),
        linewidth=1,
      )
      push!(plt["ini"],p1,p2)
      pltupd(ax,ax_title,a,b,f,plt)
    end


    fig=Figure(
      fonts = (; regular= "TeX Mono")
    )
    ax_title=Observable("init")
    ax=Axis(
      fig[1,1],
      xgridvisible=false,
      ygridvisible=false,
      title=ax_title,
    )
    hidedecorations!(ax)
    hidespines!(ax)

    a=-1; b=1
    f(x)=x^3-0.3x+0.1     

    plt=Dict("ini"=>[],"upd"=>[])
    pltini(ax,ax_title,a,b,f,plt)

    btnstep=Button(
      fig[2,2], 
      label="step",
      font="TeX Mono",
      fontsize=16,
      tellwidth=true,
    )


    on(btnstep.clicks) do _
      fa,fb=f(a),f(b)
      mid=a-fa/(fa-fb)*(a-b)
      if f(a)*f(mid)<=0.0
        b=mid
      else
        a=mid
      end
      println(f(a)," ",f(b))
      pltupd(ax,ax_title,a,b,f,plt)
    end

    btnzoom=Button(
      fig[3,2], 
      label="zoom",
      font="TeX Mono",
      fontsize=16,
      tellwidth=true,
    )


    on(btnzoom.clicks) do _
      pltini(ax,ax_title,a,b,f,plt)
    end


    fig
  end # of regulafalsi()

  export regulafalsi


end # of Zero
