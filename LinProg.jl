# got a more involved "method", but the overall complexity is smaller (especially 
# when every block is folded
# 

module LinProg
  #GLMakie.activate!()

  using GLMakie, Tools
  using LinearAlgebra

  # collection of test functions
  # TODO extend it
  function mkdata_graphical(what)
    if what=="ex1"
      A=[
        1.0  2.0;
        1.0 -2.0;
        1.0 1.0
      ]
      b=[
        10.0;
        3.0 ;
        4.0
      ]
      c=[
        2.0;
        1.0
      ]
    else
      nothing
    end
    (A=A,b=b,c=c)
  end # of mkdata_graphical

  # preliminary computations - to decide about xlim, ylim and
  # the extremal points
  function init(store)
    ncond=store["ncond"]
    A=store["A"]
    b=store["b"]
    AA=vcat([-1 0; 0 -1],A)
    bb=vcat([0,0],b)
    POIS=Matrix{Any}(undef,ncond+2,ncond+2) # intersection
    for k in 1:ncond+2, l in k:ncond+2
      if k==l
        POIS[k,k]=nothing
      else
        X=AA[[k,l],:]
        if rank(X)<2
          POIS[k,l]=POIS[l,k]=nothing
          continue
        end
        POIS[k,l]=POIS[l,k]=X\bb[[k,l]]
      end
    end
    store["AA"]=AA
    store["bb"]=bb    
    store["POIS"]=POIS
    
  end

  function go(store)
    idx=store["idx"]
    if idx<store["ncond"]
      idx=store["idx"]=idx+1
    else
      return
    end
    
    a,b=store["A"][idx,:]
    c=store["b"][idx]
    
    ax=store["ax"]
    if a==0.0
    elseif b==0.0
    else
      l1=ablines!(ax, [c/b], [-a/b], color=:black)
      delta=sqrt(1.0+(-a/b)^2)
      l2=ablines!(ax, [(c-delta)/b], [-a/b]; visible=false)
      fill_between!(ax,l1,l2)
    end
    
  end

  function graphical()
    # basic definitions
    begin
      fig=Figure(
        fonts = (; regular= "TeX Mono")
      )
      
      fmenu=fig[0,3]
      fax=fig[1:2,1:2]
      fgo=fig[3,3]
      
      ax=Axis(
        fax,
        xgridvisible=false,
        ygridvisible=false,
        title="none",
        aspect=1,
      )
      #hidedecorations!(ax)
      #hidespines!(ax)
      set_theme!(backgroundcolor = :gray90)
      limits!(ax,-10,10,-10,10)

      store=Dict{String,Any}(
        "ax"=>ax, 
      )
    end
    
    # buttons
    begin 
      btngo=Button(
        fgo, 
        label="go",
        font="TeX Mono",
        fontsize=16,
        tellwidth=true,
      )
      on(btngo.clicks) do _
        go(store)
      end

    end

    # menu
    begin
      menu = Menu(
        fmenu, 
        options = [
          "ex1", 
        ],
        fontsize=16,
        tellwidth=false,
      )
            
      on(menu.selection,update=true) do what
        data=mkdata_graphical(what)
        #println(data)
        empty!(ax)
        println(typeof(ax))
        hlines!(
          ax,
          [0],
          color=:black,
        )
        hlines!(
          ax,
          [1],
          color=(:black,0.1),
          linewidth=85,
        )

        vlines!(
          ax,
          [0],
          color=:black,

        )
        vlines!(
          ax,
          [1],
          color=(:black,0.1),
          linewidth=85,
        )



        store["idx"]=0
        store["A"]=data.A
        store["b"]=data.b
        store["c"]=data.c
        (ncond,_)=size(data.A)
        store["ncond"]=ncond
        init(store)
      end
    end

    fig
  end # of graphical()

  export graphical



end # of LinProg
