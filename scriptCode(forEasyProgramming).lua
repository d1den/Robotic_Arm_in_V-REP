function sysCall_init()
    -- Take a few handles from the robot:
    simBase=sim.getObjectHandle('Mark2')
    simTip=sim.getObjectHandle('EndPoint')
    simTarget=sim.getObjectHandle('TargetPoint')
    simMotors={}
    motorsPositions={}
    for i=1,6,1 do
        simMotors[i]=sim.getObjectHandle('Motor'..i)
    end

    -- Now build a kinematic chain and 2 IK groups (undamped and damped) inside of the IK plugin environment,
    -- based on the kinematics of the robot in the scene:
    ikJoints={}
    -- create an IK environment:
    ikEnv=simIK.createEnvironment()
    -- create a dummy in the IK environemnt: 
    ikBase=simIK.createDummy(ikEnv) 
    -- set that dummy into the same pose as its CoppeliaSim counterpart:
    simIK.setObjectMatrix(ikEnv,ikBase,-1,sim.getObjectMatrix(simBase,-1)) 
    local parent=ikBase
    -- loop through all joints:
    for i=1,#simMotors,1 do
        -- create a joint in the IK environment: 
        ikJoints[i]=simIK.createJoint(ikEnv,simIK.jointtype_revolute)
        -- set it into IK mode: 
        simIK.setJointMode(ikEnv,ikJoints[i],simIK.jointmode_ik) 
        -- set the same joint limits as its CoppeliaSim counterpart joint:
        local cyclic,interv=sim.getJointInterval(simMotors[i])
        simIK.setJointInterval(ikEnv,ikJoints[i],cyclic,interv)
        -- set the same joint position as its CoppeliaSim counterpart joint: 
        simIK.setJointPosition(ikEnv,ikJoints[i],sim.getJointPosition(simMotors[i]))
        -- set the same object pose as its CoppeliaSim counterpart joint: 
        simIK.setObjectMatrix(ikEnv,ikJoints[i],-1,sim.getObjectMatrix(simMotors[i],-1))
        -- set its corresponding parent: 
        simIK.setObjectParent(ikEnv,ikJoints[i],parent,true) 
        parent=ikJoints[i]
    end
    -- create the tip dummy in the IK environment:
    ikTip=simIK.createDummy(ikEnv)
    -- set that dummy into the same pose as its CoppeliaSim counterpart: 
    simIK.setObjectMatrix(ikEnv,ikTip,-1,sim.getObjectMatrix(simTip,-1))
    -- attach it to the kinematic chain: 
    simIK.setObjectParent(ikEnv,ikTip,parent,true)
    -- create the target dummy in the IK environment: 
    ikTarget=simIK.createDummy(ikEnv)
    -- set that dummy into the same pose as its CoppeliaSim counterpart: 
    simIK.setObjectMatrix(ikEnv,ikTarget,-1,sim.getObjectMatrix(simTarget,-1))
    -- link the two dummies: 
    simIK.setLinkedDummy(ikEnv,ikTip,ikTarget)
    -- create an IK group: 
    ikGroup_undamped=simIK.createIkGroup(ikEnv)
    -- set its resolution method to undamped: 
    simIK.setIkGroupCalculation(ikEnv,ikGroup_undamped,simIK.method_pseudo_inverse,0,6)
    -- make sure the robot doesn't shake if the target position/orientation wasn't reached: 
    simIK.setIkGroupFlags(ikEnv,ikGroup_undamped,1+2+4+8)
    -- add an IK element to that IK group: 
    local ikElementHandle=simIK.addIkElement(ikEnv,ikGroup_undamped,ikTip)
    -- specify the base of that IK element: 
    simIK.setIkElementBase(ikEnv,ikGroup_undamped,ikElementHandle,ikBase)
    -- specify the constraints of that IK element: 
    simIK.setIkElementConstraints(ikEnv,ikGroup_undamped,ikElementHandle,simIK.constraint_pose)
    -- create another IK group: 
    ikGroup_damped=simIK.createIkGroup(ikEnv)
    -- set its resolution method to damped: 
    simIK.setIkGroupCalculation(ikEnv,ikGroup_damped,simIK.method_damped_least_squares,1,99)
    -- add an IK element to that IK group: 
    local ikElementHandle=simIK.addIkElement(ikEnv,ikGroup_damped,ikTip)
    -- specify the base of that IK element: 
    simIK.setIkElementBase(ikEnv,ikGroup_damped,ikElementHandle,ikBase)
    -- specify the constraints of that IK element: 
    simIK.setIkElementConstraints(ikEnv,ikGroup_damped,ikElementHandle,simIK.constraint_pose) 
end

function sysCall_actuation()
    CalculateIKJointPosition()
    SetAllMotorsPosition()
end 

function sysCall_cleanup()
    -- erase the IK environment: 
    simIK.eraseEnvironment(ikEnv) 
end

function CalculateIKJointPosition()
    -- reflect the pose of the target dummy to its counterpart in the IK environment:
    simIK.setObjectMatrix(ikEnv,ikTarget,ikBase,sim.getObjectMatrix(simTarget, simBase))
    -- try to solve with the undamped method:
    if simIK.handleIkGroup(ikEnv,ikGroup_undamped)==simIK.result_fail then 
        -- the position/orientation could not be reached.
        -- try to solve with the damped method:
        simIK.handleIkGroup(ikEnv,ikGroup_damped)
    end
    for i=1, #simMotors,1 do
        motorsPositions[i]=simIK.getJointPosition(ikEnv,ikJoints[i])
    end
end

function SetAllMotorsPosition()
    for i=1,#simMotors,1 do
        -- apply the joint values computed in the IK environment to their CoppeliaSim joint counterparts:
        sim.setJointTargetPosition(simMotors[i],motorsPositions[i])
    end
end