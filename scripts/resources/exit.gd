extends Resource
class_name Exit

var location1 : Location = null
var location2 : Location = null


func get_other_location(location : Location) -> Location:
    if location == location1:
        return location2
    else:
        return location1
