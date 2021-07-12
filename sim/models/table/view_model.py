import pybullet as p
import pybullet_data
import time

p.connect(p.GUI)
p.configureDebugVisualizer(p.COV_ENABLE_GUI,0)
p.setAdditionalSearchPath('.')

table = p.loadURDF('table.urdf', [0,0, 0.5],useFixedBase=True)

time.sleep(1000)