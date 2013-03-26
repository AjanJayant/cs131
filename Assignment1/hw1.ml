let rec subset a b =
if a == [] then true
else ((List.mem (List.hd a) b) && subset (List.tl a) b);;

let equal_sets a b =
if a == [] && b == [] then true
else subset a b && subset b a;;

let proper_subset a b =
if (equal_sets a b) then false
else subset a b;;

let rec computed_fixed_point eq f x =
if eq x (f x) then x
else computed_fixed_point eq f (f x);;

(*Code for filter blind alleys follow*)

(*typedef for symbols*)
type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal;;
(*Following code checks if a rule is composed of only terminal symbols*)
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

let get_symbol rule =
        match rule with
        (a,b) -> a;;

(*Following marks the terminals, non-terminals and terminal symbols and puts them into separate lists*)
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

let rec mark_terminal_symbols t_rules =
        match t_rules with
        |[] -> []
        |h::t -> match check_rule h with
                 |true -> mark_terminal_symbols t  @ [(get_symbol h)]
                 |false -> mark_terminal_symbols t;;

(*The following to functions help check for a non-terminal rule if it has non-erminal symbols which can be taken as terminal symbols*)
let rec check_RHS_NT rhs t_sym =
        match rhs with
        |[] -> true
        |h::t -> match h with
                 |(N a) -> (match subset [a] t_sym with
                           |false -> false
                           |true ->check_RHS_NT t t_sym)
                 |(T a) -> check_RHS_NT t t_sym;;

let check_NTRule rule t_sym =
        match check_RHS_NT (snd(rule)) t_sym with
        |true -> true
        |false -> false;;

(*Following functions go through non-terminal rules, extracting the rule/symbol
 whose rhs is composed of non-terminals which have terminal leaves*)
let update_terminal_rule rule t_rules t_sym =
        match check_NTRule rule t_sym && (subset [rule] t_rules = false) with
        |true -> t_rules @ [rule]
        |false -> t_rules ;;

let rec parse_rules nt_rules t_rules t_sym =
        match nt_rules with
        |[] -> t_rules
        |h::t -> parse_rules t (update_terminal_rule (h) t_rules t_sym) t_sym;;

let update_terminal_symbol rule t_sym =
        match check_NTRule rule t_sym && (subset [get_symbol (rule)] t_sym = false) with
        |true -> t_sym @ [get_symbol rule]
        |false -> t_sym ;;

let rec parse_symbols nt_rules t_sym =
        match nt_rules with
        |[] -> t_sym
        |h::t -> parse_symbols t (update_terminal_symbol (h) t_sym);;

(*Function filters blind alley rules by checking if two subsequent calls to parse the rules result in the same set of rules being generated. Ordered by which ones considered terminal first*)
let rec filter_rules nt_rules t_rules t_sym =
        if (List.length t_rules = List.length (parse_rules nt_rules t_rules t_sym))
        then t_rules
        else (filter_rules nt_rules (parse_rules nt_rules t_rules t_sym) (parse_symbols nt_rules t_sym));;

(*This function returns an expression with the order in exactly the same way it appears in the original list by concatanting the rule if it isn't a blind alley rule to the value returned by the function*)
let rec set_order orig_rules t_rules =
        match orig_rules with
        |[] -> []
        |h::t -> if subset [h] t_rules then
                 [h] @ set_order t t_rules
                 else set_order t t_rules;;

(*This function filters blind alley rules returning a grammar as an expression*)
let rec filter_blind_alleys g =
        match g with
        |(a,b) -> (a, set_order b (filter_rules b [] []));;

