import robust_laplacian
from plyfile import PlyData
import numpy as np
import polyscope as ps
import scipy.sparse.linalg as sla
from svgpathtools import svg2paths, wsvg
from functools import reduce
from scipy.io import savemat

# Read input
#plydata = PlyData.read("/path/to/cloud.ply")
#points = np.vstack((
#    plydata['vertex']['x'],
#    plydata['vertex']['y'],
#    plydata['vertex']['z']
#)).T

inputName = 'Flower'

paths,attributes = svg2paths('../input/'+inputName+'.svg')
all_segments = [[(line.point(0.0), line.point(1.0)) for line in path] for path in paths]
all_segments = reduce(lambda x,y: x+y, all_segments)
nSamples = 5
all_pts = [(1-t)*segment[0]+t*segment[1] for t in (i/(nSamples-1) for i in range(nSamples)) for segment in all_segments]
#all_pts = reduce(lambda x,y: x+y, all_pts)
x = [pt.real for pt in all_pts]
y = [pt.imag for pt in all_pts]
points = np.vstack((x,y,np.zeros(np.size(x)))).T

# Build point cloud Laplacian
L, M = robust_laplacian.point_cloud_laplacian(points,mollify_factor=0.0001)
mdic = {"L":L, "M":M, "pts":points}
savemat('../input/'+inputName+'.mat',mdic)


# (or for a mesh)
# L, M = robust_laplacian.mesh_laplacian(verts, faces)

# Compute some eigenvectors
n_eig = 10
evals, evecs = sla.eigsh(L, n_eig, M, sigma=1e-8)

# Visualize
ps.init()
ps_cloud = ps.register_point_cloud("my cloud", points)
for i in range(n_eig):
    ps_cloud.add_scalar_quantity("eigenvector_"+str(i), evecs[:,i], enabled=True)
ps.show()