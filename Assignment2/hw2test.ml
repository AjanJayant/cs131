
type english_nonterminals =
  | Expr | Art | Adj | Adverb | VerbPh | NounPh | Noun | Verb

let english_rules =
   [
    Adj, [T "smart"];
    Adj, [T "tall"];
    Adj, [N Art; N Adj];
    Art, [T "a"];
    Noun, [T "man"];
    Noun, [T "woman"];
    Verb, [T "runs"];
    Verb, [T "swims"];
    Verb, [T "flies"];
    Adverb, [T "quietly"];
    Adverb, [T "loudly"];
    Expr, [N NounPh; N Verb; N NounPh];
    Expr, [N Adj; N NounPh; N VerbPh];
    Expr, [N NounPh; N VerbPh];
    VerbPh, [N Adverb; N Verb];
    VerbPh, [N Verb; N Adverb];
    VerbPh, [N Verb];
    NounPh, [N Art; N Noun];
    NounPh, [N Noun]]

let english_grammar = Expr, english_rules

let accept_smart derivation = function
|smart -> Some(derivation, "smart")
|_ -> None;;

let accept_verb derivation = fun verb -> match verb
|swim
|flies
|runs
|flies -> Some(derivation, verb)
|_ -> None;;

let test1 english_grammar = parse_prefix awkish_grammar accept_smart ["This"; "man"; "swims"];;

let test2 english_grammar = parse_prefix awkish_grammar accept_verb ["smart";"tall"; "a"; "flies"; "loudly"; "runs"; "quietly";
 "man"];;

