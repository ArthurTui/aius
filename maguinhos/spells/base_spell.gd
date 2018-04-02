extends Node2D

export (int) var max_charge # charge time (in frames) to next level (0 if in max level already)
export (float) var cooldown # cooldown time (in seconds)
export (bool) var has_activation = false # flag for spells that require activation