extends Node3D

# initialize an empty array for palm tree AnimationPlayer node path
var palm_tree_anims = []

func _ready():

    # Find and collect AnimationPlayer nodes of all palm trees
	# parse through each child node of setting node
    for child in get_children():
		# if there is an occurance with child node named "palm_tree"
        if child.name.find("palm_tree") != -1:
			# fetch the AnimationPlayer node and store as variable
            var anim_player = child.get_node("AnimationPlayer")
			# if variable could be stored, append that AnimationPlayer node path
			# to the palm_tree_anims empty array
            if anim_player:
                palm_tree_anims.append(anim_player)
				
    # Play Palm Tree Animation for all Palm Trees
    for anim in palm_tree_anims:
        anim.play("PalmTreeAction")
