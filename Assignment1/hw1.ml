let rec subset a b = 
	if a == [] then true 
	else (List.mem (List.hd a) b) && subset (List.tl a) b;;

let equal_sets a b = 
	if a == [] && b == [] then true
	else subset a b && subset b a;;

let proper_subset a b =
	if (equal_sets a b) then false 
	else subset a b;;

let rec computed_fixed_point eq f x =
	if eq x (f x) then x 
	else computed_fixed_point eq f (f x);;

let filter_blind_alleys g = 
	snd(g) = remove_extras snd(g);;

let remove_extras l = 
	
