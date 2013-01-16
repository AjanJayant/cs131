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

let get_start g = 
    	match g with 
		|(a,b) -> a;;

let filter_blind_alleys g = 
	(get_start g, remove_rules (get_start g) snd(g) [] []);;

let rec check_RHS rhs terminal_sym =
	match rhs with
	|[] -> true
	|h::t -> match h with
		 |(N a) -> (match subset [h] terminal_sym with
			   |false -> false
		           |true ->check_RHS t terminal_sym)
                 |(T a) -> check_RHS t terminal_sym;;

let check_rule rule term_sym = 
  	match rule with
  	|(a,b) -> match (check_RHS b term_sym) with
  		  |true -> true
  		  |false -> false;;

let rec get_terminals rules = 
	match rules with 
	|[] -> []
	|h::t -> get_terminals t @ [T (fst(h))];;

let rec mark_terminal orig_list curr_list term_list = 
	match curr_list with
	|[] -> term_list
	|h::t -> match check_rule h (get_terminals term_list) with
		 |true -> mark_terminal orig_list orig_list (term_list @ [h])
		 |false -> mark_terminal orig_list t term_list;;
