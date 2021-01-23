function sysCall_init()
    -- do some initialization here
    modelBase=sim.getObjectHandle('MainPart')
    leftSide=sim.getObjectHandle('LeftSide')
    rightSide=sim.getObjectHandle('RightSide')
    leftMotor=sim.getObjectHandle('LeftJoint')
    rightMotor=sim.getObjectHandle('RightJoint')
    floorObject=sim.getObjectHandle('ResizableFloor_5_25')
    lastSimTime=0
    flag = false
    leftMotorSpeed=0
    rightMotorSpeed=0
    ShowDialog()

end

function sysCall_actuation()
    sim.setJointTargetVelocity(leftMotor, leftMotorSpeed)
    sim.setJointTargetVelocity(rightMotor, rightMotorSpeed)
    --simTime = sim.getSimulationTime()
    --if (simTime-lastSimTime>5) then
    --if(flag == false) then
        --sim.setJointTargetVelocity(leftMotor, 0.008)
        --sim.setJointTargetVelocity(rightMotor, -0.008)
        --flag=true
    --else
       -- sim.setJointTargetVelocity(leftMotor, -0.008)
        --sim.setJointTargetVelocity(rightMotor, 0.008)
        --flag=false
    --end
-- getObject position and write it in console
    --sim.addStatusbarMessage('simTime = '..simTime)
    --table=sim.getObjectPosition(leftSide, floorObject)
    --sim.addStatusbarMessage('Left side X = '..table[1])
    --sim.addStatusbarMessage('Left side Y = '..table[2])
    --sim.addStatusbarMessage('Left side Z = '..table[3])
    --lastSimTime=simTime
    --end
    
end

function sysCall_cleanup()
    HideDialog()
end

function UpdateUi()
    simUI.setLabelText(ui,1,'Left motor speed (m/s): '..string.format("%.3f",leftMotorSpeed,true))
    simUI.setSliderValue(ui,2,leftMotorSpeed/0.001,true)
    simUI.setLabelText(ui,3,'Right motor speed (m/s): '..string.format("%.3f",-rightMotorSpeed,true))
    simUI.setSliderValue(ui,4,rightMotorSpeed/(-0.001),true)
end

function SliderLeftMotorChange(ui,id,newVal)
    leftMotorSpeed=newVal*0.001
    UpdateUi()
end

function SliderRightMotorChange(ui,id,newVal)
    rightMotorSpeed=newVal*(-0.001)
    UpdateUi()
end

function ShowDialog()
    if not ui then
    xml = [[
        <ui title="MyModel GUI" closeable="true" resizable="false" activate="false" size="600,100">
        <group layout="form" flat="false">
            <label text="Left motor speed (m/s): 1" id="1"/>
            <hslider tick-position="above" tick-interval="1" minimum="-10" maximum="10" on-change="SliderLeftMotorChange" id="2"/>
            <label text="Right motor speed (m/s): 1" id="3"/>
            <hslider tick-position="above" tick-interval="1" minimum="-10" maximum="10" on-change="SliderRightMotorChange" id="4"/>
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