# test: forward/backward steps

module Zero
  #GLMakie.activate!()

  using GLMakie, Tools

#############################################################
# bisect - preliminary ver. ("deprecated")
#############################################################

  function bisect0()

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

  export bisect0


#############################################################
# bisectfb = bisect restructured
#############################################################
##
#  the plots are really deleted during the delete!(ax,...) so they cannot be reused
##

  function mkdata_bracket(fun)
    if fun=="sin(x)"
      a=-pi/2
      b=2pi/3
      f=x->sin(x)
      exact=0.0
      desc="f($(exact))=0"
      limits=(a,b,-1.1,1.1)
    elseif fun=="x^3-0.3x+0.1"
      a=-1.0
      b=1.0
      f=x->x^3-0.3*x+0.1
      exact=-0.670226327532111
      desc="f($(exact))=0"
      limits=(a,b,-1.1,1.1)
    elseif fun=="x^3-x-2"
      a=1.0
      b=2.0
      f=x->x^3-x-2.0
      exact=1.521379706804568
      desc="f($(exact))=0"
      limits=(a,b,-2.1,4.1)
    elseif fun=="x^2-2"
      a=1.0
      b=2.0
      f=x->x^2-2
      exact=1.4142135623730951
      desc="f($(exact))=0"
      limits=(a,b,-1.1,2.1)
    elseif fun=="x^3-6"
      a=1.0
      b=2.0
      f=x->x^3-6
      exact=1.817120592832139
      desc="f($(exact))=0"
      limits=(a,b,-5.1,2.1)
    elseif fun=="cos(x)-0.999"
      a=-0.01
      b=0.8
      f=x->cos(x)-0.999
      exact=0.04472508716873383
      desc="f($(exact))=0"
      limits=(a,b,-1.1,0.5)
    else
      nothing
    end
    (a=a,b=b,f=f,desc=desc,exact=exact,limits=limits)
  end # of mkdata_bracket

  
  function comp_bisect(a,b,f)
    m=0.5*(a+b)
    if f(a)*f(m)<=0.0
      b=m
    else
      a=m
    end
    a,b
  end
  
  function dec_bisect(store)
    pos=store["pos"]
    npos=store["npos"]
    ax=store["ax"]
    f=store["f"]
    a,b,_=store["abseq"][pos]
    fa,fb=f(a),f(b)

    # mod of regula-falsi
    c=0.5*(a+b)
    fc=f(c)
    cc,fcc=if fa*fc<=0
      a,fa
    else
      b,fb
    end
    
    p=linesegments!(
      ax, 
      [
        (Point2f(c,0),Point2f(cc,0)),
        (Point2f(c,0),Point2f(c,fc)),        
        (Point2f(cc,0),Point2f(cc,fcc)),        
      ],
      linewidth=2,
      color=(:green,0.9)
    )
    push!(store["aktplt"],p)
  end

  
  function comp_regulafalsi(a,b,f)
    fa,fb=f(a),f(b)
    c=a-fa/(fa-fb)*(a-b)
    if fa*f(c)<=0.0
      b=c
    else
      a=c
    end
    a,b
  end

  function dec_regulafalsi(store)
    pos=store["pos"]
    npos=store["npos"]
    ax=store["ax"]
    f=store["f"]
    a,b,_=store["abseq"][pos]
    fa,fb=f(a),f(b)

    c=a-fa*(a-b)/(fa-fb)
    fc=f(c)
    cc,fcc=if fa*fc<=0
      a,fa
    else
      b,fb
    end
    
    p=linesegments!(
      ax, 
      [
        (Point2f(c,0),Point2f(cc,0)),
        (Point2f(a,fa),Point2f(b,fb)),
        (Point2f(c,0),Point2f(c,fc)),        
        (Point2f(cc,0),Point2f(cc,fcc)),        
      ],
      linewidth=2,
      color=(:green,0.9)
    )
    push!(store["aktplt"],p)
  end
  
  function comp_bsrf(a,b,f)
    fa,fb=f(a),f(b)
    m=0.5*(a+b); fm=f(m)
    c=a-fa/(fa-fb)*(a-b); fc=f(c)
    
    m1,m2,fm1,fm2=if m>c
      c,m,fc,fm
    else
      m,c,fm,fc
    end
    
    if fm1*fm2<=0
      m1,m2
    else
      if fa*fm1<=0
        a,m1
      else
        m2,b
      end
    end
  end

  function dec_bsrf(store)
  
  end

  function comp_rf2(a,b,f)
    fa,fb=f(a),f(b)
    m1=a-fa/(fa-fb)*(a-b); f1=f(m1)
    
    if fa*f1>0
      m2=a-fa/(fa-f1)*(a-m1); f2=f(m2)
      if m1<m2<b && f1*f2<=0
        m1,m2
      else
        m1,b
      end
    else
      m2=b-fb/(fb-f1)*(b-m1); f2=f(m2)
      if a<m2<m1 && f1*f2<=0
        m2,m1
      else
        a,m1
      end
    end
  end

  function dec_rf2(store)

  end

 
  
  
  function bracket(methodname="")
    # method "menu" (of course there will be one)
    begin
      method,dec,mname=if methodname in ["bisect","bs"]
        comp_bisect,dec_bisect,"bisection"
      elseif methodname in ["regulafalsi", "rf"]
        comp_regulafalsi,dec_regulafalsi,"regula-falsi"
      elseif methodname in ["bsrf"]
        comp_bsrf, dec_bsrf, "bisection+regula-falsi"
      elseif methodname in ["rf2"]
        comp_rf2, dec_rf2, "regula-falsi variation"
      else
        println("""call:\nbracket(methodname)\nwhere methodname in {"bs", "rf", "bsrf", "rf2"}""")
        return
      end
      mname=mname*"@bracket"
    end
    
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
      store["ax_title"][]="""a=$(mround(a)), b=$(mround(b)), |b-a|=$(mround(b-a))
      (a+b)/2=$(0.5*(a+b)), f((a+b)/2)=$(mround(f(0.5*(a+b)))), """
     end

    function right(store)
      pos=store["pos"]
      npos=store["npos"]
      ax=store["ax"]

      #println(pos," ",npos)
  
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
        a,b=method(a,b,f)
        store["abseq"][pos]=(a,b,false)
        store["aktplt"],store["xyseq"][pos]=mkplt(ax,a,b,f,store["xyseq"][pos-1]...)
        npos+=1
      end

      store["pos"]=pos
      store["npos"]=npos
      store["ax_title"][]="""a=$(mround(a)), b=$(mround(b)), |b-a|=$(mround(b-a))
      (a+b)/2=$(0.5*(a+b)), f((a+b)/2)=$(mround(f(0.5*(a+b)))), """
      
      #store["ax_title"][]="a=$(mround(a)), b=$(mround(b)), f((a+b)/2)=$(mround(f(0.5*(a+b)))), \n|b-a|=$(mround(b-a))"
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
      f=store["f"]
      
      store["aktplt"],_=mkplt(ax,a,b,f,store["xyseq"][pos]...)
      store["pos"]=pos
      #store["ax_title"][]="a=$(mround(a)), b=$(mround(b)), f((a+b)/2)=$(mround(f(0.5*(a+b)))), |b-a|=$(mround(b-a))"
      store["ax_title"][]="""a=$(mround(a)), b=$(mround(b)), |b-a|=$(mround(b-a))
      (a+b)/2=$(0.5*(a+b)), f((a+b)/2)=$(mround(f(0.5*(a+b)))), """
    end

    # base
    begin
      fig=Figure(
        fonts = (; regular= "TeX Mono")
      )
      
      flab1=fig[-1,1:6]
      flab2=fig[0,1:4]; fmenu=fig[0,5:6]
      fax=fig[1:5,:1:5]
      fleft=fig[6,1] ; fzoom=fig[6,2]; fright=fig[6,3]; fdec=fig[6,6];
      
      flab2_text=Observable("init")
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

      store=Dict(
        "ax"=>ax, 
        "ax_title"=>ax_title,
        "aktplt"=>[],
        "xyseq"=>Dict(0=>[]),
        "npos"=>0,
        "pos"=>0,
      )
    end
    
    # buttons
    begin 
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

      # some decoration
      btndec=Button(
        fdec, 
        label="?",
        font="TeX Mono",
        fontsize=16,
        tellwidth=true,
      )

      on(btndec.clicks) do _
        dec(store)
      end
    end

    # function menu
    begin
      menu = Menu(
        fmenu, 
        options = [
          "sin(x)", 
          "x^3-0.3x+0.1", 
          "x^2-2",
          "x^3-x-2",
          "cos(x)-0.999",
        ],
        fontsize=16,
        tellwidth=false,
      )      
      on(menu.selection,update=true) do funname
        data=mkdata_bracket(funname)
        flab2_text[]=data.desc
        for p in store["aktplt"]
          delete!(ax,p)
        end
        store["aktplt"]=[]
        store["xyseq"]=Dict(0=>[])
        store["npos"]=0
        store["pos"]=0
        store["f"]=data.f;
        store["abseq"]=Dict(0=>(data.a,data.b,false))
        zoom(store)
      end
    end

    # labels
    begin
      Label(
        flab2,
        flab2_text,
        fontsize=22,
        tellwidth=false
      )

      Label(
        flab1,
        mname,
        fontsize=22,
        tellwidth=false
      )
    end

    fig
  end # of bracket()

  export bracket


end # of Zero
