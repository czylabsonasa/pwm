# got a more involved "method", but the overall complexity is smaller (especially 
# when every block is folded
# 

module Zero
  #GLMakie.activate!()

  using GLMakie, Tools

  # collection of test functions
  # TODO extend it
  function mkdata_bracket(fun)
    if fun=="sin(x)"
      A=-pi/2 
      B=2pi/3
      f=x->sin(x)
      exact=0.0
      desc="f($(exact))=0"
    elseif fun=="x^3-0.3x+0.1"
      A=-1.0
      B=1.0
      f=x->x^3-0.3*x+0.1
      exact=-0.670226327532111
      desc="f($(exact))=0"
    elseif fun=="x^3-x-2"
      A=1.0
      B=2.0
      f=x->x^3-x-2.0
      exact=1.521379706804568
      desc="f($(exact))=0"
    elseif fun=="x^2-2"
      A=1.0
      B=2.0
      f=x->x^2-2
      exact=1.4142135623730951
      desc="f($(exact))=0"
    elseif fun=="x^3-6"
      A=1.0
      B=2.0
      f=x->x^3-6
      exact=1.817120592832139
      desc="f($(exact))=0"
    elseif fun=="cos(x)-0.999"
      A=-0.01
      B=0.8
      f=x->cos(x)-0.999
      exact=0.04472508716873383
      desc="f($(exact))=0"
    else
      nothing
    end
    (A=A,B=B,f=f,desc=desc,exact=exact)
  end # of mkdata_bracket


  function bisect(store)
    pos,npos=store["pos"],store["npos"]
    (pos<=npos) && return

    function comp_bisect(f,a,b)
      m=0.5*(a+b)
      if f(a)*f(m)<=0.0
        b=m
      else
        a=m
      end
      a,b
    end
    
    ax=store["ax"]
    f=store["f"]
    a,b=store["next_ab"][pos-1]
    na,nb=store["next_ab"][pos]=comp_bisect(f,a,b)
    
    
    xx=range(a,b,200)
    yy=f.(xx)
    c,d=extrema(yy)
    plt=lines!(
      ax,
      xx, yy,
      color=:blue,
      visible=false,
    )
    m1=0.5*(a+b)
    m2=0.5*(c+d)
    h=1.1
    store["limits"][pos]=((h*(a-m1)+m1,h*(b-m1)+m1),(h*(c-m2)+m2,h*(d-m2)+m2))

  
    pts=[
      (Point2f(a,0),Point2f(b,0)),
      (Point2f(a,0),Point2f(a,f(a))),    
      (Point2f(b,0),Point2f(b,f(b))),    
    ]
    red=linesegments!(
      ax, 
      pts,
      linewidth=2,
      color=(:red,0.4),
      visible=false,
    )

    pts=[
      (Point2f(na,0),Point2f(nb,0)),
      (Point2f(na,0),Point2f(na,f(na))),    
      (Point2f(nb,0),Point2f(nb,f(nb))),    
    ]
    green=linesegments!(
      ax, 
      pts,
      linewidth=2,
      color=(:green,0.7),
      visible=false,
    )

    store["plt"][pos]=(plt=plt,common=red,extra=green)

    store["ax_title"]="""a=$(mround(a)), b=$(mround(b)), |b-a|=$(mround(b-a))
    (a+b)/2=$(0.5*(a+b)), f((a+b)/2)=$(mround(f(0.5*(a+b)))), """
  end

  function regulafalsi(store)
    pos,npos=store["pos"],store["npos"]
    (pos<=npos) && return

    function comp_regulafalsi(f,a,b)
      fa,fb=f(a),f(b)
      c=a-fa/(fa-fb)*(a-b)
      if fa*f(c)<=0.0
        b=c
      else
        a=c
      end
      a,b
    end
    
    ax=store["ax"]
    f=store["f"]
    a,b=store["next_ab"][pos-1]
    na,nb=store["next_ab"][pos]=comp_regulafalsi(f,a,b)
    
    
    xx=range(a,b,200)
    yy=f.(xx)
    plt=lines!(
      ax,
      xx, yy,
      color=:blue,
      visible=false,
    )
    c,d=extrema(yy)
    m1=0.5*(a+b)
    m2=0.5*(c+d)
    h=1.1
    store["limits"][pos]=((h*(a-m1)+m1,h*(b-m1)+m1),(h*(c-m2)+m2,h*(d-m2)+m2))

  
    fa,fb=f(a),f(b)
    pts=[
      (Point2f(a,0),Point2f(b,0)),
      (Point2f(a,0),Point2f(a,fa)),    
      (Point2f(b,0),Point2f(b,fb)),    
    ]
    red=linesegments!(
      ax, 
      pts,
      linewidth=2,
      color=(:red,0.4),
      visible=false,
    )

    fna,fnb=f(na),f(nb)
    pts=[
      (Point2f(na,0),Point2f(nb,0)),
      (Point2f(na,0),Point2f(na,fna)),    
      (Point2f(nb,0),Point2f(nb,fnb)),    
      (Point2f(a,fa),Point2f(b,fb)),    
    ]
    green=linesegments!(
      ax, 
      pts,
      linewidth=2,
      color=(:green,0.7),
      visible=false,
    )

    store["plt"][pos]=(plt=plt,common=red,extra=green)

    store["ax_title"]="""a=$(mround(a)), b=$(mround(b)), |b-a|=$(mround(b-a))
    (a+b)/2=$(0.5*(a+b)), f((a+b)/2)=$(mround(f(0.5*(a+b)))), """
  end


  function bsrf(store)
    pos,npos=store["pos"],store["npos"]
    (pos<=npos) && return

    function comp_bsrf(f,a,b)
      fa,fb=f(a),f(b)
      c=a-fa/(fa-fb)*(a-b)
      fc=f(c)
      m=0.5*(a+b)
      fm=f(m)
      level=2
      if fm*fc<=0
        level=0
        na,nb=min(m,c),max(m,c)
      else
        d=c-fc/(fc-fm)*(c-m)
        fd=f(d)
        if a<=d<=b && fd*fc<=0
          if abs(d-c)<=abs(d-m)
            na,nb=min(d,c),max(d,c)
          else
            na,nb=min(d,m),max(d,m)
          end
          level=1
        else
          if fa*fc<=0
            na,nc=a,min(c,m)
          else
            na,nb=max(c,m),b
          end
        end
      end
      na,nb
    end
    
    ax=store["ax"]
    f=store["f"]
    a,b=store["next_ab"][pos-1]
    na,nb=store["next_ab"][pos]=comp_bsrf(f,a,b)
    
    
    xx=range(a,b,200)
    yy=f.(xx)
    plt=lines!(
      ax,
      xx, yy,
      color=:blue,
      visible=false,
    )
    c,d=extrema(yy)
    m1=0.5*(a+b)
    m2=0.5*(c+d)
    h=1.1
    store["limits"][pos]=((h*(a-m1)+m1,h*(b-m1)+m1),(h*(c-m2)+m2,h*(d-m2)+m2))

  
    fa,fb=f(a),f(b)
    pts=[
      (Point2f(a,0),Point2f(b,0)),
      (Point2f(a,0),Point2f(a,fa)),    
      (Point2f(b,0),Point2f(b,fb)),    
    ]
    red=linesegments!(
      ax, 
      pts,
      linewidth=2,
      color=(:red,0.4),
      visible=false,
    )

    fna,fnb=f(na),f(nb)
    pts=[
      (Point2f(na,0),Point2f(nb,0)),
      (Point2f(na,0),Point2f(na,fna)),    
      (Point2f(nb,0),Point2f(nb,fnb)),    
      (Point2f(a,fa),Point2f(b,fb)),    
    ]
    green=linesegments!(
      ax, 
      pts,
      linewidth=2,
      color=(:green,0.7),
      visible=false,
    )

    store["plt"][pos]=(plt=plt,common=red,extra=green)

    store["ax_title"]="""a=$(mround(a)), b=$(mround(b)), |b-a|=$(mround(b-a))
    (a+b)/2=$(0.5*(a+b)), f((a+b)/2)=$(mround(f(0.5*(a+b)))), """
  end

  
#  function comp_bsrf(a,b,f)
#    fa,fb=f(a),f(b)
#    m=0.5*(a+b); fm=f(m)
#    c=a-fa/(fa-fb)*(a-b); fc=f(c)
    
#    m1,m2,fm1,fm2=if m>c
#      c,m,fc,fm
#    else
#      m,c,fm,fc
#    end
    
#    if fm1*fm2<=0
#      m1,m2
#    else
#      if fa*fm1<=0
#        a,m1
#      else
#        m2,b
#      end
#    end
#  end

#  function comp_rf2(a,b,f)
#    fa,fb=f(a),f(b)
#    m1=a-fa/(fa-fb)*(a-b); f1=f(m1)
    
#    if fa*f1>0
#      m2=a-fa/(fa-f1)*(a-m1); f2=f(m2)
#      if m1<m2<b && f1*f2<=0
#        m1,m2
#      else
#        m1,b
#      end
#    else
#      m2=b-fb/(fb-f1)*(b-m1); f2=f(m2)
#      if a<m2<m1 && f1*f2<=0
#        m2,m1
#      else
#        a,m1
#      end
#    end
#  end


  
  function bracket(methodname="")
    # method "menu" (TODO make a graphical method menu)
    begin
      method,mname=if methodname in ["bisect","bs"]
        bisect,"bisection"
      elseif methodname in ["regulafalsi", "rf", "fp"]
        regulafalsi,"false position"
      elseif methodname in ["bsrf", "bsfp"]
        bsrf, "bisection+false pos."
      elseif methodname in ["rf2","fp2"]
        rf2, "regula-falsi variation"
      else
        println("""call:\nbracket(methodname)\nwhere methodname in "bs", "rf"/"fp", "bsrf"/"bsfp", "rf2"/"fp2"}""")
        return
      end
      mname=mname*"@bracket"
    end
    
    function hide(store)
      for p in store["plt"][store["pos"]]
        p.visible=false
      end
    end
    
    function plt(store)
      pos=store["pos"]
      aktplt=store["plt"][pos]
      aktplt.common.visible=true;
      aktplt.extra.visible=store["extra"]
      aktplt.plt.visible=true
      store["ax"].limits=store["limits"][pos]

      store["ax"].title=store["ax_title"]
    end
    
    function extra(store)
      store["extra"]=!store["extra"]
      plt(store)
    end


    function right(store)
      hide(store)
      store["pos"]+=1
      method(store)
      plt(store)
    end

    function left(store)
      (store["pos"]<=1) && return
      hide(store)
      store["pos"]-=1
      plt(store)
    end

    # basic definitions
    begin
      fig=Figure(
        fonts = (; regular= "TeX Mono")
      )
      
      flab1=fig[-1,1:6]
      flab2=fig[0,1:4]; fmenu=fig[0,6]
      fax=fig[1:5,1:6]
      fleft=fig[6,2] ; fextra=fig[6,3]; fright=fig[6,4]
      
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
        "ax_title"=>"init",
        "next_ab"=>Dict(0=>()),
        "plt"=>Dict(0=>()),
        "npos"=>0,
        "pos"=>0,
        "extra"=>false,
        "limits"=>Dict{Int,Any}(
          0=>(nothing,nothing),
        )
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

      # some decoration
      btnextra=Button(
        fextra, 
        label="extra",
        font="TeX Mono",
        fontsize=16,
        tellwidth=true,
      )

      on(btnextra.clicks) do _
        extra(store)
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
        empty!(ax)
        xline=hlines!(
          ax,
          [0],
          color=(:black,0.5),
          linewidth=1,
        ); xline.visible=true

        store["npos"]=0
        store["pos"]=0
        store["f"]=data.f;
        store["next_ab"]=Dict(
          0=>(data.A,data.B),
        )
        store["plt"]=Dict{Int,Any}(
          0=>(),
        )
        
        right(store)
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
