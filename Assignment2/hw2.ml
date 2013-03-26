type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal;;

let rec prod rule_list acc nts = match rule_list with
|[] -> acc
|(head::tail) -> match head with 
			   (a,b) -> if a == nts then prod tail (acc@[b]) nts else prod tail acc nts;;
			   
let convert_grammar gram1 = match gram1 with
(a,b) -> (a, prod b []);;

let match_empty rule d prod accept frag = accept d frag;;

let match_nothing rule d prod frag = None;;

let rec or_matcher matcher rules d prod nts accept frag = match rules with
|[] -> match_nothing [] d prod accept frag
|head::tail -> match frag with
			   |[] -> match_nothing [] d prod accept frag
			   |_ -> match matcher head (d @ [(nts, head)]) prod accept frag with
			   		 |None -> or_matcher matcher tail d prod nts accept frag
			   		 |_ -> matcher head (d @ [(nts, head)]) prod accept frag;;
			     
let rec and_matcher rule d prod accept frag = match rule with
|[] -> match_empty [] d prod accept frag
|head::tail ->match (symbol_matcher head prod d accept frag) with
			  |None -> and_matcher (tail) d prod accept frag
			  |_ -> and_matcher (tail) d prod accept ((List.tl(frag)))
			  
and symbol_matcher sym prod d accept frag = match sym with 
	|(N a) -> or_matcher and_matcher (prod a) d prod a accept frag
	|(T a) -> match frag with 
			  |[] -> None
			  |head ::tail -> if a = head then Some(d, tail)
			  else None;;

let parse_prefix gram = or_matcher and_matcher (snd(gram) (fst(gram))) [] (snd gram) (fst(gram));;