using MeshCat, MeshCatMechanisms, RigidBodyDynamics, CoordinateTransformations
using GeometryTypes, MeshIO, FileIO, Rotations
using GeometryBasics: HyperRectangle, Vec, Point, Mesh
using Colors: RGBA, RGB
using Distributions
using PDDL
include("../solver/mip_solver.jl")
include("action_model.jl")


function load_table(urdf_path, xypos, vis)
    object = load(urdf_path)
    color_material = MeshPhongMaterial(color=colorant"sienna4")
    setobject!(vis["table"], object, color_material)
    rotation = LinearMap(AngleAxis(-pi/2,0,pi,pi/2))
    rotationx = LinearMap(RotX(pi/2))
    rotationy = LinearMap(RotY(-pi/2))
    translation = Translation(xypos[1], xypos[2], xypos[3])
    transformation = translation ∘ rotationx ∘ rotationy
    settransform!(vis["table"], transformation)
end


function create_cube(name, pos, vis, color)
    box = HyperRectangle(Vec(0.,0,0), Vec(0.1,0.1,0.1))
    color_material = MeshPhongMaterial(color=color)
    cube = setobject!(vis["object"][name], box, color_material)
    settransform!(vis["object"][name], Translation(pos[1],pos[2],pos[3]))
    return cube
end


function load_objects!(problem, vis, poses)
    yrange = (-1.5, -0.5)
    xrange = (-0.5, 0.5)
    cube_colors = [colorant"blue",colorant"magenta2",colorant"snow",colorant"yellow1",colorant"honeydew3",colorant"deepskyblue1",colorant"salmon3",colorant"navajowhite4",colorant"darkred",colorant"orange3",colorant"darkgreen",colorant"goldenrod",colorant"lightyellow4",colorant"chartreuse3",colorant"slateblue2"]
    for obj in problem.objects
        cube_color = cube_colors[rand(1:end)]
        x = rand(Uniform(xrange[1],xrange[2]))
        y = rand(Uniform(yrange[1],yrange[2]))
        create_cube(string(obj), (x,y,1.325), vis, cube_color)
        poses[string(obj)] = (x,y,1.325)
    end
    return poses
end

function initialize_objects!(problem, vis, poses)
    for cond in problem.init
        if string(cond.name) == "on"
            top = string(cond.args[1])
            bot = string(cond.args[2])
            settransform!(vis["object"][top], Translation(poses[bot][1], poses[bot][2], poses[bot][3]+0.1))
            poses[top] = (poses[bot][1], poses[bot][2], poses[bot][3]+0.1)
        elseif string(cond.name) == "holding"
            obj = string(cond.args[1])
            settransform!(vis["ee"], Translation(0, 0.0, 2.5))
            settransform!(vis["object"][obj], Translation(-0.05, -0.05, 2.4))
            poses[obj] = (-0.05, -0.05, 2.4)
        end
    end
end

function load_ee!(vis, urdf_path, poses)
    object = load(urdf_path)
    color_material = MeshPhongMaterial(color=colorant"gray10")
    setobject!(vis["ee"], object, color_material)
    translation = Translation(0,0,2.5)
    rotationx = LinearMap(RotX(-pi/2))
    transformation = translation ∘ rotationx
    settransform!(vis["ee"], transformation)
    poses["ee"] = (0,0,2.5)
    return poses
end

function process_action_string(action)
    obj1 = nothing; obj2 = nothing
    compound = split(string(action), "(")
    act = compound[1]
    objs = split(compound[2],",")
    if length(objs) == 1
        obj1 = string(objs[1][1:end-1])
    else
        obj1 = objs[1]
        obj2 = string(lstrip(objs[2][1:end-1]))
    end
    return (act, obj1, obj2)
end

function process_action(action)
    obj1 = nothing; obj2 = nothing
    act = string(action.name)
    obj1 = string(action.args[1])
    if length(action.args) == 2
        obj2 = string(action.args[2])
    end
    return (act, obj1, obj2)
end

function execute_plan!(plan, vis, poses, anim, ts)
    for action in plan
        act = process_action(action)
        if act[1] == "pickup"
            pickup!(act[2], vis, poses, anim, ts)
        elseif act[1] == "putdown"
            putdown!(act[2], vis, poses, anim, ts)
        elseif act[1] == "stack"
            stack!(act[2], act[3], vis, poses, anim, ts)
        elseif act[1] == "unstack"
            unstack!(act[2], act[3], vis, poses, anim, ts)
        end
    end
end

function load_and_run_sim(domain_path, problem_path)
    vis = Visualizer()
    load_table("sim/models/table/desk.obj", [0.0, 0.0, 0.0], vis)
    gripper_path = "sim/models/ee/endeffector.obj"
    poses = Dict()
    domain = load_domain(domain_path)
    problem = load_problem(problem_path)
    load_objects!(problem, vis, poses)
    load_ee!(vis, gripper_path, poses)
    initialize_objects!(problem, vis, poses)
    anim = Animation()
    ts = [0]
    @time plan = mip_planner(domain_path, problem_path)
    execute_plan!(plan, vis, poses, anim, ts)
    render(vis)
end
