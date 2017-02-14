/** 
Copyright 2017 James Somervail
*/

fn polymesh_filt obj =
(
case superclassof obj of
	(
	GeometryClass: 1
	default: 0
	)
)

fn specifynormals obj =
(
nVerts = getNumVerts obj
for i = 1 to nVerts do
	(
	setNormal obj i [xcomp,ycomp,zcomp]
	)
)

fn pointnormals obj ref isinverted =
(
nVerts = getNumVerts obj
if isinverted then inv = 1 else inv = -1
for i = 1 to nVerts do
	(
	vec = (ref.pos - getVert obj i ) * inv
	normal = normalize vec
	setNormal obj i normal
	)
)

fn clonenormals obj src =
(
nVerts = getNumVerts obj
for i = 1 to nVerts do --iterate through all vertices in tar mesh
	(
	nVerts_src = getNumVerts src
	closestvert = 1
	for j = 1 to nVerts_src do --iterate through all faces in ref mesh
		(
		closestdist = getVert src closestvert - getVert obj i
		currentdist = getVert src j - getVert obj i
		--check if distance to face j is closer than to current closest
		if  length currentdist < length closestdist do
			(
			closestvert = j
			)
		)
	norm = getNormal src closestvert
	setNormal obj i norm
	)
)

	--GLOBAL VARIABLE DECLARATIONS

global tarmesh --target mesh
global refpoint --reference dummy for point normals
global srcmesh --source mesh for clone normals
global xcomp = 0 --x component
global ycomp = 0 --y component
global zcomp = 1 --z component

	--UI ELEMENTS

MainWindow = newRolloutFloater "Normal Toolkit" 220 167

rollout SpecifyNormal "Specify Normals" width:220 height:24
(
	spinner 'xspin' "" pos:[0,3] width:35 height:16 range:[-1,1,0] align:#left
	spinner 'yspin' "" pos:[38,3] width:35 height:16 range:[-1,1,0] align:#left
	spinner 'zspin' "" pos:[76,3] width:35 height:16 range:[-1,1,1] align:#left
		
	button 'apply' "Apply" pos:[151,2] width:54 height:18 toolTip:"Apply specific normals to selection" align:#left
	
	on xspin changed val do
		xcomp = val
	on yspin changed val do
		yomp = val
	on zspin changed val do
		zcomp = val
	on apply pressed do
	(
	undo on
		(
			
		selectarr = selection as array
		for i in selectarr do
			(
			if (polymesh_filt i) == 1 do
				(
				try(convertToMesh i)catch()
				specifynormals i
				convertToPoly i
				addModifier i (Edit_Normals ())
				)
			)
		
		)
	)
)

---------------------------------------------------------------------------------------

rollout PointNormal "Point Normals" width:162 height:78
(
	pickbutton 'selectpoint' "Select Point Helper" pos:[-1,2] width:150 height:21 toolTip:"Select Point Helper to determine Target Mesh normal origin" align:#left
	checkbox 'inverted' "Invert" pos:[2,23] width:54 height:15 toolTip:"Invert normal direction" align:#left
	
	button 'apply' "Apply" pos:[151,2] width:54 height:21 toolTip:"Apply point normals to selection" align:#left enabled: false
		
	on selectpoint picked obj do
	(
	refpoint = obj
	selectpoint.text = "Point Helper: "+obj.name
	apply.enabled = true
	)
	
	on apply pressed do
	(
	undo on
		(
		
		selectarr = selection as array
		for i in selectarr do
			(
			if polymesh_filt(i) == 1 then
				(
				try(convertToMesh i)catch()
				pointnormals i refpoint inverted.checked
				convertToPoly i
				addModifier i (Edit_Normals ())
				)
			)
		
		)
	)
)

---------------------------------------------------------------------------------------

rollout CloneNormal "Cloned Normals" width:162 height:84
(
	pickbutton 'selectsrc' "Select Source Mesh" pos:[0,2] width:150 height:21 toolTip:"Select Source Mesh to clone normals from" align:#left
	
	button 'apply' "Apply" pos:[151,2] width:54 height:21 toolTip:"Apply cloned normals to selection" align:#left enabled:false
	
	on selectsrc picked obj do
	(
	if polymesh_filt(obj) == 1 then
		(
		srcmesh = obj
		selectsrc.text = "Source Mesh: "+obj.name
		apply.enabled = true
		) else
		(
		--clear target mesh and button text
		srcmesh = undefined
		selectsrc.text = "Select Source Mesh"
		
		--play error ping
		ssounds = dotNetClass "System.Media.SystemSounds"
		ssounds.Hand.Play()
		apply.enabled = false
		)
	)
	
	on apply pressed do
	(
	undo on
		(
		
		selectarr = selection as array
		for i in selectarr do
			(
			if polymesh_filt(i) == 1 then
				(
				try(convertToMesh i)catch()
				srcclone = copy srcmesh
				convertTomesh srcclone
				clonenormals i srcclone
				delete srcclone
				convertToPoly i
				addModifier i (Edit_Normals ())
				)
			)
		
		)
	)
)
	
addrollout SpecifyNormal MainWindow
addrollout PointNormal MainWindow
addrollout CloneNormal MainWindow