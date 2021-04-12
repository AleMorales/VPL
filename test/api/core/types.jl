# User-defined types for testing the package
module GT

  using VPL

  struct bar <: Node
    x::Int
  end

  struct A <: Node end

  struct B <: Node end

  mutable struct Cell{T} <: Node
    state::T
  end

  struct G3pars
    division::Rational{Int}
    growth::Rational{Int}
  end

  struct ACell <: Node
    state::Int
  end

  struct BCell <: Node
    state::Int
  end

  struct CCell <: Node
    state::Int
  end

  struct B <: Node end

end
