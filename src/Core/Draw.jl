"""
  get_id(key, data)

Method that defines the label associated to the node `data` when drawing the
graph. The argument `key` is the unique identifier of the node in the graph.
The default method prints the type of data stored in the node and the unique
identifier of the node in parenthesis.
"""
function get_id(key, data)
  string(typeof(data))*"("*string(key)*")"
end

# Convert a node in a graph into a series of statements in the DOT language
function dotlang(id, label, children)
  sid = string(id)
  out = sid*" [label=\""*label*"\", shape = box];\n"#" ("*sid*")\", shape = box];\n"
  for child in children
    out *= sid*" -> "*string(child)*";\n"
  end
  return out
end
  
# Translate a StaticGraph into DOT language
function dotlang(g::StaticGraph)
  out = "digraph {\n"
  for (key, val) in g.nodes
    out *= dotlang(key, get_id(key, val.data), childrenID(val), )
  end
  out *= "}"
  return out
end
  
# Translate a Graph into DOT language
function dotlang(g::Graph)
  dotlang(graph(g))
end

"""
    draw(g::Graph; name::String = "VPL Graph")
Draw a network representation of the graph. The drawing is performed
on a `Blink` window using the vis.js Javascript library. The function returns
the handler to the Blink window. Access to Internet is required as the libraries
are loaded from the cdns server.
"""
function draw(g::Graph; name::String = "VPL Graph") 
  draw(dotlang(g), name = name)
end
function draw(g::StaticGraph; name::String = "VPL Graph") 
  draw(dotlang(g), name = name)
end


function draw(graph::String; name::String = "VPL Graph")
    # Open window and load external requirements
    w = Blink.Window(async=false);
    Blink.loadjs!(w, "//cdnjs.cloudflare.com/ajax/libs/vis/4.21.0/vis.min.js")
    Blink.loadcss!(w, "//cdnjs.cloudflare.com/ajax/libs/vis/4.21.0/vis.min.css")

    # Title
    Blink.title(w, name)

    # For some reason, the DOT conversion refuses DOT formats with newlines
    graph = replace(graph, "\n" => " ")

    # Script from the website
    content = """
    <style type="text/css">
        #mynetwork {
            width: 100vw;
            height: 100vh;
            border-style: none;
        }
    </style>

    <div id="mynetwork"></div>

    <script type="text/javascript">
        // string with graph description
        var DOTstring = '$graph';
        var parsedData = vis.network.convertDot(DOTstring);

        // provide the data in the vis format
        var data = {
            nodes: parsedData.nodes,
            edges: parsedData.edges
        };
        var options = parsedData.options;

        // Layout settings
        options.layout = {
            RandomSeed: undefined,
            improvedLayout:true,
            hierarchical: {
              enabled:true,
              levelSeparation: 150,
              nodeSpacing: 100,
              treeSpacing: 200,
              blockShifting: true,
              edgeMinimization: true,
              parentCentralization: false,
              direction: 'UD',        // UD, DU, LR, RL
              sortMethod: 'directed'   // hubsize, directed
            }};

        // assemble the network and put it inside the div
        var container = document.getElementById('mynetwork');
        var network = new vis.Network(container, data, options);
    </script>
    </body>
    """

    Blink.body!(w, content, async = true)

    return w
end
