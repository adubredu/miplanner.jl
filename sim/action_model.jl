
function pickup!(obj, vis, poses, anim, ts)
    position = poses[obj]
    atframe(anim, 0+ts[1]) do
        settransform!(vis["ee"], Translation(poses["ee"][1], poses["ee"][2], poses["ee"][3]))
    end
    atframe(anim, 30+ts[1]) do
        settransform!(vis["ee"], Translation(position[1]+0.05, position[2]+0.05, position[3]+0.1))
        settransform!(vis["object"][obj], Translation(poses[obj][1], poses[obj][2], poses[obj][3]))
    end
    atframe(anim, 60+ts[1]) do
        settransform!(vis["ee"], Translation(0, 0.0, 2.5))
        settransform!(vis["object"][obj], Translation(-0.05, -0.05, 2.4))
    end
    setanimation!(vis, anim)
    ts[1]+=90
    poses[obj] = (-0.05, -0.05, 2.4)
end

function putdown!(obj, vis, poses, anim, ts)
    position = poses[obj]
    yrange = (0.5, 1.5)
    xrange = (-0.5, 0.5)
    x = rand(Uniform(xrange[1],xrange[2]))
    y = rand(Uniform(yrange[1],yrange[2]))
    atframe(anim, 0+ts[1]) do
        settransform!(vis["ee"], Translation(poses["ee"][1], poses["ee"][2], poses["ee"][3]))
        settransform!(vis["object"][obj], Translation(poses[obj][1], poses[obj][2], poses[obj][3]))
    end
    atframe(anim, 30+ts[1]) do
        settransform!(vis["ee"], Translation(x+0.05, y+0.05, 1.325+0.1))
        settransform!(vis["object"][obj], Translation(x, y, 1.325))
    end
    atframe(anim, 60+ts[1]) do
        settransform!(vis["ee"], Translation(0, 0.0, 2.5))
    end
    setanimation!(vis, anim)
    ts[1]+=90
    poses[obj] = (x,y,1.325)


end

function stack!(top, bot, vis, poses, anim, ts)
    toppos = poses[top]
    botpos = poses[bot]
    atframe(anim, 0+ts[1]) do
        settransform!(vis["ee"], Translation(poses["ee"][1], poses["ee"][2], poses["ee"][3]))
        settransform!(vis["object"][top], Translation(poses[top][1], poses[top][2], poses[top][3]))
    end
    atframe(anim, 30+ts[1]) do
        settransform!(vis["ee"], Translation(botpos[1]+0.05, botpos[2]+0.05, botpos[3]+0.2))
        settransform!(vis["object"][top], Translation(poses[bot][1], poses[bot][2], poses[bot][3]+0.1))
    end
    atframe(anim, 60+ts[1]) do
        settransform!(vis["ee"], Translation(0, 0.0, 2.5))
    end
    setanimation!(vis, anim)
    ts[1]+=90
    poses[top] = (poses[bot][1], poses[bot][2], poses[bot][3]+0.1)
end

function unstack!(top, bot, vis, poses, anim, ts)
    pickup!(top, vis, poses, anim, ts)
end
