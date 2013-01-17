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

let rec check_RHS rhs term_val =
        match rhs with
        |[] -> true
        |h::t -> match h with
                 |(N a) -> (match subset [a] term_val with                                                  |false -> false
                           |true ->check_RHS t term_val)                                          |(T a) -> check_RHS t term_val;;

let check_rule rule term_val =
        match rule with
        |(a,b) -> match (check_RHS b term_val) with
                  |true -> true
                  |false -> false;;

let rec get_terminals rules =
        match rules with
        |[] -> []
        |h::t -> match h with
                 |(a,_) -> get_terminals t @ [a] ;;

let rec mark_terminal orig_list curr_list term_list =
        match curr_list with
        |[] -> term_list
        |h::t -> match (check_rule h [get_terminals term_list]) with                              |true -> mark_terminal orig_list t term_list @ [h]                       |false -> mark_terminal orig_list t term_list;;
