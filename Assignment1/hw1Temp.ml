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

let rec check_RHS rhs =
        match rhs with
        |[] -> true
        |h::t -> match h with
                 |(N a) -> false
		 |(T a) -> check_RHS t;;

let check_rule rule =
        match rule with
        |(a,b) -> match (check_RHS b) with
                  |true -> true
                  |false -> false;;

(*Mark terminals mark non terminals mark terminal  symbols*)

let rec mark_terminals rule_list =
        match rule_list with
	|[] -> [] 
	|h::t -> match check_rule h with
		 |false ->  mark_terminals t
		 |true ->  mark_terminals t @ [h];;

let rec mark_non_terminals rule_list =
	match rule_list with
        |[] -> []
        |h::t -> match check_rule h with
                 |true ->  mark_non_terminals t
                 |false ->  mark_non_terminals t @ [h];;

let get_symbol rule = 
	match rule with
	(a,b) -> a;;

let rec mark_terminal_symbols terminal_rules = 
	match terminal_rules with 
	|[] -> []
	|h::t -> match check_rule h with
		 |true -> mark_terminal_symbols t  @ [(get_symbol h)]
		 |false -> mark_terminal_symbols t;;

(*Check if r.h.s of non-terminal is terminal*)
let rec check_RHS_NT rhs term_val =
        match rhs with
        |[] -> true
        |h::t -> match h with
                 |(N a) -> (match subset [a] term_val with 
			   |false -> false
                           |true ->check_RHS_NT t term_val)
		 |(T a) -> check_RHS_NT t term_val;;

let check_NTRule rule term_sym =
	match check_RHS_NT (snd(rule)) term_sym with
	|true -> true
	|false -> false;;

let update_terminal_rule rule t_rules t_sym =
	match check_NTRule rule t_sym && (subset [rule] t_rules = false) with
        |true -> t_rules @ [rule]
        |false -> t_rules ;;

let rec parse_rules nt_rules t_rules t_sym = 
	match nt_rules with
	|[] -> t_rules
	|h::t -> parse_rules t (update_terminal_rule (h) t_rules t_sym) t_sym;;

let update_terminal_symbols rule term_sym = 
	match check_NTRule rule term_sym && (subset [get_symbol (rule)] term_sym = false) with
        |true -> term_sym @ [get_symbol rule]
        |false -> term_sym ;;

let rec parse_symbols nt_rules t_sym =
        match nt_rules with
        |[] -> t_sym
        |h::t -> parse_symbols t (update_terminal_symbols (h) t_sym);;

let rec get_rules nt_rules t_rules t_sym =
	if (List.length t_rules = List.length (parse_rules nt_rules t_rules t_sym)) 
	then t_rules 
	else (get_rules nt_rules (parse_rules nt_rules t_rules t_sym) (parse_symbols nt_rules t_sym));;

let rec get_order orig_rules terminal_rules =
	match orig_rules with
	|[] -> []
	|h::t -> if subset [h] terminal_rules then
		 [h] @ get_order t terminal_rules
		 else get_order t terminal_rules;;

let rec filter_blind_alleys g = 
	match g with
	|(a,b) -> (a, get_order b (get_rules b [] []));;
