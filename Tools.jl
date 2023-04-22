module Tools
  using Printf
  
###########################################
# mround
###########################################

  function mround(x)
    if abs(x)<0.001
      @sprintf "%.3e" x
    else
      @sprintf "%.3f" x
    end
  end
  export mround

end
