    english2C(S,C) :- parse(S,C).
     
    %The operator precedence is defined below.
    %Taken from http://en.cppreference.com/w/cpp/language/operator_precedence*
    %Defined in the order thery appear as parser
    :-op(6,xfy,+).
    :-op(6,xfy,-).
    :-op(3,fy,+).
    :-op(3,fy,-).
    :-op(3,fy,~).
    :-op(5,xfy,*).
    :-op(5,xfy,'/').
    :-op(5,xfy,'%').
    :-op(7,xfy,<<).
    :-op(7,xfy,>>).
    :-op(10,xfy,&).
    :-op(11,xfy,^).
    :-op(12,xfy,!).
     
    % Repeated connectives defined here 
    con(to).
    con(and). 
    mul(by).
    mul(and).
    
    % Recursively parsing basic english phrases with no expressions
    parse([H|T],C):- T = [],C = H.
    parse([add,I,X,J | T], C) :-  parse([I+J|T],C), con(X).
	parse([subtract,I,from,J | T], C) :-  parse([J-I|T],C).
    parse([negative,of,I | T], C) :- parse([-I|T],C).
    parse([I,unaltered | T], C) :- parse([+I|T],C).
    parse([complement,of,I | T], C) :- parse([~I|T],C).
   
    parse([multiply,I,X,J | T], C) :-  parse([I*J|T],C), mul(X).
    parse([divide,I,by,J | T], C) :-  parse([I/J|T],C).
    
    parse([take,the,remainder,of,I,after,dividing,by,J | T], C) :-  parse([I '%' J|T],C).
    parse([I,shifted,left,J,bits | T], C) :-  parse([I<<J|T],C).
    parse([I,shifted,right,J,bits | T], C) :-   parse([I>>J|T],C).
    parse([I,and,J | T], C) :-  parse([I&J|T],C).    
    parse([I,exclusive,or,J | T], C) :-  parse([I^J|T],C).
    parse([I,or,J | T], C) :-  parse([I!J|T],C).   
    parse([discard,I,then,use,J,instead | T], C) :-  parse([(I,J)|T],C).
     
    % Parsing using expressions with remaining terms;
    % a sublist of the expression is evaluated as a list then another operation is performed  
    parse([E,',',then,add,J | T], C) :- parse([E+J|T],C).
    parse([E,',',then,subtract,J | T], C) :- parse([E-J|T],C).
    parse([E,',',then,do,nothing | T], C) :- parse([+E|T],C).
    parse([E,',',then,negate,it | T], C) :-  parse([-E|T],C).
    parse([E,',',then,complement,it | T], C) :- parse([~E|T],C).
    parse([E,',',then,multiply,by,J | T], C) :- parse([E*J|T],C).
    parse([E,',',then,divide,by,J | T], C) :- parse([E/J|T],C).
    parse([E,',',then,divide,by,J,and,take,the,remainder | T], C) :- parse([E'%'J|T],C). 
    parse([E,',',then,shift,left,J,bits | T], C) :- parse([E<<J|T],C).
    parse([E,',',then,shift,right,J,bits | T], C) :- parse([E>>J|T],C).
    parse([E,',',then,and,with,J | T], C) :- parse([E&J|T],C).
    parse([E,',',then,exclusive,or,with,J | T], C) :- parse([E^J|T],C).
    parse([E,',',then,or,with,J | T], C) :- parse([E!J|T],C).
    parse([E,',',then,discard,and,use,J,instead | T], C) :- parse([(E,J)|T],C).
