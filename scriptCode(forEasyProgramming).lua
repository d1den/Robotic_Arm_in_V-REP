function UpdateUi()
    simUI.setLabelText(ui,5,'6 motor pos (deg): '..string.format("%.2f",ConvertRadToDeg(targetMotorsPositions[6]),true))
    simUI.setSliderValue(ui,6,ConvertRadToDeg(targetMotorsPositions[6]),true)
    simUI.setLabelText(ui,7,'5 motor pos (deg): '..string.format("%.2f",ConvertRadToDeg(targetMotorsPositions[5]),true))
    simUI.setSliderValue(ui,8,ConvertRadToDeg(targetMotorsPositions[5]),true)
    simUI.setLabelText(ui,9,'4 motor pos (deg): '..string.format("%.2f",ConvertRadToDeg(targetMotorsPositions[4]),true))
    simUI.setSliderValue(ui,10,ConvertRadToDeg(targetMotorsPositions[4]),true)
    simUI.setLabelText(ui,11,'3 motor pos (deg): '..string.format("%.2f",ConvertRadToDeg(targetMotorsPositions[3]),true))
    simUI.setSliderValue(ui,12,ConvertRadToDeg(targetMotorsPositions[3]),true)
    simUI.setLabelText(ui,13,'2 motor pos (deg): '..string.format("%.2f",ConvertRadToDeg(targetMotorsPositions[2]),true))
    simUI.setSliderValue(ui,14,ConvertRadToDeg(targetMotorsPositions[2]),true)
    simUI.setLabelText(ui,15,'1 motor pos (deg): '..string.format("%.2f",ConvertRadToDeg(targetMotorsPositions[1]),true))
    simUI.setSliderValue(ui,16,ConvertRadToDeg(targetMotorsPositions[1]),true)
    simUI.setEditValue(ui,18,string.format("%.3f",targetPosition[1],true),true)
    simUI.setEditValue(ui,19,string.format("%.3f",targetPosition[2],true),true)
    simUI.setEditValue(ui,20,string.format("%.3f",targetPosition[3],true),true)
end

function ConvertRadToDeg(rad)
    return (rad*180)/3.14
end

function ConvertDegToRad(deg)
    return (deg*3.14)/180
end

function ButtonClicked(ui,id)
    targetPosition[1]=tonumber(simUI.getEditValue(ui, 18))
    targetPosition[2]=tonumber(simUI.getEditValue(ui, 19))
    targetPosition[3]=tonumber(simUI.getEditValue(ui, 20))
    sim.setObjectPosition(target, -1, targetPosition)
    for i=1,5,1 do
        CalculateIKJointPosition()
    end
    
    UpdateUi()
end

function SliderMotorPositionChange(ui,id,newVal)
    if id==6 then
        targetMotorsPositions[6]=ConvertDegToRad(newVal) 
    else
        if id==8 then
            targetMotorsPositions[5]=ConvertDegToRad(newVal) 
        else
            if id==10 then
                targetMotorsPositions[4]=ConvertDegToRad(newVal) 
            else
                if id==12 then
                    targetMotorsPositions[3]=ConvertDegToRad(newVal) 
                else
                    if id==14 then
                        targetMotorsPositions[2]=ConvertDegToRad(newVal) 
                    else
                        if id==16 then
                            targetMotorsPositions[1]=ConvertDegToRad(newVal) 
                        end
                    end
                end
            end
        end
    end
    UpdateUi()
end

function RbClicked(ui, id)
    if id==2 then
        simUI.setEnabled(ui, 4, true, true)
        simUI.setEnabled(ui, 17, false, true)
    else
        if id==3 then
            simUI.setEnabled(ui, 4, false, true)
            simUI.setEnabled(ui, 17, true, true)
        end
    end
end

function ShowDialog()
    if not ui then
    xml = [[
        <ui title="Mark2 control GUI" closeable="true" resizable="false" activate="false" size="600,100">
        <group layout="vbox" flat="false" id="1">
            <label text="Choose control mode:"/>
            <radiobutton text="Motor control mode" checked="true" on-click="RbClicked" id="2"/>
            <radiobutton text="Target control mode" on-click="RbClicked" id="3"/>
        </group>
        <group layout="vbox" flat="false" id="4" enabled="true">
            <label text="Motor control mode:"/>
            <group layout="form" flat="true">
                <label text="6 motor pos (deg): 0" id="5"/>
                <hslider tick-position="above" tick-interval="1" minimum="-150" maximum="150" on-change="SliderMotorPositionChange" id="6"/>
                <label text="5 motor pos (deg): 0" id="7"/>
                <hslider tick-position="above" tick-interval="1" minimum="-125" maximum="110" on-change="SliderMotorPositionChange" id="8"/>
                <label text="4 motor pos (deg): 0" id="9"/>
                <hslider tick-position="above" tick-interval="1" minimum="-155" maximum="155" on-change="SliderMotorPositionChange" id="10"/>
                <label text="3 motor pos (deg): 0" id="11"/>
                <hslider tick-position="above" tick-interval="1" minimum="-170" maximum="10" on-change="SliderMotorPositionChange" id="12"/>
                <label text="2 motor pos (deg): 0" id="13"/>
                <hslider tick-position="above" tick-interval="1" minimum="-155" maximum="65" on-change="SliderMotorPositionChange" id="14"/>
                <label text="1 motor pos (deg): 0" id="15"/>
                <hslider tick-position="above" tick-interval="1" minimum="-105" maximum="105" on-change="SliderMotorPositionChange" id="16"/>
            </group>
        </group>
        <group layout="vbox" flat="false" id="17" enabled="false">
            <label text="Target control mode:"/>
            <group layout="form" flat="true">
                <label text="X (m): "/>
                <edit value="0" id="18"/>
                <label text="Y (m):"/>
                <edit value="0" id="19"/>
                <label text="Z (m):"/>
                <edit value="0" id="20"/>
            </group>
            <button text="Go!" on-click="ButtonClicked" id="21"/>
        </group>
    </ui>
]]
        ui=simUI.create(xml)
        UpdateUi()
    end
end

function  HideDialog()
    if ui then
        simUI.destroy(ui)
        ui=nil
    end
end

function sysCall_init()
    -- Take a few handles from the robot:
    simBase=sim.getObjectHandle('Mark2')
    simTip=sim.getObjectHandle('EndPoint')
    simTarget=sim.getObjectHandle('TargetPoint')
    target=sim.getObjectHandle('Target')
    targetPosition=sim.getObjectPosition(target,-1)
    simMotors={}
    targetMotorsPositions={}
    for i=1,6,1 do
        targetMotorsPositions[i]=0
    end
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
    
    ShowDialog()
end

function sysCall_actuation()
    targetPosition=sim.getObjectPosition(target,-1)
    SetAllMotorsPosition()
end 

function sysCall_cleanup()
    -- erase the IK environment: 
    simIK.eraseEnvironment(ikEnv)
    HideDialog()
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
        targetMotorsPositions[i]=simIK.getJointPosition(ikEnv,ikJoints[i])
    end
end


function SetAllMotorsPosition()
    for i=1,#simMotors,1 do
        -- apply the joint values computed in the IK environment to their CoppeliaSim joint counterparts:
        sim.setJointTargetPosition(simMotors[i],targetMotorsPositions[i])
    end
end