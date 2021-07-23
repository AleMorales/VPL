# Virtual Plant Laboratory

## Introduction

The Virtual Plant Laboratory (VPL) is a Julia package that aids in the construction, 
simulation and visualization of functional-structural plant models (FSPM). VPL 
is not a standalone solution to all the computational problems relevant to FSPM, 
but rather it focuses on those algorithms and visualizations that are specific to 
FSPM and for which there are no good solutions in the Julia package ecosystem. 
Furthermore, VPL is 100% written in Julia and therefore VPL will work in any 
platform and with any code editor where Julia works. Finally, VPL does not offer 
a domain specific language for FSPM but rather it allows building FSP models by 
creating user-defined data [types](https://docs.julialang.org/en/v1/manual/types/) 
and [methods](https://docs.julialang.org/en/v1/manual/methods/).

There is no standard definition of what an  FSPM is, though these models will 
always involve some combination of plant structure and function, so it is likely 
that VPL will not be useful with every possible FSPM. Instead, VPL focuses on 
models that represent indivudual plants as graphs of elements (usually organs) 
that interact with each other and with the environment. In a typical VPL model, 
each plant is represented by its own graph which can change dynamically through 
the iterative application of graph rewriting rules. Based on this goal, what VPL 
offers mainly are data structures and algorithms that allow 

1.  modelling dynamic graphs that represent plants,  
2.  modelling the interaction between plants and their 3D environment by generating 
3D structures from the graphs and simulating capture of different resources 
(e.g. light) and 
3.  modelling the interaction among elements within each plant by constructing 
dynamic networks that represent systems of ordinary differential equations. 

In terms of design, VPL gives priority to performance and simple interfaces as
opposed to complex layers of abstraction. This implies that models in VPL may
be more verbose and procedural (as opposed to descriptive) than in other FSPM
platforms, while being more transparent and easier to follow.

## Installation 

VPL requires using Julia version 1.6 or higher. The installation of VPL is as
easy as running the following code:

```julia
using Pkg
Pkg.add(PackageSpec(url = "https://git.wur.nl/vpl/vpl.git", rev  = "master"))
```

## The VPL ecosystem

The package VPL contains all the basic functionality to build FSPM but, as 
indicated earlier, the emphasis is on minimal, simple and transparent interfaces.
In order to facilitate the construction of advanced FSPM, an ecosystem of 
packages will be built around VPL that bring higher levels of abstraction and 
reusable components with which models can be built.

The packages currently planned include

* Ecophys: Algorithms and data structures to simulate ecophysiological processes 
including photosynthesis, transpiration, leaf energy balance, phenology, 
respiration, nutrient and water uptake, etc.

* Sky: Algorithms to simulate different sky conditions in terms of the intensity 
of solar radiation and its spatial distribution.

* GCIM: A generic model that allows simulating multiple types of crops with an
emphasis on interactions among crops

## Documentation

Documentation for VPL is provided in this website in four formats:

1. User manual
2. Tutorials and examples
3. API
4. Technical notes

New users are expected to start with the tutorials and consult the user manual
to understand better the different concepts used in VPL and get an overview of
the different options available. The API documentation describes each individual 
function and data type, with an emphasis on inputs and outputs and (in addition 
to this website) it can be accessed from within Julia with `?` (see the section 
[Accessing Documentation](https://docs.julialang.org/en/v1/manual/documentation/#Accessing-Documentation-1) 
in the Julia manual). The developer manual is useful for people who want to 
understand the internal details of VPL and how different algorithms are 
implemented (i.e. the developer manual should be seen as a supplementary to the
source code of VPL).




