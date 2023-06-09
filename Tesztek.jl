module Tesztek
  #GLMakie.activate!()

  using GLMakie, Tools

  mutable struct Ball
    x::Float32
    y::Float32
    vx::Float32
    vy::Float32
  end
  
  function move(b::Ball)
    d=2.0 # depends on markersize...
    b.x+=b.vx
    b.y+=b.vy
    if b.x< -50+d || b.x>50-d # -50,50: limits of axis
      b.vx=-b.vx
    elseif b.y< -50+d || b.y>50-d
      b.vy=-b.vy
    end
  end
  function coll(bb::Array{Ball})
    d=2.0
    n=length(bb)
    for i in 1:n-1, j in i+1:n
      if abs(bb[i].x-bb[j].x)+abs(bb[i].y-bb[j].y)<d
        bb[i].vx,bb[j].vx=bb[j].vx,bb[i].vx
        bb[i].vy,bb[j].vy=bb[j].vy,bb[i].vy
      end
    end
  end


 
  function teszt1()
    
    # definitions
    begin
      fig=Figure(
        fonts = (; regular= "TeX Mono"),
        resolution=(500,500),
      )
      ax=Axis(
        fig[1:5,1:5],
        xgridvisible=false,
        ygridvisible=false,
        title="ball",
      )
      ax.limits=((-50,50),(-50,50))
      hidespines!(ax)
      set_theme!(backgroundcolor = :gray90)
      
      ostop=Observable(false)
      btnstop=Button(
        fig[5,6], 
        label="stop",
        font="TeX Mono",
        fontsize=16,
        tellwidth=true,
      )
      on(btnstop.clicks) do _
        ostop[]=true
      end

      opause=Observable(false)
      btnpause=Button(
        fig[6,6], 
        label=lift(opause) do v
          v ? "conti" : "pause"
        end,
        font="TeX Mono",
        fontsize=16,
        tellwidth=false,
      )
      on(btnpause.clicks) do _
        opause[]=!opause[]
        #println(opause[])
      end
    end

    display(fig)

    # actions
    begin
      bb=[
        Ball(40*rand()-20,40*rand()-20,rand([-3,-2,-1,1,2,3])/3,rand([-3,-2,-1,1,2,3])/3) for k in 1:33
      ]

      plt=nothing
      while true
        move.(bb)
        coll(bb)
        if plt!==nothing
          delete!(ax,plt)
        end
        plt=scatter!(
          ax, [b.x for b in bb], [b.y for b in bb], 
          markersize=20,
          visible=true,
          color=:black
        )        
        if ostop[]==true
          break
        end
        while opause[]==true
          sleep(0.1)
        end
        sleep(0.01)
      end

    end

  end # of teszt1
  
  export teszt1


  function teszt2()
    fig=Figure(
      fonts = (; regular= "TeX Mono"),
    )
    ax=Axis(
      fig[1,1],
      xgridvisible=false,
      ygridvisible=false,
      title="none",
      aspect=1,
    )

    alfa=0.15
    fc=:green
    lc=:blue

    x=range(-5,5,100)

    y1=3*x.+1
    lines!(ax,x,y1,color=lc)
    y2=2*x.+3
    lines!(ax,x,y2,color=lc)
    fill_between!(ax,x,y1,y2,color=(fc,alfa))


    vlines!(ax,[0],color=lc)
    fill_between!(ax,[0,100],-100,100,color=(fc,alfa))

    hlines!(ax,[0],color=lc)
    fill_between!(ax,[-1,100],0,100,color=(fc,alfa))
    limits!(ax,-1,5,-5,5)


    limits!(ax,-1,5,-1,5)
    
    
    current_figure()
  end
  export teszt2



end # of Tesztek
